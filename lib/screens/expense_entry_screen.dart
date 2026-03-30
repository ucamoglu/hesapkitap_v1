import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/account.dart';
import '../models/category.dart';
import '../models/credit_card_statement.dart';
import '../models/finance_transaction.dart';
import '../services/account_service.dart';
import '../services/category_service.dart';
import '../services/credit_card_installment_service.dart';
import '../services/credit_card_statement_service.dart';
import '../services/finance_transaction_service.dart';
import '../services/location_consent_service.dart';
import '../services/transaction_location_service.dart';
import '../services/transaction_attachment_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme_helpers.dart';
import '../utils/app_feedback.dart';
import '../utils/camera_support.dart';
import '../utils/navigation_helpers.dart';
import '../utils/turkish_money_input_formatter.dart';
import '../utils/turkish_upper_case_formatter.dart';

class ExpenseEntryScreen extends StatefulWidget {
  const ExpenseEntryScreen({
    super.key,
    this.initialTransaction,
  });

  final FinanceTransaction? initialTransaction;

  @override
  State<ExpenseEntryScreen> createState() => _ExpenseEntryScreenState();
}

class _ExpenseEntryScreenState extends State<ExpenseEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _installmentCountController = TextEditingController();
  final _imagePicker = ImagePicker();

  List<Account> _accounts = [];
  List<Category> _categories = [];
  List<CreditCardStatement> _creditCardStatements = [];

  int? _selectedAccountId;
  int? _selectedCategoryId;
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;
  bool _isLoading = true;
  final List<Uint8List> _attachments = [];
  final List<Uint8List> _existingAttachments = [];
  int _initialExistingAttachmentCount = 0;
  int? _initialAccountId;
  int? _initialCategoryId;
  DateTime? _initialDate;
  String _initialAmountText = '';
  String _initialDescriptionText = '';
  bool _isInstallment = false;
  bool _initialIsInstallment = false;
  String _initialInstallmentCountText = '';
  bool _hasExistingInstallments = false;

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
    _loadData();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _installmentCountController.dispose();
    super.dispose();
  }

  // Form icin hesaplari, kategorileri ve varsa mevcut ekleri yukler.
  Future<void> _loadData() async {
    await CategoryService.seedExpenseDefaultsIfEmpty();

    final accounts = await AccountService.getActiveExpenseAccounts();
    final categories = await CategoryService.getActiveManualExpenseCategories();
    final creditCardStatements = await CreditCardStatementService.getAll();

    if (!mounted) return;

    if (_isEditMode) {
      final tx = widget.initialTransaction!;
      final existing = await TransactionAttachmentService.getByOwner(
        ownerType: 'finance',
        ownerId: tx.id,
      );
      final hasInstallments =
          await CreditCardInstallmentService.hasInstallments(tx.id);
      _existingAttachments
        ..clear()
        ..addAll(existing.map((e) => Uint8List.fromList(e.imageBytes)));
      _initialExistingAttachmentCount = _existingAttachments.length;
      _hasExistingInstallments = hasInstallments;
    }

    setState(() {
      _accounts = accounts;
      _categories = categories;
      _creditCardStatements = creditCardStatements;
      if (_isEditMode) {
        final tx = widget.initialTransaction!;
        _selectedAccountId = accounts.any((a) => a.id == tx.accountId)
            ? tx.accountId
            : (accounts.isNotEmpty ? accounts.first.id : null);
        _selectedCategoryId = tx.categoryId;
        _selectedDate = tx.date;
        _amountController.text = _fmtAmount(tx.amount);
        _descriptionController.text = tx.description ?? '';
        _isInstallment = _hasExistingInstallments;
      } else {
        _selectedAccountId = accounts.isNotEmpty ? accounts.first.id : null;
        _selectedCategoryId =
            categories.isNotEmpty ? categories.first.id : null;
      }
      _initialAccountId = _selectedAccountId;
      _initialCategoryId = _selectedCategoryId;
      _initialDate = _selectedDate;
      _initialAmountText = _amountController.text;
      _initialDescriptionText = _descriptionController.text;
      _initialIsInstallment = _isInstallment;
      _initialInstallmentCountText = _installmentCountController.text;
      _isLoading = false;
    });
  }

  // Gider hareketinin tarih secimini yonetir.
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

  // Yeni gider ekler veya var olan gideri duzenler.
  Future<void> _save() async {
    if (_isSaving) return;
    if (!_formKey.currentState!.validate()) return;
    if (_selectedAccountId == null || _selectedCategoryId == null) {
      _showSnack('Hesap ve kategori seçiniz.');
      return;
    }

    final amount = TurkishMoneyInputFormatter.parse(_amountController.text);
    if (amount == null || amount <= 0) {
      _showSnack("Geçerli bir tutar giriniz.");
      return;
    }
    final account = _selectedAccount();
    final installmentCount = int.tryParse(_installmentCountController.text);
    if (_isEditMode && _hasExistingInstallments) {
      _showSnack(
          'Taksitli kredi kartı giderlerinde düzenleme henüz desteklenmiyor.');
      return;
    }
    if (_isInstallment && (account == null || !account.isCreditCard)) {
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

    setState(() {
      _isSaving = true;
    });

    try {
      final location = await _resolveLocationForSave();
      if (_isEditMode) {
        final tx = widget.initialTransaction!;
        await FinanceTransactionService.updateTransaction(
          transactionId: tx.id,
          accountId: _selectedAccountId!,
          categoryId: _selectedCategoryId!,
          type: 'expense',
          amount: amount,
          date: _selectedDate,
          latitude: location?.latitude,
          longitude: location?.longitude,
          description: _descriptionController.text,
          incomePlanId: null,
          expensePlanId: tx.expensePlanId,
        );
        await TransactionAttachmentService.replaceAll(
          ownerType: 'finance',
          ownerId: tx.id,
          images: [
            ..._existingAttachments.map((e) => e.toList()),
            ..._attachments.map((e) => e.toList()),
          ],
        );
      } else {
        final txId = await FinanceTransactionService.addExpenseAndGetId(
          accountId: _selectedAccountId!,
          categoryId: _selectedCategoryId!,
          amount: amount,
          date: _selectedDate,
          latitude: location?.latitude,
          longitude: location?.longitude,
          description: _descriptionController.text,
          syncCreditCardStatement: !_isInstallment,
        );
        if (_isInstallment && account != null) {
          await CreditCardInstallmentService.createInstallmentsForExpense(
            financeTransactionId: txId,
            creditCardAccount: account,
            transactionDate: _selectedDate,
            totalAmount: amount,
            installmentCount: installmentCount!,
          );
        }
        await TransactionAttachmentService.addMany(
          ownerType: 'finance',
          ownerId: txId,
          images: _attachments.map((e) => e.toList()).toList(),
        );
      }

      if (!mounted) return;
      _isEditMode ? AppFeedback.updated() : AppFeedback.saved();
      Navigator.pop(context, true);
    } catch (e) {
      _showSnack("Gider kaydedilemedi: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
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
            'İstersen işlemler kaydedilirken bulunduğun konum otomatik ilişkilendirilebilir. Bu özellik daha sonra harita üzerinde harcamaları göstermemize yardımcı olur.',
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

  // Edit modundaki gider hareketini geri sararak siler.
  Future<void> _deleteCurrent() async {
    if (!_isEditMode || _isSaving) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('İşlemi Sil'),
        content: const Text('Bu gider işlemi silinsin mi?'),
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
      _isSaving = true;
    });
    try {
      await FinanceTransactionService.deleteAndReturn(
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
          _isSaving = false;
        });
      }
    }
  }

  String _fmtAmount(double value) {
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

  String _fmtDate(DateTime d) {
    final day = d.day.toString().padLeft(2, '0');
    final month = d.month.toString().padLeft(2, '0');
    return "$day.$month.${d.year}";
  }

  Account? _selectedAccount() {
    final id = _selectedAccountId;
    if (id == null) return null;
    for (final account in _accounts) {
      if (account.id == id) return account;
    }
    return null;
  }

  double? _liveAmount() {
    return TurkishMoneyInputFormatter.parse(_amountController.text);
  }

  String? _liveBalanceWarning() {
    final account = _selectedAccount();
    final amount = _liveAmount();
    if (account == null || amount == null || amount <= 0) {
      return null;
    }
    if (account.isCreditCard) {
      return null;
    }
    if (!account.canWithdraw(amount)) {
      return 'Bu gider mevcut hesap bakiyesini aşıyor.';
    }
    return null;
  }

  bool get _supportsInstallment {
    final account = _selectedAccount();
    return !_isEditMode && account != null && account.isCreditCard;
  }

  List<CreditCardInstallmentPreview> _liveInstallmentPreview() {
    final account = _selectedAccount();
    final amount = _liveAmount();
    final installmentCount = int.tryParse(_installmentCountController.text);
    if (!_isInstallment ||
        account == null ||
        !account.isCreditCard ||
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

    final account = _selectedAccount();
    if (account == null) return total;

    try {
      final cycle = CreditCardStatementService.resolveCycle(
        creditCardAccount: account,
        transactionDate: _selectedDate,
      );
      if (_sameMonth(cycle.statementDate, referenceMonth)) {
        total += amount;
      }
    } catch (_) {
      // Ignore cycle preview failures in the live summary.
    }

    return total;
  }

  Widget _buildLiveSummary() {
    final account = _selectedAccount();
    final amount = _liveAmount();
    if (account == null || amount == null || amount <= 0) {
      return const SizedBox.shrink();
    }

    final projectedBalance = account.balance - amount;
    final warning = _liveBalanceWarning();
    final hasWarning = warning != null;
    final isCreditCard = account.isCreditCard;
    final currentCardDebt = account.balance.abs();
    final projectedCardDebt = projectedBalance.abs();
    final installmentPreview = _liveInstallmentPreview();
    final firstInstallment =
        installmentPreview.isNotEmpty ? installmentPreview.first : null;
    final lastInstallment =
        installmentPreview.isNotEmpty ? installmentPreview.last : null;
    final projectedCurrentMonthCardPayment =
        _projectedCurrentMonthCardPaymentTotal(
      referenceMonth: _selectedDate,
      isCreditCard: isCreditCard,
      amount: amount,
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
          Text('Gider tutarı: ${_fmtAmount(amount)} TL'),
          Text(isCreditCard
              ? 'Kart borcu: ${_fmtAmount(currentCardDebt)} TL '
                  '→ ${_fmtAmount(projectedCardDebt)} TL'
              : 'Hesap bakiyesi: ${_fmtAmount(account.balance)} TL '
                  '→ ${_fmtAmount(projectedBalance)} TL'),
          if (!isCreditCard && account.effectiveOverdraftLimit > 0)
            Text(
              'Ek hesap limiti: ${_fmtAmount(account.effectiveOverdraftLimit)} TL',
            ),
          if (isCreditCard)
            const Text(
              'Bu işlem ilgili hesap ekstresine borç olarak yansıtılacaktır.',
            ),
          if (isCreditCard) ...[
            const SizedBox(height: 8),
            Text(
              'Bu ayki toplam kart ödemeniz ${_fmtAmount(projectedCurrentMonthCardPayment)} TL olacaktır.',
              style: const TextStyle(
                color: AppColors.expense,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          if (firstInstallment != null) ...[
            const SizedBox(height: 8),
            Text(
              'Taksit Planı: ${firstInstallment.installmentCount} taksit • '
              'İlk taksit ${_fmtAmount(firstInstallment.amount)} TL',
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
    return !_isSaving && _liveBalanceWarning() == null;
  }

  // Gider kaydina eklenecek gorseli gecici ek listesine koyar.
  Future<void> _pickAttachment(ImageSource source) async {
    try {
      if (source == ImageSource.camera && !isCameraSourceAvailable()) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kamera bu platformda desteklenmiyor.')),
        );
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
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Resim eklenemedi: $e')),
      );
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

  bool _sameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _hasUnsavedChanges() {
    if (_isLoading) return false;
    return _selectedAccountId != _initialAccountId ||
        _selectedCategoryId != _initialCategoryId ||
        !_sameDay(_selectedDate, _initialDate ?? _selectedDate) ||
        _amountController.text.trim() != _initialAmountText.trim() ||
        _descriptionController.text.trim() != _initialDescriptionText.trim() ||
        _isInstallment != _initialIsInstallment ||
        _installmentCountController.text.trim() !=
            _initialInstallmentCountText.trim() ||
        _existingAttachments.length != _initialExistingAttachmentCount ||
        _attachments.isNotEmpty;
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

  @override
  Widget build(BuildContext context) {
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
                ? buildBackAction(
                    context,
                    onPressed: () => _handleExit(toDashboard: false),
                  )
                : buildBackAction(
                    context,
                    onPressed: () => _handleExit(toDashboard: true),
                  ),
            title: Text(_isEditMode ? "Gider Düzenle" : "Gider Girişi"),
            actions: [buildHomeAction(context)],
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : (_accounts.isEmpty || _categories.isEmpty)
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          "Gider girişi için en az bir hesap ve aktif gider kategorisi olmalı.",
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : Form(
                      key: _formKey,
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          DropdownButtonFormField<int>(
                            initialValue: _selectedAccountId,
                            decoration: const InputDecoration(
                              labelText: "Hesap",
                              border: OutlineInputBorder(),
                            ),
                            items: _accounts
                                .map(
                                  (a) => DropdownMenuItem<int>(
                                    value: a.id,
                                    child: Text(
                                      a.isCreditCard
                                          ? '${a.name} (Kredi Kartı)'
                                          : a.name,
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedAccountId = value;
                                final account = _selectedAccount();
                                if (account == null || !account.isCreditCard) {
                                  _isInstallment = false;
                                  _installmentCountController.clear();
                                }
                              });
                            },
                            validator: (value) =>
                                value == null ? "Hesap seçiniz." : null,
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<int>(
                            initialValue: _selectedCategoryId,
                            decoration: const InputDecoration(
                              labelText: "Gider Kategorisi",
                              border: OutlineInputBorder(),
                            ),
                            items: _categories
                                .map(
                                  (c) => DropdownMenuItem<int>(
                                    value: c.id,
                                    child: Text(c.name),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedCategoryId = value;
                              });
                            },
                            validator: (value) => value == null
                                ? "Gider kategorisi seçiniz."
                                : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _amountController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: const [
                              TurkishMoneyInputFormatter()
                            ],
                            decoration: const InputDecoration(
                              labelText: "Tutar (TL)",
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              final parsed =
                                  TurkishMoneyInputFormatter.parse(value ?? "");
                              if (parsed == null || parsed <= 0) {
                                return "Geçerli bir tutar giriniz.";
                              }
                              return null;
                            },
                            onChanged: (_) => setState(() {}),
                          ),
                          if (_supportsInstallment) ...[
                            const SizedBox(height: 12),
                            CheckboxListTile(
                              value: _isInstallment,
                              contentPadding: EdgeInsets.zero,
                              title: const Text('Taksitli işlem'),
                              subtitle: const Text(
                                'Bu gider kredi kartı ekstrelere taksitli olarak dağıtılsın.',
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
                                  border: OutlineInputBorder(),
                                  hintText: '2-24',
                                ),
                                onChanged: (_) => setState(() {}),
                              ),
                            ],
                          ],
                          if (_isEditMode && _hasExistingInstallments)
                            const Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: Text(
                                'Bu kayıt taksitli kredi kartı gideridir. Düzenleme bu aşamada kapalı tutuldu.',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          const SizedBox(height: 10),
                          _buildLiveSummary(),
                          const SizedBox(height: 12),
                          InkWell(
                            onTap: _pickDate,
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: "Tarih",
                                border: OutlineInputBorder(),
                              ),
                              child: Text(_fmtDate(_selectedDate)),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _descriptionController,
                            textCapitalization: TextCapitalization.words,
                            inputFormatters: const [
                              TurkishUpperCaseFormatter()
                            ],
                            maxLines: 2,
                            decoration: const InputDecoration(
                              labelText: "Açıklama (opsiyonel)",
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Text(
                                'Resim Eki (opsiyonel)',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              const Spacer(),
                              TextButton.icon(
                                onPressed: _showAddAttachmentSheet,
                                icon: const Icon(
                                    Icons.add_photo_alternate_outlined),
                                label: const Text('Resim Ekle'),
                              ),
                            ],
                          ),
                          if (_existingAttachments.isNotEmpty ||
                              _attachments.isNotEmpty)
                            SizedBox(
                              height: 78,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: _existingAttachments.length +
                                    _attachments.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(width: 8),
                                itemBuilder: (context, index) {
                                  final isExisting =
                                      index < _existingAttachments.length;
                                  final bytes = isExisting
                                      ? _existingAttachments[index]
                                      : _attachments[
                                          index - _existingAttachments.length];
                                  return Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.memory(
                                          bytes,
                                          width: 78,
                                          height: 78,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Positioned(
                                        top: 0,
                                        right: 0,
                                        child: InkWell(
                                          onTap: () {
                                            setState(() {
                                              if (isExisting) {
                                                _existingAttachments
                                                    .removeAt(index);
                                              } else {
                                                _attachments.removeAt(
                                                  index -
                                                      _existingAttachments
                                                          .length,
                                                );
                                              }
                                            });
                                          },
                                          child: Container(
                                            decoration: const BoxDecoration(
                                              color: Colors.black54,
                                              shape: BoxShape.circle,
                                            ),
                                            padding: const EdgeInsets.all(2),
                                            child: const Icon(
                                              Icons.close,
                                              color: Colors.white,
                                              size: 14,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.expense,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: _canSubmit ? _save : null,
                            child: Text(
                              _isSaving
                                  ? "Kaydediliyor..."
                                  : (_isEditMode ? "Güncelle" : "Kaydet"),
                            ),
                          ),
                          if (_isEditMode) ...[
                            const SizedBox(height: 10),
                            OutlinedButton(
                              onPressed: _isSaving ? null : _deleteCurrent,
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
