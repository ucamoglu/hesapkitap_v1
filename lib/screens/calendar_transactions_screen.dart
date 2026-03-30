import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../core/runtime/app_runtime.dart';
import '../models/cari_transaction.dart';
import '../models/expense_plan.dart';
import '../models/finance_transaction.dart';
import '../models/income_plan.dart';
import '../models/investment_transaction.dart';
import '../models/subscription_definition.dart';
import '../screens/cari_account_screen.dart';
import '../screens/expense_entry_screen.dart';
import '../screens/income_entry_screen.dart';
import '../screens/investment_entry_screen.dart';
import '../services/account_service.dart';
import '../services/cari_card_service.dart';
import '../services/cari_transaction_service.dart';
import '../services/category_service.dart';
import '../services/expense_plan_service.dart';
import '../services/finance_transaction_service.dart';
import '../services/income_category_service.dart';
import '../services/income_plan_service.dart';
import '../services/investment_transaction_service.dart';
import '../services/subscription_definition_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme_helpers.dart';
import '../utils/navigation_helpers.dart';
import '../utils/planning_standard.dart';

class CalendarTransactionsScreen extends StatefulWidget {
  const CalendarTransactionsScreen({super.key});

  @override
  State<CalendarTransactionsScreen> createState() =>
      _CalendarTransactionsScreenState();
}

class _CalendarTransactionsScreenState
    extends State<CalendarTransactionsScreen> {
  static const int _transactionMonthCacheRadius = 2;
  bool _loading = true;
  String? _error;

  DateTime _selectedDate = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  List<FinanceTransaction> _all = [];
  List<IncomePlan> _plans = [];
  List<ExpensePlan> _expensePlans = [];
  List<SubscriptionDefinition> _subscriptions = [];
  List<_IncomePlanOccurrence> _incomePlanOccurrences = [];
  List<_ExpensePlanOccurrence> _expensePlanOccurrences = [];
  final LinkedHashMap<DateTime, int> _txCountByDay =
      LinkedHashMap<DateTime, int>(
    equals: isSameDay,
    hashCode: _getHashCode,
  );
  final LinkedHashMap<DateTime, int> _planCountByDay =
      LinkedHashMap<DateTime, int>(
    equals: isSameDay,
    hashCode: _getHashCode,
  );
  final LinkedHashMap<DateTime, int> _expensePlanCountByDay =
      LinkedHashMap<DateTime, int>(
    equals: isSameDay,
    hashCode: _getHashCode,
  );
  final LinkedHashMap<DateTime, int> _subscriptionCountByDay =
      LinkedHashMap<DateTime, int>(
    equals: isSameDay,
    hashCode: _getHashCode,
  );

  Map<int, String> _accountNames = {};
  Map<int, String> _incomeCategoryNames = {};
  Map<int, String> _expenseCategoryNames = {};
  Map<int, String> _cariCardNames = {};
  Map<int, String> _cariRawTypeByTxId = {};
  Map<int, CariTransaction> _cariTxBySyntheticId = {};
  Map<int, InvestmentTransaction> _investmentById = {};
  Map<int, _InvestmentCalendarMeta> _investmentMetaByTxId = {};
  DateTime? _loadedTransactionStart;
  DateTime? _loadedTransactionEnd;

  @override
  void initState() {
    super.initState();
    _load();
  }

  // Takvim gunleri icin hareket ve plan sayilarini hesaplayip ekrana hazirlar.
  Future<void> _load({
    DateTime? focusedDay,
    bool showLoader = true,
  }) async {
    final targetFocusedDay = focusedDay ?? _focusedDay;
    final txStart = _transactionWindowStart(targetFocusedDay);
    final txEnd = _transactionWindowEnd(targetFocusedDay);

    if (showLoader) {
      setState(() {
        _loading = true;
        _error = null;
      });
    } else {
      _error = null;
    }

    try {
      final results = await Future.wait([
        FinanceTransactionService.getByDateRange(start: txStart, end: txEnd),
        CariTransactionService.getByDateRange(start: txStart, end: txEnd),
        AccountService.getAllAccounts(),
        IncomeCategoryService.getAll(),
        CategoryService.getAllExpenseCategories(),
        CariCardService.getAll(),
        InvestmentTransactionService.getByDateRange(start: txStart, end: txEnd),
        IncomePlanService.getAll(),
        ExpensePlanService.getAll(),
        SubscriptionDefinitionService.getAll(),
      ]);

      final tx = (results[0] as List<FinanceTransaction>)
          .where((e) => !_isSyntheticInvestmentPnlTx(e))
          .toList();
      final cariTx = results[1] as List<CariTransaction>;
      final accounts = results[2] as List<dynamic>;
      final incomeCategories = results[3] as List<dynamic>;
      final expenseCategories = results[4] as List<dynamic>;
      final cariCards = results[5] as List<dynamic>;
      final investmentTx = results[6] as List<InvestmentTransaction>;
      final plans = results[7] as List<IncomePlan>;
      final expensePlans = results[8] as List<ExpensePlan>;
      final subscriptions = results[9] as List<SubscriptionDefinition>;

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
      final activeSubscriptions =
          subscriptions.where((item) => item.isActive).toList();
      final activePlans = plans.where((e) => e.isActive).toList();
      final activeExpensePlans = expensePlans.where((e) => e.isActive).toList();

      setState(() {
        _focusedDay = targetFocusedDay;
        _all = merged;
        _plans = activePlans;
        _expensePlans = activeExpensePlans;
        _subscriptions = activeSubscriptions;
        _incomePlanOccurrences = _buildIncomePlanOccurrences(targetFocusedDay);
        _expensePlanOccurrences = _buildExpensePlanOccurrences(targetFocusedDay);
        _txCountByDay
          ..clear()
          ..addAll(txCounts);
        _planCountByDay
          ..clear()
          ..addAll(_buildIncomePlanCounts(targetFocusedDay));
        _expensePlanCountByDay
          ..clear()
          ..addAll(_buildExpensePlanCounts(targetFocusedDay));
        _subscriptionCountByDay
          ..clear()
          ..addAll(_buildSubscriptionCounts(targetFocusedDay));
        _accountNames = {for (final a in accounts) a.id: a.name};
        _incomeCategoryNames = {for (final c in incomeCategories) c.id: c.name};
        _expenseCategoryNames = {
          for (final c in expenseCategories) c.id: c.name
        };
        _cariCardNames = {
          for (final c in cariCards)
            c.id: (c.type == 'company'
                    ? (c.title?.trim().isNotEmpty == true ? c.title! : null)
                    : (c.fullName?.trim().isNotEmpty == true
                        ? c.fullName!
                        : null)) ??
                'Cari #${c.id}',
        };
        _cariRawTypeByTxId = {
          for (final c in cariTx) -(c.id + 1): c.type,
        };
        _cariTxBySyntheticId = {
          for (final c in cariTx) -(c.id + 1): c,
        };
        _investmentById = {for (final it in investmentTx) it.id: it};
        _investmentMetaByTxId = mappedInvestment.$2;
        _loadedTransactionStart = txStart;
        _loadedTransactionEnd = txEnd;
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

  DateTime _transactionWindowStart(DateTime focusedDay) {
    return DateTime(
      focusedDay.year,
      focusedDay.month - _transactionMonthCacheRadius,
      1,
    );
  }

  DateTime _transactionWindowEnd(DateTime focusedDay) {
    return DateTime(
      focusedDay.year,
      focusedDay.month + _transactionMonthCacheRadius + 1,
      0,
      23,
      59,
      59,
      999,
    );
  }

  bool _needsTransactionReload(DateTime focusedDay) {
    final loadedStart = _loadedTransactionStart;
    final loadedEnd = _loadedTransactionEnd;
    if (loadedStart == null || loadedEnd == null) return true;
    final monthStart = DateTime(focusedDay.year, focusedDay.month, 1);
    final monthEnd = DateTime(
      focusedDay.year,
      focusedDay.month + 1,
      0,
      23,
      59,
      59,
      999,
    );
    return monthStart.isBefore(loadedStart) || monthEnd.isAfter(loadedEnd);
  }

  bool _isCariTx(FinanceTransaction tx) =>
      _cariRawTypeByTxId.containsKey(tx.id);

  bool _isInvestmentAssetTx(FinanceTransaction tx) =>
      _investmentMetaByTxId[tx.id]?.isAssetSide == true;

  bool _isCariCollection(FinanceTransaction tx) =>
      _cariRawTypeByTxId[tx.id] == 'collection';

  List<_IncomePlanOccurrence> _selectedDayIncomeOccurrences() {
    final list = _incomePlanOccurrences
        .where((item) => isSameDay(item.date, _selectedDate))
        .toList();
    list.sort((a, b) => a.date.compareTo(b.date));
    return list;
  }

  List<_ExpensePlanOccurrence> _selectedDayExpenseOccurrences() {
    final list = _expensePlanOccurrences
        .where((item) => isSameDay(item.date, _selectedDate))
        .toList();
    list.sort((a, b) => a.date.compareTo(b.date));
    return list;
  }

  List<FinanceTransaction> _selectedDayTransactions() {
    final list = _all.where((tx) => isSameDay(tx.date, _selectedDate)).toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  List<SubscriptionDefinition> _selectedDaySubscriptions() {
    final list = _subscriptions.where((item) {
      return _subscriptionOccursOnDate(item, _selectedDate);
    }).toList();
    list.sort((a, b) => a.name.compareTo(b.name));
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
    if (_isCariTx(tx)) {
      return _cariCardNames[tx.categoryId] ?? 'Cari #${tx.categoryId}';
    }
    final invMeta = _investmentMetaByTxId[tx.id];
    if (invMeta != null) {
      return invMeta.symbol;
    }
    if (tx.type == 'income') {
      return _incomeCategoryNames[tx.categoryId] ??
          'Kategori #${tx.categoryId}';
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

  String _incomePlanSummary(IncomePlan plan) {
    return PlanningStandard.planSummary(
      periodType: plan.periodType,
      frequency: plan.frequency,
      reminderMinutesBefore: plan.reminderMinutesBefore,
    );
  }

  String _expensePlanSummary(ExpensePlan plan) {
    return PlanningStandard.planSummary(
      periodType: plan.periodType,
      frequency: plan.frequency,
      reminderMinutesBefore: plan.reminderMinutesBefore,
    );
  }

  DateTime _windowStart(DateTime focusedDay) {
    return DateTime(focusedDay.year, focusedDay.month - 12, 1);
  }

  DateTime _windowEnd(DateTime focusedDay) {
    return DateTime(focusedDay.year, focusedDay.month + 13, 0, 23, 59, 59, 999);
  }

  List<_IncomePlanOccurrence> _buildIncomePlanOccurrences(DateTime focusedDay) {
    final occurrences = <_IncomePlanOccurrence>[];
    final start = _windowStart(focusedDay);
    final end = _windowEnd(focusedDay);
    for (final plan in _plans.where((p) => p.isActive)) {
      occurrences.addAll(_generateIncomeOccurrences(plan, start, end));
    }
    return occurrences;
  }

  List<_ExpensePlanOccurrence> _buildExpensePlanOccurrences(DateTime focusedDay) {
    final occurrences = <_ExpensePlanOccurrence>[];
    final start = _windowStart(focusedDay);
    final end = _windowEnd(focusedDay);
    for (final plan in _expensePlans.where((p) => p.isActive)) {
      occurrences.addAll(_generateExpenseOccurrences(plan, start, end));
    }
    return occurrences;
  }

  List<_IncomePlanOccurrence> _generateIncomeOccurrences(
    IncomePlan plan,
    DateTime start,
    DateTime end,
  ) {
    final result = <_IncomePlanOccurrence>[];
    final inclusiveEnd = plan.endDate == null
        ? null
        : DateTime(
            plan.endDate!.year,
            plan.endDate!.month,
            plan.endDate!.day,
            23,
            59,
            59,
            999,
          );
    var current = plan.nextDueDate;
    while (!current.isAfter(end)) {
      if (inclusiveEnd != null && current.isAfter(inclusiveEnd)) {
        break;
      }
      if (!current.isBefore(start)) {
        result.add(
          _IncomePlanOccurrence(
            plan: plan,
            date: current,
            isActionable: isSameDay(current, plan.nextDueDate),
          ),
        );
      }
      if (plan.periodType == 'once') {
        break;
      }
      current = PlanningStandard.nextOccurrence(
        from: current,
        periodType: plan.periodType,
        frequency: plan.frequency,
      );
    }
    return result;
  }

  List<_ExpensePlanOccurrence> _generateExpenseOccurrences(
    ExpensePlan plan,
    DateTime start,
    DateTime end,
  ) {
    final result = <_ExpensePlanOccurrence>[];
    final inclusiveEnd = plan.endDate == null
        ? null
        : DateTime(
            plan.endDate!.year,
            plan.endDate!.month,
            plan.endDate!.day,
            23,
            59,
            59,
            999,
          );
    var current = plan.nextDueDate;
    while (!current.isAfter(end)) {
      if (inclusiveEnd != null && current.isAfter(inclusiveEnd)) {
        break;
      }
      if (!current.isBefore(start)) {
        result.add(
          _ExpensePlanOccurrence(
            plan: plan,
            date: current,
            isActionable: isSameDay(current, plan.nextDueDate),
          ),
        );
      }
      if (plan.periodType == 'once') {
        break;
      }
      current = PlanningStandard.nextOccurrence(
        from: current,
        periodType: plan.periodType,
        frequency: plan.frequency,
      );
    }
    return result;
  }

  LinkedHashMap<DateTime, int> _buildIncomePlanCounts(DateTime focusedDay) {
    final counts = LinkedHashMap<DateTime, int>(
      equals: isSameDay,
      hashCode: _getHashCode,
    );
    for (final item in _buildIncomePlanOccurrences(focusedDay)) {
      final dayKey = DateTime(item.date.year, item.date.month, item.date.day);
      counts[dayKey] = (counts[dayKey] ?? 0) + 1;
    }
    return counts;
  }

  LinkedHashMap<DateTime, int> _buildExpensePlanCounts(DateTime focusedDay) {
    final counts = LinkedHashMap<DateTime, int>(
      equals: isSameDay,
      hashCode: _getHashCode,
    );
    for (final item in _buildExpensePlanOccurrences(focusedDay)) {
      final dayKey = DateTime(item.date.year, item.date.month, item.date.day);
      counts[dayKey] = (counts[dayKey] ?? 0) + 1;
    }
    return counts;
  }

  DateTime _subscriptionDueDateForMonth(
    SubscriptionDefinition item,
    DateTime month,
  ) {
    final year = month.year;
    final monthValue = month.month;
    if (item.duePeriod == 'yearly' && item.dueDay != null) {
      final dueMonth = item.dueMonth ?? monthValue;
      final lastDay = DateUtils.getDaysInMonth(year, dueMonth);
      final day = item.dueDay!.clamp(1, lastDay);
      return DateTime(year, dueMonth, day);
    }
    if (item.dueDay != null) {
      final lastDay = DateUtils.getDaysInMonth(year, monthValue);
      final day = item.dueDay!.clamp(1, lastDay);
      return DateTime(year, monthValue, day);
    }
    return _lastBusinessDayOfMonth(year, monthValue);
  }

  bool _subscriptionOccursOnDate(SubscriptionDefinition item, DateTime date) {
    final dueDate = _subscriptionDueDateForMonth(item, date);
    return isSameDay(dueDate, date);
  }

  DateTime _lastBusinessDayOfMonth(int year, int month) {
    var date = DateTime(year, month + 1, 0);
    while (date.weekday == DateTime.saturday ||
        date.weekday == DateTime.sunday) {
      date = date.subtract(const Duration(days: 1));
    }
    return DateTime(year, month, date.day);
  }

  LinkedHashMap<DateTime, int> _buildSubscriptionCounts(DateTime focusedDay) {
    final counts = LinkedHashMap<DateTime, int>(
      equals: isSameDay,
      hashCode: _getHashCode,
    );
    final startMonth = DateTime(focusedDay.year, focusedDay.month - 12);
    final endMonth = DateTime(focusedDay.year, focusedDay.month + 12);
    for (final item in _subscriptions) {
      for (var month = DateTime(startMonth.year, startMonth.month);
          !month.isAfter(endMonth);
          month = DateTime(month.year, month.month + 1)) {
        if (item.duePeriod == 'yearly' &&
            item.dueDay != null &&
            item.dueMonth != null &&
            item.dueMonth != month.month) {
          continue;
        }
        final dueDate = _subscriptionDueDateForMonth(item, month);
        counts[dueDate] = (counts[dueDate] ?? 0) + 1;
      }
    }
    return counts;
  }

  String _subscriptionTimingLabel(SubscriptionDefinition item, DateTime month) {
    if (item.duePeriod == 'yearly' &&
        item.dueDay != null &&
        item.dueMonth != null) {
      return 'Her yil: ${_fmtDate(_subscriptionDueDateForMonth(item, month))}';
    }
    if (item.dueDay != null) {
      return 'Son odeme gunu: ${_fmtDate(_subscriptionDueDateForMonth(item, month))}';
    }
    return 'Bu ay son is gunu: ${_fmtDate(_subscriptionDueDateForMonth(item, month))}';
  }

  bool _isSyntheticInvestmentPnlTx(FinanceTransaction tx) {
    final desc = (tx.description ?? '').trim().toLowerCase();
    return desc.startsWith('yatirim satis k/z') ||
        desc.startsWith('yatırım satış k/z');
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
            'Yatırım: ${it.symbol} • Miktar: ${_fmtQuantity(it.quantity)} • Birim: ${_fmtAmount(it.unitPrice)} TL'
        ..date = it.date
        ..createdAt = it.createdAt;
      result.add(cash);
      metaById[cashId] = _InvestmentCalendarMeta(
        symbol: it.symbol,
        rawType: it.type,
        isAssetSide: false,
        linkedAccountName: accountNames[it.investmentAccountId] ??
            'Yatırım #${it.investmentAccountId}',
        investmentTransactionId: it.id,
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
        investmentTransactionId: it.id,
      );
    }

    return (result, metaById);
  }

  // Takvimden secilen islemi ilgili duzenleme ekranina acarak gunceller.
  Future<void> _editTransaction(FinanceTransaction tx) async {
    bool? changed;
    final invMeta = _investmentMetaByTxId[tx.id];
    if (invMeta != null) {
      final invTx = _investmentById[invMeta.investmentTransactionId];
      if (invTx == null) return;
      changed = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => InvestmentEntryScreen(initialTransaction: invTx),
        ),
      );
    } else if (_isCariTx(tx)) {
      final cariTx = _cariTxBySyntheticId[tx.id];
      if (cariTx == null) return;
      changed = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => CariAccountScreen(initialTransaction: cariTx),
        ),
      );
    } else {
      changed = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => tx.type == 'income'
              ? IncomeEntryScreen(initialTransaction: tx)
              : ExpenseEntryScreen(initialTransaction: tx),
        ),
      );
    }
    if (changed == true && mounted) {
      await _load();
    }
  }

  // Takvimdeki hareketi tipine gore dogru servis uzerinden siler.
  Future<void> _deleteTransaction(FinanceTransaction tx) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('İşlemi Sil'),
        content: const Text('Bu işlem silinsin mi?'),
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

    try {
      final invMeta = _investmentMetaByTxId[tx.id];
      if (invMeta != null) {
        await AppRuntime.dataLayer.investments.deleteAndReturn(
          invMeta.investmentTransactionId,
        );
      } else if (_isCariTx(tx)) {
        final cariId = -tx.id - 1;
        await AppRuntime.dataLayer.cariTransactions.deleteAndReturn(cariId);
      } else {
        await AppRuntime.dataLayer.finance.deleteAndReturn(tx.id);
      }
      if (!mounted) return;
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('İşlem silindi.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Silme hatası: $e')),
      );
    }
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
    final colorScheme = Theme.of(context).colorScheme;
    final list = _selectedDayTransactions();
    final dayPlans = _selectedDayIncomeOccurrences();
    final dayExpensePlans = _selectedDayExpenseOccurrences();
    final daySubscriptions = _selectedDaySubscriptions();
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
          buildBarIconAction(
            context,
            onPressed: _load,
            icon: Icons.refresh,
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
                      child: Container(
                        decoration: context.surfaceDecoration(),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: TableCalendar<String>(
                            locale: 'tr_TR',
                            firstDay: DateTime(2000),
                            lastDay: DateTime(2100),
                            focusedDay: _focusedDay,
                            selectedDayPredicate: (day) =>
                                isSameDay(day, _selectedDate),
                            eventLoader: (day) {
                              final result = <String>[];
                              final txCount = _txCountByDay[day] ?? 0;
                              final planCount = _planCountByDay[day] ?? 0;
                              final expensePlanCount =
                                  _expensePlanCountByDay[day] ?? 0;
                              final subscriptionCount =
                                  _subscriptionCountByDay[day] ?? 0;
                              result.addAll(List.filled(txCount, 'tx'));
                              result.addAll(List.filled(planCount, 'plan'));
                              result.addAll(List.filled(
                                  expensePlanCount, 'expense_plan'));
                              result.addAll(List.filled(
                                  subscriptionCount, 'subscription'));
                              return result;
                            },
                            startingDayOfWeek: StartingDayOfWeek.monday,
                            headerStyle: HeaderStyle(
                              formatButtonVisible: false,
                              titleCentered: true,
                            ),
                            calendarStyle: CalendarStyle(
                              outsideDaysVisible: false,
                              selectedDecoration: BoxDecoration(
                                color: colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                              todayDecoration: BoxDecoration(
                                color: colorScheme.primary.withValues(alpha: 0.30),
                                shape: BoxShape.circle,
                              ),
                            ),
                            calendarBuilders: CalendarBuilders(
                              defaultBuilder: (context, day, focusedDay) {
                                final hasTx = (_txCountByDay[day] ?? 0) > 0;
                                final hasPlan = (_planCountByDay[day] ?? 0) > 0;
                                final hasExpensePlan =
                                    (_expensePlanCountByDay[day] ?? 0) > 0;
                                final hasSubscription =
                                    (_subscriptionCountByDay[day] ?? 0) > 0;
                                if (!hasTx &&
                                    !hasPlan &&
                                    !hasExpensePlan &&
                                    !hasSubscription) {
                                  return null;
                                }
                                final borderColor =
                                    (hasPlan || hasExpensePlan || hasSubscription)
                                    ? (hasExpensePlan
                                        ? Colors.red.shade400
                                        : hasSubscription
                                            ? Colors.teal.shade500
                                            : Colors.orange.shade500)
                                    : colorScheme.primary.withValues(alpha: 0.75);
                                final bgColor =
                                    (hasPlan || hasExpensePlan || hasSubscription)
                                    ? (hasExpensePlan
                                        ? Colors.red.shade50
                                        : hasSubscription
                                            ? Colors.teal.shade50
                                            : Colors.orange.shade50)
                                    : colorScheme.primary.withValues(alpha: 0.10);
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
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600),
                                  ),
                                );
                              },
                              markerBuilder: (context, day, events) {
                                final hasTx = events.contains('tx');
                                final hasPlan = events.contains('plan');
                                final hasExpensePlan =
                                    events.contains('expense_plan');
                                final hasSubscription =
                                    events.contains('subscription');
                                if (!hasTx &&
                                    !hasPlan &&
                                    !hasExpensePlan &&
                                    !hasSubscription) {
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
                                            color: colorScheme.primary,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      if (hasTx && hasPlan)
                                        const SizedBox(width: 3),
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
                                      if ((hasTx || hasPlan || hasExpensePlan) &&
                                          hasSubscription)
                                        const SizedBox(width: 3),
                                      if (hasSubscription)
                                        Container(
                                          width: 6,
                                          height: 6,
                                          decoration: BoxDecoration(
                                            color: Colors.teal.shade500,
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
                              setState(() {
                                _focusedDay = focusedDay;
                                _incomePlanOccurrences =
                                    _buildIncomePlanOccurrences(focusedDay);
                                _expensePlanOccurrences =
                                    _buildExpensePlanOccurrences(focusedDay);
                                _planCountByDay
                                  ..clear()
                                  ..addAll(_buildIncomePlanCounts(focusedDay));
                                _expensePlanCountByDay
                                  ..clear()
                                  ..addAll(_buildExpensePlanCounts(focusedDay));
                                _subscriptionCountByDay
                                  ..clear()
                                  ..addAll(_buildSubscriptionCounts(focusedDay));
                              });
                              if (_needsTransactionReload(focusedDay)) {
                                _load(
                                  focusedDay: focusedDay,
                                  showLoader: false,
                                );
                              }
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
                          '${_fmtDate(_selectedDate)} • ${list.length} hareket • ${dayPlans.length + dayExpensePlans.length} plan • ${daySubscriptions.length} sabit odeme',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    if (daySubscriptions.isNotEmpty)
                      _stableSection(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
                      child: Container(
                          decoration: context.surfaceDecoration(
                            accent: Colors.teal,
                            fillColor: Colors.teal.shade50,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Sabit Odemeler',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                ...daySubscriptions.map(
                                  (item) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '• ${item.name} • ${item.providerName}',
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          _subscriptionTimingLabel(
                                            item,
                                            _selectedDate,
                                          ),
                                          style: const TextStyle(
                                            color: Colors.black54,
                                          ),
                                        ),
                                        if (item.paymentType == 'fixed' &&
                                            item.defaultAmount != null)
                                          Text(
                                            'Sabit tutar: ${_fmtAmount(item.defaultAmount!)} TL',
                                            style: const TextStyle(
                                              color: Colors.black54,
                                            ),
                                          )
                                        else
                                          const Text(
                                            'Degisken tutarli sabit odeme',
                                            style: TextStyle(
                                              color: Colors.black54,
                                            ),
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
                                  (occurrence) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '• ${_incomeCategoryNameById(occurrence.plan.incomeCategoryId)}'
                                          ' • ${_fmtAmount(occurrence.plan.amount)} TL'
                                          ' • ${_incomePlanSummary(occurrence.plan)}'
                                          ' • ${_fmtDate(occurrence.date)}',
                                        ),
                                        if (occurrence.isActionable) ...[
                                          const SizedBox(height: 6),
                                          Wrap(
                                            spacing: 6,
                                            runSpacing: 6,
                                            children: [
                                              OutlinedButton(
                                                style: OutlinedButton.styleFrom(
                                                  foregroundColor:
                                                      AppColors.income,
                                                  side: const BorderSide(
                                                    color: AppColors.income,
                                                  ),
                                                ),
                                                onPressed: () => _completePlan(
                                                  occurrence.plan,
                                                ),
                                                child: const Text('Gerçekleşti'),
                                              ),
                                              OutlinedButton(
                                                onPressed: () => _postponePlan(
                                                  occurrence.plan,
                                                ),
                                                child: const Text('Ertele'),
                                              ),
                                              OutlinedButton(
                                                onPressed: () => _cancelPlan(
                                                  occurrence.plan,
                                                ),
                                                child: const Text('İptal Et'),
                                              ),
                                            ],
                                          ),
                                        ] else
                                          const Padding(
                                            padding: EdgeInsets.only(top: 6),
                                            child: Text(
                                              'Gelecek plan onizlemesi',
                                              style: TextStyle(
                                                color: Colors.black54,
                                              ),
                                            ),
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
                                  (occurrence) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '• ${_expenseCategoryNameById(occurrence.plan.expenseCategoryId)}'
                                          ' • ${_fmtAmount(occurrence.plan.amount)} TL'
                                          ' • ${_expensePlanSummary(occurrence.plan)}'
                                          ' • ${_fmtDate(occurrence.date)}',
                                        ),
                                        if (occurrence.isActionable) ...[
                                          const SizedBox(height: 6),
                                          Wrap(
                                            spacing: 6,
                                            runSpacing: 6,
                                            children: [
                                              OutlinedButton(
                                                style: OutlinedButton.styleFrom(
                                                  foregroundColor:
                                                      AppColors.expense,
                                                  side: const BorderSide(
                                                    color: AppColors.expense,
                                                  ),
                                                ),
                                                onPressed: () =>
                                                    _completeExpensePlan(
                                                  occurrence.plan,
                                                ),
                                                child: const Text('Gerçekleşti'),
                                              ),
                                              OutlinedButton(
                                                onPressed: () =>
                                                    _postponeExpensePlan(
                                                  occurrence.plan,
                                                ),
                                                child: const Text('Ertele'),
                                              ),
                                              OutlinedButton(
                                                onPressed: () =>
                                                    _cancelExpensePlan(
                                                  occurrence.plan,
                                                ),
                                                child: const Text('İptal Et'),
                                              ),
                                            ],
                                          ),
                                        ] else
                                          const Padding(
                                            padding: EdgeInsets.only(top: 6),
                                            child: Text(
                                              'Gelecek plan onizlemesi',
                                              style: TextStyle(
                                                color: Colors.black54,
                                              ),
                                            ),
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
                        child: const Center(
                            child: Text('Seçili gün için hareket yok.')),
                      )
                    else
                      ...list.map(
                        (tx) => _stableSection(
                          padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
                          child: Builder(
                            builder: (_) {
                              final isIncome = tx.type == 'income';
                              final accountName = _accountNames[tx.accountId] ??
                                  'Hesap #${tx.accountId}';
                              final invMeta = _investmentMetaByTxId[tx.id];
                              final amountText = invMeta == null
                                  ? '${isIncome ? '+' : '-'}${_fmtAmount(tx.amount)} TL'
                                  : invMeta.isAssetSide
                                      ? '${isIncome ? '+' : '-'}${_fmtQuantity(tx.amount)} ${invMeta.symbol}'
                                      : '${isIncome ? '+' : '-'}${_fmtAmount(tx.amount)} TL';

                              return Column(
                                children: [
                                  ListTile(
                                    leading: Icon(
                                      isIncome
                                          ? Icons.arrow_downward
                                          : Icons.arrow_upward,
                                      color:
                                          isIncome ? Colors.green : Colors.red,
                                    ),
                                    title: Text(
                                        '${_txTypeLabel(tx)} • ${_categoryName(tx)}'),
                                    subtitle: Text(
                                      '${_fmtDateTime(tx.date)} • $accountName\n'
                                      '${invMeta != null ? '${invMeta.isAssetSide ? 'Nakit Hesabı' : 'Yatırım Hesabı'}: ${invMeta.linkedAccountName}\n' : ''}'
                                      'Açıklama: ${(tx.description ?? '').trim().isEmpty ? '-' : tx.description!.trim()}',
                                    ),
                                    isThreeLine: true,
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          amountText,
                                          style: TextStyle(
                                            color: isIncome
                                                ? Colors.green
                                                : Colors.red,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        PopupMenuButton<String>(
                                          onSelected: (v) async {
                                            if (v == 'edit') {
                                              await _editTransaction(tx);
                                            } else if (v == 'delete') {
                                              await _deleteTransaction(tx);
                                            }
                                          },
                                          itemBuilder: (_) => const [
                                            PopupMenuItem<String>(
                                              value: 'edit',
                                              child: Text('Düzenle'),
                                            ),
                                            PopupMenuItem<String>(
                                              value: 'delete',
                                              child: Text('Sil'),
                                            ),
                                          ],
                                        ),
                                      ],
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
    return Builder(
      builder: (context) => Container(
        decoration: context.surfaceDecoration(accent: color),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _fmtAmount(value),
                style: TextStyle(
                    color: color, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
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
  final int investmentTransactionId;

  const _InvestmentCalendarMeta({
    required this.symbol,
    required this.rawType,
    required this.isAssetSide,
    required this.linkedAccountName,
    required this.investmentTransactionId,
  });
}

class _IncomePlanOccurrence {
  const _IncomePlanOccurrence({
    required this.plan,
    required this.date,
    required this.isActionable,
  });

  final IncomePlan plan;
  final DateTime date;
  final bool isActionable;
}

class _ExpensePlanOccurrence {
  const _ExpensePlanOccurrence({
    required this.plan,
    required this.date,
    required this.isActionable,
  });

  final ExpensePlan plan;
  final DateTime date;
  final bool isActionable;
}
