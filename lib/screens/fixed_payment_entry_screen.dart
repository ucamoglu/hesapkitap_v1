import 'package:flutter/material.dart';

import '../models/account.dart';
import '../models/category.dart';
import '../models/finance_transaction.dart';
import '../models/subscription_definition.dart';
import '../services/account_service.dart';
import '../services/category_service.dart';
import '../services/finance_transaction_service.dart';
import '../services/subscription_definition_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme_helpers.dart';
import '../utils/app_feedback.dart';
import '../utils/navigation_helpers.dart';
import '../utils/turkish_money_input_formatter.dart';
import '../utils/turkish_upper_case_formatter.dart';

class FixedPaymentEntryScreen extends StatefulWidget {
  const FixedPaymentEntryScreen({super.key});

  @override
  State<FixedPaymentEntryScreen> createState() => _FixedPaymentEntryScreenState();
}

class _FixedPaymentEntryScreenState extends State<FixedPaymentEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  List<SubscriptionDefinition> _allPayments = [];
  List<SubscriptionDefinition> _payments = [];
  List<Account> _accounts = [];
  List<Category> _categories = [];
  List<FinanceTransaction> _paymentTransactions = [];
  bool _isLoading = true;
  bool _isSaving = false;

  int? _selectedPaymentId;
  int? _selectedAccountId;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final results = await Future.wait([
      SubscriptionDefinitionService.getAll(),
      AccountService.getActiveExpenseAccounts(),
      CategoryService.getAllExpenseCategories(),
      FinanceTransactionService.getAll(),
    ]);
    if (!mounted) return;

    final allPayments = (results[0] as List<SubscriptionDefinition>)
        .where((item) => item.isActive)
        .toList();
    final accounts = results[1] as List<Account>;
    final categories = results[2] as List<Category>;
    final paymentTransactions = (results[3] as List<FinanceTransaction>)
        .where((tx) => tx.type == 'expense' && (tx.expensePlanId ?? 0) < 0)
        .toList();

    setState(() {
      _allPayments = allPayments;
      _accounts = accounts;
      _categories = categories;
      _paymentTransactions = paymentTransactions;
      _isLoading = false;
    });
    _refreshAvailablePayments();
  }

  int _subscriptionMarker(int subscriptionId) => -subscriptionId;

  bool _isPaymentPaidInSelectedPeriod(SubscriptionDefinition item) {
    final marker = _subscriptionMarker(item.id);
    for (final tx in _paymentTransactions) {
      if (tx.expensePlanId != marker) continue;
      if (item.duePeriod == 'yearly') {
        if (tx.date.year == _selectedDate.year) {
          return true;
        }
        continue;
      }
      if (tx.date.year == _selectedDate.year &&
          tx.date.month == _selectedDate.month) {
        return true;
      }
    }
    return false;
  }

  void _refreshAvailablePayments() {
    final payments = _allPayments
        .where((item) => !_isPaymentPaidInSelectedPeriod(item))
        .toList();

    int? selectedPaymentId = _selectedPaymentId;
    int? selectedAccountId;
    if (payments.isNotEmpty) {
      final selectedStillExists = selectedPaymentId != null &&
          payments.any((payment) => payment.id == selectedPaymentId);
      if (!selectedStillExists) {
        selectedPaymentId = payments.first.id;
      }
      final payment = payments.firstWhere((p) => p.id == selectedPaymentId);
      if (payment.paymentAccountId != null &&
          _accounts.any((a) => a.id == payment.paymentAccountId)) {
        selectedAccountId = payment.paymentAccountId;
      } else if (_accounts.isNotEmpty) {
        selectedAccountId = _accounts.first.id;
      }
      if (payment.paymentType == 'fixed' && payment.defaultAmount != null) {
        _amountController.text = _fmtAmount(payment.defaultAmount!);
      }
      _descriptionController.text = _defaultDescription(payment);
    } else {
      selectedPaymentId = null;
      _amountController.clear();
      _descriptionController.clear();
    }

    setState(() {
      _payments = payments;
      _selectedPaymentId = selectedPaymentId;
      _selectedAccountId = selectedAccountId ?? _selectedAccountId;
    });
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
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
    return '$day.$month.${d.year}';
  }

  SubscriptionDefinition? _selectedPayment() {
    final id = _selectedPaymentId;
    if (id == null) return null;
    for (final item in _payments) {
      if (item.id == id) return item;
    }
    return null;
  }

  Account? _selectedAccount() {
    final id = _selectedAccountId;
    if (id == null) return null;
    for (final item in _accounts) {
      if (item.id == id) return item;
    }
    return null;
  }

  String? _categoryName(int? id) {
    if (id == null) return null;
    for (final item in _categories) {
      if (item.id == id) return item.name;
    }
    return null;
  }

  String _defaultDescription(SubscriptionDefinition item) {
    final provider = item.providerName.trim();
    if (provider.isEmpty) return 'SABIT ODEME: ${item.name}';
    return 'SABIT ODEME: ${item.name} - $provider';
  }

  void _applyPaymentSelection(SubscriptionDefinition item) {
    if (item.paymentAccountId != null &&
        _accounts.any((a) => a.id == item.paymentAccountId)) {
      _selectedAccountId = item.paymentAccountId;
    } else if (_selectedAccountId == null && _accounts.isNotEmpty) {
      _selectedAccountId = _accounts.first.id;
    }

    if (item.paymentType == 'fixed' && item.defaultAmount != null) {
      _amountController.text = _fmtAmount(item.defaultAmount!);
    } else if (item.paymentType == 'variable') {
      _amountController.clear();
    }

    _descriptionController.text = _defaultDescription(item);
  }

  String? _liveBalanceWarning() {
    final account = _selectedAccount();
    final amount = TurkishMoneyInputFormatter.parse(_amountController.text);
    if (account == null || amount == null || amount <= 0) {
      return null;
    }
    if (account.isCreditCard) {
      return null;
    }
    if (!account.canWithdraw(amount)) {
      return 'Bu odeme mevcut hesap bakiyesini asiyor.';
    }
    return null;
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
    if (_isSaving) return;
    if (!_formKey.currentState!.validate()) return;

    final payment = _selectedPayment();
    if (payment == null) {
      _showSnack('Sabit odeme seciniz.');
      return;
    }
    if (_selectedAccountId == null) {
      _showSnack('Odeme hesabi seciniz.');
      return;
    }
    if (payment.defaultExpenseCategoryId == null) {
      _showSnack(
        'Bu sabit odeme icin varsayilan gider kategorisi tanimlanmamis.',
      );
      return;
    }

    final amount = TurkishMoneyInputFormatter.parse(_amountController.text);
    if (amount == null || amount <= 0) {
      _showSnack('Gecerli bir tutar giriniz.');
      return;
    }
    if (_isPaymentPaidInSelectedPeriod(payment)) {
      final periodLabel = payment.duePeriod == 'yearly'
          ? '${_selectedDate.year}'
          : '${_selectedDate.month.toString().padLeft(2, '0')}.${_selectedDate.year}';
      _showSnack('Bu sabit odeme $periodLabel donemi icin zaten kaydedildi.');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await FinanceTransactionService.addExpenseAndGetId(
        accountId: _selectedAccountId!,
        categoryId: payment.defaultExpenseCategoryId!,
        amount: amount,
        date: _selectedDate,
        description: _descriptionController.text,
        expensePlanId: _subscriptionMarker(payment.id),
      );
      if (!mounted) return;
      AppFeedback.saved();
      Navigator.pop(context, true);
    } catch (e) {
      _showSnack('Odeme kaydedilemedi: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      drawer: buildAppMenuDrawer(),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => popToDashboard(context),
        ),
        title: const Text('Fatura Ode'),
        actions: [
          IconButton(
            icon: const Icon(Icons.home_outlined),
            tooltip: 'Ana Ekran',
            onPressed: () => popToDashboard(context),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : (_payments.isEmpty || _accounts.isEmpty)
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      _payments.isEmpty
                          ? 'Fatura odemek icin once en az bir sabit odeme tanimlayin.'
                          : 'Fatura odemek icin en az bir aktif odeme hesabi olmali.',
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
                        initialValue: _selectedPaymentId,
                        decoration: const InputDecoration(
                          labelText: 'Sabit Odeme',
                          border: OutlineInputBorder(),
                        ),
                        items: _payments
                            .map(
                              (item) => DropdownMenuItem<int>(
                                value: item.id,
                                child: Text(item.name),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          final item = _payments.firstWhere((e) => e.id == value);
                          setState(() {
                            _selectedPaymentId = value;
                            _applyPaymentSelection(item);
                          });
                        },
                        validator: (value) =>
                            value == null ? 'Sabit odeme seciniz.' : null,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<int>(
                        initialValue: _selectedAccountId,
                        decoration: const InputDecoration(
                          labelText: 'Odeme Hesabi',
                          border: OutlineInputBorder(),
                        ),
                        items: _accounts
                            .map(
                              (item) => DropdownMenuItem<int>(
                                value: item.id,
                                child: Text(
                                  item.isCreditCard
                                      ? '${item.name} (Kredi Karti)'
                                      : item.name,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedAccountId = value;
                          });
                        },
                        validator: (value) =>
                            value == null ? 'Odeme hesabi seciniz.' : null,
                      ),
                      const SizedBox(height: 12),
                      Builder(
                        builder: (context) {
                          final payment = _selectedPayment();
                          final categoryName =
                              _categoryName(payment?.defaultExpenseCategoryId);
                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: context.surfaceDecoration(
                              accent: colorScheme.primary,
                              fillColor: colorScheme.primary.withValues(alpha: 0.08),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  payment == null
                                      ? '-'
                                      : 'Saglayici: ${payment.providerName}',
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  categoryName == null
                                      ? 'Varsayilan kategori tanimli degil'
                                      : 'Gider kategorisi: $categoryName',
                                  style: TextStyle(
                                    color: categoryName == null
                                        ? AppColors.expense
                                        : colorScheme.onSurface,
                                  ),
                                ),
                                if (payment?.paymentType == 'fixed' &&
                                    payment?.defaultAmount != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    'Varsayilan tutar: ${_fmtAmount(payment!.defaultAmount!)} TL',
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: const [TurkishMoneyInputFormatter()],
                        decoration: const InputDecoration(
                          labelText: 'Tutar (TL)',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          final parsed =
                              TurkishMoneyInputFormatter.parse(value ?? '');
                          if (parsed == null || parsed <= 0) {
                            return 'Gecerli bir tutar giriniz.';
                          }
                          return null;
                        },
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 10),
                      Builder(
                        builder: (_) {
                          final warning = _liveBalanceWarning();
                          if (warning == null) return const SizedBox.shrink();
                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: context.surfaceDecoration(
                              accent: Colors.orange,
                              fillColor: Colors.orange.withValues(alpha: 0.12),
                            ),
                            child: Text(
                              warning,
                              style: const TextStyle(
                                color: Color(0xFF8A4B00),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      InkWell(
                        onTap: () async {
                          await _pickDate();
                          if (!mounted) return;
                          _refreshAvailablePayments();
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Tarih',
                            border: OutlineInputBorder(),
                          ),
                          child: Text(_fmtDate(_selectedDate)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (_payments.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: context.surfaceDecoration(
                            accent: Colors.green,
                            fillColor: Colors.green.withValues(alpha: 0.10),
                          ),
                          child: Text(
                            'Secili donem icin odeme bekleyen sabit fatura bulunmuyor.',
                            style: TextStyle(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      if (_payments.isNotEmpty) const SizedBox(height: 12),
                      TextFormField(
                        controller: _descriptionController,
                        textCapitalization: TextCapitalization.words,
                        inputFormatters: const [TurkishUpperCaseFormatter()],
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Aciklama (opsiyonel)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed:
                            _isSaving ||
                                    _liveBalanceWarning() != null ||
                                    _payments.isEmpty
                                ? null
                                : _save,
                        icon: const Icon(Icons.payments_outlined),
                        label: Text(_isSaving ? 'Kaydediliyor...' : 'Odemeyi Kaydet'),
                      ),
                    ],
                  ),
                ),
    );
  }
}
