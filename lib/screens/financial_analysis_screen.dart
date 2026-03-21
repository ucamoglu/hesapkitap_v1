import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/category.dart';
import '../models/finance_transaction.dart';
import '../models/income_category.dart';
import '../services/category_service.dart';
import '../services/finance_transaction_service.dart';
import '../services/income_category_service.dart';
import '../theme/app_colors.dart';
import '../utils/navigation_helpers.dart';

enum _AnalysisPeriodMode { monthly, yearly }

class FinancialAnalysisScreen extends StatefulWidget {
  const FinancialAnalysisScreen({super.key});

  @override
  State<FinancialAnalysisScreen> createState() => _FinancialAnalysisScreenState();
}

class _FinancialAnalysisScreenState extends State<FinancialAnalysisScreen> {
  bool _loading = true;
  String? _error;
  List<FinanceTransaction> _transactions = [];
  Map<int, String> _expenseCategoryNames = {};
  Map<int, String> _incomeCategoryNames = {};
  _AnalysisPeriodMode _periodMode = _AnalysisPeriodMode.monthly;
  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;

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
      final results = await Future.wait([
        FinanceTransactionService.getAll(),
        CategoryService.getAllExpenseCategories(),
        IncomeCategoryService.getAll(),
      ]);
      final transactions = results[0] as List<FinanceTransaction>;
      final expenseCategories = results[1] as List<Category>;
      final incomeCategories = results[2] as List<IncomeCategory>;

      if (!mounted) return;
      setState(() {
        _transactions = transactions;
        _expenseCategoryNames = {
          for (final category in expenseCategories)
            category.id: category.name.trim().isEmpty
                ? 'Gider #${category.id}'
                : category.name.trim(),
        };
        _incomeCategoryNames = {
          for (final category in incomeCategories)
            category.id: category.name.trim().isEmpty
                ? 'Gelir #${category.id}'
                : category.name.trim(),
        };
        final years = _availableYears();
        if (years.isNotEmpty && !years.contains(_selectedYear)) {
          _selectedYear = years.first;
        }
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Finansal analiz verileri yüklenemedi: $e';
        _loading = false;
      });
    }
  }

  List<int> _availableYears() {
    final years = _transactions.map((tx) => tx.date.year).toSet().toList()
      ..sort((a, b) => b.compareTo(a));
    if (years.isEmpty) {
      return [DateTime.now().year];
    }
    return years;
  }

  List<int> _availableMonthsForYear(int year) {
    final months = _transactions
        .where((tx) => tx.date.year == year)
        .map((tx) => tx.date.month)
        .toSet()
        .toList()
      ..sort();
    if (months.isEmpty) {
      return List<int>.generate(12, (index) => index + 1);
    }
    return months;
  }

  List<FinanceTransaction> _periodTransactions() {
    final effectiveMonth = _effectiveSelectedMonth();
    return _transactions.where((tx) {
      if (tx.date.year != _selectedYear) return false;
      if (_periodMode == _AnalysisPeriodMode.monthly &&
          tx.date.month != effectiveMonth) {
        return false;
      }
      return true;
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  List<FinanceTransaction> _comparisonTransactions() {
    if (_periodMode == _AnalysisPeriodMode.monthly) {
      final previous = DateTime(_selectedYear, _effectiveSelectedMonth() - 1, 1);
      return _transactions.where((tx) {
        return tx.date.year == previous.year && tx.date.month == previous.month;
      }).toList()
        ..sort((a, b) => b.date.compareTo(a.date));
    }

    final previousYear = _selectedYear - 1;
    return _transactions.where((tx) => tx.date.year == previousYear).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  int _effectiveSelectedMonth() {
    final months = _availableMonthsForYear(_selectedYear);
    if (months.contains(_selectedMonth)) {
      return _selectedMonth;
    }
    return months.last;
  }

  double _sumByType(List<FinanceTransaction> items, String type) {
    return items
        .where((tx) => tx.type == type)
        .fold<double>(0, (sum, tx) => sum + tx.amount);
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

  String _fmtPercent(double value) {
    return '${value.toStringAsFixed(1).replaceAll('.', ',')}%';
  }

  String _monthLabel(int month) {
    return DateFormat('MMMM', 'tr_TR').format(DateTime(2000, month));
  }

  String _periodLabel() {
    if (_periodMode == _AnalysisPeriodMode.monthly) {
      return '${_monthLabel(_effectiveSelectedMonth())} $_selectedYear';
    }
    return '$_selectedYear';
  }

  String _comparisonPeriodLabel() {
    if (_periodMode == _AnalysisPeriodMode.monthly) {
      final previous = DateTime(_selectedYear, _effectiveSelectedMonth() - 1, 1);
      return '${_monthLabel(previous.month)} ${previous.year}';
    }
    return '${_selectedYear - 1}';
  }

  String _deltaText(double current, double previous) {
    final delta = current - previous;
    final sign = delta >= 0 ? '+' : '';
    return '$sign${_fmtMoney(delta)} TL';
  }

  String _deltaPercentText(double current, double previous) {
    if (previous.abs() <= 1e-9) {
      if (current.abs() <= 1e-9) return '%0,0';
      return 'Yeni';
    }
    final percent = ((current - previous) / previous) * 100;
    final sign = percent >= 0 ? '+' : '';
    return '$sign${_fmtPercent(percent)}';
  }

  Map<String, double> _categoryTotals({
    required List<FinanceTransaction> items,
    required String type,
  }) {
    final totals = <String, double>{};
    for (final tx in items.where((item) => item.type == type)) {
      final names =
          type == 'expense' ? _expenseCategoryNames : _incomeCategoryNames;
      final label = names[tx.categoryId] ?? '${type == 'expense' ? 'Gider' : 'Gelir'} #${tx.categoryId}';
      totals[label] = (totals[label] ?? 0) + tx.amount;
    }
    final sortedEntries = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return {
      for (final entry in sortedEntries) entry.key: entry.value,
    };
  }

  List<_CategoryDelta> _topExpenseCategoryChanges({
    required List<FinanceTransaction> currentItems,
    required List<FinanceTransaction> previousItems,
  }) {
    final current = _categoryTotals(items: currentItems, type: 'expense');
    final previous = _categoryTotals(items: previousItems, type: 'expense');
    final names = {...current.keys, ...previous.keys};
    final deltas = names
        .map(
          (name) => _CategoryDelta(
            label: name,
            current: current[name] ?? 0,
            previous: previous[name] ?? 0,
          ),
        )
        .where((item) => item.current > 0 || item.previous > 0)
        .toList()
      ..sort((a, b) => b.delta.compareTo(a.delta));
    return deltas.take(5).toList();
  }

  List<_TrendBucket> _last12MonthBuckets() {
    final now = DateTime.now();
    final buckets = <_TrendBucket>[];
    for (int offset = 11; offset >= 0; offset--) {
      final target = DateTime(now.year, now.month - offset, 1);
      double income = 0;
      double expense = 0;
      for (final tx in _transactions) {
        if (tx.date.year == target.year && tx.date.month == target.month) {
          if (tx.type == 'income') {
            income += tx.amount;
          } else if (tx.type == 'expense') {
            expense += tx.amount;
          }
        }
      }
      buckets.add(
        _TrendBucket(
          label: DateFormat('MMM', 'tr_TR').format(target),
          income: income,
          expense: expense,
        ),
      );
    }
    return buckets;
  }

  Widget _summaryCard({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
    String? caption,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (caption != null) ...[
            const SizedBox(height: 6),
            Text(
              caption,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _categorySection({
    required String title,
    required Color color,
    required Map<String, double> totals,
    required String emptyText,
  }) {
    final entries = totals.entries.take(6).toList();
    final totalValue = entries.fold<double>(0, (sum, item) => sum + item.value);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          if (entries.isEmpty)
            Text(
              emptyText,
              style: const TextStyle(color: Colors.black54),
            )
          else
            ...entries.map((entry) {
              final ratio = totalValue <= 0 ? 0.0 : (entry.value / totalValue);
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            entry.key,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${_fmtMoney(entry.value)} TL',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: ratio.clamp(0, 1),
                        minHeight: 10,
                        backgroundColor: color.withValues(alpha: 0.12),
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Pay: ${_fmtPercent(ratio * 100)}',
                      style: const TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _trendSection(List<_TrendBucket> buckets) {
    final maxValue = buckets.fold<double>(
      0,
      (max, item) => [
        max,
        item.income,
        item.expense,
      ].reduce((a, b) => a > b ? a : b),
    );
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Son 12 Ay Gelir / Gider Trendi',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          const Text(
            'Yeşil sütun gelir, kırmızı sütun gider tutarını gösterir.',
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 220,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final bucket in buckets)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _trendBar(
                                    value: bucket.income,
                                    maxValue: maxValue,
                                    color: AppColors.income,
                                  ),
                                  const SizedBox(width: 4),
                                  _trendBar(
                                    value: bucket.expense,
                                    maxValue: maxValue,
                                    color: AppColors.expense,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            bucket.label,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Net ${_fmtMoney(bucket.income - bucket.expense)}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.black54,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _comparisonSection({
    required List<FinanceTransaction> currentItems,
    required List<FinanceTransaction> previousItems,
  }) {
    final currentIncome = _sumByType(currentItems, 'income');
    final currentExpense = _sumByType(currentItems, 'expense');
    final currentNet = currentIncome - currentExpense;

    final previousIncome = _sumByType(previousItems, 'income');
    final previousExpense = _sumByType(previousItems, 'expense');
    final previousNet = previousIncome - previousExpense;

    Widget row({
      required String title,
      required double current,
      required double previous,
      required Color color,
    }) {
      final delta = current - previous;
      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.18)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_periodLabel()}: ${_fmtMoney(current)} TL',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    '${_comparisonPeriodLabel()}: ${_fmtMoney(previous)} TL',
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _deltaText(current, previous),
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: delta >= 0 ? color : Colors.black87,
                  ),
                ),
                Text(
                  _deltaPercentText(current, previous),
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dönem Karşılaştırması',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            '${_periodLabel()} ile ${_comparisonPeriodLabel()} karşılaştırılıyor.',
            style: const TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 12),
          row(
            title: 'Gelir',
            current: currentIncome,
            previous: previousIncome,
            color: AppColors.income,
          ),
          row(
            title: 'Gider',
            current: currentExpense,
            previous: previousExpense,
            color: AppColors.expense,
          ),
          row(
            title: 'Net Durum',
            current: currentNet,
            previous: previousNet,
            color: AppColors.brand,
          ),
        ],
      ),
    );
  }

  Widget _expenseChangeSection(List<_CategoryDelta> deltas) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'En Çok Artan Gider Kategorileri',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            '${_periodLabel()} dönemi, ${_comparisonPeriodLabel()} ile kıyaslanır.',
            style: const TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 12),
          if (deltas.isEmpty)
            const Text(
              'Karşılaştırılacak yeterli gider verisi bulunmuyor.',
              style: TextStyle(color: Colors.black54),
            )
          else
            ...deltas.map((item) {
              final positive = item.delta >= 0;
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (positive ? AppColors.expense : AppColors.income)
                      .withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: (positive ? AppColors.expense : AppColors.income)
                        .withValues(alpha: 0.18),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.label,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_periodLabel()}: ${_fmtMoney(item.current)} TL',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          Text(
                            '${_comparisonPeriodLabel()}: ${_fmtMoney(item.previous)} TL',
                            style: const TextStyle(color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _deltaText(item.current, item.previous),
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color:
                                positive ? AppColors.expense : AppColors.income,
                          ),
                        ),
                        Text(
                          _deltaPercentText(item.current, item.previous),
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _trendBar({
    required double value,
    required double maxValue,
    required Color color,
  }) {
    final heightFactor = maxValue <= 0 ? 0.0 : (value / maxValue).clamp(0, 1);
    return Flexible(
      child: Container(
        width: 14,
        height: (150 * heightFactor).clamp(6, 150).toDouble(),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _filterPanel() {
    final years = _availableYears();
    final months = _availableMonthsForYear(_selectedYear);
    final selectedMonth = _effectiveSelectedMonth();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.brandSoft,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.brand.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Analiz Filtresi',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              ChoiceChip(
                label: const Text('Aylık Analiz'),
                selected: _periodMode == _AnalysisPeriodMode.monthly,
                onSelected: (_) {
                  setState(() {
                    _periodMode = _AnalysisPeriodMode.monthly;
                  });
                },
              ),
              ChoiceChip(
                label: const Text('Yıllık Analiz'),
                selected: _periodMode == _AnalysisPeriodMode.yearly,
                onSelected: (_) {
                  setState(() {
                    _periodMode = _AnalysisPeriodMode.yearly;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<int>(
                  initialValue: _selectedYear,
                  decoration: const InputDecoration(
                    labelText: 'Yıl',
                    border: OutlineInputBorder(),
                  ),
                  items: years
                      .map(
                        (year) => DropdownMenuItem(
                          value: year,
                          child: Text('$year'),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _selectedYear = value;
                    });
                  },
                ),
              ),
              if (_periodMode == _AnalysisPeriodMode.monthly) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    initialValue: selectedMonth,
                    decoration: const InputDecoration(
                      labelText: 'Ay',
                      border: OutlineInputBorder(),
                    ),
                    items: months
                        .map(
                          (month) => DropdownMenuItem(
                            value: month,
                            child: Text(_monthLabel(month)),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _selectedMonth = value;
                      });
                    },
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  List<List<String>> _categoryRows(Map<String, double> totals) {
    return totals.entries
        .take(6)
        .map((entry) => [entry.key, '${_fmtMoney(entry.value)} TL'])
        .toList();
  }

  List<List<String>> _trendRows(List<_TrendBucket> buckets) {
    return buckets
        .map(
          (bucket) => [
            bucket.label,
            '${_fmtMoney(bucket.income)} TL',
            '${_fmtMoney(bucket.expense)} TL',
            '${_fmtMoney(bucket.income - bucket.expense)} TL',
          ],
        )
        .toList();
  }

  List<List<String>> _comparisonRows({
    required List<FinanceTransaction> currentItems,
    required List<FinanceTransaction> previousItems,
  }) {
    final currentIncome = _sumByType(currentItems, 'income');
    final currentExpense = _sumByType(currentItems, 'expense');
    final currentNet = currentIncome - currentExpense;
    final previousIncome = _sumByType(previousItems, 'income');
    final previousExpense = _sumByType(previousItems, 'expense');
    final previousNet = previousIncome - previousExpense;

    return [
      [
        'Gelir',
        '${_fmtMoney(currentIncome)} TL',
        '${_fmtMoney(previousIncome)} TL',
        _deltaText(currentIncome, previousIncome),
        _deltaPercentText(currentIncome, previousIncome),
      ],
      [
        'Gider',
        '${_fmtMoney(currentExpense)} TL',
        '${_fmtMoney(previousExpense)} TL',
        _deltaText(currentExpense, previousExpense),
        _deltaPercentText(currentExpense, previousExpense),
      ],
      [
        'Net Durum',
        '${_fmtMoney(currentNet)} TL',
        '${_fmtMoney(previousNet)} TL',
        _deltaText(currentNet, previousNet),
        _deltaPercentText(currentNet, previousNet),
      ],
    ];
  }

  List<List<String>> _expenseChangeRows(List<_CategoryDelta> deltas) {
    return deltas
        .map(
          (item) => [
            item.label,
            '${_fmtMoney(item.current)} TL',
            '${_fmtMoney(item.previous)} TL',
            _deltaText(item.current, item.previous),
            _deltaPercentText(item.current, item.previous),
          ],
        )
        .toList();
  }

  Future<Uint8List> _buildPdf(PdfPageFormat format) async {
    final font = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Roboto-Regular.ttf'),
    );
    final bold = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Roboto-Bold.ttf'),
    );
    final doc = pw.Document(
      theme: pw.ThemeData.withFont(base: font, bold: bold),
    );

    final periodTransactions = _periodTransactions();
    final income = _sumByType(periodTransactions, 'income');
    final expense = _sumByType(periodTransactions, 'expense');
    final net = income - expense;
    final savingsRate = income <= 0 ? 0.0 : (net / income) * 100;
    final expenseTotals = _categoryTotals(
      items: periodTransactions,
      type: 'expense',
    );
    final incomeTotals = _categoryTotals(
      items: periodTransactions,
      type: 'income',
    );
    final comparisonTransactions = _comparisonTransactions();
    final expenseChanges = _topExpenseCategoryChanges(
      currentItems: periodTransactions,
      previousItems: comparisonTransactions,
    );
    final trendBuckets = _last12MonthBuckets();

    pw.Widget metricCell(String title, String value, PdfColor color) {
      return pw.Container(
        padding: const pw.EdgeInsets.all(10),
        decoration: pw.BoxDecoration(
          color: color.shade(0.08),
          borderRadius: pw.BorderRadius.circular(10),
          border: pw.Border.all(color: color.shade(0.35)),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              title,
              style: pw.TextStyle(
                font: bold,
                fontSize: 10,
                color: color,
              ),
            ),
            pw.SizedBox(height: 6),
            pw.Text(
              value,
              style: pw.TextStyle(font: bold, fontSize: 14),
            ),
          ],
        ),
      );
    }

    pw.Widget sectionTable({
      required String title,
      required List<String> headers,
      required List<List<String>> rows,
      required PdfColor color,
      required String emptyText,
    }) {
      return pw.Container(
        margin: const pw.EdgeInsets.only(bottom: 14),
        padding: const pw.EdgeInsets.all(14),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.grey300),
          borderRadius: pw.BorderRadius.circular(12),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(title, style: pw.TextStyle(font: bold, fontSize: 14)),
            pw.SizedBox(height: 8),
            if (rows.isEmpty)
              pw.Text(emptyText)
            else
              pw.TableHelper.fromTextArray(
                headers: headers,
                data: rows,
                headerStyle: pw.TextStyle(
                  font: bold,
                  color: PdfColors.white,
                  fontSize: 9,
                ),
                cellStyle: pw.TextStyle(font: font, fontSize: 9),
                headerDecoration: pw.BoxDecoration(color: color),
                cellAlignment: pw.Alignment.centerLeft,
                headerAlignment: pw.Alignment.centerLeft,
                border: pw.TableBorder.all(color: PdfColors.grey300),
              ),
          ],
        ),
      );
    }

    doc.addPage(
      pw.MultiPage(
        pageFormat: format,
        margin: const pw.EdgeInsets.all(24),
        build: (context) => [
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromInt(AppColors.brandSoft.toARGB32()),
              borderRadius: pw.BorderRadius.circular(12),
              border: pw.Border.all(
                color: PdfColor.fromInt(AppColors.brand.toARGB32()),
              ),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Finansal Analiz Raporu',
                      style: pw.TextStyle(font: bold, fontSize: 18),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text('Seçili Dönem: ${_periodLabel()}'),
                    pw.Text('Rapor Tarihi: ${DateFormat('dd.MM.yyyy').format(DateTime.now())}'),
                  ],
                ),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromInt(AppColors.brand.toARGB32()),
                    borderRadius: pw.BorderRadius.circular(999),
                  ),
                  child: pw.Text(
                    'HesapKitap',
                    style: pw.TextStyle(font: bold, color: PdfColors.white),
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 14),
          pw.Row(
            children: [
              pw.Expanded(
                child: metricCell(
                  'Toplam Gelir',
                  '${_fmtMoney(income)} TL',
                  PdfColor.fromInt(AppColors.income.toARGB32()),
                ),
              ),
              pw.SizedBox(width: 8),
              pw.Expanded(
                child: metricCell(
                  'Toplam Gider',
                  '${_fmtMoney(expense)} TL',
                  PdfColor.fromInt(AppColors.expense.toARGB32()),
                ),
              ),
              pw.SizedBox(width: 8),
              pw.Expanded(
                child: metricCell(
                  'Net Durum',
                  '${net >= 0 ? '+' : ''}${_fmtMoney(net)} TL',
                  PdfColor.fromInt(
                    (net >= 0 ? AppColors.income : AppColors.expense)
                        .toARGB32(),
                  ),
                ),
              ),
              pw.SizedBox(width: 8),
              pw.Expanded(
                child: metricCell(
                  'Tasarruf Oranı',
                  _fmtPercent(savingsRate),
                  PdfColor.fromInt(AppColors.brand.toARGB32()),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 14),
          sectionTable(
            title: 'Gider Kategorileri',
            headers: const ['Kategori', 'Tutar'],
            rows: _categoryRows(expenseTotals),
            color: PdfColor.fromInt(AppColors.expense.toARGB32()),
            emptyText: 'Seçili dönemde gider kaydı bulunmuyor.',
          ),
          sectionTable(
            title: 'Gelir Kategorileri',
            headers: const ['Kategori', 'Tutar'],
            rows: _categoryRows(incomeTotals),
            color: PdfColor.fromInt(AppColors.income.toARGB32()),
            emptyText: 'Seçili dönemde gelir kaydı bulunmuyor.',
          ),
          sectionTable(
            title: 'Dönem Karşılaştırması',
            headers: [
              'Metrik',
              _periodLabel(),
              _comparisonPeriodLabel(),
              'Fark',
              'Oran',
            ],
            rows: _comparisonRows(
              currentItems: periodTransactions,
              previousItems: comparisonTransactions,
            ),
            color: PdfColor.fromInt(AppColors.brand.toARGB32()),
            emptyText: 'Karşılaştırma verisi bulunmuyor.',
          ),
          sectionTable(
            title: 'En Çok Artan Gider Kategorileri',
            headers: [
              'Kategori',
              _periodLabel(),
              _comparisonPeriodLabel(),
              'Fark',
              'Oran',
            ],
            rows: _expenseChangeRows(expenseChanges),
            color: PdfColor.fromInt(AppColors.expense.toARGB32()),
            emptyText: 'Karşılaştırılacak yeterli gider verisi bulunmuyor.',
          ),
          sectionTable(
            title: 'Son 12 Ay Gelir / Gider Trendi',
            headers: const ['Ay', 'Gelir', 'Gider', 'Net'],
            rows: _trendRows(trendBuckets),
            color: PdfColor.fromInt(AppColors.brand.toARGB32()),
            emptyText: 'Trend verisi bulunmuyor.',
          ),
        ],
      ),
    );

    return doc.save();
  }

  void _openPdfPreview() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          drawer: buildAppMenuDrawer(),
          appBar: AppBar(
            leading: const BackButton(),
            title: const Text('PDF Rapor'),
            actions: [buildHomeAction(context)],
          ),
          body: PdfPreview(
            build: _buildPdf,
            canChangePageFormat: false,
            canChangeOrientation: false,
            canDebug: false,
            allowSharing: true,
            allowPrinting: true,
            pdfFileName: 'finansal_analiz_raporu.pdf',
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    rememberDrawerSelectionForScreen(widget);

    final periodTransactions = _periodTransactions();
    final income = _sumByType(periodTransactions, 'income');
    final expense = _sumByType(periodTransactions, 'expense');
    final net = income - expense;
    final savingsRate = income <= 0 ? 0.0 : (net / income) * 100;
    final expenseTotals = _categoryTotals(
      items: periodTransactions,
      type: 'expense',
    );
    final incomeTotals = _categoryTotals(
      items: periodTransactions,
      type: 'income',
    );
    final comparisonTransactions = _comparisonTransactions();
    final expenseChanges = _topExpenseCategoryChanges(
      currentItems: periodTransactions,
      previousItems: comparisonTransactions,
    );
    final trendBuckets = _last12MonthBuckets();

    return Scaffold(
      drawer: buildAppMenuDrawer(),
      appBar: AppBar(
        leading: buildMenuLeading(),
        title: const Text('Finansal Analiz'),
        actions: [
          IconButton(
            onPressed: _openPdfPreview,
            icon: const Icon(Icons.picture_as_pdf_outlined),
            tooltip: 'PDF Al',
          ),
          buildHomeAction(context),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _filterPanel(),
                      const SizedBox(height: 16),
                      Text(
                        'Seçili Dönem: ${_periodLabel()}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 12),
                      GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        childAspectRatio: 1.35,
                        children: [
                          _summaryCard(
                            title: 'Toplam Gelir',
                            value: '${_fmtMoney(income)} TL',
                            color: AppColors.income,
                            icon: Icons.south_west,
                            caption:
                                '${periodTransactions.where((tx) => tx.type == 'income').length} gelir kaydı',
                          ),
                          _summaryCard(
                            title: 'Toplam Gider',
                            value: '${_fmtMoney(expense)} TL',
                            color: AppColors.expense,
                            icon: Icons.north_east,
                            caption:
                                '${periodTransactions.where((tx) => tx.type == 'expense').length} gider kaydı',
                          ),
                          _summaryCard(
                            title: 'Net Durum',
                            value:
                                '${net >= 0 ? '+' : ''}${_fmtMoney(net)} TL',
                            color: net >= 0 ? AppColors.income : AppColors.expense,
                            icon: net >= 0
                                ? Icons.trending_up
                                : Icons.trending_down,
                            caption: 'Gelir - gider farkı',
                          ),
                          _summaryCard(
                            title: 'Tasarruf Oranı',
                            value: _fmtPercent(savingsRate),
                            color: AppColors.brand,
                            icon: Icons.pie_chart_outline,
                            caption: 'Net / gelir oranı',
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _categorySection(
                        title: 'Gider Kategorileri',
                        color: AppColors.expense,
                        totals: expenseTotals,
                        emptyText: 'Seçili dönemde gider kaydı bulunmuyor.',
                      ),
                      const SizedBox(height: 16),
                      _categorySection(
                        title: 'Gelir Kategorileri',
                        color: AppColors.income,
                        totals: incomeTotals,
                        emptyText: 'Seçili dönemde gelir kaydı bulunmuyor.',
                      ),
                      const SizedBox(height: 16),
                      _comparisonSection(
                        currentItems: periodTransactions,
                        previousItems: comparisonTransactions,
                      ),
                      const SizedBox(height: 16),
                      _expenseChangeSection(expenseChanges),
                      const SizedBox(height: 16),
                      _trendSection(trendBuckets),
                    ],
                  ),
                ),
    );
  }
}

class _TrendBucket {
  final String label;
  final double income;
  final double expense;

  const _TrendBucket({
    required this.label,
    required this.income,
    required this.expense,
  });
}

class _CategoryDelta {
  final String label;
  final double current;
  final double previous;

  const _CategoryDelta({
    required this.label,
    required this.current,
    required this.previous,
  });

  double get delta => current - previous;
}
