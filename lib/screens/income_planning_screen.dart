import 'package:flutter/material.dart';

import '../models/account.dart';
import '../models/income_category.dart';
import '../models/income_plan.dart';
import '../services/account_service.dart';
import '../services/income_category_service.dart';
import '../services/income_plan_service.dart';
import '../theme/app_colors.dart';
import '../utils/navigation_helpers.dart';
import '../utils/planning_standard.dart';
import '../utils/turkish_money_input_formatter.dart';
import '../utils/turkish_upper_case_formatter.dart';

class IncomePlanningScreen extends StatefulWidget {
  const IncomePlanningScreen({super.key});

  @override
  State<IncomePlanningScreen> createState() => _IncomePlanningScreenState();
}

class _IncomePlanningScreenState extends State<IncomePlanningScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descController = TextEditingController();

  bool _loading = true;
  bool _saving = false;
  bool _askingDue = false;
  bool _dueCheckDone = false;
  bool _formExpanded = true;

  List<Account> _accounts = [];
  List<IncomeCategory> _categories = [];
  List<IncomePlan> _plans = [];

  int? _selectedAccountId;
  int? _selectedCategoryId;
  String _periodType = 'monthly';
  int _frequency = 1;
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _load(checkDue: true);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _load({bool checkDue = false}) async {
    setState(() => _loading = true);

    await IncomeCategoryService.seedDefaultsIfEmpty();

    final accounts = await AccountService.getActiveAccounts();
    final categories = await IncomeCategoryService.getActiveManual();
    final plans = await IncomePlanService.getAll();

    if (!mounted) return;
    setState(() {
      _accounts = accounts;
      _categories = categories;
      _plans = plans;
      _selectedAccountId = accounts.isNotEmpty
          ? (_selectedAccountId ?? accounts.first.id)
          : null;
      _selectedCategoryId = categories.isNotEmpty
          ? (_selectedCategoryId ?? categories.first.id)
          : null;
      _loading = false;
    });

    if (checkDue && !_dueCheckDone) {
      _dueCheckDone = true;
      _checkDuePlans();
    }
  }

  Future<void> _checkDuePlans() async {
    if (_askingDue) return;

    final due = await IncomePlanService.getDuePlans(DateTime.now());
    if (!mounted || due.isEmpty) return;

    _askingDue = true;
    try {
      for (final plan in due) {
        if (!mounted) break;
        await _askForDuePlan(plan);
      }
    } finally {
      _askingDue = false;
      if (mounted) {
        await _load();
      }
    }
  }

  Future<void> _askForDuePlan(IncomePlan plan) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Gelir Planı Hatırlatma'),
          content: Text(
            '"${_categoryName(plan.incomeCategoryId)}" planı bugün için bekliyor.\n'
            'Tutar: ${_fmtAmount(plan.amount)} TL\n'
            'Hesap: ${_accountName(plan.accountId)}\n\n'
            'Bu gelir gerçekleşti mi?',
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: ctx,
                  initialDate: DateTime.now().add(const Duration(days: 1)),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked == null) return;
                await IncomePlanService.postpone(plan, picked);
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Şu tarihe ertele'),
            ),
            TextButton(
              onPressed: () async {
                await IncomePlanService.cancel(plan);
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('İptal Et'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.income,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                await IncomePlanService.markCompleted(plan);
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Evet, Gerçekleşti'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickDate({required bool start}) async {
    final current = start ? _startDate : _endDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() {
      if (start) {
        _startDate = picked;
        if (_endDate != null && _endDate!.isBefore(_startDate)) {
          _endDate = _startDate;
        }
      } else {
        _endDate = picked;
      }
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

  String _periodLabel(String v) {
    return PlanningStandard.periodLabel(v);
  }

  String _accountName(int id) {
    for (final a in _accounts) {
      if (a.id == id) return a.name;
    }
    return 'Hesap #$id';
  }

  String _categoryName(int id) {
    for (final c in _categories) {
      if (c.id == id) return c.name;
    }
    return 'Kategori #$id';
  }

  Future<void> _savePlan() async {
    if (_saving) return;
    if (!_formKey.currentState!.validate()) return;
    if (_selectedAccountId == null || _selectedCategoryId == null) return;

    final amount = TurkishMoneyInputFormatter.parse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Geçerli bir tutar giriniz.')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final plan = IncomePlan()
        ..accountId = _selectedAccountId!
        ..incomeCategoryId = _selectedCategoryId!
        ..amount = amount
        ..description = _descController.text.trim().isEmpty ? null : _descController.text.trim()
        ..periodType = _periodType
        ..frequency = _frequency
        ..startDate = DateTime(_startDate.year, _startDate.month, _startDate.day)
        ..endDate = _endDate == null
            ? null
            : DateTime(_endDate!.year, _endDate!.month, _endDate!.day)
        ..nextDueDate = DateTime(_startDate.year, _startDate.month, _startDate.day)
        ..isActive = true
        ..createdAt = DateTime.now();

      await IncomePlanService.save(plan);
      if (!mounted) return;

      _amountController.clear();
      _descController.clear();
      _frequency = 1;
      _periodType = 'monthly';
      _startDate = DateTime.now();
      _endDate = null;

      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gelir planı kaydedildi.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kayıt hatası: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: buildAppMenuDrawer(),
      appBar: AppBar(
        leading: buildMenuLeading(),
        title: const Text('Gelir Planlama'),
        actions: [
          IconButton(
            onPressed: _load,
            icon: const Icon(Icons.refresh),
          ),
          buildHomeAction(context),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : (_accounts.isEmpty || _categories.isEmpty)
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Planlama için en az bir aktif hesap ve aktif gelir tipi gerekli.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(12),
                  children: [
                    Card(
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.tune),
                            title: const Text(
                              'Yeni Gelir Planı',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                            trailing: Icon(
                              _formExpanded
                                  ? Icons.expand_less
                                  : Icons.expand_more,
                            ),
                            onTap: () {
                              setState(() {
                                _formExpanded = !_formExpanded;
                              });
                            },
                          ),
                          if (_formExpanded)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                              DropdownButtonFormField<int>(
                                initialValue: _selectedCategoryId,
                                decoration: const InputDecoration(
                                  labelText: 'Gelir Tipi',
                                ),
                                items: _categories
                                    .map(
                                      (c) => DropdownMenuItem<int>(
                                        value: c.id,
                                        child: Text(c.name),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (v) => setState(() => _selectedCategoryId = v),
                                validator: (v) => v == null ? 'Gelir tipi seçiniz.' : null,
                              ),
                              const SizedBox(height: 10),
                              DropdownButtonFormField<int>(
                                initialValue: _selectedAccountId,
                                decoration: const InputDecoration(
                                  labelText: 'Hangi Hesaba Gelecek',
                                ),
                                items: _accounts
                                    .map(
                                      (a) => DropdownMenuItem<int>(
                                        value: a.id,
                                        child: Text(a.name),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (v) => setState(() => _selectedAccountId = v),
                                validator: (v) => v == null ? 'Hesap seçiniz.' : null,
                              ),
                              const SizedBox(height: 10),
                              TextFormField(
                                controller: _amountController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                inputFormatters: const [TurkishMoneyInputFormatter()],
                                decoration: const InputDecoration(labelText: 'Tutar (TL)'),
                                validator: (v) {
                                  final p = TurkishMoneyInputFormatter.parse(v ?? '');
                                  if (p == null || p <= 0) return 'Geçerli tutar giriniz.';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      initialValue: _periodType,
                                      decoration: const InputDecoration(
                                        labelText: 'Plan Dönemi',
                                      ),
                                      items: PlanningStandard.periodItems(),
                                      onChanged: (v) {
                                        if (v == null) return;
                                        setState(() => _periodType = v);
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: DropdownButtonFormField<int>(
                                      initialValue: _frequency,
                                      decoration: const InputDecoration(
                                        labelText: 'Sıklık',
                                      ),
                                      items: PlanningStandard.frequencyItems(),
                                      onChanged: (v) {
                                        if (v == null) return;
                                        setState(() => _frequency = v);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: InkWell(
                                      onTap: () => _pickDate(start: true),
                                      child: InputDecorator(
                                        decoration: const InputDecoration(labelText: 'Başlama'),
                                        child: Text(_fmtDate(_startDate)),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: InkWell(
                                      onTap: () => _pickDate(start: false),
                                      child: InputDecorator(
                                        decoration: const InputDecoration(labelText: 'Bitiş (opsiyonel)'),
                                        child: Text(_endDate == null ? '-' : _fmtDate(_endDate!)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              TextFormField(
                                controller: _descController,
                                textCapitalization: TextCapitalization.words,
                                inputFormatters: const [TurkishUpperCaseFormatter()],
                                maxLines: 2,
                                decoration: const InputDecoration(
                                  labelText: 'Açıklama (opsiyonel)',
                                ),
                              ),
                              const SizedBox(height: 14),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.income,
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: _saving ? null : _savePlan,
                                  child: Text(_saving ? 'Kaydediliyor...' : 'Planı Kaydet'),
                                ),
                              ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const Text(
                      'Aktif Gelir Planları',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    ..._plans.where((p) => p.isActive).map((p) {
                      return Card(
                        child: ListTile(
                          title: Text('${_categoryName(p.incomeCategoryId)} • ${_fmtAmount(p.amount)} TL'),
                          subtitle: Text(
                            'Sonraki Tarih: ${_fmtDate(p.nextDueDate)}\n'
                            'Hesap: ${_accountName(p.accountId)} • ${_periodLabel(p.periodType)} / Her ${p.frequency}',
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (v) async {
                              if (v == 'done') {
                                await IncomePlanService.markCompleted(p);
                              } else if (v == 'postpone') {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: p.nextDueDate.add(const Duration(days: 1)),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2100),
                                );
                                if (picked != null) {
                                  await IncomePlanService.postpone(p, picked);
                                }
                              } else if (v == 'cancel') {
                                await IncomePlanService.cancel(p);
                              } else if (v == 'delete') {
                                await IncomePlanService.delete(p.id);
                              }

                              if (!mounted) return;
                              await _load();
                            },
                            itemBuilder: (_) => const [
                              PopupMenuItem(value: 'done', child: Text('Gerçekleşti')),
                              PopupMenuItem(value: 'postpone', child: Text('Ertele')),
                              PopupMenuItem(value: 'cancel', child: Text('İptal Et')),
                              PopupMenuItem(value: 'delete', child: Text('Sil')),
                            ],
                          ),
                        ),
                      );
                    }),
                    if (_plans.where((p) => p.isActive).isEmpty)
                      const Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('Aktif gelir planı yok.'),
                        ),
                      ),
                  ],
                ),
    );
  }
}
