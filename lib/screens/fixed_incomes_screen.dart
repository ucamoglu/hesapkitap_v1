import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../models/account.dart';
import '../models/income_category.dart';
import '../models/income_plan.dart';
import '../services/account_service.dart';
import '../services/income_category_service.dart';
import '../services/income_plan_service.dart';
import '../utils/navigation_helpers.dart';
import '../utils/turkish_money_input_formatter.dart';
import '../utils/turkish_upper_case_formatter.dart';

class FixedIncomesScreen extends StatefulWidget {
  const FixedIncomesScreen({super.key});

  @override
  State<FixedIncomesScreen> createState() => _FixedIncomesScreenState();
}

class _FixedIncomesScreenState extends State<FixedIncomesScreen> {
  final DateFormat _dateFormat = DateFormat('dd.MM.yyyy', 'tr_TR');

  List<IncomePlan> _plans = [];
  List<Account> _accounts = [];
  List<IncomeCategory> _categories = [];
  bool _loading = true;

  static const _periodOptions = <(String, String)>[
    ('monthly', 'Aylık'),
    ('yearly', 'Yıllık'),
    ('once', 'Tek Seferlik'),
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    await IncomeCategoryService.seedDefaultsIfEmpty();
    final results = await Future.wait([
      IncomePlanService.getAll(),
      AccountService.getActiveCashflowAccounts(),
      IncomeCategoryService.getActiveManual(),
    ]);
    if (!mounted) return;
    setState(() {
      _plans = results[0] as List<IncomePlan>;
      _accounts = results[1] as List<Account>;
      _categories = results[2] as List<IncomeCategory>;
      _loading = false;
    });
  }

  String _accountName(int id) {
    for (final account in _accounts) {
      if (account.id == id) return account.name;
    }
    return 'Hesap #$id';
  }

  String _categoryName(int id) {
    for (final category in _categories) {
      if (category.id == id) return category.name;
    }
    return 'Kategori #$id';
  }

  String _periodLabel(String value) {
    for (final option in _periodOptions) {
      if (option.$1 == value) return option.$2;
    }
    return value;
  }

  String _formatAmount(double value) {
    return value.toStringAsFixed(2).replaceAll('.', ',');
  }

  String _formatDate(DateTime date) => _dateFormat.format(date);

  Future<void> _showInfoDialog() async {
    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sabit Gelirlerim'),
        content: const Text(
          'Bu ekranda maaş, kira ve benzeri düzenli gelirlerini tanımlarsın.\n\n'
          'Her kayıt mevcut gelir planı altyapısını kullanır ve sonraki tahsil tarihini takip eder.\n\n'
          'İleride bu yapıdan otomatik gelir hazırlama ve tahsilat takibi akışı kurabiliriz.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  Future<DateTime?> _pickDate(DateTime initialDate) {
    return showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('tr', 'TR'),
    );
  }

  Future<void> _openDialog({IncomePlan? edit}) async {
    if (_accounts.isEmpty || _categories.isEmpty) {
      _showSnack('Önce en az bir hesap ve gelir kategorisi tanımlanmalı.');
      return;
    }

    final descriptionController =
        TextEditingController(text: edit?.description ?? '');
    final amountController = TextEditingController(
      text: edit == null ? '' : _formatAmount(edit.amount),
    );

    int selectedAccountId = edit?.accountId ?? _accounts.first.id;
    int selectedCategoryId = edit?.incomeCategoryId ?? _categories.first.id;
    String selectedPeriod = edit?.periodType ?? 'monthly';
    DateTime startDate = edit?.startDate ?? DateTime.now();
    DateTime? endDate = edit?.endDate;
    bool isActive = edit?.isActive ?? true;

    await showDialog<void>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setInnerState) => AlertDialog(
          title: Text(edit == null ? 'Yeni Sabit Gelir' : 'Sabit Geliri Düzenle'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 460,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: descriptionController,
                    inputFormatters: const [TurkishUpperCaseFormatter()],
                    decoration: const InputDecoration(
                      labelText: 'Gelir Açıklaması',
                      hintText: 'MAAŞ',
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9,\\.]')),
                      const TurkishMoneyInputFormatter(),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Tutar',
                      hintText: '35.000,00',
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<int>(
                    initialValue: selectedAccountId,
                    decoration: const InputDecoration(
                      labelText: 'Yatacağı Hesap',
                    ),
                    items: _accounts
                        .map(
                          (account) => DropdownMenuItem<int>(
                            value: account.id,
                            child: Text(account.name),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setInnerState(() {
                        selectedAccountId = value;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<int>(
                    initialValue: selectedCategoryId,
                    decoration: const InputDecoration(
                      labelText: 'Gelir Kategorisi',
                    ),
                    items: _categories
                        .map(
                          (category) => DropdownMenuItem<int>(
                            value: category.id,
                            child: Text(category.name),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setInnerState(() {
                        selectedCategoryId = value;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    initialValue: selectedPeriod,
                    decoration: const InputDecoration(
                      labelText: 'Tekrar Tipi',
                    ),
                    items: _periodOptions
                        .map(
                          (option) => DropdownMenuItem<String>(
                            value: option.$1,
                            child: Text(option.$2),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setInnerState(() {
                        selectedPeriod = value;
                        if (selectedPeriod == 'once') {
                          endDate = null;
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Başlangıç Tarihi'),
                    subtitle: Text(_formatDate(startDate)),
                    trailing: const Icon(Icons.calendar_today_outlined),
                    onTap: () async {
                      final picked = await _pickDate(startDate);
                      if (picked == null) return;
                      setInnerState(() {
                        startDate = picked;
                        if (endDate != null && endDate!.isBefore(startDate)) {
                          endDate = startDate;
                        }
                      });
                    },
                  ),
                  if (selectedPeriod != 'once')
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Bitiş Tarihi (opsiyonel)'),
                      subtitle: Text(
                        endDate == null ? 'Seçilmedi' : _formatDate(endDate!),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (endDate != null)
                            IconButton(
                              onPressed: () {
                                setInnerState(() {
                                  endDate = null;
                                });
                              },
                              icon: const Icon(Icons.clear),
                              tooltip: 'Temizle',
                            ),
                          const Icon(Icons.event_outlined),
                        ],
                      ),
                      onTap: () async {
                        final picked = await _pickDate(endDate ?? startDate);
                        if (picked == null) return;
                        setInnerState(() {
                          endDate = picked;
                        });
                      },
                    ),
                  SwitchListTile(
                    value: isActive,
                    onChanged: (value) {
                      setInnerState(() {
                        isActive = value;
                      });
                    },
                    title: const Text('Aktif'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Vazgeç'),
            ),
            ElevatedButton(
              onPressed: () async {
                final amount =
                    TurkishMoneyInputFormatter.parse(amountController.text);
                if (descriptionController.text.trim().isEmpty) {
                  _showSnack('Gelir açıklaması zorunludur.');
                  return;
                }
                if (amount == null || amount <= 0) {
                  _showSnack('Geçerli bir tutar giriniz.');
                  return;
                }

                final item = edit ?? IncomePlan();
                final previousCreatedAt = edit?.createdAt;
                final previousNextDueDate = edit?.nextDueDate;

                item
                  ..accountId = selectedAccountId
                  ..incomeCategoryId = selectedCategoryId
                  ..amount = amount
                  ..description = descriptionController.text.trim()
                  ..periodType = selectedPeriod
                  ..frequency = 1
                  ..reminderMinutesBefore = 0
                  ..startDate = startDate
                  ..endDate = selectedPeriod == 'once' ? null : endDate
                  ..nextDueDate = previousNextDueDate != null &&
                          !previousNextDueDate.isBefore(startDate)
                      ? previousNextDueDate
                      : startDate
                  ..isActive = isActive
                  ..createdAt = previousCreatedAt ?? DateTime.now();

                try {
                  await IncomePlanService.save(item);
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  await _load();
                  _showSnack(edit == null
                      ? 'Sabit gelir kaydedildi.'
                      : 'Sabit gelir güncellendi.');
                } catch (e) {
                  _showSnack('Kayıt hatası: $e');
                }
              },
              child: Text(edit == null ? 'Kaydet' : 'Güncelle'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _delete(IncomePlan plan) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sabit Geliri Sil'),
        content: Text('${plan.description ?? 'Bu kayıt'} silinsin mi?'),
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
    if (confirmed != true) return;

    try {
      await IncomePlanService.delete(plan.id);
      await _load();
      _showSnack('Sabit gelir silindi.');
    } catch (e) {
      _showSnack('Silme hatası: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: buildAppMenuDrawer(),
      appBar: AppBar(
        leading: buildMenuLeading(),
        title: const Text('Sabit Gelirlerim'),
        actions: [
          IconButton(
            onPressed: _showInfoDialog,
            icon: const Icon(Icons.info_outline),
            tooltip: 'Bilgi',
          ),
          buildHomeAction(context),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Yeni Sabit Gelir'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _plans.isEmpty
              ? const Center(
                  child: Text(
                    'Henüz sabit gelir tanımlanmadı',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 88),
                  itemCount: _plans.length,
                  itemBuilder: (context, index) {
                    final plan = _plans[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(14),
                        leading: CircleAvatar(
                          backgroundColor: plan.isActive
                              ? Colors.green.withValues(alpha: 0.12)
                              : Colors.grey.withValues(alpha: 0.14),
                          child: Icon(
                            plan.periodType == 'yearly'
                                ? Icons.event_repeat_outlined
                                : plan.periodType == 'once'
                                    ? Icons.payments_outlined
                                    : Icons.account_balance_wallet_outlined,
                            color: plan.isActive ? Colors.green : Colors.grey,
                          ),
                        ),
                        title: Text(
                          (plan.description ?? 'Sabit Gelir').trim(),
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${_formatAmount(plan.amount)} TL • ${_periodLabel(plan.periodType)}',
                              ),
                              Text('Hesap: ${_accountName(plan.accountId)}'),
                              Text(
                                'Kategori: ${_categoryName(plan.incomeCategoryId)}',
                              ),
                              Text(
                                'Başlangıç: ${_formatDate(plan.startDate)}',
                              ),
                              Text(
                                'Sonraki Tahsil: ${_formatDate(plan.nextDueDate)}',
                              ),
                              if (plan.endDate != null)
                                Text('Bitiş: ${_formatDate(plan.endDate!)}'),
                              Text(plan.isActive ? 'Aktif' : 'Pasif'),
                            ],
                          ),
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) async {
                            if (value == 'edit') {
                              await _openDialog(edit: plan);
                            } else if (value == 'toggle') {
                              plan.isActive = !plan.isActive;
                              await IncomePlanService.save(plan);
                              await _load();
                              _showSnack(plan.isActive
                                  ? 'Sabit gelir aktif yapıldı.'
                                  : 'Sabit gelir pasif yapıldı.');
                            } else if (value == 'delete') {
                              await _delete(plan);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Text('Düzenle'),
                            ),
                            PopupMenuItem(
                              value: 'toggle',
                              child:
                                  Text(plan.isActive ? 'Pasif Yap' : 'Aktif Yap'),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('Sil'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
