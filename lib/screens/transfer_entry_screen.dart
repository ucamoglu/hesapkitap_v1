import 'package:flutter/material.dart';

import '../models/account.dart';
import '../services/account_service.dart';
import '../services/transfer_transaction_service.dart';
import '../utils/app_feedback.dart';
import '../utils/navigation_helpers.dart';
import '../utils/turkish_money_input_formatter.dart';
import '../utils/turkish_upper_case_formatter.dart';

class TransferEntryScreen extends StatefulWidget {
  const TransferEntryScreen({super.key});

  @override
  State<TransferEntryScreen> createState() => _TransferEntryScreenState();
}

class _TransferEntryScreenState extends State<TransferEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  List<Account> _accounts = [];
  int? _fromAccountId;
  int? _toAccountId;
  DateTime _selectedDate = DateTime.now();
  bool _loading = true;
  bool _saving = false;
  int? _initialFromAccountId;
  int? _initialToAccountId;
  DateTime? _initialDate;
  String _initialAmountText = '';
  String _initialDescriptionText = '';

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
    _descriptionController.dispose();
    super.dispose();
  }

  // Transfer formu icin aktif hesap listesini yukler.
  Future<void> _load() async {
    final accounts = await AccountService.getActiveCashflowAccounts();
    if (!mounted) return;
    setState(() {
      _accounts = accounts;
      _fromAccountId = accounts.isNotEmpty ? accounts.first.id : null;
      _toAccountId = accounts.length > 1 ? accounts[1].id : null;
      _initialFromAccountId = _fromAccountId;
      _initialToAccountId = _toAccountId;
      _initialDate = _selectedDate;
      _initialAmountText = _amountController.text;
      _initialDescriptionText = _descriptionController.text;
      _loading = false;
    });
  }

  // Transfer tarih secimini yonetir.
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

  String _fmtDate(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '$dd.$mm.${d.year}';
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

  String _accountLabel(Account a) {
    return '${a.name}  •  ${_fmtAmount(a.balance)} TL';
  }

  Account? _selectedFromAccount() {
    final id = _fromAccountId;
    if (id == null) return null;
    for (final account in _accounts) {
      if (account.id == id) return account;
    }
    return null;
  }

  Account? _selectedToAccount() {
    final id = _toAccountId;
    if (id == null) return null;
    for (final account in _accounts) {
      if (account.id == id) return account;
    }
    return null;
  }

  double? _liveAmount() {
    return TurkishMoneyInputFormatter.parse(_amountController.text);
  }

  String? _liveTransferWarning() {
    final fromAccount = _selectedFromAccount();
    final toAccount = _selectedToAccount();
    final amount = _liveAmount();
    if (fromAccount == null ||
        toAccount == null ||
        amount == null ||
        amount <= 0) {
      return null;
    }
    if (fromAccount.id == toAccount.id) {
      return 'Gönderen ve alan hesap aynı olamaz.';
    }
    if (fromAccount.balance + 1e-9 < amount) {
      return 'Gönderen hesap bakiyesi bu transfer için yetersiz.';
    }
    return null;
  }

  Widget _buildLiveSummary() {
    final fromAccount = _selectedFromAccount();
    final toAccount = _selectedToAccount();
    final amount = _liveAmount();
    if (fromAccount == null ||
        toAccount == null ||
        amount == null ||
        amount <= 0) {
      return const SizedBox.shrink();
    }

    final warning = _liveTransferWarning();
    final hasWarning = warning != null;
    final projectedFromBalance = fromAccount.balance - amount;
    final projectedToBalance = toAccount.balance + amount;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: hasWarning ? const Color(0xFFFFF4E5) : const Color(0xFFF4F8FF),
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
          Text('Transfer tutarı: ${_fmtAmount(amount)} TL'),
          Text(
            'Gönderen: ${_fmtAmount(fromAccount.balance)} TL '
            '→ ${_fmtAmount(projectedFromBalance)} TL',
          ),
          Text(
            'Alan: ${_fmtAmount(toAccount.balance)} TL '
            '→ ${_fmtAmount(projectedToBalance)} TL',
          ),
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
    return !_saving && _liveTransferWarning() == null;
  }

  bool _sameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _hasUnsavedChanges() {
    if (_loading) return false;
    return _fromAccountId != _initialFromAccountId ||
        _toAccountId != _initialToAccountId ||
        !_sameDay(_selectedDate, _initialDate ?? _selectedDate) ||
        _amountController.text.trim() != _initialAmountText.trim() ||
        _descriptionController.text.trim() != _initialDescriptionText.trim();
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

  // Kaynak ve hedef hesap arasinda transfer hareketi olusturur.
  Future<void> _save() async {
    if (_saving) return;
    if (!_formKey.currentState!.validate()) return;
    if (_fromAccountId == null || _toAccountId == null) {
      _showSnack('Gönderen ve alan hesap seçiniz.');
      return;
    }
    if (_fromAccountId == _toAccountId) {
      _showSnack('Aynı hesaba transfer yapılamaz.');
      return;
    }

    final amount = TurkishMoneyInputFormatter.parse(_amountController.text);
    if (amount == null || amount <= 0) {
      _showSnack('Geçerli bir tutar giriniz.');
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      await TransferTransactionService.addTransfer(
        fromAccountId: _fromAccountId!,
        toAccountId: _toAccountId!,
        amount: amount,
        date: _selectedDate,
        description: _descriptionController.text,
      );
      if (!mounted) return;
      AppFeedback.saved();
      Navigator.pop(context, true);
    } catch (e) {
      _showSnack('Transfer kaydedilemedi: $e');
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
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
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => _handleExit(toDashboard: true),
            ),
            title: const Text('Transfer'),
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
              : _accounts.length < 2
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'Transfer için en az iki aktif hesap olmalı.',
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
                            initialValue: _fromAccountId,
                            decoration: const InputDecoration(
                              labelText: 'Gönderen Hesap',
                              border: OutlineInputBorder(),
                            ),
                            isExpanded: true,
                            items: _accounts
                                .map(
                                  (a) => DropdownMenuItem<int>(
                                    value: a.id,
                                    child: Text(
                                      _accountLabel(a),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _fromAccountId = v),
                            validator: (v) =>
                                v == null ? 'Hesap seçiniz.' : null,
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<int>(
                            initialValue: _toAccountId,
                            decoration: const InputDecoration(
                              labelText: 'Alan Hesap',
                              border: OutlineInputBorder(),
                            ),
                            isExpanded: true,
                            items: _accounts
                                .map(
                                  (a) => DropdownMenuItem<int>(
                                    value: a.id,
                                    child: Text(
                                      _accountLabel(a),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) => setState(() => _toAccountId = v),
                            validator: (v) =>
                                v == null ? 'Hesap seçiniz.' : null,
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
                              labelText: 'Tutar (TL)',
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) {
                              final parsed =
                                  TurkishMoneyInputFormatter.parse(v ?? '');
                              if (parsed == null || parsed <= 0) {
                                return 'Geçerli tutar giriniz.';
                              }
                              return null;
                            },
                            onChanged: (_) => setState(() {}),
                          ),
                          const SizedBox(height: 10),
                          _buildLiveSummary(),
                          const SizedBox(height: 12),
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
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _descriptionController,
                            inputFormatters: const [
                              TurkishUpperCaseFormatter()
                            ],
                            decoration: const InputDecoration(
                              labelText: 'Açıklama (opsiyonel)',
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 2,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _canSubmit ? _save : null,
                            child: Text(_saving ? 'Kaydediliyor...' : 'Kaydet'),
                          ),
                        ],
                      ),
                    ),
        ));
  }
}
