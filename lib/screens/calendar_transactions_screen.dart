import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../models/cari_transaction.dart';
import '../models/expense_plan.dart';
import '../models/finance_transaction.dart';
import '../models/income_plan.dart';
import '../models/investment_transaction.dart';
import '../screens/cari_account_screen.dart';
import '../screens/expense_entry_screen.dart';
import '../screens/income_entry_screen.dart';
import '../services/account_service.dart';
import '../services/cari_card_service.dart';
import '../services/cari_transaction_service.dart';
import '../services/category_service.dart';
import '../services/expense_plan_service.dart';
import '../services/finance_transaction_service.dart';
import '../services/income_category_service.dart';
import '../services/income_plan_service.dart';
import '../services/investment_transaction_service.dart';
import '../theme/app_colors.dart';
import '../utils/navigation_helpers.dart';
import '../utils/planning_standard.dart';

class CalendarTransactionsScreen extends StatefulWidget {
  const CalendarTransactionsScreen({super.key});

  @override
  State<CalendarTransactionsScreen> createState() =>
      _CalendarTransactionsScreenState();
}

class _CalendarTransactionsScreenState extends State<CalendarTransactionsScreen> {
  bool _loading = true;
  String? _error;

  DateTime _selectedDate = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  List<FinanceTransaction> _all = [];
  List<IncomePlan> _plans = [];
  List<ExpensePlan> _expensePlans = [];
  final LinkedHashMap<DateTime, int> _txCountByDay = LinkedHashMap<DateTime, int>(
    equals: isSameDay,
    hashCode: _getHashCode,
  );
  final LinkedHashMap<DateTime, int> _planCountByDay = LinkedHashMap<DateTime, int>(
    equals: isSameDay,
    hashCode: _getHashCode,
  );
  final LinkedHashMap<DateTime, int> _expensePlanCountByDay =
      LinkedHashMap<DateTime, int>(
    equals: isSameDay,
    hashCode: _getHashCode,
  );

  Map<int, String> _accountNames = {};
  Map<int, String> _incomeCategoryNames = {};
  Map<int, String> _expenseCategoryNames = {};
  Map<int, String> _cariCardNames = {};
  Map<int, String> _cariRawTypeByTxId = {};
  Map<int, _InvestmentCalendarMeta> _investmentMetaByTxId = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final tx = (await FinanceTransactionService.getAll())
          .where((e) => !_isSyntheticInvestmentPnlTx(e))
          .toList();
      final cariTx = await CariTransactionService.getAll();
      final accounts = await AccountService.getAllAccounts();
      final incomeCategories = await IncomeCategoryService.getAll();
      final expenseCategories = await CategoryService.getAllExpenseCategories();
      final cariCards = await CariCardService.getAll();
      final investmentTx = await InvestmentTransactionService.getAll();
      final plans = await IncomePlanService.getAll();
      final expensePlans = await ExpensePlanService.getAll();

      if (!mounted) return;

      final mappedCari = cariTx.map(_mapCariToFinanceLike).toList();
      final mappedInvestment = _mapInvestmentToFinanceLike(
        investmentTx,
        {for (final a in accounts) a.id: a.name},
      );
      final merged = [...tx, ...mappedCari, ...mappedInvestment.$1]
        ..sort((a, b) => b.date.compareTo(a.date));
      final txCounts = LinkedHashMap<DateTime, int>(
        equals: isSameDay,
        hashCode: _getHashCode,
      );
      for (final t in merged) {
        final dayKey = DateTime(t.date.year, t.date.month, t.date.day);
        txCounts[dayKey] = (txCounts[dayKey] ?? 0) + 1;
      }
      final planCounts = LinkedHashMap<DateTime, int>(
        equals: isSameDay,
        hashCode: _getHashCode,
      );
      for (final p in plans.where((e) => e.isActive)) {
        final dayKey =
            DateTime(p.nextDueDate.year, p.nextDueDate.month, p.nextDueDate.day);
        planCounts[dayKey] = (planCounts[dayKey] ?? 0) + 1;
      }
      final expensePlanCounts = LinkedHashMap<DateTime, int>(
        equals: isSameDay,
        hashCode: _getHashCode,
      );
      for (final p in expensePlans.where((e) => e.isActive)) {
        final dayKey =
            DateTime(p.nextDueDate.year, p.nextDueDate.month, p.nextDueDate.day);
        expensePlanCounts[dayKey] = (expensePlanCounts[dayKey] ?? 0) + 1;
      }

      setState(() {
        _all = merged;
        _plans = plans.where((e) => e.isActive).toList();
        _expensePlans = expensePlans.where((e) => e.isActive).toList();
        _txCountByDay
          ..clear()
          ..addAll(txCounts);
        _planCountByDay
          ..clear()
          ..addAll(planCounts);
        _expensePlanCountByDay
          ..clear()
          ..addAll(expensePlanCounts);
        _accountNames = {for (final a in accounts) a.id: a.name};
        _incomeCategoryNames = {for (final c in incomeCategories) c.id: c.name};
        _expenseCategoryNames = {for (final c in expenseCategories) c.id: c.name};
        _cariCardNames = {
          for (final c in cariCards)
            c.id: (c.type == 'company'
                    ? (c.title?.trim().isNotEmpty == true ? c.title! : null)
                    : (c.fullName?.trim().isNotEmpty == true ? c.fullName! : null)) ??
                'Cari #${c.id}',
        };
        _cariRawTypeByTxId = {
          for (final c in cariTx) -(c.id + 1): c.type,
        };
        _investmentMetaByTxId = mappedInvestment.$2;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Takvim verileri yüklenemedi: $e';
      });
    }
  }

  static int _getHashCode(DateTime key) =>
      key.day * 1000000 + key.month * 10000 + key.year;

  bool _isCariTx(FinanceTransaction tx) => _cariRawTypeByTxId.containsKey(tx.id);

  bool _isInvestmentAssetTx(FinanceTransaction tx) =>
      _investmentMetaByTxId[tx.id]?.isAssetSide == true;

  bool _isCariCollection(FinanceTransaction tx) =>
      _cariRawTypeByTxId[tx.id] == 'collection';

  List<IncomePlan> _selectedDayPlans() {
    final list = _plans.where((p) => isSameDay(p.nextDueDate, _selectedDate)).toList();
    list.sort((a, b) => a.nextDueDate.compareTo(b.nextDueDate));
    return list;
  }

  List<ExpensePlan> _selectedDayExpensePlans() {
    final list = _expensePlans
        .where((p) => isSameDay(p.nextDueDate, _selectedDate))
        .toList();
    list.sort((a, b) => a.nextDueDate.compareTo(b.nextDueDate));
    return list;
  }

  List<FinanceTransaction> _selectedDayTransactions() {
    final list = _all.where((tx) => isSameDay(tx.date, _selectedDate)).toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  String _txTypeLabel(FinanceTransaction tx) {
    if (_isCariTx(tx)) {
      return _isCariCollection(tx) ? 'Cari Kart (Gelen)' : 'Cari Kart (Giden)';
    }
    final invMeta = _investmentMetaByTxId[tx.id];
    if (invMeta != null) {
      if (invMeta.isAssetSide) {
        return invMeta.rawType == 'buy'
            ? 'Yatırım Varlık Giriş'
            : 'Yatırım Varlık Çıkış';
      }
      return invMeta.rawType == 'buy'
          ? 'Yatırım Alış (Nakit)'
          : 'Yatırım Satış (Nakit)';
    }
    return tx.type == 'income' ? 'Gelir' : 'Gider';
  }

  String _categoryName(FinanceTransaction tx) {
    if (_isCariTx(tx)) return _cariCardNames[tx.categoryId] ?? 'Cari #${tx.categoryId}';
    final invMeta = _investmentMetaByTxId[tx.id];
    if (invMeta != null) {
      return invMeta.symbol;
    }
    if (tx.type == 'income') {
      return _incomeCategoryNames[tx.categoryId] ?? 'Kategori #${tx.categoryId}';
    }
    return _expenseCategoryNames[tx.categoryId] ?? 'Kategori #${tx.categoryId}';
  }

  String _incomeCategoryNameById(int id) =>
      _incomeCategoryNames[id] ?? 'Kategori #$id';
  String _expenseCategoryNameById(int id) =>
      _expenseCategoryNames[id] ?? 'Kategori #$id';

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
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '$dd.$mm.${d.year}';
  }

  String _fmtDateTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '${_fmtDate(dt)} $h:$min';
  }

  String _periodLabel(String v) {
    return PlanningStandard.periodLabel(v);
  }

  bool _isSyntheticInvestmentPnlTx(FinanceTransaction tx) {
    final desc = (tx.description ?? '').trim().toLowerCase();
    return desc.startsWith('yatirim satis k/z');
  }

  FinanceTransaction _mapCariToFinanceLike(CariTransaction c) {
    return FinanceTransaction()
      ..id = -(c.id + 1)
      ..accountId = c.accountId
      ..categoryId = c.cariCardId
      ..type = c.type == 'collection' ? 'income' : 'expense'
      ..amount = c.amount
      ..description = c.description
      ..date = c.date
      ..createdAt = c.createdAt;
  }

  (List<FinanceTransaction>, Map<int, _InvestmentCalendarMeta>)
      _mapInvestmentToFinanceLike(
    List<InvestmentTransaction> items,
    Map<int, String> accountNames,
  ) {
    final result = <FinanceTransaction>[];
    final metaById = <int, _InvestmentCalendarMeta>{};

    for (final it in items) {
      final base = 1000000000 + (it.id * 10);
      final cashId = -(base + 1);
      final assetId = -(base + 2);
      final isBuy = it.type == 'buy';

      final cash = FinanceTransaction()
        ..id = cashId
        ..accountId = it.cashAccountId
        ..categoryId = 0
        ..type = isBuy ? 'expense' : 'income'
        ..amount = it.total
        ..description =
            'Yatırım: ${it.symbol} • Miktar: ${it.quantity.toStringAsFixed(4)} • Birim: ${_fmtAmount(it.unitPrice)} TL'
        ..date = it.date
        ..createdAt = it.createdAt;
      result.add(cash);
      metaById[cashId] = _InvestmentCalendarMeta(
        symbol: it.symbol,
        rawType: it.type,
        isAssetSide: false,
        linkedAccountName:
            accountNames[it.investmentAccountId] ?? 'Yatırım #${it.investmentAccountId}',
      );

      final asset = FinanceTransaction()
        ..id = assetId
        ..accountId = it.investmentAccountId
        ..categoryId = 0
        ..type = isBuy ? 'income' : 'expense'
        ..amount = it.quantity
        ..description =
            'Nakit hesap: ${accountNames[it.cashAccountId] ?? 'Hesap #${it.cashAccountId}'} • Birim: ${_fmtAmount(it.unitPrice)} TL • Toplam: ${_fmtAmount(it.total)} TL'
        ..date = it.date
        ..createdAt = it.createdAt;
      result.add(asset);
      metaById[assetId] = _InvestmentCalendarMeta(
        symbol: it.symbol,
        rawType: it.type,
        isAssetSide: true,
        linkedAccountName:
            accountNames[it.cashAccountId] ?? 'Hesap #${it.cashAccountId}',
      );
    }

    return (result, metaById);
  }

  Future<void> _openManualTransactionMenu() async {
    await showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.arrow_downward, color: Colors.green),
                title: const Text('Gelir (Manuel)'),
                onTap: () async {
                  Navigator.pop(ctx);
                  await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(builder: (_) => const IncomeEntryScreen()),
                  );
                  if (!mounted) return;
                  await _load();
                },
              ),
              ListTile(
                leading: const Icon(Icons.arrow_upward, color: Colors.red),
                title: const Text('Gider (Manuel)'),
                onTap: () async {
                  Navigator.pop(ctx);
                  await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(builder: (_) => const ExpenseEntryScreen()),
                  );
                  if (!mounted) return;
                  await _load();
                },
              ),
              ListTile(
                leading: const Icon(Icons.handshake, color: Colors.orange),
                title: const Text('Cari Hesap (Manuel)'),
                onTap: () async {
                  Navigator.pop(ctx);
                  await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(builder: (_) => const CariAccountScreen()),
                  );
                  if (!mounted) return;
                  await _load();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _completePlan(IncomePlan plan) async {
    try {
      await IncomePlanService.markCompleted(plan);
      if (!mounted) return;
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('İşlem hatası: $e')),
      );
    }
  }

  Future<void> _postponePlan(IncomePlan plan) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: plan.nextDueDate.add(const Duration(days: 1)),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    try {
      await IncomePlanService.postpone(plan, picked);
      if (!mounted) return;
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erteleme hatası: $e')),
      );
    }
  }

  Future<void> _cancelPlan(IncomePlan plan) async {
    try {
      await IncomePlanService.cancel(plan);
      if (!mounted) return;
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('İptal hatası: $e')),
      );
    }
  }

  Future<void> _completeExpensePlan(ExpensePlan plan) async {
    try {
      await ExpensePlanService.markCompleted(plan);
      if (!mounted) return;
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('İşlem hatası: $e')),
      );
    }
  }

  Future<void> _postponeExpensePlan(ExpensePlan plan) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: plan.nextDueDate.add(const Duration(days: 1)),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    try {
      await ExpensePlanService.postpone(plan, picked);
      if (!mounted) return;
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erteleme hatası: $e')),
      );
    }
  }

  Future<void> _cancelExpensePlan(ExpensePlan plan) async {
    try {
      await ExpensePlanService.cancel(plan);
      if (!mounted) return;
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('İptal hatası: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final list = _selectedDayTransactions();
    final dayPlans = _selectedDayPlans();
    final dayExpensePlans = _selectedDayExpensePlans();
    final income = list
        .where((e) => e.type == 'income' && !_isInvestmentAssetTx(e))
        .fold<double>(0, (sum, e) => sum + e.amount);
    final expense = list
        .where((e) => e.type == 'expense' && !_isInvestmentAssetTx(e))
        .fold<double>(0, (sum, e) => sum + e.amount);
    final net = income - expense;

    return Scaffold(
      drawer: buildAppMenuDrawer(),
      appBar: AppBar(
        leading: buildMenuLeading(),
        title: const Text('Takvim'),
        actions: [
          IconButton(
            onPressed: _openManualTransactionMenu,
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Manuel İşlem',
          ),
          IconButton(
            onPressed: _load,
            icon: const Icon(Icons.refresh),
            tooltip: 'Yenile',
          ),
          buildHomeAction(context),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : ListView(
                  padding: const EdgeInsets.only(bottom: 12),
                  children: [
                    _stableSection(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: TableCalendar<String>(
                          locale: 'tr_TR',
                          firstDay: DateTime(2000),
                          lastDay: DateTime(2100),
                          focusedDay: _focusedDay,
                          selectedDayPredicate: (day) => isSameDay(day, _selectedDate),
                          eventLoader: (day) {
                            final result = <String>[];
                            final txCount = _txCountByDay[day] ?? 0;
                            final planCount = _planCountByDay[day] ?? 0;
                            final expensePlanCount = _expensePlanCountByDay[day] ?? 0;
                            result.addAll(List.filled(txCount, 'tx'));
                            result.addAll(List.filled(planCount, 'plan'));
                            result.addAll(List.filled(expensePlanCount, 'expense_plan'));
                            return result;
                          },
                          startingDayOfWeek: StartingDayOfWeek.monday,
                          calendarStyle: CalendarStyle(
                            outsideDaysVisible: false,
                            selectedDecoration: const BoxDecoration(
                              color: Colors.deepPurple,
                              shape: BoxShape.circle,
                            ),
                            todayDecoration: BoxDecoration(
                              color: Colors.deepPurple.shade200,
                              shape: BoxShape.circle,
                            ),
                          ),
                          calendarBuilders: CalendarBuilders(
                            defaultBuilder: (context, day, focusedDay) {
                              final hasTx = (_txCountByDay[day] ?? 0) > 0;
                              final hasPlan = (_planCountByDay[day] ?? 0) > 0;
                              final hasExpensePlan =
                                  (_expensePlanCountByDay[day] ?? 0) > 0;
                              if (!hasTx && !hasPlan && !hasExpensePlan) return null;
                              final borderColor = (hasPlan || hasExpensePlan)
                                  ? (hasExpensePlan
                                      ? Colors.red.shade400
                                      : Colors.orange.shade500)
                                  : Colors.deepPurple.shade300;
                              final bgColor = (hasPlan || hasExpensePlan)
                                  ? (hasExpensePlan
                                      ? Colors.red.shade50
                                      : Colors.orange.shade50)
                                  : Colors.deepPurple.shade50;
                              return Container(
                                margin: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: bgColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: borderColor),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '${day.day}',
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                              );
                            },
                            markerBuilder: (context, day, events) {
                              final hasTx = events.contains('tx');
                              final hasPlan = events.contains('plan');
                              final hasExpensePlan = events.contains('expense_plan');
                              if (!hasTx && !hasPlan && !hasExpensePlan) {
                                return const SizedBox.shrink();
                              }
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (hasTx)
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          color: Colors.deepPurple.shade400,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    if (hasTx && hasPlan) const SizedBox(width: 3),
                                    if (hasPlan)
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          color: Colors.orange.shade600,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    if ((hasTx || hasPlan) && hasExpensePlan)
                                      const SizedBox(width: 3),
                                    if (hasExpensePlan)
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          color: Colors.red.shade500,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
                          onDaySelected: (selectedDay, focusedDay) {
                            setState(() {
                              _selectedDate = selectedDay;
                              _focusedDay = focusedDay;
                            });
                          },
                          onPageChanged: (focusedDay) {
                            _focusedDay = focusedDay;
                          },
                          ),
                        ),
                      ),
                    ),
                    _stableSection(
                      padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          const gap = 8.0;
                          final compact = constraints.maxWidth < 760;
                          final cardWidth = compact
                              ? constraints.maxWidth
                              : (constraints.maxWidth - (gap * 2)) / 3;

                          return Wrap(
                            spacing: gap,
                            runSpacing: gap,
                            children: [
                              SizedBox(
                                width: cardWidth,
                                child: _summary('Gelir', income, Colors.green),
                              ),
                              SizedBox(
                                width: cardWidth,
                                child: _summary('Gider', expense, Colors.red),
                              ),
                              SizedBox(
                                width: cardWidth,
                                child: _summary(
                                  'Net',
                                  net.abs(),
                                  net >= 0 ? Colors.blue : Colors.orange,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    _stableSection(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '${_fmtDate(_selectedDate)} • ${list.length} hareket • ${dayPlans.length + dayExpensePlans.length} plan',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    if (dayPlans.isNotEmpty)
                      _stableSection(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
                        child: Card(
                          color: Colors.orange.shade50,
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Planlanan Gelirler',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 6),
                                ...dayPlans.map(
                                  (p) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '• ${_incomeCategoryNameById(p.incomeCategoryId)}'
                                          ' • ${_fmtAmount(p.amount)} TL'
                                          ' • ${_periodLabel(p.periodType)} / Her ${p.frequency}',
                                        ),
                                        const SizedBox(height: 6),
                                        Wrap(
                                          spacing: 6,
                                          runSpacing: 6,
                                          children: [
                                            OutlinedButton(
                                              style: OutlinedButton.styleFrom(
                                                foregroundColor: AppColors.income,
                                                side: const BorderSide(
                                                  color: AppColors.income,
                                                ),
                                              ),
                                              onPressed: () => _completePlan(p),
                                              child: const Text('Gerçekleşti'),
                                            ),
                                            OutlinedButton(
                                              onPressed: () => _postponePlan(p),
                                              child: const Text('Ertele'),
                                            ),
                                            OutlinedButton(
                                              onPressed: () => _cancelPlan(p),
                                              child: const Text('İptal Et'),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    if (dayExpensePlans.isNotEmpty)
                      _stableSection(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
                        child: Card(
                          color: Colors.red.shade50,
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Planlanan Giderler',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 6),
                                ...dayExpensePlans.map(
                                  (p) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '• ${_expenseCategoryNameById(p.expenseCategoryId)}'
                                          ' • ${_fmtAmount(p.amount)} TL'
                                          ' • ${_periodLabel(p.periodType)} / Her ${p.frequency}',
                                        ),
                                        const SizedBox(height: 6),
                                        Wrap(
                                          spacing: 6,
                                          runSpacing: 6,
                                          children: [
                                            OutlinedButton(
                                              style: OutlinedButton.styleFrom(
                                                foregroundColor: AppColors.expense,
                                                side: const BorderSide(
                                                  color: AppColors.expense,
                                                ),
                                              ),
                                              onPressed: () => _completeExpensePlan(p),
                                              child: const Text('Gerçekleşti'),
                                            ),
                                            OutlinedButton(
                                              onPressed: () => _postponeExpensePlan(p),
                                              child: const Text('Ertele'),
                                            ),
                                            OutlinedButton(
                                              onPressed: () => _cancelExpensePlan(p),
                                              child: const Text('İptal Et'),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    if (list.isEmpty)
                      _stableSection(
                        padding: const EdgeInsets.all(16),
                        child: const Center(child: Text('Seçili gün için hareket yok.')),
                      )
                    else
                      ...list.map(
                        (tx) => _stableSection(
                          padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
                          child: Builder(
                            builder: (_) {
                              final isIncome = tx.type == 'income';
                              final accountName =
                                  _accountNames[tx.accountId] ?? 'Hesap #${tx.accountId}';
                              final invMeta = _investmentMetaByTxId[tx.id];
                              final amountText = invMeta == null
                                  ? '${isIncome ? '+' : '-'}${_fmtAmount(tx.amount)} TL'
                                  : invMeta.isAssetSide
                                      ? '${isIncome ? '+' : '-'}${tx.amount.toStringAsFixed(4)} ${invMeta.symbol}'
                                      : '${isIncome ? '+' : '-'}${_fmtAmount(tx.amount)} TL';

                              return Column(
                                children: [
                                  ListTile(
                                    leading: Icon(
                                      isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                                      color: isIncome ? Colors.green : Colors.red,
                                    ),
                                    title: Text('${_txTypeLabel(tx)} • ${_categoryName(tx)}'),
                                    subtitle: Text(
                                      '${_fmtDateTime(tx.date)} • $accountName\n'
                                      '${invMeta != null ? 'Karşı: ${invMeta.linkedAccountName}\n' : ''}'
                                      'Açıklama: ${(tx.description ?? '').trim().isEmpty ? '-' : tx.description!.trim()}',
                                    ),
                                    isThreeLine: true,
                                    trailing: Text(
                                      amountText,
                                      style: TextStyle(
                                        color: isIncome ? Colors.green : Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const Divider(height: 1),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                  ],
                ),
    );
  }

  Widget _stableSection({
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.fromLTRB(12, 0, 12, 8),
  }) {
    return Padding(
      padding: padding,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: child,
        ),
      ),
    );
  }

  Widget _summary(String title, double value, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 4),
            Text(
              _fmtAmount(value),
              style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class _InvestmentCalendarMeta {
  final String symbol;
  final String rawType;
  final bool isAssetSide;
  final String linkedAccountName;

  const _InvestmentCalendarMeta({
    required this.symbol,
    required this.rawType,
    required this.isAssetSide,
    required this.linkedAccountName,
  });
}
