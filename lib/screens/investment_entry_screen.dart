import 'package:flutter/material.dart';

import '../models/account.dart';
import '../models/credit_card_statement.dart';
import '../models/investment_transaction.dart';
import '../services/account_service.dart';
import '../services/credit_card_installment_service.dart';
import '../services/credit_card_statement_service.dart';
import '../services/investment_transaction_service.dart';
import '../services/tracked_currency_service.dart';
import '../services/tracked_metal_service.dart';
import '../utils/app_feedback.dart';
import '../utils/navigation_helpers.dart';
import '../utils/turkish_money_input_formatter.dart';

class InvestmentEntryScreen extends StatefulWidget {
  const InvestmentEntryScreen({
    super.key,
    this.initialTransaction,
  });

  final InvestmentTransaction? initialTransaction;

  @override
  State<InvestmentEntryScreen> createState() => _InvestmentEntryScreenState();
}

class _InvestmentEntryScreenState extends State<InvestmentEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _quantityController = TextEditingController();
  final _installmentCountController = TextEditingController();

  List<Account> _investmentAccounts = [];
  List<Account> _buyPaymentAccounts = [];
  List<Account> _sellTargetAccounts = [];
  List<CreditCardStatement> _creditCardStatements = [];
  final Map<String, String> _currencyNameByCode = {};
  final Map<String, String> _metalNameByCode = {};

  int? _selectedAccountId;
  int? _selectedCashAccountId;
  String _txType = 'buy';
  DateTime _selectedDate = DateTime.now();
  FifoSellPreview? _sellPreview;
  String? _sellPreviewError;
  String? _lastCalculationKey;
  int _previewRequestId = 0;

  int? _initialAccountId;
  int? _initialCashAccountId;
  String _initialTxType = 'buy';
  DateTime? _initialDate;
  String _initialAmountText = '';
  String _initialQuantityText = '';
  bool _isInstallment = false;
  bool _initialIsInstallment = false;
  String _initialInstallmentCountText = '';
  bool _hasExistingInstallments = false;

  bool _loading = true;
  bool _saving = false;

  bool get _isEditMode => widget.initialTransaction != null;

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _quantityController.dispose();
    _installmentCountController.dispose();
    super.dispose();
  }

  // Yatirim formu icin hesaplar, fiyatlar ve varsa mevcut hareketi yukler.
  Future<void> _load() async {
    final results = await Future.wait([
      AccountService.getActiveAccounts(),
      AccountService.getActiveExpenseAccounts(),
      AccountService.getActiveCashflowAccounts(),
      CreditCardStatementService.getAll(),
      if (_isEditMode) AccountService.getAllAccounts(),
      TrackedCurrencyService.getAll(),
      TrackedMetalService.getAll(),
    ]);

    final allAccounts = results[0] as List<Account>;
    final buyPaymentAccounts = results[1] as List<Account>;
    final sellTargetAccounts = results[2] as List<Account>;
    final creditCardStatements = results[3] as List<CreditCardStatement>;
    final allAccountsForEdit =
        _isEditMode ? (results[4] as List<Account>) : const <Account>[];
    final trackedCurrencies =
        results[_isEditMode ? 5 : 4] as List<TrackedCurrencyItem>;
    final trackedMetals =
        results[_isEditMode ? 6 : 5] as List<TrackedMetalItem>;

    for (final c in trackedCurrencies) {
      _currencyNameByCode[c.code.toUpperCase()] = c.name;
    }
    for (final m in trackedMetals) {
      _metalNameByCode[m.code.toUpperCase()] = m.name;
    }

    if (_isEditMode && widget.initialTransaction != null) {
      _hasExistingInstallments =
          await CreditCardInstallmentService.hasInstallmentsForInvestment(
        widget.initialTransaction!.id,
      );
    }

    final activeInvestmentAccounts = allAccounts
        .where(
          (a) =>
              a.type == 'investment' &&
              (a.investmentSymbol ?? '').trim().isNotEmpty,
        )
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    final extraInvestment = _isEditMode
        ? allAccountsForEdit.where(
            (a) => a.id == widget.initialTransaction!.investmentAccountId)
        : const <Account>[];
    final extraCash = _isEditMode
        ? allAccountsForEdit
            .where((a) => a.id == widget.initialTransaction!.cashAccountId)
        : const <Account>[];

    final investmentMap = <int, Account>{};
    for (final a in [...activeInvestmentAccounts, ...extraInvestment]) {
      investmentMap[a.id] = a;
    }
    final buyPaymentMap = <int, Account>{};
    for (final a in [...buyPaymentAccounts, ...extraCash]) {
      if (AccountService.isExpensePaymentAccount(a)) {
        buyPaymentMap[a.id] = a;
      }
    }
    final sellTargetMap = <int, Account>{};
    for (final a in [...sellTargetAccounts, ...extraCash]) {
      if (AccountService.isCashflowAccount(a)) {
        sellTargetMap[a.id] = a;
      }
    }
    final investmentAccounts = investmentMap.values.toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    final normalizedBuyPaymentAccounts = buyPaymentMap.values.toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    final normalizedSellTargetAccounts = sellTargetMap.values.toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    if (!mounted) return;
    final tx = widget.initialTransaction;
    setState(() {
      _investmentAccounts = investmentAccounts;
      _buyPaymentAccounts = normalizedBuyPaymentAccounts;
      _sellTargetAccounts = normalizedSellTargetAccounts;
      _creditCardStatements = creditCardStatements;
      if (_isEditMode && tx != null) {
        _txType = tx.type;
        final availableAccountsForTx =
            tx.type == 'buy' ? _buyPaymentAccounts : _sellTargetAccounts;
        _selectedAccountId =
            investmentAccounts.any((a) => a.id == tx.investmentAccountId)
                ? tx.investmentAccountId
                : (investmentAccounts.isNotEmpty
                    ? investmentAccounts.first.id
                    : null);
        _selectedCashAccountId =
            availableAccountsForTx.any((a) => a.id == tx.cashAccountId)
                ? tx.cashAccountId
                : (availableAccountsForTx.isNotEmpty
                    ? availableAccountsForTx.first.id
                    : null);
        _selectedDate = tx.date;
        _amountController.text = _fmtMoney(tx.total);
        _quantityController.text = _fmtQuantity(tx.quantity);
        _isInstallment = _hasExistingInstallments;
      } else {
        _selectedAccountId =
            investmentAccounts.isNotEmpty ? investmentAccounts.first.id : null;
        _selectedCashAccountId = _availableCashAccounts().isNotEmpty
            ? _availableCashAccounts().first.id
            : null;
      }
      _initialAccountId = _selectedAccountId;
      _initialCashAccountId = _selectedCashAccountId;
      _initialTxType = _txType;
      _initialDate = _selectedDate;
      _initialAmountText = _amountController.text;
      _initialQuantityText = _quantityController.text;
      _initialIsInstallment = _isInstallment;
      _initialInstallmentCountText = _installmentCountController.text;
      _loading = false;
    });
    _refreshSellPreview();
  }

  Account? _selectedAccount() {
    final id = _selectedAccountId;
    if (id == null) return null;
    for (final a in _investmentAccounts) {
      if (a.id == id) return a;
    }
    return null;
  }

  Account? _selectedCashAccount() {
    final id = _selectedCashAccountId;
    if (id == null) return null;
    for (final a in _availableCashAccounts()) {
      if (a.id == id) return a;
    }
    return null;
  }

  List<Account> _availableCashAccounts() {
    return _txType == 'buy' ? _buyPaymentAccounts : _sellTargetAccounts;
  }

  String _instrumentLabel(Account? account) {
    if (account == null) return '-';
    final symbol = (account.investmentSymbol ?? '').trim();
    if (symbol.isEmpty) return '-';

    final upper = symbol.toUpperCase();
    final subtype = account.investmentSubtype;

    if (subtype == 'currency') {
      final name = _currencyNameByCode[upper] ?? upper;
      return '$name ($upper)';
    }
    if (subtype == 'metal') {
      final name = _metalNameByCode[upper] ?? upper;
      return '$name ($upper)';
    }
    return upper;
  }

  String _instrumentUnit(Account? account) {
    final symbol = (account?.investmentSymbol ?? '').trim().toUpperCase();
    return symbol.isEmpty ? 'Adet' : symbol;
  }

  // Yatirim hareket tarih secimini yonetir.
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _selectedDate = picked;
    });
  }

  String _fmtDate(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '$dd.$mm.${d.year}';
  }

  String _buildCalculationKey({
    required int accountId,
    required String txType,
    required double amount,
    required double quantity,
  }) {
    return '$accountId|$txType|${amount.toStringAsFixed(6)}|${quantity.toStringAsFixed(8)}';
  }

  void _invalidateCalculation() {
    _sellPreview = null;
    _sellPreviewError = null;
    _lastCalculationKey = null;
    _previewRequestId++;
  }

  bool _sameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _hasUnsavedChanges() {
    if (_loading) return false;
    return _selectedAccountId != _initialAccountId ||
        _selectedCashAccountId != _initialCashAccountId ||
        _txType != _initialTxType ||
        !_sameDay(_selectedDate, _initialDate ?? _selectedDate) ||
        _amountController.text.trim() != _initialAmountText.trim() ||
        _quantityController.text.trim() != _initialQuantityText.trim() ||
        _isInstallment != _initialIsInstallment ||
        _installmentCountController.text.trim() !=
            _initialInstallmentCountText.trim();
  }

  Future<bool> _confirmDiscardChanges() async {
    if (!_hasUnsavedChanges()) return true;
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Değişiklikler Kaydedilmedi'),
        content: const Text(
          'Bu ekrandan çıkarsanız yaptığınız değişiklikler kaybolacak. Çıkmak istiyor musunuz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Kal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Çık'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _handleExit({required bool toDashboard}) async {
    final shouldLeave = await _confirmDiscardChanges();
    if (!mounted || !shouldLeave) return;
    if (toDashboard) {
      popToDashboard(context);
      return;
    }
    Navigator.of(context).pop();
  }

  double? _parseQuantity(String raw) {
    final input = raw.trim();
    if (input.isEmpty) return null;

    String normalized = input;
    if (normalized.contains(',') && normalized.contains('.')) {
      normalized = normalized.replaceAll('.', '');
      normalized = normalized.replaceAll(',', '.');
    } else {
      normalized = normalized.replaceAll(',', '.');
    }
    return double.tryParse(normalized);
  }

  double? _liveAmount() {
    return TurkishMoneyInputFormatter.parse(_amountController.text);
  }

  double? _liveQuantity() {
    return _parseQuantity(_quantityController.text);
  }

  bool get _supportsInstallment {
    final cashAccount = _selectedCashAccount();
    return !_isEditMode &&
        _txType == 'buy' &&
        cashAccount != null &&
        cashAccount.isCreditCard;
  }

  bool _hasValidInputsForPreview() {
    final amount = _liveAmount();
    final quantity = _liveQuantity();
    return amount != null && amount > 0 && quantity != null && quantity > 0;
  }

  double? _projectedInvestmentBalance() {
    final account = _selectedAccount();
    final quantity = _liveQuantity();
    if (account == null || quantity == null || quantity <= 0) return null;
    return _txType == 'buy'
        ? account.balance + quantity
        : account.balance - quantity;
  }

  double? _projectedCashBalance() {
    final cashAccount = _selectedCashAccount();
    final amount = _liveAmount();
    if (cashAccount == null || amount == null || amount <= 0) return null;
    if (_txType == 'buy') {
      return cashAccount.isCreditCard
          ? cashAccount.balance - amount
          : cashAccount.balance - amount;
    }
    return cashAccount.balance + amount;
  }

  String? _liveBalanceWarning() {
    final account = _selectedAccount();
    final cashAccount = _selectedCashAccount();
    final amount = _liveAmount();
    final quantity = _liveQuantity();

    if (account == null ||
        cashAccount == null ||
        amount == null ||
        amount <= 0 ||
        quantity == null ||
        quantity <= 0) {
      return null;
    }

    if (_txType == 'buy' &&
        !cashAccount.isCreditCard &&
        cashAccount.balance + 1e-9 < amount) {
      return 'Kaynak hesap bakiyesi bu alış tutarını karşılamıyor.';
    }
    if (_txType == 'sell' && cashAccount.isCreditCard) {
      return 'Satış işleminde hedef hesap kredi kartı olamaz.';
    }
    if (_txType == 'sell' && account.balance + 1e-9 < quantity) {
      return 'Yatırım hesabındaki mevcut miktar bu satış için yetersiz.';
    }
    return null;
  }

  List<CreditCardInstallmentPreview> _liveInstallmentPreview() {
    final cashAccount = _selectedCashAccount();
    final amount = _liveAmount();
    final installmentCount = int.tryParse(_installmentCountController.text);
    if (!_isInstallment ||
        _txType != 'buy' ||
        cashAccount == null ||
        !cashAccount.isCreditCard ||
        amount == null ||
        amount <= 0 ||
        installmentCount == null ||
        installmentCount < 2) {
      return const [];
    }
    try {
      return CreditCardInstallmentService.previewInstallments(
        creditCardAccount: cashAccount,
        transactionDate: _selectedDate,
        totalAmount: amount,
        installmentCount: installmentCount,
      );
    } catch (_) {
      return const [];
    }
  }

  bool _sameMonth(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month;
  }

  double _projectedCurrentMonthCardPayment({
    required Account? cashAccount,
    required double amount,
  }) {
    final total = _creditCardStatements.fold<double>(0, (sum, statement) {
      if (!_sameMonth(statement.statementDate, _selectedDate)) return sum;
      final remaining = (statement.totalAmount - statement.paidAmount)
          .clamp(0, double.infinity)
          .toDouble();
      return sum + remaining;
    });

    if (_txType != 'buy' || cashAccount == null || !cashAccount.isCreditCard) {
      return total;
    }

    try {
      final cycle = CreditCardStatementService.resolveCycle(
        creditCardAccount: cashAccount,
        transactionDate: _selectedDate,
      );
      if (_sameMonth(cycle.statementDate, _selectedDate)) {
        return total + amount;
      }
    } catch (_) {
      return total;
    }

    return total;
  }

  Future<void> _refreshSellPreview() async {
    final amount = _liveAmount();
    final quantity = _liveQuantity();
    final account = _selectedAccount();

    if (_txType != 'sell' ||
        amount == null ||
        amount <= 0 ||
        quantity == null ||
        quantity <= 0 ||
        account == null) {
      return;
    }

    final unitPrice = amount / quantity;
    final key = _buildCalculationKey(
      accountId: account.id,
      txType: _txType,
      amount: amount,
      quantity: quantity,
    );
    final requestId = ++_previewRequestId;

    try {
      final preview = await InvestmentTransactionService.previewSell(
        investmentAccountId: account.id,
        symbol: (account.investmentSymbol ?? '').toUpperCase(),
        sellQuantity: quantity,
        sellUnitPrice: unitPrice,
      );
      if (!mounted || requestId != _previewRequestId) return;
      setState(() {
        _sellPreview = preview;
        _sellPreviewError = null;
        _lastCalculationKey = key;
      });
    } catch (e) {
      if (!mounted || requestId != _previewRequestId) return;
      setState(() {
        _sellPreview = null;
        _sellPreviewError = '$e';
        _lastCalculationKey = key;
      });
    }
  }

  // Alis/satis hareketini dogrulayip kaydeder.
  Future<void> _save() async {
    if (_saving) return;
    if (!_formKey.currentState!.validate()) return;

    final account = _selectedAccount();
    final cashAccountId = _selectedCashAccountId;

    if (account == null) {
      _showSnack('Yatırım hesabı seçiniz.');
      return;
    }
    if (cashAccountId == null) {
      _showSnack('Kaynak/Hedef hesap seçiniz.');
      return;
    }

    final amount = TurkishMoneyInputFormatter.parse(_amountController.text);
    final quantity = _parseQuantity(_quantityController.text);
    final cashAccount = _selectedCashAccount();
    final installmentCount = int.tryParse(_installmentCountController.text);

    if (amount == null || amount <= 0 || quantity == null || quantity <= 0) {
      _showSnack('Geçerli tutar ve miktar giriniz.');
      return;
    }
    if (_isEditMode && _hasExistingInstallments) {
      _showSnack(
        'Taksitli kredi kartı yatırım alışlarında düzenleme henüz desteklenmiyor.',
      );
      return;
    }
    if (_isInstallment &&
        (_txType != 'buy' ||
            cashAccount == null ||
            !cashAccount.isCreditCard)) {
      _showSnack(
          'Taksit yalnızca kredi kartı ile yatırım alışında kullanılabilir.');
      return;
    }
    if (_isInstallment &&
        (installmentCount == null ||
            installmentCount < 2 ||
            installmentCount > 24)) {
      _showSnack('Taksit sayısı 2 ile 24 arasında olmalıdır.');
      return;
    }

    final unitPrice = amount / quantity;
    final key = _buildCalculationKey(
      accountId: account.id,
      txType: _txType,
      amount: amount,
      quantity: quantity,
    );
    FifoSellPreview? sellPreview;
    if (_lastCalculationKey == key) {
      sellPreview = _sellPreview;
    } else if (_txType == 'sell') {
      try {
        sellPreview = await InvestmentTransactionService.previewSell(
          investmentAccountId: account.id,
          symbol: (account.investmentSymbol ?? '').toUpperCase(),
          sellQuantity: quantity,
          sellUnitPrice: unitPrice,
        );
      } catch (e) {
        _showSnack('$e');
        return;
      }
    }

    setState(() {
      _saving = true;
      _sellPreview = sellPreview;
      _lastCalculationKey = key;
    });

    try {
      if (_isEditMode) {
        await InvestmentTransactionService.updateTransaction(
          transactionId: widget.initialTransaction!.id,
          investmentAccountId: account.id,
          cashAccountId: cashAccountId,
          symbol: (account.investmentSymbol ?? '').toUpperCase(),
          type: _txType,
          quantity: quantity,
          unitPrice: unitPrice,
          total: amount,
          date: _selectedDate,
        );
      } else {
        final createdId = await InvestmentTransactionService.addAndGetId(
          investmentAccountId: account.id,
          cashAccountId: cashAccountId,
          symbol: (account.investmentSymbol ?? '').toUpperCase(),
          type: _txType,
          quantity: quantity,
          unitPrice: unitPrice,
          total: amount,
          date: _selectedDate,
          syncCreditCardStatement: !_isInstallment,
        );
        if (_isInstallment && cashAccount != null) {
          await CreditCardInstallmentService.createInstallmentsForInvestment(
            investmentTransactionId: createdId,
            creditCardAccount: cashAccount,
            transactionDate: _selectedDate,
            totalAmount: amount,
            installmentCount: installmentCount!,
          );
        }
      }

      if (!mounted) return;
      _isEditMode ? AppFeedback.updated() : AppFeedback.saved();
      Navigator.pop(context, true);
    } catch (e) {
      _showSnack('Kayıt hatası: $e');
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  // Edit modundaki yatirim hareketini geri sararak siler.
  Future<void> _deleteCurrent() async {
    if (!_isEditMode || _saving) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('İşlemi Sil'),
        content: const Text('Bu yatırım işlemi silinsin mi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Vazgeç'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    setState(() {
      _saving = true;
    });
    try {
      await InvestmentTransactionService.deleteAndReturn(
          widget.initialTransaction!.id);
      if (!mounted) return;
      AppFeedback.deleted();
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Silme hatası: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  String _fmtMoney(double value) {
    final fixed = value.toStringAsFixed(2);
    final parts = fixed.split('.');
    final intPart = parts[0];
    final decPart = parts[1];

    final b = StringBuffer();
    for (int i = 0; i < intPart.length; i++) {
      final fromRight = intPart.length - i;
      b.write(intPart[i]);
      if (fromRight > 1 && fromRight % 3 == 1) b.write('.');
    }
    return '${b.toString()},$decPart';
  }

  String _fmtQuantity(double value) {
    final fixed = value.toStringAsFixed(4);
    final normalized = fixed.replaceFirst(RegExp(r'([.,]?)0+$'), '');
    final parts = normalized.split('.');
    final intPart = parts[0];
    final decPart = parts.length > 1 ? parts[1] : '';

    final b = StringBuffer();
    for (int i = 0; i < intPart.length; i++) {
      final fromRight = intPart.length - i;
      b.write(intPart[i]);
      if (fromRight > 1 && fromRight % 3 == 1) b.write('.');
    }
    if (decPart.isEmpty) return b.toString();
    return '${b.toString()},$decPart';
  }

  String _investmentAccountLabel(Account a) {
    final symbol = (a.investmentSymbol ?? '-').toUpperCase();
    return '${a.name} • Bakiye: ${_fmtQuantity(a.balance)} $symbol';
  }

  String _cashAccountLabel(Account a) {
    if (a.isCreditCard) {
      return '${a.name} • Kart Borcu: ${_fmtMoney(a.balance.abs())} TL';
    }
    return '${a.name} • Bakiye: ${_fmtMoney(a.balance)} TL';
  }

  Widget _buildLiveSummary(Account? investmentAccount, Account? cashAccount) {
    if (!_hasValidInputsForPreview()) {
      return const SizedBox.shrink();
    }

    final amount = _liveAmount()!;
    final quantity = _liveQuantity()!;
    final unitPrice = amount / quantity;
    final projectedInvestmentBalance = _projectedInvestmentBalance();
    final projectedCashBalance = _projectedCashBalance();
    final instrumentUnit = _instrumentUnit(investmentAccount);
    final warning = _liveBalanceWarning();
    final hasWarning = warning != null;
    final installmentPreview = _liveInstallmentPreview();
    final firstInstallment =
        installmentPreview.isNotEmpty ? installmentPreview.first : null;
    final lastInstallment =
        installmentPreview.isNotEmpty ? installmentPreview.last : null;
    final isCreditCardBuy =
        _txType == 'buy' && cashAccount != null && cashAccount.isCreditCard;
    final projectedCurrentMonthCardPayment = _projectedCurrentMonthCardPayment(
      cashAccount: cashAccount,
      amount: amount,
    );

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: hasWarning ? const Color(0xFFFFF4E5) : const Color(0xFFF6F8FB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: hasWarning ? const Color(0xFFE09F3E) : Colors.black12,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'İşlem Özeti',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'İşlem: ${_txType == 'buy' ? 'Alış' : 'Satış'} • '
            '${_fmtQuantity(quantity)} $instrumentUnit • '
            'Toplam ${_fmtMoney(amount)} TL',
          ),
          Text('Birim fiyat: ${_fmtMoney(unitPrice)} TL'),
          if (investmentAccount != null && projectedInvestmentBalance != null)
            Text(
              'Yatırım bakiyesi: ${_fmtQuantity(investmentAccount.balance)} $instrumentUnit '
              '→ ${_fmtQuantity(projectedInvestmentBalance)} $instrumentUnit',
            ),
          if (cashAccount != null && projectedCashBalance != null)
            Text(
              isCreditCardBuy
                  ? 'Kart borcu: ${_fmtMoney(cashAccount.balance.abs())} TL '
                      '→ ${_fmtMoney(projectedCashBalance.abs())} TL'
                  : 'Nakit bakiye: ${_fmtMoney(cashAccount.balance)} TL '
                      '→ ${_fmtMoney(projectedCashBalance)} TL',
            ),
          if (isCreditCardBuy) ...[
            const SizedBox(height: 8),
            const Text(
              'Bu alış ilgili kredi kartı ekstresine borç olarak yansıtılacaktır.',
            ),
            Text(
              'Bu ayki toplam kart ödemeniz ${_fmtMoney(projectedCurrentMonthCardPayment)} TL olacaktır.',
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          if (firstInstallment != null) ...[
            const SizedBox(height: 8),
            Text(
              'Taksit Planı: ${firstInstallment.installmentCount} taksit • '
              'İlk taksit ${_fmtMoney(firstInstallment.amount)} TL',
            ),
            Text(
              'İlk ekstre: ${_fmtDate(firstInstallment.statementDate)} • '
              'Son ödeme: ${_fmtDate(firstInstallment.dueDate)}',
            ),
            if (lastInstallment != null)
              Text(
                'Son taksit ekstresi: ${_fmtDate(lastInstallment.statementDate)}',
              ),
          ],
          if (hasWarning) ...[
            const SizedBox(height: 8),
            Text(
              warning,
              style: const TextStyle(
                color: Color(0xFF8A4B00),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  bool get _canSubmit {
    if (_saving) return false;
    if (_liveBalanceWarning() != null) return false;
    if (_txType == 'sell' && _sellPreviewError != null) return false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final selectedAccount = _selectedAccount();
    final selectedCashAccount = _selectedCashAccount();

    return PopScope(
        canPop: !_hasUnsavedChanges(),
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;
          await _handleExit(toDashboard: false);
        },
        child: Scaffold(
          drawer: buildAppMenuDrawer(),
          appBar: AppBar(
            leading: _isEditMode
                ? IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => _handleExit(toDashboard: false),
                  )
                : IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => _handleExit(toDashboard: true),
                  ),
            title:
                Text(_isEditMode ? 'Yatırım İşlemi Düzenle' : 'Yatırım İşlemi'),
            actions: [
              IconButton(
                icon: const Icon(Icons.home_outlined),
                tooltip: 'Ana Ekran',
                onPressed: () => _handleExit(toDashboard: true),
              ),
            ],
          ),
          body: _loading
              ? const Center(child: CircularProgressIndicator())
              : (_investmentAccounts.isEmpty ||
                      _availableCashAccounts().isEmpty)
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          _investmentAccounts.isEmpty
                              ? 'İşlem için en az bir aktif yatırım hesabı ve bağlı yatırım türü olmalı.'
                              : _txType == 'buy'
                                  ? 'İşlem için en az bir aktif ödeme hesabı olmalı.'
                                  : 'İşlem için en az bir aktif hedef hesap olmalı.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : Form(
                      key: _formKey,
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          SegmentedButton<String>(
                            segments: const [
                              ButtonSegment<String>(
                                  value: 'buy', label: Text('Alış')),
                              ButtonSegment<String>(
                                  value: 'sell', label: Text('Satış')),
                            ],
                            selected: {_txType},
                            onSelectionChanged: (set) {
                              setState(() {
                                _txType = set.first;
                                final availableAccounts =
                                    _availableCashAccounts();
                                if (!_supportsInstallment) {
                                  _isInstallment = false;
                                  _installmentCountController.clear();
                                }
                                if (!availableAccounts.any(
                                    (a) => a.id == _selectedCashAccountId)) {
                                  _selectedCashAccountId =
                                      availableAccounts.isNotEmpty
                                          ? availableAccounts.first.id
                                          : null;
                                }
                                _invalidateCalculation();
                              });
                              _refreshSellPreview();
                            },
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<int>(
                            initialValue: _selectedAccountId,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Yatırım Hesabı',
                              border: OutlineInputBorder(),
                            ),
                            items: _investmentAccounts
                                .map(
                                  (a) => DropdownMenuItem<int>(
                                    value: a.id,
                                    child: Text(
                                      _investmentAccountLabel(a),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) {
                              setState(() {
                                _selectedAccountId = v;
                                _invalidateCalculation();
                              });
                              _refreshSellPreview();
                            },
                            validator: (v) =>
                                v == null ? 'Hesap seçiniz.' : null,
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<int>(
                            initialValue: _selectedCashAccountId,
                            isExpanded: true,
                            decoration: InputDecoration(
                              labelText: _txType == 'buy'
                                  ? 'Kaynak Hesap'
                                  : 'Hedef Hesap',
                              border: const OutlineInputBorder(),
                            ),
                            items: _availableCashAccounts()
                                .map(
                                  (a) => DropdownMenuItem<int>(
                                    value: a.id,
                                    child: Text(
                                      _cashAccountLabel(a),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) {
                              setState(() {
                                _selectedCashAccountId = v;
                                if (!_supportsInstallment) {
                                  _isInstallment = false;
                                  _installmentCountController.clear();
                                }
                                _invalidateCalculation();
                              });
                              _refreshSellPreview();
                            },
                            validator: (v) =>
                                v == null ? 'Hesap seçiniz.' : null,
                          ),
                          const SizedBox(height: 12),
                          InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Tür (hesaba bağlı)',
                              border: OutlineInputBorder(),
                            ),
                            child: Text(_instrumentLabel(selectedAccount)),
                          ),
                          const SizedBox(height: 12),
                          if (_supportsInstallment) ...[
                            CheckboxListTile(
                              contentPadding: EdgeInsets.zero,
                              title: const Text('Taksitli İşlem'),
                              subtitle: const Text(
                                'Bu yatırım alışı kredi kartı ekstrelere taksitli olarak dağıtılsın.',
                              ),
                              value: _isInstallment,
                              onChanged: (value) {
                                setState(() {
                                  _isInstallment = value ?? false;
                                  if (!_isInstallment) {
                                    _installmentCountController.clear();
                                  }
                                });
                              },
                            ),
                            if (_isInstallment) ...[
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _installmentCountController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Taksit Sayısı',
                                  border: OutlineInputBorder(),
                                ),
                                onChanged: (_) => setState(() {}),
                                validator: (v) {
                                  if (!_isInstallment) return null;
                                  final parsed = int.tryParse(v ?? '');
                                  if (parsed == null ||
                                      parsed < 2 ||
                                      parsed > 24) {
                                    return '2-24 arası taksit giriniz.';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                            ],
                          ],
                          if (_isEditMode && _hasExistingInstallments) ...[
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF4E5),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(0xFFE09F3E),
                                ),
                              ),
                              child: const Text(
                                'Bu kayıt taksitli kredi kartı yatırım alışıdır. Düzenleme bu aşamada kapalı tutuldu.',
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                          InkWell(
                            onTap: _pickDate,
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Tarih',
                                border: OutlineInputBorder(),
                              ),
                              child: Text(_fmtDate(_selectedDate)),
                            ),
                          ),
                          TextFormField(
                            controller: _amountController,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            inputFormatters: const [
                              TurkishMoneyInputFormatter()
                            ],
                            decoration: const InputDecoration(
                              labelText: 'Tutar (TL)',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (_) {
                              setState(() {
                                _invalidateCalculation();
                              });
                              _refreshSellPreview();
                            },
                            validator: (v) {
                              final parsed =
                                  TurkishMoneyInputFormatter.parse(v ?? '');
                              if (parsed == null || parsed <= 0) {
                                return 'Geçerli tutar giriniz.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _quantityController,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            decoration: const InputDecoration(
                              labelText: 'Miktar',
                              border: OutlineInputBorder(),
                              hintText: 'Örn: 12,50',
                            ),
                            onChanged: (_) {
                              setState(() {
                                _invalidateCalculation();
                              });
                              _refreshSellPreview();
                            },
                            validator: (v) {
                              final parsed = _parseQuantity(v ?? '');
                              if (parsed == null || parsed <= 0) {
                                return 'Geçerli miktar giriniz.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          _buildLiveSummary(
                              selectedAccount, selectedCashAccount),
                          if (_txType == 'sell' && _sellPreview != null) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.black12),
                              ),
                              child: Text(
                                'FIFO Maliyet: ${_fmtMoney(_sellPreview!.costBasisTotal)} TL\n'
                                'Gerçekleşen K/Z: ${_fmtMoney(_sellPreview!.realizedPnl.abs())} TL ${_sellPreview!.realizedPnl >= 0 ? '(Kar)' : '(Zarar)'}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: _sellPreview!.realizedPnl >= 0
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                            ),
                          ],
                          if (_txType == 'sell' &&
                              _sellPreviewError != null) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF4E5),
                                borderRadius: BorderRadius.circular(8),
                                border:
                                    Border.all(color: const Color(0xFFE09F3E)),
                              ),
                              child: Text(
                                _sellPreviewError!,
                                style: const TextStyle(
                                  color: Color(0xFF8A4B00),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _canSubmit ? _save : null,
                            child: Text(
                              _saving
                                  ? 'Kaydediliyor...'
                                  : (_isEditMode ? 'Güncelle' : 'Kaydet'),
                            ),
                          ),
                          if (_isEditMode) ...[
                            const SizedBox(height: 10),
                            OutlinedButton(
                              onPressed: _saving ? null : _deleteCurrent,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                              ),
                              child: const Text('Sil'),
                            ),
                          ],
                        ],
                      ),
                    ),
        ));
  }
}
