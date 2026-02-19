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
    final accounts = (await AccountService.getActiveAccounts())
        .where((a) => a.type != 'investment')
        .toList();
    if (!mounted) return;
    setState(() {
      _accounts = accounts;
      _fromAccountId = accounts.isNotEmpty ? accounts.first.id : null;
      _toAccountId = accounts.length > 1 ? accounts[1].id : null;
      _loading = false;
    });
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

  String _accountLabel(Account a, {required bool outgoing}) {
    final sign = outgoing ? '-' : '+';
    return '${a.name}  •  $sign ${_fmtAmount(a.balance)} TL';
  }

  Future<void> _save() async {
    if (_saving) return;
    if (!_formKey.currentState!.validate()) return;
    if (_fromAccountId == null || _toAccountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gönderen ve alan hesap seçiniz.')),
      );
      return;
    }
    if (_fromAccountId == _toAccountId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aynı hesaba transfer yapılamaz.')),
      );
      return;
    }

    final amount = TurkishMoneyInputFormatter.parse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Geçerli bir tutar giriniz.')),
      );
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
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Transfer kaydedilemedi: $e')),
      );
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
    return Scaffold(
      drawer: buildAppMenuDrawer(),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => popToDashboard(context),
        ),
        title: const Text('Transfer'),
        actions: [buildHomeAction(context)],
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
                          labelText: 'Gönderen Hesap (-)',
                          border: OutlineInputBorder(),
                        ),
                        isExpanded: true,
                        items: _accounts
                            .map(
                              (a) => DropdownMenuItem<int>(
                                value: a.id,
                                child: Text(
                                  _accountLabel(a, outgoing: true),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => _fromAccountId = v),
                        validator: (v) => v == null ? 'Hesap seçiniz.' : null,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<int>(
                        initialValue: _toAccountId,
                        decoration: const InputDecoration(
                          labelText: 'Alan Hesap (+)',
                          border: OutlineInputBorder(),
                        ),
                        isExpanded: true,
                        items: _accounts
                            .map(
                              (a) => DropdownMenuItem<int>(
                                value: a.id,
                                child: Text(
                                  _accountLabel(a, outgoing: false),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => _toAccountId = v),
                        validator: (v) => v == null ? 'Hesap seçiniz.' : null,
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
                        validator: (v) {
                          final parsed = TurkishMoneyInputFormatter.parse(v ?? '');
                          if (parsed == null || parsed <= 0) {
                            return 'Geçerli tutar giriniz.';
                          }
                          return null;
                        },
                      ),
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
                        inputFormatters: const [TurkishUpperCaseFormatter()],
                        decoration: const InputDecoration(
                          labelText: 'Açıklama (opsiyonel)',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _saving ? null : _save,
                        child: Text(_saving ? 'Kaydediliyor...' : 'Kaydet'),
                      ),
                    ],
                  ),
                ),
    );
  }
}
