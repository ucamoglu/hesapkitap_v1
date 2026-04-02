import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../core/runtime/app_runtime.dart';
import '../models/account.dart';
import '../models/asset_record.dart';
import '../models/credit_card_statement.dart';
import '../services/account_service.dart';
import '../services/category_service.dart';
import '../services/credit_card_installment_service.dart';
import '../services/credit_card_statement_service.dart';
import '../services/income_category_service.dart';
import '../services/location_consent_service.dart';
import '../services/transaction_attachment_service.dart';
import '../services/transaction_location_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme_helpers.dart';
import '../utils/app_feedback.dart';
import '../utils/camera_support.dart';
import '../utils/navigation_helpers.dart';
import '../utils/turkish_money_input_formatter.dart';
import '../utils/turkish_upper_case_formatter.dart';

enum AssetOperationMode {
  buy,
  sell,
  edit,
}

class AssetOperationScreen extends StatefulWidget {
  const AssetOperationScreen({
    super.key,
    required this.mode,
    this.initialAsset,
  });

  final AssetOperationMode mode;
  final AssetRecord? initialAsset;

  @override
  State<AssetOperationScreen> createState() => _AssetOperationScreenState();
}

class _AssetOperationScreenState extends State<AssetOperationScreen> {
  static const _assetTypeOptions = <(String, String)>[
    ('housing', 'Konut'),
    ('workplace', 'İşyeri'),
    ('land', 'Arsa'),
    ('field', 'Arazi'),
    ('vehicle', 'Araç'),
    ('fixture', 'Demirbaş'),
  ];

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _areaController = TextEditingController();
  final _addressController = TextEditingController();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _currentValueController = TextEditingController();
  final _amountController = TextEditingController();
  final _splitCashAmountController = TextEditingController();
  final _splitCreditCardAmountController = TextEditingController();
  final _installmentCountController = TextEditingController();
  final _imagePicker = ImagePicker();

  final List<Uint8List> _attachments = <Uint8List>[];
  final List<Uint8List> _existingAttachments = <Uint8List>[];

  List<Account> _accounts = <Account>[];
  List<CreditCardStatement> _creditCardStatements = <CreditCardStatement>[];
  List<AssetRecord> _activeAssets = <AssetRecord>[];

  String _selectedAssetType = 'housing';
  String _paymentMethod = 'single';
  int? _selectedExpenseAccountId;
  int? _selectedSplitCreditCardAccountId;
  int? _selectedSplitCashAccountId;
  int? _selectedIncomeAccountId;
  int? _selectedAssetId;
  DateTime _selectedDate = DateTime.now();
  bool _loading = true;
  bool _saving = false;
  bool _isActive = true;
  bool _isInstallment = false;

  bool get _isBuyMode => widget.mode == AssetOperationMode.buy;
  bool get _isSellMode => widget.mode == AssetOperationMode.sell;
  bool get _isEditMode => widget.mode == AssetOperationMode.edit;

  bool get _isRealEstateType =>
      _selectedAssetType == 'housing' ||
      _selectedAssetType == 'workplace' ||
      _selectedAssetType == 'land' ||
      _selectedAssetType == 'field';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _areaController.dispose();
    _addressController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _descriptionController.dispose();
    _currentValueController.dispose();
    _amountController.dispose();
    _splitCashAmountController.dispose();
    _splitCreditCardAmountController.dispose();
    _installmentCountController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
    });

    final results = await Future.wait([
      AccountService.getAllAccounts(),
      CreditCardStatementService.getAll(),
      AppRuntime.dataLayer.assets.getActive(),
    ]);

    final accounts = (results[0] as List<Account>)
        .where((account) => account.type != 'investment' && account.isActive)
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    final creditCardStatements = results[1] as List<CreditCardStatement>;
    final activeAssets = results[2] as List<AssetRecord>;

    final initialAsset = widget.initialAsset;
    if (initialAsset != null) {
      _selectedAssetType = initialAsset.assetType;
      _nameController.text = initialAsset.name;
      _areaController.text = initialAsset.areaSquareMeters ?? '';
      _addressController.text = initialAsset.address ?? '';
      _brandController.text = initialAsset.brand ?? '';
      _modelController.text = initialAsset.model ?? '';
      _descriptionController.text = initialAsset.description ?? '';
      _currentValueController.text = initialAsset.currentValueInput ?? '';
      _selectedDate = _isSellMode
          ? (initialAsset.saleDate ?? DateTime.now())
          : initialAsset.acquisitionDate;
      _selectedAssetId = initialAsset.id;
      _isActive = initialAsset.isActive;
      if (_isEditMode) {
        final existing = await TransactionAttachmentService.getByOwner(
          ownerType: 'asset',
          ownerId: initialAsset.id,
        );
        _existingAttachments
          ..clear()
          ..addAll(existing.map((e) => Uint8List.fromList(e.imageBytes)));
      }
    }

    if (_isBuyMode) {
      _selectedExpenseAccountId ??=
          accounts.isNotEmpty ? accounts.first.id : null;
      _selectedSplitCreditCardAccountId ??= _creditCardAccounts(accounts).isNotEmpty
          ? _creditCardAccounts(accounts).first.id
          : null;
      _selectedSplitCashAccountId ??= _nonCreditCardAccounts(accounts).isNotEmpty
          ? _nonCreditCardAccounts(accounts).first.id
          : null;
    } else if (_isSellMode) {
      _selectedIncomeAccountId ??=
          accounts.isNotEmpty ? accounts.first.id : null;
      _selectedAssetId ??= activeAssets.isNotEmpty ? activeAssets.first.id : null;
      _syncSellAssetDetails();
    }

    if (!mounted) return;
    setState(() {
      _accounts = accounts;
      _creditCardStatements = creditCardStatements;
      _activeAssets = activeAssets;
      _loading = false;
    });
  }

  void _syncSellAssetDetails() {
    if (!_isSellMode) return;
    final asset = _selectedAsset;
    if (asset == null) return;
    _selectedAssetType = asset.assetType;
    _nameController.text = asset.name;
    _areaController.text = asset.areaSquareMeters ?? '';
    _addressController.text = asset.address ?? '';
    _brandController.text = asset.brand ?? '';
    _modelController.text = asset.model ?? '';
    _currentValueController.text = asset.currentValueInput ?? '';
  }

  List<Account> _creditCardAccounts([List<Account>? source]) {
    final accounts = source ?? _accounts;
    return accounts.where((account) => account.isCreditCard).toList();
  }

  List<Account> _nonCreditCardAccounts([List<Account>? source]) {
    final accounts = source ?? _accounts;
    return accounts.where((account) => !account.isCreditCard).toList();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() {
      _selectedDate = picked;
    });
  }

  Future<void> _save() async {
    if (_saving) return;
    if (!_formKey.currentState!.validate()) return;

    final amount = TurkishMoneyInputFormatter.parse(_amountController.text);
    if ((_isBuyMode || _isSellMode) && (amount == null || amount <= 0)) {
      _showSnack('Geçerli bir tutar giriniz.');
      return;
    }
    if (_isSellMode && _selectedAssetId == null) {
      _showSnack('Satılacak varlığı seçiniz.');
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      final location = _isEditMode ? null : await _resolveLocationForSave();
      if (_isBuyMode) {
        final assetCategory = await CategoryService.ensureAssetPurchaseCategory();
        final installmentCount = _isInstallment
            ? int.tryParse(_installmentCountController.text)
            : null;
        final splitCashAmount =
            TurkishMoneyInputFormatter.parse(_splitCashAmountController.text);
        final splitCreditCardAmount = TurkishMoneyInputFormatter.parse(
          _splitCreditCardAmountController.text,
        );
        if (_paymentMethod == 'split') {
          if (_selectedSplitCashAccountId == null ||
              _selectedSplitCreditCardAccountId == null) {
            _showSnack('Çift ödemede iki hesap da seçilmelidir.');
            return;
          }
          if (_selectedSplitCashAccountId == _selectedSplitCreditCardAccountId) {
            _showSnack('Nakit ve kredi kartı hesapları farklı olmalıdır.');
            return;
          }
          if (splitCashAmount == null ||
              splitCashAmount <= 0 ||
              splitCreditCardAmount == null ||
              splitCreditCardAmount <= 0) {
            _showSnack('İki ödeme tutarı da sıfırdan büyük olmalıdır.');
            return;
          }
          if (((splitCashAmount + splitCreditCardAmount) - amount!).abs() > 0.005) {
            _showSnack('Ödeme tutarlarının toplamı edinim değerine eşit olmalıdır.');
            return;
          }
        }
        if (_isInstallment &&
            (_selectedCreditCardPaymentAccount() == null)) {
          _showSnack('Taksit yalnızca kredi kartı seçildiğinde kullanılabilir.');
          return;
        }
        if (_isInstallment &&
            (installmentCount == null ||
                installmentCount < 2 ||
                installmentCount > 24)) {
          _showSnack('Taksit sayısı 2 ile 24 arasında olmalıdır.');
          return;
        }
        final assetId = await AppRuntime.dataLayer.assets.addPurchase(
          assetType: _selectedAssetType,
          name: _resolvedName(),
          areaSquareMeters: _normalizeText(_areaController.text),
          address: _normalizeText(_addressController.text),
          brand: _normalizeText(_brandController.text),
          model: _normalizeText(_modelController.text),
          description: _normalizeText(_descriptionController.text),
          currentValueInput: null,
          acquisitionValue: amount!,
          acquisitionDate: _selectedDate,
          expenseAccountId: _paymentMethod == 'split'
              ? _selectedSplitCashAccountId!
              : _selectedExpenseAccountId!,
          expenseCategoryId: assetCategory.id,
          paymentMethod: _paymentMethod,
          primaryPaymentAmount:
              _paymentMethod == 'split' ? splitCashAmount : amount,
          secondaryExpenseAccountId: _paymentMethod == 'split'
              ? _selectedSplitCreditCardAccountId
              : null,
          secondaryPaymentAmount: _paymentMethod == 'split'
              ? splitCreditCardAmount
              : null,
          installmentCount: installmentCount,
          latitude: location?.latitude,
          longitude: location?.longitude,
        );
        await TransactionAttachmentService.addMany(
          ownerType: 'asset',
          ownerId: assetId,
          images: _attachments.map((e) => e.toList()).toList(),
        );
      } else if (_isSellMode) {
        final assetSaleCategory =
            await IncomeCategoryService.ensureAssetSaleCategory();
        await AppRuntime.dataLayer.assets.sell(
          assetId: _selectedAssetId!,
          incomeAccountId: _selectedIncomeAccountId!,
          incomeCategoryId: assetSaleCategory.id,
          saleValue: amount!,
          saleDate: _selectedDate,
          description: _normalizeText(_descriptionController.text),
          latitude: location?.latitude,
          longitude: location?.longitude,
        );
      } else {
        await AppRuntime.dataLayer.assets.updateDefinition(
          assetId: widget.initialAsset!.id,
          assetType: _selectedAssetType,
          name: _resolvedName(),
          areaSquareMeters: _normalizeText(_areaController.text),
          address: _normalizeText(_addressController.text),
          brand: _normalizeText(_brandController.text),
          model: _normalizeText(_modelController.text),
          description: _normalizeText(_descriptionController.text),
          currentValueInput: _normalizeText(_currentValueController.text),
          isActive: _isActive,
        );
        await TransactionAttachmentService.replaceAll(
          ownerType: 'asset',
          ownerId: widget.initialAsset!.id,
          images: [
            ..._existingAttachments.map((e) => e.toList()),
            ..._attachments.map((e) => e.toList()),
          ],
        );
      }

      if (!mounted) return;
      _isEditMode ? AppFeedback.updated() : AppFeedback.saved();
      Navigator.pop(context, true);
    } catch (e) {
      _showSnack('İşlem kaydedilemedi: $e');
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  Future<TransactionLocationPoint?> _resolveLocationForSave() async {
    final preference = await LocationConsentService.getPreference();
    if (preference == null) {
      if (!mounted) return null;
      final approved = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Konum İlişkilendirilsin mi?'),
          content: const Text(
            'İstersen işlemler kaydedilirken bulunduğun konum otomatik ilişkilendirilebilir. Bu özellik daha sonra harita üzerinde hareketleri göstermemize yardımcı olur.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Şimdilik Kullanma'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Konumu Kullan'),
            ),
          ],
        ),
      );
      final allowAutoCapture = approved == true;
      await LocationConsentService.savePreference(
        autoCaptureEnabled: allowAutoCapture,
      );
      if (!allowAutoCapture) return null;
      return TransactionLocationService.tryGetCurrentLocation(
        requestPermission: true,
      );
    }

    if (!preference.autoCaptureEnabled) return null;
    return TransactionLocationService.tryGetCurrentLocation();
  }

  Future<void> _pickAttachment(ImageSource source) async {
    try {
      if (source == ImageSource.camera && !isCameraSourceAvailable()) {
        _showSnack('Kamera bu platformda desteklenmiyor.');
        return;
      }
      final file = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1600,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      setState(() {
        _attachments.add(bytes);
      });
    } catch (e) {
      _showSnack('Resim eklenemedi: $e');
    }
  }

  Future<void> _showAddAttachmentSheet() async {
    final cameraSupported = isCameraSourceAvailable();
    await showModalBottomSheet<void>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (cameraSupported)
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Kamera'),
                onTap: () async {
                  Navigator.pop(context);
                  await Future<void>.delayed(const Duration(milliseconds: 220));
                  if (!mounted) return;
                  await _pickAttachment(ImageSource.camera);
                },
              ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeri'),
              onTap: () async {
                Navigator.pop(context);
                await Future<void>.delayed(const Duration(milliseconds: 220));
                if (!mounted) return;
                await _pickAttachment(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  String _resolvedName() {
    if (_selectedAssetType == 'vehicle') {
      final brand = _normalizeText(_brandController.text) ?? '';
      final model = _normalizeText(_modelController.text) ?? '';
      return '$brand $model'.trim();
    }
    return _normalizeText(_nameController.text) ?? '';
  }

  String? _normalizeText(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  AssetRecord? get _selectedAsset {
    for (final asset in _activeAssets) {
      if (asset.id == _selectedAssetId) return asset;
    }
    return widget.initialAsset;
  }

  Account? _selectedSingleExpenseAccount() {
    final id = _selectedExpenseAccountId;
    if (id == null) return null;
    for (final account in _accounts) {
      if (account.id == id) return account;
    }
    return null;
  }

  Account? _selectedSplitCashAccount() {
    final id = _selectedSplitCashAccountId;
    if (id == null) return null;
    for (final account in _accounts) {
      if (account.id == id) return account;
    }
    return null;
  }

  Account? _selectedSplitCreditCardAccount() {
    final id = _selectedSplitCreditCardAccountId;
    if (id == null) return null;
    for (final account in _accounts) {
      if (account.id == id) return account;
    }
    return null;
  }

  Account? _selectedAccount() {
    final id = _isBuyMode ? _selectedExpenseAccountId : _selectedIncomeAccountId;
    if (id == null) return null;
    for (final account in _accounts) {
      if (account.id == id) return account;
    }
    return null;
  }

  double? _liveAmount() {
    return TurkishMoneyInputFormatter.parse(_amountController.text);
  }

  double? _liveSplitCashAmount() {
    return TurkishMoneyInputFormatter.parse(_splitCashAmountController.text);
  }

  double? _liveSplitCreditCardAmount() {
    return TurkishMoneyInputFormatter.parse(
      _splitCreditCardAmountController.text,
    );
  }

  Account? _selectedCreditCardPaymentAccount() {
    if (_paymentMethod == 'split') {
      return _selectedSplitCreditCardAccount();
    }
    final account = _selectedSingleExpenseAccount();
    if (account?.isCreditCard == true) return account;
    return null;
  }

  double? _selectedCreditCardPaymentAmount() {
    if (_paymentMethod == 'split') return _liveSplitCreditCardAmount();
    final account = _selectedSingleExpenseAccount();
    if (account?.isCreditCard == true) return _liveAmount();
    return null;
  }

  String? _liveBalanceWarning() {
    if (!_isBuyMode) return null;
    if (_paymentMethod == 'split') {
      final cashAccount = _selectedSplitCashAccount();
      final cashAmount = _liveSplitCashAmount();
      if (cashAccount == null || cashAmount == null || cashAmount <= 0) {
        return null;
      }
      if (!cashAccount.canWithdraw(cashAmount)) {
        return 'Nakit/banka hesabı ödeme tutarı için yetersiz.';
      }
      return null;
    }
    final account = _selectedSingleExpenseAccount();
    final amount = _liveAmount();
    if (account == null || amount == null || amount <= 0 || account.isCreditCard) {
      return null;
    }
    if (!account.canWithdraw(amount)) {
      return 'Bu satın alma mevcut hesap bakiyesini aşıyor.';
    }
    return null;
  }

  bool get _supportsInstallment {
    return !_isEditMode &&
        _isBuyMode &&
        _selectedCreditCardPaymentAccount() != null;
  }

  List<CreditCardInstallmentPreview> _liveInstallmentPreview() {
    final account = _selectedCreditCardPaymentAccount();
    final amount = _selectedCreditCardPaymentAmount();
    final installmentCount = int.tryParse(_installmentCountController.text);
    if (!_isInstallment ||
        account == null ||
        amount == null ||
        amount <= 0 ||
        installmentCount == null ||
        installmentCount < 2) {
      return const [];
    }
    try {
      return CreditCardInstallmentService.previewInstallments(
        creditCardAccount: account,
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

  double _projectedCurrentMonthCardPaymentTotal({
    required DateTime referenceMonth,
    required bool isCreditCard,
    required double amount,
    required List<CreditCardInstallmentPreview> installmentPreview,
  }) {
    var total = _creditCardStatements.fold<double>(0, (sum, statement) {
      if (!_sameMonth(statement.statementDate, referenceMonth)) return sum;
      final remaining = (statement.totalAmount - statement.paidAmount)
          .clamp(0, double.infinity)
          .toDouble();
      return sum + remaining;
    });

    if (!isCreditCard) return total;

    if (installmentPreview.isNotEmpty) {
      total += installmentPreview.fold<double>(0, (sum, installment) {
        if (!_sameMonth(installment.statementDate, referenceMonth)) {
          return sum;
        }
        return sum + installment.amount;
      });
      return total;
    }

    final account = _selectedCreditCardPaymentAccount();
    if (account == null) return total;

    try {
      final cycle = CreditCardStatementService.resolveCycle(
        creditCardAccount: account,
        transactionDate: _selectedDate,
      );
      if (_sameMonth(cycle.statementDate, referenceMonth)) {
        total += amount;
      }
    } catch (_) {}

    return total;
  }

  Widget _buildLiveSummary() {
    final amount = _liveAmount();
    if ((_isBuyMode && (amount == null || amount <= 0)) ||
        (!_isBuyMode && (_selectedAccount() == null || amount == null || amount <= 0))) {
      return const SizedBox.shrink();
    }
    final liveAmount = amount!;

    if (_isBuyMode) {
      final singleAccount = _selectedSingleExpenseAccount();
      final cashAccount = _paymentMethod == 'split' ? _selectedSplitCashAccount() : null;
      final cardAccount =
          _paymentMethod == 'split' ? _selectedSplitCreditCardAccount() : null;
      final cashAmount =
          _paymentMethod == 'split' ? _liveSplitCashAmount() : null;
      final cardAmount =
          _paymentMethod == 'split' ? _liveSplitCreditCardAmount() : null;
      final warning = _liveBalanceWarning();
      final hasWarning = warning != null;
      final installmentPreview = _liveInstallmentPreview();
      final firstInstallment =
          installmentPreview.isNotEmpty ? installmentPreview.first : null;
      final lastInstallment =
          installmentPreview.isNotEmpty ? installmentPreview.last : null;
      final projectedCurrentMonthCardPayment =
          _projectedCurrentMonthCardPaymentTotal(
        referenceMonth: _selectedDate,
        isCreditCard: _selectedCreditCardPaymentAccount() != null,
        amount: _selectedCreditCardPaymentAmount() ?? 0,
        installmentPreview: installmentPreview,
      );
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: context.surfaceDecoration(
          accent: hasWarning ? Colors.orange : AppColors.expense,
          fillColor: hasWarning
              ? Colors.orange.withValues(alpha: 0.12)
              : context.softAccent(AppColors.expense, 0.10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'İşlem Özeti',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text('Edinim değeri: ${_fmtMoney(liveAmount)} TL'),
            if (_paymentMethod == 'split') ...[
              if (cashAccount != null && cashAmount != null)
                Text(
                  'Nakit/Banka: ${_fmtMoney(cashAccount.balance)} TL → ${_fmtMoney(cashAccount.balance - cashAmount)} TL',
                ),
              if (cardAccount != null && cardAmount != null)
                Text(
                  'Kart borcu: ${_fmtMoney(cardAccount.balance.abs())} TL → ${_fmtMoney((cardAccount.balance - cardAmount).abs())} TL',
                ),
            ] else if (singleAccount != null) ...[
              Text(
                singleAccount.isCreditCard
                    ? 'Kart borcu: ${_fmtMoney(singleAccount.balance.abs())} TL → ${_fmtMoney((singleAccount.balance - liveAmount).abs())} TL'
                    : 'Hesap bakiyesi: ${_fmtMoney(singleAccount.balance)} TL → ${_fmtMoney(singleAccount.balance - liveAmount)} TL',
              ),
            ],
            if (_selectedCreditCardPaymentAccount() != null) ...[
              const SizedBox(height: 8),
              Text(
                'Bu ayki toplam kart ödemeniz ${_fmtMoney(projectedCurrentMonthCardPayment)} TL olacaktır.',
                style: const TextStyle(
                  color: AppColors.expense,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
            if (firstInstallment != null) ...[
              const SizedBox(height: 8),
              Text(
                'Taksit Planı: ${firstInstallment.installmentCount} taksit • İlk taksit ${_fmtMoney(firstInstallment.amount)} TL',
              ),
              Text(
                'İlk ekstre: ${_fmtDate(firstInstallment.statementDate)} • Son ödeme: ${_fmtDate(firstInstallment.dueDate)}',
              ),
              if (lastInstallment != null)
                Text(
                  'Son taksit ekstresi: ${_fmtDate(lastInstallment.statementDate)}',
                ),
            ],
            if (warning != null) ...[
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

    final account = _selectedAccount()!;
    final projectedBalance = account.balance + liveAmount;
    final asset = _selectedAsset;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: context.surfaceDecoration(
        accent: Colors.orange,
        fillColor: context.softAccent(Colors.orange, 0.10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'İşlem Özeti',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text('Satış değeri: ${_fmtMoney(liveAmount)} TL'),
          Text(
            'Hesap bakiyesi: ${_fmtMoney(account.balance)} TL → ${_fmtMoney(projectedBalance)} TL',
          ),
          if (asset != null)
            Text(
              'Kar/Zarar: ${_fmtSignedMoney(liveAmount - asset.acquisitionValue)} TL',
              style: TextStyle(
                color: liveAmount >= asset.acquisitionValue
                    ? Colors.green.shade700
                    : Colors.red.shade700,
                fontWeight: FontWeight.w700,
              ),
            ),
        ],
      ),
    );
  }

  String _fmtMoney(double value) {
    final fixed = value.toStringAsFixed(2);
    final parts = fixed.split('.');
    final intPart = parts[0];
    final decPart = parts[1];
    final buffer = StringBuffer();
    for (int i = 0; i < intPart.length; i++) {
      final fromRight = intPart.length - i;
      buffer.write(intPart[i]);
      if (fromRight > 1 && fromRight % 3 == 1) {
        buffer.write('.');
      }
    }
    return '${buffer.toString()},$decPart';
  }

  String _fmtSignedMoney(double value) {
    final prefix = value > 0 ? '+' : '';
    return '$prefix${_fmtMoney(value)}';
  }

  String _fmtDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day.$month.${date.year}';
  }

  String _title() {
    switch (widget.mode) {
      case AssetOperationMode.buy:
        return 'Varlık Satın Al';
      case AssetOperationMode.sell:
        return 'Varlık Sat';
      case AssetOperationMode.edit:
        return 'Varlık Düzenle';
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasRequiredData = _isSellMode
        ? _activeAssets.isNotEmpty && _accounts.isNotEmpty
        : _accounts.isNotEmpty;

    return Scaffold(
      drawer: buildAppMenuDrawer(),
      appBar: AppBar(
        leading: buildBackAction(
          context,
          onPressed: () => popToDashboard(context),
        ),
        title: Text(_title()),
        actions: [buildHomeAction(context)],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : !hasRequiredData
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      _isSellMode
                          ? 'Satış işlemi için aktif varlık, hesap ve aktif gelir tipi olmalı.'
                          : 'Varlık alımı için en az bir hesap olmalı.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (!_isSellMode) ...[
                        _buildAssetTypeSelector(),
                        const SizedBox(height: 12),
                      ],
                      if (_isSellMode) ...[
                        _buildActiveAssetSelector(),
                        const SizedBox(height: 12),
                      ] else ...[
                        ..._buildAssetDetailFields(),
                        if (_isEditMode) ...[
                          const SizedBox(height: 12),
                          _buildCurrentValueField(),
                          const SizedBox(height: 12),
                          SwitchListTile.adaptive(
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 4),
                            title: const Text('Aktif'),
                            subtitle: const Text(
                              'Satılmayan veya kullanım dışı kalan varlığı aktif/pasif yapabilirsin.',
                            ),
                            value: _isActive,
                            onChanged: (value) {
                              setState(() {
                                _isActive = value;
                              });
                            },
                          ),
                        ],
                      ],
                      const SizedBox(height: 12),
                      _buildDateField(),
                      if (!_isEditMode) ...[
                        const SizedBox(height: 12),
                        _buildAccountAndCategoryFields(),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _amountController,
                          decoration: InputDecoration(
                            labelText:
                                _isBuyMode ? 'Edinim Değeri' : 'Satış Değeri',
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: const [TurkishMoneyInputFormatter()],
                          validator: (value) {
                            final parsed =
                                TurkishMoneyInputFormatter.parse(value ?? '');
                            if (parsed == null || parsed <= 0) {
                              return 'Geçerli bir tutar giriniz.';
                            }
                            return null;
                          },
                          onChanged: (_) => setState(() {}),
                        ),
                        if (_isBuyMode && _paymentMethod == 'split') ...[
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _splitCashAmountController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: const [TurkishMoneyInputFormatter()],
                            decoration: const InputDecoration(
                              labelText: 'Nakit/Banka Tutarı',
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _splitCreditCardAmountController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: const [TurkishMoneyInputFormatter()],
                            decoration: const InputDecoration(
                              labelText: 'Kredi Kartı Tutarı',
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        ],
                        if (_supportsInstallment) ...[
                          const SizedBox(height: 12),
                          CheckboxListTile(
                            value: _isInstallment,
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Taksitli işlem'),
                            subtitle: const Text(
                              'Bu varlık alımı kredi kartı ekstrelere taksitli olarak dağıtılsın.',
                            ),
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
                                hintText: '2-24',
                              ),
                              onChanged: (_) => setState(() {}),
                            ),
                          ],
                        ],
                        const SizedBox(height: 10),
                        _buildLiveSummary(),
                      ],
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _descriptionController,
                        minLines: 2,
                        maxLines: 4,
                        textCapitalization: TextCapitalization.words,
                        inputFormatters: const [TurkishUpperCaseFormatter()],
                        decoration: const InputDecoration(
                          labelText: 'Açıklama (opsiyonel)',
                        ),
                      ),
                      if (!_isSellMode) ...[
                        const SizedBox(height: 16),
                        _buildAttachmentSection(),
                      ],
                      if (_isSellMode && _selectedAsset != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration:
                              context.surfaceDecoration(accent: Colors.orange),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _selectedAsset!.displayName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text('Tür: ${_selectedAsset!.assetTypeLabel}'),
                              Text(
                                'Edinim: ${_fmtMoney(_selectedAsset!.acquisitionValue)} TL',
                              ),
                              if (_selectedAsset!.currentValueInput?.isNotEmpty ==
                                  true)
                                Text(
                                  'Güncel: ${_selectedAsset!.currentValueInput} TL',
                                ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed:
                            _saving || _liveBalanceWarning() != null ? null : _save,
                        child: Text(_isEditMode ? 'Güncelle' : 'Kaydet'),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildAssetTypeSelector() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedAssetType,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Varlık Türü',
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      items: _assetTypeOptions
          .map(
            (item) => DropdownMenuItem<String>(
              value: item.$1,
              child: Text(
                item.$2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
          .toList(),
      onChanged: _isSellMode
          ? null
          : (value) {
              if (value == null) return;
              setState(() {
                _selectedAssetType = value;
                if (value != 'vehicle' && value != 'fixture') {
                  _brandController.clear();
                }
                if (value != 'vehicle') {
                  _modelController.clear();
                }
                if (!_isRealEstateType) {
                  _areaController.clear();
                  _addressController.clear();
                }
                if (value == 'vehicle') {
                  _nameController.clear();
                }
              });
            },
    );
  }

  Widget _buildActiveAssetSelector() {
    return DropdownButtonFormField<int>(
      initialValue: _selectedAssetId,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Aktif Varlık',
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      items: _activeAssets
          .map(
            (asset) => DropdownMenuItem<int>(
              value: asset.id,
              child: Text(
                asset.displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
          .toList(),
      onChanged: (value) {
        setState(() {
          _selectedAssetId = value;
          _syncSellAssetDetails();
        });
      },
      validator: (value) => value == null ? 'Varlık seçiniz.' : null,
    );
  }

  List<Widget> _buildAssetDetailFields() {
    if (_selectedAssetType == 'vehicle') {
      return [
        TextFormField(
          controller: _brandController,
          textCapitalization: TextCapitalization.words,
          inputFormatters: const [TurkishUpperCaseFormatter()],
          decoration: const InputDecoration(labelText: 'Marka'),
          validator: (value) =>
              _normalizeText(value) == null ? 'Marka giriniz.' : null,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _modelController,
          textCapitalization: TextCapitalization.words,
          inputFormatters: const [TurkishUpperCaseFormatter()],
          decoration: const InputDecoration(labelText: 'Model'),
          validator: (value) =>
              _normalizeText(value) == null ? 'Model giriniz.' : null,
        ),
      ];
    }

    if (_selectedAssetType == 'fixture') {
      return [
        TextFormField(
          controller: _nameController,
          textCapitalization: TextCapitalization.words,
          inputFormatters: const [TurkishUpperCaseFormatter()],
          decoration: const InputDecoration(labelText: 'Adı'),
          validator: (value) =>
              _normalizeText(value) == null ? 'Ad giriniz.' : null,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _brandController,
          textCapitalization: TextCapitalization.words,
          inputFormatters: const [TurkishUpperCaseFormatter()],
          decoration: const InputDecoration(labelText: 'Markası'),
        ),
      ];
    }

    return [
      TextFormField(
        controller: _nameController,
        textCapitalization: TextCapitalization.words,
        inputFormatters: const [TurkishUpperCaseFormatter()],
        decoration: const InputDecoration(labelText: 'Adı'),
        validator: (value) =>
            _normalizeText(value) == null ? 'Ad giriniz.' : null,
      ),
      const SizedBox(height: 12),
      TextFormField(
        controller: _areaController,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
        ],
        decoration: const InputDecoration(labelText: 'm2'),
      ),
      const SizedBox(height: 12),
      TextFormField(
        controller: _addressController,
        minLines: 2,
        maxLines: 3,
        textCapitalization: TextCapitalization.sentences,
        decoration: const InputDecoration(labelText: 'Adresi'),
      ),
    ];
  }

  Widget _buildCurrentValueField() {
    return TextFormField(
      controller: _currentValueController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: const [TurkishMoneyInputFormatter()],
      decoration: const InputDecoration(
        labelText: 'Güncel Değer (opsiyonel)',
      ),
    );
  }

  Widget _buildDateField() {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: _pickDate,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: _isSellMode ? 'Satış Tarihi' : 'Tarih',
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        child: Row(
          children: [
            Expanded(child: Text(_fmtDate(_selectedDate))),
            const Icon(Icons.calendar_month_outlined),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountAndCategoryFields() {
    if (_isBuyMode) {
      final creditCardAccounts = _creditCardAccounts();
      final nonCreditCardAccounts = _nonCreditCardAccounts();
      return Column(
        children: [
          DropdownButtonFormField<String>(
            initialValue: _paymentMethod,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Ödeme Yöntemi',
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            items: const [
              DropdownMenuItem(value: 'single', child: Text('Tek')),
              DropdownMenuItem(value: 'split', child: Text('Çift')),
            ],
            onChanged: (value) {
              if (value == null) return;
              setState(() {
                _paymentMethod = value;
                _isInstallment = false;
                _installmentCountController.clear();
                _splitCashAmountController.clear();
                _splitCreditCardAmountController.clear();
                _selectedSplitCreditCardAccountId ??=
                    creditCardAccounts.isNotEmpty ? creditCardAccounts.first.id : null;
                _selectedSplitCashAccountId ??=
                    nonCreditCardAccounts.isNotEmpty ? nonCreditCardAccounts.first.id : null;
              });
            },
          ),
          const SizedBox(height: 12),
          if (_paymentMethod == 'single')
            DropdownButtonFormField<int>(
              initialValue: _selectedExpenseAccountId,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Ödeme Hesabı',
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              items: _accounts
                  .map(
                    (account) => DropdownMenuItem<int>(
                      value: account.id,
                      child: Text(
                        account.isCreditCard
                            ? '${account.name} (Kredi Kartı)'
                            : account.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedExpenseAccountId = value;
                  final account = _selectedSingleExpenseAccount();
                  if (account == null || !account.isCreditCard) {
                    _isInstallment = false;
                    _installmentCountController.clear();
                  }
                });
              },
              validator: (value) => value == null ? 'Hesap seçiniz.' : null,
            )
          else ...[
            DropdownButtonFormField<int>(
              initialValue: _selectedSplitCreditCardAccountId,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Kredi Kartı Hesabı',
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              items: creditCardAccounts
                  .map(
                    (account) => DropdownMenuItem<int>(
                      value: account.id,
                      child: Text(
                        '${account.name} (Kredi Kartı)',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedSplitCreditCardAccountId = value;
                });
              },
              validator: (value) => value == null ? 'Kredi kartı seçiniz.' : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              initialValue: _selectedSplitCashAccountId,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Nakit/Banka Hesabı',
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              items: nonCreditCardAccounts
                  .map(
                    (account) => DropdownMenuItem<int>(
                      value: account.id,
                      child: Text(
                        account.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedSplitCashAccountId = value;
                });
              },
              validator: (value) => value == null ? 'Nakit/banka hesabı seçiniz.' : null,
            ),
          ],
        ],
      );
    }

    return Column(
      children: [
        DropdownButtonFormField<int>(
          initialValue: _selectedIncomeAccountId,
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: 'Gelir Hesabı',
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          items: _accounts
              .map(
                (account) => DropdownMenuItem<int>(
                  value: account.id,
                  child: Text(
                    account.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
          onChanged: (value) {
            setState(() {
              _selectedIncomeAccountId = value;
            });
          },
          validator: (value) => value == null ? 'Hesap seçiniz.' : null,
        ),
      ],
    );
  }

  Widget _buildAttachmentSection() {
    final allCount = _existingAttachments.length + _attachments.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Resim Eki (opsiyonel)',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            FilledButton.tonalIcon(
              onPressed: _showAddAttachmentSheet,
              icon: const Icon(Icons.add_a_photo_outlined),
              label: const Text('Resim Ekle'),
            ),
          ],
        ),
        if (allCount > 0) ...[
          const SizedBox(height: 12),
          SizedBox(
            height: 92,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: allCount,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final isExisting = index < _existingAttachments.length;
                final bytes = isExisting
                    ? _existingAttachments[index]
                    : _attachments[index - _existingAttachments.length];
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.memory(
                        bytes,
                        width: 92,
                        height: 92,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            if (isExisting) {
                              _existingAttachments.removeAt(index);
                            } else {
                              _attachments.removeAt(
                                index - _existingAttachments.length,
                              );
                            }
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.60),
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(4),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}
