import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/cari_transaction.dart';
import '../models/finance_transaction.dart';
import '../models/investment_transaction.dart';
import 'cari_account_screen.dart';
import 'expense_entry_screen.dart';
import 'income_entry_screen.dart';
import 'investment_entry_screen.dart';
import '../services/account_service.dart';
import '../services/cari_card_service.dart';
import '../services/cari_transaction_service.dart';
import '../services/category_service.dart';
import '../services/finance_transaction_service.dart';
import '../services/income_category_service.dart';
import '../services/investment_transaction_service.dart';
import '../services/transaction_attachment_service.dart';
import '../theme/app_colors.dart';
import '../utils/navigation_helpers.dart';

enum _TypeFilter { all, income, expense, incomeExpense, cari }
enum _CariKindFilter { all, debt, collection }

enum _DatePreset { all, day, week, month, year, custom }

enum _GroupBy { none, day, week, month, year, category, account }

class _CategoryOption {
  final String key;
  final String type;
  final int id;
  final String label;

  const _CategoryOption({
    required this.key,
    required this.type,
    required this.id,
    required this.label,
  });
}

class _GroupedBucket {
  final String key;
  final String label;
  final List<FinanceTransaction> items;

  const _GroupedBucket({
    required this.key,
    required this.label,
    required this.items,
  });
}

class IncomeExpenseTransactionsScreen extends StatefulWidget {
  const IncomeExpenseTransactionsScreen({super.key});

  @override
  State<IncomeExpenseTransactionsScreen> createState() =>
      _IncomeExpenseTransactionsScreenState();
}

class _IncomeExpenseTransactionsScreenState
    extends State<IncomeExpenseTransactionsScreen> {
  static const List<String> _monthNames = [
    'Ocak',
    'Şubat',
    'Mart',
    'Nisan',
    'Mayıs',
    'Haziran',
    'Temmuz',
    'Ağustos',
    'Eylül',
    'Ekim',
    'Kasım',
    'Aralık',
  ];

  bool _loading = true;
  String? _error;

  List<FinanceTransaction> _all = [];
  Map<int, String> _accountNames = {};
  Map<int, String> _incomeCategoryNames = {};
  Map<int, String> _expenseCategoryNames = {};
  Map<int, String> _cariCardNames = {};
  Map<int, String> _cariRawTypeByTxId = {};
  Map<int, _InvestmentHistoryMeta> _investmentMetaByTxId = {};
  Map<int, int> _investmentTxIdByFinanceTxId = {};
  Map<int, InvestmentTransaction> _investmentById = {};
  Map<String, int> _attachmentCountMap = {};
  List<_CategoryOption> _categoryOptions = [];

  _TypeFilter _typeFilter = _TypeFilter.all;
  _CariKindFilter _cariKindFilter = _CariKindFilter.all;
  _DatePreset _datePreset = _DatePreset.month;
  _GroupBy _groupBy = _GroupBy.day;
  int? _selectedAccountId;
  String? _selectedCategoryKey;
  DateTime _periodReferenceDate = DateTime.now();
  DateTime? _customStart;
  DateTime? _customEnd;
  bool _filtersExpanded = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final tx = await FinanceTransactionService.getAll();
      final cariTx = await CariTransactionService.getAll();
      final investmentTx = await InvestmentTransactionService.getAll();
      final accounts = await AccountService.getAllAccounts();
      final incomeCategories = await IncomeCategoryService.getAll();
      final expenseCategories = await CategoryService.getAllExpenseCategories();
      final manualIncomeCategories = await IncomeCategoryService.getAllManual();
      final manualExpenseCategories =
          await CategoryService.getAllManualExpenseCategories();
      final cariCards = await CariCardService.getAll();
      final attachmentCountMap = await TransactionAttachmentService.getCountMap();

      if (!mounted) return;

      final mappedCari = cariTx.map(_mapCariToFinanceLike).toList();
      final mappedInvestment = _mapInvestmentToFinanceLike(
        investmentTx,
        {for (final a in accounts) a.id: a.name},
      );
      final investmentById = {
        for (final it in investmentTx) it.id: it,
      };
      final investmentFinanceLinkMap = _buildInvestmentFinanceLinkMap(
        financeTx: tx,
        investmentTx: investmentTx,
      );
      final cariTypeMap = <int, String>{
        for (final c in cariTx) -(c.id + 1): c.type,
      };
      final merged = [...tx, ...mappedCari, ...mappedInvestment.$1]
        ..sort((a, b) => b.date.compareTo(a.date));
      final accountFilterMap = {
        for (final a in accounts.where((a) => a.type != 'investment')) a.id: a.name,
      };

      setState(() {
        _all = merged;
        _accountNames = accountFilterMap;
        if (_selectedAccountId != null &&
            !_accountNames.containsKey(_selectedAccountId)) {
          _selectedAccountId = null;
        }
        _incomeCategoryNames = {for (final c in incomeCategories) c.id: c.name};
        _expenseCategoryNames = {for (final c in expenseCategories) c.id: c.name};
        _cariRawTypeByTxId = cariTypeMap;
        _investmentMetaByTxId = mappedInvestment.$2;
        _investmentTxIdByFinanceTxId = investmentFinanceLinkMap;
        _investmentById = investmentById;
        _attachmentCountMap = attachmentCountMap;
        _cariCardNames = {
          for (final c in cariCards)
            c.id: (c.type == 'company'
                    ? (c.title?.trim().isNotEmpty == true ? c.title! : null)
                    : (c.fullName?.trim().isNotEmpty == true ? c.fullName! : null)) ??
                'Cari #${c.id}',
        };
        _categoryOptions = [
          ...manualIncomeCategories.map(
            (c) => _CategoryOption(
              key: 'income:${c.id}',
              type: 'income',
              id: c.id,
              label: 'Gelir • ${c.name}',
            ),
          ),
          ...manualExpenseCategories.map(
            (c) => _CategoryOption(
              key: 'expense:${c.id}',
              type: 'expense',
              id: c.id,
              label: 'Gider • ${c.name}',
            ),
          ),
          ...cariCards.map(
            (c) => _CategoryOption(
              key: 'cari:${c.id}',
              type: 'cari',
              id: c.id,
              label: 'Cari • ${_cariCardNames[c.id] ?? 'Cari #${c.id}'}',
            ),
          ),
        ];
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'İşlemler yüklenemedi: $e';
      });
    }
  }

  List<FinanceTransaction> _filtered() {
    final range = _resolveDateRange(_datePreset);
    final query = _searchController.text.trim().toLowerCase();

    final filtered = _all.where((tx) {
      if (_typeFilter == _TypeFilter.income && tx.type != 'income') {
        return false;
      }
      if (_typeFilter == _TypeFilter.expense && tx.type != 'expense') {
        return false;
      }
      if (_typeFilter == _TypeFilter.cari && !_isCariTx(tx)) {
        return false;
      }
      if (_typeFilter == _TypeFilter.incomeExpense && _isCariTx(tx)) {
        return false;
      }
      if (_typeFilter == _TypeFilter.cari) {
        if (_cariKindFilter == _CariKindFilter.debt && !_isCariDebt(tx)) {
          return false;
        }
        if (_cariKindFilter == _CariKindFilter.collection && !_isCariCollection(tx)) {
          return false;
        }
      }

      if (_selectedAccountId != null && tx.accountId != _selectedAccountId) {
        return false;
      }

      if (_selectedCategoryKey != null) {
        final split = _selectedCategoryKey!.split(':');
        if (split.length == 2) {
          final t = split[0];
          final id = int.tryParse(split[1]);
          if (id != null) {
            if (t == 'cari') {
              if (!_isCariTx(tx) || tx.categoryId != id) return false;
            } else if (tx.type != t || tx.categoryId != id) {
              return false;
            }
          }
        }
      }

      if (range != null) {
        if (tx.date.isBefore(range.$1) || tx.date.isAfter(range.$2)) {
          return false;
        }
      }

      if (query.isNotEmpty) {
        final desc = (tx.description ?? '').toLowerCase();
        final acc = (_accountNames[tx.accountId] ?? '').toLowerCase();
        final cat = _categoryName(tx).toLowerCase();
        if (!desc.contains(query) && !acc.contains(query) && !cat.contains(query)) {
          return false;
        }
      }

      return true;
    }).toList();

    filtered.sort((a, b) => b.date.compareTo(a.date));
    return filtered;
  }

  (DateTime, DateTime)? _resolveDateRange(_DatePreset preset) {
    if (preset == _DatePreset.all) return null;

    final ref = _periodReferenceDate;

    DateTime start;
    DateTime end;

    if (preset == _DatePreset.day) {
      final now = DateTime.now();
      start = DateTime(now.year, now.month, now.day);
      end = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
      return (start, end);
    }

    if (preset == _DatePreset.week) {
      final weekday = ref.weekday; // Monday=1
      start = DateTime(ref.year, ref.month, ref.day)
          .subtract(Duration(days: weekday - 1));
      end = DateTime(start.year, start.month, start.day + 6, 23, 59, 59, 999);
      return (start, end);
    }

    if (preset == _DatePreset.month) {
      start = DateTime(ref.year, ref.month, 1);
      end = DateTime(ref.year, ref.month + 1, 0, 23, 59, 59, 999);
      return (start, end);
    }

    if (preset == _DatePreset.year) {
      start = DateTime(ref.year, 1, 1);
      end = DateTime(ref.year, 12, 31, 23, 59, 59, 999);
      return (start, end);
    }

    if (preset == _DatePreset.custom) {
      if (_customStart == null || _customEnd == null) return null;
      start = DateTime(_customStart!.year, _customStart!.month, _customStart!.day);
      end = DateTime(
        _customEnd!.year,
        _customEnd!.month,
        _customEnd!.day,
        23,
        59,
        59,
        999,
      );
      return (start, end);
    }

    return null;
  }

  String _periodLabel() {
    if (_datePreset == _DatePreset.all) return 'Tümü';
    if (_datePreset == _DatePreset.day) {
      return 'Günlük (${_fmtDateOnly(DateTime.now())})';
    }
    if (_datePreset == _DatePreset.week) {
      final monday = DateTime(
        _periodReferenceDate.year,
        _periodReferenceDate.month,
        _periodReferenceDate.day,
      ).subtract(Duration(days: _periodReferenceDate.weekday - 1));
      final sunday = monday.add(const Duration(days: 6));
      return 'Haftalık (${_fmtDateOnly(monday)} - ${_fmtDateOnly(sunday)})';
    }
    if (_datePreset == _DatePreset.month) {
      final mm = _periodReferenceDate.month.toString().padLeft(2, '0');
      return 'Aylık ($mm.${_periodReferenceDate.year})';
    }
    if (_datePreset == _DatePreset.year) {
      return 'Yıllık (${_periodReferenceDate.year})';
    }
    if (_datePreset == _DatePreset.custom) {
      if (_customStart == null || _customEnd == null) return 'Özel';
      return 'Özel (${_fmtDateOnly(_customStart!)} - ${_fmtDateOnly(_customEnd!)})';
    }
    return 'Tümü';
  }

  List<int> _availableYears() {
    final years = <int>{DateTime.now().year};
    for (final tx in _all) {
      if (_selectedAccountId != null && tx.accountId != _selectedAccountId) continue;
      years.add(tx.date.year);
    }
    final list = years.toList()..sort((a, b) => b.compareTo(a));
    return list;
  }

  String _weekRangeLabel(DateTime ref) {
    final monday = DateTime(
      ref.year,
      ref.month,
      ref.day,
    ).subtract(Duration(days: ref.weekday - 1));
    final sunday = monday.add(const Duration(days: 6));
    return '${_fmtDateOnly(monday)} - ${_fmtDateOnly(sunday)}';
  }

  void _onDatePresetChanged(_DatePreset value) {
    setState(() {
      _datePreset = value;
      if (value == _DatePreset.day) {
        _periodReferenceDate = DateTime.now();
      }
      if (value == _DatePreset.custom) {
        _customStart ??= DateTime.now();
        _customEnd ??= DateTime.now();
      }
    });
  }

  List<_GroupedBucket> _grouped(List<FinanceTransaction> data) {
    if (_groupBy == _GroupBy.none) {
      return [
        _GroupedBucket(key: 'all', label: 'Tüm İşlemler', items: data),
      ];
    }

    final map = <String, List<FinanceTransaction>>{};
    final labels = <String, String>{};

    for (final tx in data) {
      final pair = _groupKeyLabel(tx);
      map.putIfAbsent(pair.$1, () => []).add(tx);
      labels[pair.$1] = pair.$2;
    }

    final buckets = map.entries
        .map(
          (e) => _GroupedBucket(
            key: e.key,
            label: labels[e.key] ?? e.key,
            items: e.value,
          ),
        )
        .toList();

    if (_groupBy == _GroupBy.category || _groupBy == _GroupBy.account) {
      buckets.sort((a, b) => a.label.compareTo(b.label));
    } else {
      buckets.sort((a, b) => b.items.first.date.compareTo(a.items.first.date));
    }

    return buckets;
  }

  (String, String) _groupKeyLabel(FinanceTransaction tx) {
    final d = tx.date;
    if (_groupBy == _GroupBy.day) {
      final key = '${d.year}-${d.month}-${d.day}';
      return (key, _fmtDateOnly(d));
    }
    if (_groupBy == _GroupBy.week) {
      final monday = DateTime(d.year, d.month, d.day)
          .subtract(Duration(days: d.weekday - 1));
      final sunday = monday.add(const Duration(days: 6));
      final key = '${monday.year}-${monday.month}-${monday.day}';
      final label = '${_fmtDateOnly(monday)} - ${_fmtDateOnly(sunday)}';
      return (key, label);
    }
    if (_groupBy == _GroupBy.month) {
      final key = '${d.year}-${d.month}';
      return (key, '${d.month.toString().padLeft(2, '0')}.${d.year}');
    }
    if (_groupBy == _GroupBy.year) {
      final key = '${d.year}';
      return (key, '${d.year}');
    }
    if (_groupBy == _GroupBy.category) {
      final key = '${tx.type}:${tx.categoryId}';
      return (key, _categoryName(tx));
    }
    if (_groupBy == _GroupBy.account) {
      final key = '${tx.accountId}';
      return (key, _accountNames[tx.accountId] ?? 'Hesap #${tx.accountId}');
    }
    return ('all', 'Tüm İşlemler');
  }

  String _categoryName(FinanceTransaction tx) {
    final invMeta = _investmentMetaByTxId[tx.id];
    if (invMeta != null) return invMeta.symbol;
    if (_isCariTx(tx)) {
      return _cariCardNames[tx.categoryId] ?? 'Cari #${tx.categoryId}';
    }
    if (tx.type == 'income') {
      return _incomeCategoryNames[tx.categoryId] ?? 'Kategori #${tx.categoryId}';
    }
    return _expenseCategoryNames[tx.categoryId] ?? 'Kategori #${tx.categoryId}';
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

  String _fmtDateOnly(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    return '$d.$m.${dt.year}';
  }

  String _fmtDateTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '${_fmtDateOnly(dt)} $h:$min';
  }

  String _normalizedDescription(String? description) {
    final v = description?.trim() ?? '';
    return v.isEmpty ? '-' : v;
  }

  String _categoryLabelForKey(String key) {
    for (final c in _categoryOptions) {
      if (c.key == key) return c.label;
    }
    return key;
  }

  String _filterSummary() {
    String typeText = 'Tümü';
    if (_typeFilter == _TypeFilter.income) typeText = 'Gelir';
    if (_typeFilter == _TypeFilter.expense) typeText = 'Gider';
    if (_typeFilter == _TypeFilter.incomeExpense) typeText = 'Gelir + Gider';
    if (_typeFilter == _TypeFilter.cari) typeText = 'Cari Kart';
    if (_typeFilter == _TypeFilter.cari) {
      if (_cariKindFilter == _CariKindFilter.debt) {
        typeText = 'Cari Kart (Borç Verme)';
      } else if (_cariKindFilter == _CariKindFilter.collection) {
        typeText = 'Cari Kart (Tahsilat)';
      }
    }

    final periodText = _periodLabel();

    final account = _selectedAccountId == null
        ? 'Tüm Hesaplar'
        : (_accountNames[_selectedAccountId!] ?? 'Hesap #${_selectedAccountId!}');

    final category = _selectedCategoryKey == null
        ? 'Tüm Kategoriler'
        : _categoryLabelForKey(_selectedCategoryKey!);

    return 'Tür: $typeText | Dönem: $periodText | Hesap: $account | Kategori: $category';
  }

  Future<Uint8List> _buildPdfReport(PdfPageFormat format) async {
    final filtered = _filtered();
    final groups = _grouped(filtered);
    final totalIncome = filtered
        .where((e) => e.type == 'income')
        .fold<double>(0, (s, e) => s + e.amount);
    final totalExpense = filtered
        .where((e) => e.type == 'expense')
        .fold<double>(0, (s, e) => s + e.amount);
    final net = totalIncome - totalExpense;

    final font = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Roboto-Regular.ttf'),
    );
    final bold = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Roboto-Bold.ttf'),
    );

    final doc = pw.Document(
      theme: pw.ThemeData.withFont(
        base: font,
        bold: bold,
      ),
    );

    doc.addPage(
      pw.MultiPage(
        pageFormat: format,
        margin: const pw.EdgeInsets.all(24),
        build: (context) => [
          pw.Text(
            'Gelir / Gider Raporu',
            style: pw.TextStyle(font: bold, fontSize: 18),
          ),
          pw.SizedBox(height: 6),
          pw.Text('Oluşturulma: ${_fmtDateTime(DateTime.now())}'),
          pw.SizedBox(height: 4),
          pw.Text(_filterSummary()),
          pw.SizedBox(height: 10),
          pw.Text(
            'Toplam Gelir: ${_fmtAmount(totalIncome)} TL',
            style: pw.TextStyle(color: PdfColors.green700),
          ),
          pw.Text(
            'Toplam Gider: ${_fmtAmount(totalExpense)} TL',
            style: pw.TextStyle(color: PdfColors.red700),
          ),
          pw.Text(
            'Net: ${net >= 0 ? '+' : '-'}${_fmtAmount(net.abs())} TL',
            style: pw.TextStyle(color: PdfColors.blue700, font: bold),
          ),
          pw.SizedBox(height: 12),
          if (filtered.isEmpty)
            pw.Text('Filtreye uygun işlem bulunamadı.')
          else
            ...groups.expand((g) {
              final rows = g.items.map((tx) {
                final isIncome = tx.type == 'income';
                final account =
                    _accountNames[tx.accountId] ?? 'Hesap #${tx.accountId}';
                final category = _categoryName(tx);
                return <String>[
                  _fmtDateTime(tx.date),
                  _txTypeLabel(tx),
                  account,
                  category,
                  _normalizedDescription(tx.description),
                  '${isIncome ? '+' : '-'}${_fmtAmount(tx.amount)}',
                ];
              }).toList();

              return [
                pw.Text(
                  g.label,
                  style: pw.TextStyle(font: bold, fontSize: 13),
                ),
                pw.SizedBox(height: 4),
                pw.TableHelper.fromTextArray(
                  headers: const [
                    'Tarih',
                    'Tür',
                    'Hesap',
                    'Kategori',
                    'Açıklama',
                    'Tutar',
                  ],
                  data: rows,
                  headerStyle: pw.TextStyle(font: bold, fontSize: 9),
                  cellStyle: const pw.TextStyle(fontSize: 8.5),
                  cellAlignment: pw.Alignment.centerLeft,
                  headerDecoration:
                      const pw.BoxDecoration(color: PdfColors.grey300),
                  columnWidths: {
                    0: const pw.FlexColumnWidth(1.5),
                    1: const pw.FlexColumnWidth(0.8),
                    2: const pw.FlexColumnWidth(1.1),
                    3: const pw.FlexColumnWidth(1.1),
                    4: const pw.FlexColumnWidth(1.8),
                    5: const pw.FlexColumnWidth(1.1),
                  },
                ),
                pw.SizedBox(height: 10),
              ];
            }),
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
            build: _buildPdfReport,
            canChangePageFormat: false,
            canChangeOrientation: false,
            canDebug: false,
            allowSharing: true,
            allowPrinting: true,
            pdfFileName: 'gelir_gider_raporu.pdf',
          ),
        ),
      ),
    );
  }

  Future<void> _pickCustomDate({required bool start}) async {
    final current = start ? _customStart : _customEnd;
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null || !mounted) return;
    setState(() {
      if (start) {
        _customStart = picked;
      } else {
        _customEnd = picked;
      }
    });
  }

  Future<void> _pickReferenceDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _periodReferenceDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _periodReferenceDate = picked;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered();
    final groups = _grouped(filtered);
    final totalIncome = filtered
        .where((e) => e.type == 'income')
        .fold<double>(0, (s, e) => s + e.amount);
    final totalExpense = filtered
        .where((e) => e.type == 'expense')
        .fold<double>(0, (s, e) => s + e.amount);
    final net = totalIncome - totalExpense;

    return Scaffold(
      drawer: buildAppMenuDrawer(),
      appBar: AppBar(
        leading: buildMenuLeading(),
        title: const Text('İşlem Geçmişi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: _openPdfPreview,
            tooltip: 'PDF Raporla',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _load,
          ),
          buildHomeAction(context),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(_error!, textAlign: TextAlign.center),
                  ),
                )
              : Column(
                  children: [
                    _buildSummary(totalIncome, totalExpense, net, filtered.length),
                    _buildFilters(),
                    Expanded(
                      child: groups.isEmpty
                          ? const Center(child: Text('Filtreye uygun işlem yok.'))
                          : RefreshIndicator(
                              onRefresh: _load,
                              child: ListView.builder(
                                padding: const EdgeInsets.only(bottom: 12),
                                itemCount: groups.length,
                                itemBuilder: (context, index) {
                                  final bucket = groups[index];
                                  final groupNet = bucket.items.fold<double>(
                                    0,
                                    (s, e) => s + (e.type == 'income' ? e.amount : -e.amount),
                                  );
                                  return _buildGroup(bucket, groupNet);
                                },
                              ),
                            ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildSummary(
    double income,
    double expense,
    double net,
    int count,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _summaryMetricRow('Gelir', _fmtAmount(income), AppColors.income),
                    const SizedBox(height: 8),
                    _summaryMetricRow('Gider', _fmtAmount(expense), AppColors.expense),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _summaryMetricRow(
                      'Net',
                      _fmtAmount(net.abs()),
                      net >= 0 ? Colors.blue : Colors.orange,
                      alignRight: true,
                    ),
                    const SizedBox(height: 8),
                    _summaryMetricRow(
                      'İşlem',
                      '$count',
                      Colors.black87,
                      alignRight: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryMetricRow(
    String label,
    String value,
    Color valueColor, {
    bool alignRight = false,
  }) {
    final textAlign = alignRight ? TextAlign.right : TextAlign.left;
    final crossAlign = alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: crossAlign,
        children: [
          Text(
            label,
            textAlign: textAlign,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: alignRight ? Alignment.centerRight : Alignment.centerLeft,
            child: Text(
              value,
              maxLines: 1,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    final categories = _visibleCategoryOptions();
    final availableYears = _availableYears();

    return Card(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.filter_alt_outlined),
            title: const Text(
              'Filtreler',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            trailing: Icon(
              _filtersExpanded ? Icons.expand_less : Icons.expand_more,
            ),
            onTap: () {
              setState(() {
                _filtersExpanded = !_filtersExpanded;
              });
            },
          ),
          if (_filtersExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Aktif Dönem: ${_periodLabel()}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<_TypeFilter>(
                          isExpanded: true,
                          initialValue: _typeFilter,
                          decoration: const InputDecoration(labelText: 'Tür'),
                          items: const [
                            DropdownMenuItem(value: _TypeFilter.all, child: Text('Tümü')),
                            DropdownMenuItem(value: _TypeFilter.income, child: Text('Gelir')),
                            DropdownMenuItem(value: _TypeFilter.expense, child: Text('Gider')),
                            DropdownMenuItem(
                              value: _TypeFilter.incomeExpense,
                              child: Text('Gelir + Gider'),
                            ),
                            DropdownMenuItem(
                              value: _TypeFilter.cari,
                              child: Text('Cari Kart'),
                            ),
                          ],
                          onChanged: (v) {
                            if (v == null) return;
                            setState(() {
                              _typeFilter = v;
                              _selectedCategoryKey = null;
                              if (_typeFilter != _TypeFilter.cari) {
                                _cariKindFilter = _CariKindFilter.all;
                              }
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonFormField<_DatePreset>(
                          isExpanded: true,
                          initialValue: _datePreset,
                          decoration: const InputDecoration(labelText: 'Dönem'),
                          items: const [
                            DropdownMenuItem(value: _DatePreset.all, child: Text('Tümü')),
                            DropdownMenuItem(value: _DatePreset.day, child: Text('Günlük')),
                            DropdownMenuItem(value: _DatePreset.week, child: Text('Haftalık')),
                            DropdownMenuItem(value: _DatePreset.month, child: Text('Aylık')),
                            DropdownMenuItem(value: _DatePreset.year, child: Text('Yıllık')),
                            DropdownMenuItem(value: _DatePreset.custom, child: Text('Özel')),
                          ],
                          onChanged: (v) {
                            if (v == null) return;
                            _onDatePresetChanged(v);
                          },
                        ),
                      ),
                    ],
                  ),
                  if (_typeFilter == _TypeFilter.cari) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<_CariKindFilter>(
                            isExpanded: true,
                            initialValue: _cariKindFilter,
                            decoration: const InputDecoration(
                              labelText: 'Cari İşlem Türü',
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: _CariKindFilter.all,
                                child: Text('Tümü'),
                              ),
                              DropdownMenuItem(
                                value: _CariKindFilter.debt,
                                child: Text('Borç Verme'),
                              ),
                              DropdownMenuItem(
                                value: _CariKindFilter.collection,
                                child: Text('Tahsilat'),
                              ),
                            ],
                            onChanged: (v) {
                              if (v == null) return;
                              setState(() {
                                _cariKindFilter = v;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (_datePreset != _DatePreset.all) ...[
                    const SizedBox(height: 8),
                    if (_datePreset == _DatePreset.day)
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Referans gün: Bugün'),
                      )
                    else if (_datePreset == _DatePreset.week)
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _pickReferenceDate,
                              icon: const Icon(Icons.date_range),
                              label: Text('Hafta: ${_weekRangeLabel(_periodReferenceDate)}'),
                            ),
                          ),
                        ],
                      )
                    else if (_datePreset == _DatePreset.month)
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              isExpanded: true,
                              initialValue: _periodReferenceDate.year,
                              decoration: const InputDecoration(labelText: 'Yıl'),
                              items: availableYears
                                  .map(
                                    (y) => DropdownMenuItem<int>(
                                      value: y,
                                      child: Text(y.toString()),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) {
                                if (v == null) return;
                                setState(() {
                                  _periodReferenceDate = DateTime(
                                    v,
                                    _periodReferenceDate.month,
                                    1,
                                  );
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              isExpanded: true,
                              initialValue: _periodReferenceDate.month,
                              decoration: const InputDecoration(labelText: 'Ay'),
                              items: List.generate(
                                12,
                                (i) => DropdownMenuItem<int>(
                                  value: i + 1,
                                  child: Text(_monthNames[i]),
                                ),
                              ),
                              onChanged: (v) {
                                if (v == null) return;
                                setState(() {
                                  _periodReferenceDate = DateTime(
                                    _periodReferenceDate.year,
                                    v,
                                    1,
                                  );
                                });
                              },
                            ),
                          ),
                        ],
                      )
                    else if (_datePreset == _DatePreset.year)
                      DropdownButtonFormField<int>(
                        isExpanded: true,
                        initialValue: _periodReferenceDate.year,
                        decoration: const InputDecoration(labelText: 'Yıl'),
                        items: availableYears
                            .map(
                              (y) => DropdownMenuItem<int>(
                                value: y,
                                child: Text(y.toString()),
                              ),
                            )
                            .toList(),
                        onChanged: (v) {
                          if (v == null) return;
                          setState(() {
                            _periodReferenceDate = DateTime(v, 1, 1);
                          });
                        },
                      ),
                  ],
                  if (_datePreset == _DatePreset.custom) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _pickCustomDate(start: true),
                            child: Text(
                              _customStart == null
                                  ? 'Başlangıç'
                                  : _fmtDateOnly(_customStart!),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _pickCustomDate(start: false),
                            child: Text(
                              _customEnd == null ? 'Bitiş' : _fmtDateOnly(_customEnd!),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<int?>(
                          isExpanded: true,
                          initialValue: _selectedAccountId,
                          decoration: const InputDecoration(labelText: 'Hesap'),
                          items: [
                            const DropdownMenuItem<int?>(
                              value: null,
                              child: Text('Tüm Hesaplar'),
                            ),
                            ..._accountNames.entries.map(
                              (e) => DropdownMenuItem<int?>(
                                value: e.key,
                                child: Text(
                                  e.value,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                          onChanged: (v) {
                            setState(() {
                              _selectedAccountId = v;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonFormField<String?>(
                          isExpanded: true,
                          initialValue: _selectedCategoryKey,
                          decoration: const InputDecoration(labelText: 'Kategori'),
                          items: [
                            const DropdownMenuItem<String?>(
                              value: null,
                              child: Text('Tüm Kategoriler'),
                            ),
                            ...categories.map(
                              (e) => DropdownMenuItem<String?>(
                                value: e.key,
                                child: Text(
                                  e.label,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                          onChanged: (v) {
                            setState(() {
                              _selectedCategoryKey = v;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<_GroupBy>(
                          isExpanded: true,
                          initialValue: _groupBy,
                          decoration: const InputDecoration(labelText: 'Gruplama'),
                          items: const [
                            DropdownMenuItem(value: _GroupBy.none, child: Text('Yok')),
                            DropdownMenuItem(value: _GroupBy.day, child: Text('Gün')),
                            DropdownMenuItem(value: _GroupBy.week, child: Text('Hafta')),
                            DropdownMenuItem(value: _GroupBy.month, child: Text('Ay')),
                            DropdownMenuItem(value: _GroupBy.year, child: Text('Yıl')),
                            DropdownMenuItem(
                              value: _GroupBy.category,
                              child: Text('Kategori'),
                            ),
                            DropdownMenuItem(value: _GroupBy.account, child: Text('Hesap')),
                          ],
                          onChanged: (v) {
                            if (v == null) return;
                            setState(() {
                              _groupBy = v;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Ara (açıklama/hesap/kategori)',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (_) {
                      setState(() {});
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  List<_CategoryOption> _visibleCategoryOptions() {
    if (_typeFilter == _TypeFilter.income) {
      return _categoryOptions.where((e) => e.type == 'income').toList();
    }
    if (_typeFilter == _TypeFilter.expense) {
      return _categoryOptions.where((e) => e.type == 'expense').toList();
    }
    if (_typeFilter == _TypeFilter.incomeExpense) {
      return _categoryOptions.where((e) => e.type != 'cari').toList();
    }
    if (_typeFilter == _TypeFilter.cari) {
      return _categoryOptions.where((e) => e.type == 'cari').toList();
    }
    return _categoryOptions;
  }

  Widget _buildGroup(_GroupedBucket bucket, double groupNet) {
    return Card(
      margin: const EdgeInsets.fromLTRB(12, 6, 12, 6),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            ListTile(
              dense: true,
              title: Text(
                bucket.label,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('${bucket.items.length} işlem'),
              trailing: Text(
                'Net: ${groupNet >= 0 ? '+' : '-'}${_fmtAmount(groupNet.abs())} TL',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: groupNet >= 0 ? Colors.blue : Colors.orange,
                ),
              ),
            ),
            const Divider(height: 1),
            ...bucket.items.map(_buildTransactionTile),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionTile(FinanceTransaction tx) {
    final isIncome = tx.type == 'income';
    final account = _accountNames[tx.accountId] ?? 'Hesap #${tx.accountId}';
    final category = _categoryName(tx);
    final investmentTx = _linkedInvestmentTransaction(tx);
    final isInvestmentLinked = investmentTx != null;

    final attachmentCount = _attachmentCount(tx);
    return ListTile(
      leading: Icon(
        isIncome ? Icons.arrow_downward : Icons.arrow_upward,
        color: isIncome ? AppColors.income : AppColors.expense,
      ),
      title: Text('${_txTypeLabel(tx)} • $category'),
      subtitle: Text(
        'Hesap: $account • ${_fmtDateTime(tx.date)}\n'
        'Açıklama: ${_normalizedDescription(tx.description)}',
      ),
      isThreeLine: true,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (attachmentCount > 0)
            IconButton(
              icon: const Icon(Icons.attach_file),
              tooltip: 'Ekler ($attachmentCount)',
              onPressed: () async {
                await _showAttachments(tx);
              },
            ),
          Text(
            '${isIncome ? '+' : '-'}${_fmtAmount(tx.amount)} TL',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isIncome ? AppColors.income : AppColors.expense,
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
            itemBuilder: (_) => [
              const PopupMenuItem<String>(
                value: 'edit',
                child: Text('Düzenle'),
              ),
              if (!isInvestmentLinked)
                const PopupMenuItem<String>(
                  value: 'delete',
                  child: Text('Sil'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  int _attachmentCount(FinanceTransaction tx) {
    if (_isCariTx(tx)) {
      final cariId = -tx.id - 1;
      return _attachmentCountMap['cari:$cariId'] ?? 0;
    }
    return _attachmentCountMap['finance:${tx.id}'] ?? 0;
  }

  Future<void> _showAttachments(FinanceTransaction tx) async {
    final ownerType = _isCariTx(tx) ? 'cari' : 'finance';
    final ownerId = _isCariTx(tx) ? (-tx.id - 1) : tx.id;
    final attachments = await TransactionAttachmentService.getByOwner(
      ownerType: ownerType,
      ownerId: ownerId,
    );
    if (!mounted) return;
    if (attachments.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bu işlem için ek resim bulunmuyor.')),
      );
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (_) => Dialog(
        child: SizedBox(
          width: 560,
          height: 420,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 8, 4),
                child: Row(
                  children: [
                    Text(
                      'İşlem Ekleri (${attachments.length})',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(10),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                  itemCount: attachments.length,
                  itemBuilder: (context, index) {
                    final imageBytes = Uint8List.fromList(attachments[index].imageBytes);
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: InkWell(
                        onTap: () => _openAttachmentFullscreen(imageBytes),
                        child: Image.memory(
                          imageBytes,
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openAttachmentFullscreen(Uint8List imageBytes) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            leading: const BackButton(),
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            title: const Text('Ek Görsel'),
          ),
          body: InteractiveViewer(
            minScale: 0.7,
            maxScale: 4.0,
            child: Center(
              child: Image.memory(imageBytes, fit: BoxFit.contain),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _editTransaction(FinanceTransaction tx) async {
    bool? changed;
    final investmentTx = _linkedInvestmentTransaction(tx);
    if (investmentTx != null) {
      changed = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => InvestmentEntryScreen(initialTransaction: investmentTx),
        ),
      );
    } else if (_isCariTx(tx)) {
      final rawType = _cariRawTypeByTxId[tx.id] ?? 'debt';
      final cariTx = CariTransaction()
        ..id = -tx.id - 1
        ..cariCardId = tx.categoryId
        ..accountId = tx.accountId
        ..type = rawType
        ..amount = tx.amount
        ..description = tx.description
        ..date = tx.date
        ..createdAt = tx.createdAt;
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
      if (_isCariTx(tx)) {
        final cariId = -tx.id - 1;
        await CariTransactionService.deleteAndReturn(cariId);
      } else {
        await FinanceTransactionService.deleteAndReturn(tx.id);
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

  bool _isCariTx(FinanceTransaction tx) => _cariRawTypeByTxId.containsKey(tx.id);

  InvestmentTransaction? _linkedInvestmentTransaction(FinanceTransaction tx) {
    final syntheticMeta = _investmentMetaByTxId[tx.id];
    if (syntheticMeta != null) {
      return _investmentById[syntheticMeta.investmentTransactionId];
    }
    final linkedId = _investmentTxIdByFinanceTxId[tx.id];
    if (linkedId == null) return null;
    return _investmentById[linkedId];
  }

  String _txTypeLabel(FinanceTransaction tx) {
    final invMeta = _investmentMetaByTxId[tx.id];
    if (invMeta != null) {
      return invMeta.rawType == 'buy' ? 'Yatırım Alış (Nakit)' : 'Yatırım Satış (Nakit)';
    }
    if (_isCariTx(tx)) {
      if (_isCariDebt(tx)) return 'Cari Kart (Borç Verme)';
      if (_isCariCollection(tx)) return 'Cari Kart (Tahsilat)';
      return 'Cari Kart';
    }
    return tx.type == 'income' ? 'Gelir' : 'Gider';
  }

  bool _isCariDebt(FinanceTransaction tx) => _cariRawTypeByTxId[tx.id] == 'debt';
  bool _isCariCollection(FinanceTransaction tx) =>
      _cariRawTypeByTxId[tx.id] == 'collection';

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

  (List<FinanceTransaction>, Map<int, _InvestmentHistoryMeta>)
      _mapInvestmentToFinanceLike(
    List<InvestmentTransaction> items,
    Map<int, String> accountNames,
  ) {
    final result = <FinanceTransaction>[];
    final metaById = <int, _InvestmentHistoryMeta>{};

    for (final it in items) {
      final base = 2000000000 + (it.id * 10);
      final cashId = -(base + 1);
      final isBuy = it.type == 'buy';

      final cash = FinanceTransaction()
        ..id = cashId
        ..accountId = it.cashAccountId
        ..categoryId = 0
        ..type = isBuy ? 'expense' : 'income'
        ..amount = isBuy
            ? it.total
            : (it.costBasisTotal > 0 ? it.costBasisTotal : (it.total - it.realizedPnl))
        ..description =
            'Yatırım: ${it.symbol} • Miktar: ${it.quantity.toStringAsFixed(4)} • Birim: ${_fmtAmount(it.unitPrice)} TL • Karşı: ${accountNames[it.investmentAccountId] ?? 'Yatırım #${it.investmentAccountId}'}'
        ..date = it.date
        ..createdAt = it.createdAt;
      result.add(cash);
      metaById[cashId] = _InvestmentHistoryMeta(
        investmentTransactionId: it.id,
        symbol: it.symbol,
        rawType: it.type,
      );
    }

    return (result, metaById);
  }

  Map<int, int> _buildInvestmentFinanceLinkMap({
    required List<FinanceTransaction> financeTx,
    required List<InvestmentTransaction> investmentTx,
  }) {
    final linked = <int, int>{};
    final usedFinanceIds = <int>{};

    for (final it in investmentTx) {
      if (it.type != 'sell' || it.realizedPnl.abs() <= 1e-9) continue;

      final expectedType = it.realizedPnl >= 0 ? 'income' : 'expense';
      final expectedAmount = it.realizedPnl.abs();
      final expectedDesc = 'Yatirim satis K/Z • ${it.symbol.toUpperCase()}';

      FinanceTransaction? bestCandidate;
      var bestDelta = 1 << 62;

      for (final ft in financeTx) {
        if (usedFinanceIds.contains(ft.id)) continue;
        if (ft.type != expectedType) continue;
        if (ft.accountId != it.cashAccountId) continue;
        if ((ft.amount - expectedAmount).abs() > 1e-6) continue;
        if ((ft.description ?? '').trim() != expectedDesc) continue;
        if (!ft.date.isAtSameMomentAs(it.date)) continue;

        final delta = (ft.createdAt.millisecondsSinceEpoch -
                it.createdAt.millisecondsSinceEpoch)
            .abs();
        if (bestCandidate == null || delta < bestDelta) {
          bestCandidate = ft;
          bestDelta = delta;
        }
      }

      if (bestCandidate != null) {
        usedFinanceIds.add(bestCandidate.id);
        linked[bestCandidate.id] = it.id;
      }
    }

    return linked;
  }
}

class _InvestmentHistoryMeta {
  final int investmentTransactionId;
  final String symbol;
  final String rawType;

  const _InvestmentHistoryMeta({
    required this.investmentTransactionId,
    required this.symbol,
    required this.rawType,
  });
}
