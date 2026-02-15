import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/account.dart';
import '../models/cari_card.dart';
import '../models/cari_transaction.dart';
import '../models/finance_transaction.dart';
import '../models/investment_transaction.dart';
import '../models/transfer_transaction.dart';
import 'cari_account_screen.dart';
import 'expense_entry_screen.dart';
import 'income_entry_screen.dart';
import 'investment_entry_screen.dart';
import '../services/account_service.dart';
import '../services/cari_card_service.dart';
import '../services/cari_transaction_service.dart';
import '../services/finance_transaction_service.dart';
import '../services/investment_transaction_service.dart';
import '../services/transfer_transaction_service.dart';
import '../utils/navigation_helpers.dart';

enum _DatePreset { all, day, week, month, year, custom }
enum _MovementSourceType { finance, cari, transfer, investment }

class AccountMovementsScreen extends StatefulWidget {
  const AccountMovementsScreen({super.key});

  @override
  State<AccountMovementsScreen> createState() => _AccountMovementsScreenState();
}

class _AccountMovementsScreenState extends State<AccountMovementsScreen> {
  bool _loading = true;
  String? _error;

  List<Account> _accounts = [];
  Map<int, List<_AccountMovement>> _movementsByAccount = {};
  Map<int, double> _displayBalanceByAccount = {};
  Map<int, FinanceTransaction> _financeById = {};
  Map<int, CariTransaction> _cariById = {};
  Map<int, InvestmentTransaction> _investmentById = {};

  int? _selectedAccountId;
  _DatePreset _datePreset = _DatePreset.month;
  DateTime _periodReferenceDate = DateTime.now();
  DateTime? _customStart;
  DateTime? _customEnd;
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
        AccountService.getAllAccounts(),
        FinanceTransactionService.getAll(),
        CariTransactionService.getAll(),
        TransferTransactionService.getAll(),
        InvestmentTransactionService.getAll(),
        CariCardService.getAll(),
      ]);

      final accounts = (results[0] as List<Account>)
        ..sort((a, b) => a.name.compareTo(b.name));
      final finance = results[1] as List<FinanceTransaction>;
      final cari = results[2] as List<CariTransaction>;
      final transfer = results[3] as List<TransferTransaction>;
      final investment = results[4] as List<InvestmentTransaction>;
      final cards = results[5] as List<CariCard>;
      final financeById = {for (final tx in finance) tx.id: tx};
      final cariById = {for (final tx in cari) tx.id: tx};
      final investmentById = {for (final tx in investment) tx.id: tx};

      final cardNames = <int, String>{
        for (final c in cards)
          c.id: (c.type == 'company'
                  ? ((c.title ?? '').trim().isEmpty ? null : c.title)
                  : ((c.fullName ?? '').trim().isEmpty ? null : c.fullName)) ??
              'Cari #${c.id}',
      };

      final movementMap = <int, List<_AccountMovement>>{
        for (final a in accounts) a.id: <_AccountMovement>[],
      };
      final displayBalanceMap = <int, double>{
        for (final a in accounts) a.id: a.type == 'investment' ? 0 : a.balance,
      };

      for (final tx in finance) {
        if (!movementMap.containsKey(tx.accountId)) continue;
        final isIncome = tx.type == 'income';
        movementMap[tx.accountId]!.add(
          _AccountMovement(
            date: tx.date,
            typeLabel: isIncome ? 'Gelir' : 'Gider',
            amountSigned: isIncome ? tx.amount : -tx.amount,
            description: (tx.description ?? '').trim().isEmpty
                ? '-'
                : tx.description!.trim(),
            sourceLabel: 'Finans',
            sourceType: _MovementSourceType.finance,
            sourceId: tx.id,
          ),
        );
      }

      for (final tx in cari) {
        if (!movementMap.containsKey(tx.accountId)) continue;
        final isCollection = tx.type == 'collection';
        movementMap[tx.accountId]!.add(
          _AccountMovement(
            date: tx.date,
            typeLabel: isCollection ? 'Cari Gelen' : 'Cari Giden',
            amountSigned: isCollection ? tx.amount : -tx.amount,
            description: (tx.description ?? '').trim().isEmpty
                ? '-'
                : tx.description!.trim(),
            sourceLabel: cardNames[tx.cariCardId] ?? 'Cari #${tx.cariCardId}',
            sourceType: _MovementSourceType.cari,
            sourceId: tx.id,
          ),
        );
      }

      final accountNames = {for (final a in accounts) a.id: a.name};
      for (final tx in transfer) {
        if (movementMap.containsKey(tx.fromAccountId)) {
          movementMap[tx.fromAccountId]!.add(
            _AccountMovement(
              date: tx.date,
              typeLabel: 'Transfer Çıkış',
              amountSigned: -tx.amount,
              description: (tx.description ?? '').trim().isEmpty
                  ? '-'
                  : tx.description!.trim(),
              sourceLabel: 'Alıcı: ${accountNames[tx.toAccountId] ?? tx.toAccountId}',
              sourceType: _MovementSourceType.transfer,
              sourceId: tx.id,
            ),
          );
        }
        if (movementMap.containsKey(tx.toAccountId)) {
          movementMap[tx.toAccountId]!.add(
            _AccountMovement(
              date: tx.date,
              typeLabel: 'Transfer Giriş',
              amountSigned: tx.amount,
              description: (tx.description ?? '').trim().isEmpty
                  ? '-'
                  : tx.description!.trim(),
              sourceLabel:
                  'Gönderen: ${accountNames[tx.fromAccountId] ?? tx.fromAccountId}',
              sourceType: _MovementSourceType.transfer,
              sourceId: tx.id,
            ),
          );
        }
      }

      for (final tx in investment) {
        final hasCash = movementMap.containsKey(tx.cashAccountId);
        final hasInvestment = movementMap.containsKey(tx.investmentAccountId);
        if (!hasCash && !hasInvestment) continue;
        final isBuy = tx.type == 'buy';
        final typeLabel = isBuy ? 'Yatırım Alış' : 'Yatırım Satış';
        final principal = tx.costBasisTotal > 0 ? tx.costBasisTotal : tx.total;
        final cashSigned = isBuy ? -tx.total : principal;
        final investmentAccountName =
            accountNames[tx.investmentAccountId] ?? 'Yatırım #${tx.investmentAccountId}';
        final cashAccountName = accountNames[tx.cashAccountId] ?? 'Hesap #${tx.cashAccountId}';
        var detail =
            '${tx.symbol} ${tx.quantity.toStringAsFixed(4)} @ ${_fmtAmount(tx.unitPrice)} TL';
        if (!isBuy) {
          final pnlAbs = _fmtAmount(tx.realizedPnl.abs());
          detail =
              '$detail • FIFO: ${_fmtAmount(tx.costBasisTotal)} TL • K/Z: $pnlAbs TL ${tx.realizedPnl >= 0 ? '(Kar)' : '(Zarar)'}';
        }

        if (hasCash) {
          movementMap[tx.cashAccountId]!.add(
            _AccountMovement(
              date: tx.date,
              typeLabel: typeLabel,
              amountSigned: cashSigned,
              description: detail,
              sourceLabel: 'Yatırım: $investmentAccountName',
              sourceType: _MovementSourceType.investment,
              sourceId: tx.id,
            ),
          );
        }
        if (hasInvestment) {
          movementMap[tx.investmentAccountId]!.add(
            _AccountMovement(
              date: tx.date,
              typeLabel: typeLabel,
              amountSigned: isBuy ? tx.total : -tx.total,
              description: detail,
              sourceLabel: 'Nakit: $cashAccountName',
              sourceType: _MovementSourceType.investment,
              sourceId: tx.id,
            ),
          );

          // Investment accounts keep quantity in `balance`; for this report card,
          // show monetary net as total buys minus total sells.
          displayBalanceMap[tx.investmentAccountId] =
              (displayBalanceMap[tx.investmentAccountId] ?? 0) +
                  (isBuy ? tx.total : -tx.total);
        }
      }

      for (final e in movementMap.entries) {
        e.value.sort((x, y) => y.date.compareTo(x.date));
      }

      if (!mounted) return;
      setState(() {
        _accounts = accounts;
        _movementsByAccount = movementMap;
        _displayBalanceByAccount = displayBalanceMap;
        _financeById = financeById;
        _cariById = cariById;
        _investmentById = investmentById;
        _selectedAccountId = _resolveSelectedAccountId(_selectedAccountId, accounts);
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Hesap hareketleri yüklenemedi: $e';
      });
    }
  }

  int? _resolveSelectedAccountId(int? previousId, List<Account> accounts) {
    if (accounts.isEmpty) return null;
    if (previousId != null && accounts.any((a) => a.id == previousId)) {
      return previousId;
    }
    final firstActive = accounts.cast<Account?>().firstWhere(
          (a) => a?.isActive == true,
          orElse: () => null,
        );
    return firstActive?.id ?? accounts.first.id;
  }

  Account? _selectedAccount() {
    if (_selectedAccountId == null) return null;
    for (final a in _accounts) {
      if (a.id == _selectedAccountId) return a;
    }
    return null;
  }

  double _selectedAccountDisplayBalance() {
    final account = _selectedAccount();
    if (account == null) return 0;
    return _displayBalanceByAccount[account.id] ?? account.balance;
  }

  List<_AccountMovement> _filteredMovements() {
    final accountId = _selectedAccountId;
    if (accountId == null) return const [];

    final all = _movementsByAccount[accountId] ?? const [];
    final range = _resolveDateRange(_datePreset);
    if (range == null) return all;

    final filtered = all.where((m) {
      return !m.date.isBefore(range.$1) && !m.date.isAfter(range.$2);
    }).toList();
    filtered.sort((a, b) => b.date.compareTo(a.date));
    return filtered;
  }

  (DateTime, DateTime)? _resolveDateRange(_DatePreset preset) {
    if (preset == _DatePreset.all) return null;

    final ref = _periodReferenceDate;
    late final DateTime start;
    late final DateTime end;

    if (preset == _DatePreset.day) {
      final now = DateTime.now();
      start = DateTime(now.year, now.month, now.day);
      end = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
      return (start, end);
    }

    if (preset == _DatePreset.week) {
      final weekday = ref.weekday;
      start = DateTime(ref.year, ref.month, ref.day)
          .subtract(Duration(days: weekday - 1));
      end = start.add(const Duration(days: 7))
          .subtract(const Duration(milliseconds: 1));
      return (start, end);
    }

    if (preset == _DatePreset.month) {
      start = DateTime(ref.year, ref.month, 1);
      end = DateTime(ref.year, ref.month + 1, 1)
          .subtract(const Duration(milliseconds: 1));
      return (start, end);
    }

    if (preset == _DatePreset.year) {
      start = DateTime(ref.year, 1, 1);
      end = DateTime(ref.year + 1, 1, 1).subtract(const Duration(milliseconds: 1));
      return (start, end);
    }

    if (_customStart == null || _customEnd == null) return null;
    final s = DateTime(
      _customStart!.year,
      _customStart!.month,
      _customStart!.day,
    );
    final e = DateTime(
      _customEnd!.year,
      _customEnd!.month,
      _customEnd!.day,
      23,
      59,
      59,
      999,
    );
    return s.isBefore(e) ? (s, e) : (e, s);
  }

  List<int> _availableYears() {
    final accountId = _selectedAccountId;
    final years = <int>{DateTime.now().year};
    if (accountId != null) {
      final items = _movementsByAccount[accountId] ?? const <_AccountMovement>[];
      for (final m in items) {
        years.add(m.date.year);
      }
    }
    final list = years.toList()..sort((a, b) => b.compareTo(a));
    return list;
  }

  String _weekRangeLabel(DateTime ref) {
    final weekday = ref.weekday;
    final start =
        DateTime(ref.year, ref.month, ref.day).subtract(Duration(days: weekday - 1));
    final end = start.add(const Duration(days: 6));
    return '${_fmtDate(start)} - ${_fmtDate(end)}';
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

  String _fmtDateTime(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final h = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$d.$m.${dt.year} $h:$min';
  }

  String _fmtDate(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    return '$d.$m.${dt.year}';
  }

  Future<Uint8List> _buildPdf(
    Account account,
    List<_AccountMovement> movements,
    double displayBalance,
    PdfPageFormat format,
  ) async {
    final font = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Roboto-Regular.ttf'),
    );
    final bold = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Roboto-Bold.ttf'),
    );

    double incoming = 0;
    double outgoing = 0;
    for (final m in movements) {
      if (m.amountSigned >= 0) {
        incoming += m.amountSigned;
      } else {
        outgoing += m.amountSigned.abs();
      }
    }
    final net = incoming - outgoing;

    final doc = pw.Document(
      theme: pw.ThemeData.withFont(base: font, bold: bold),
    );

    doc.addPage(
      pw.MultiPage(
        pageFormat: format,
        margin: const pw.EdgeInsets.all(24),
        build: (_) => [
          pw.Text(
            'Hesap Hareket Dökümü',
            style: pw.TextStyle(font: bold, fontSize: 18),
          ),
          pw.SizedBox(height: 6),
          pw.Text('Hesap: ${account.name}'),
          pw.Text('Güncel Bakiye: ${_fmtAmount(displayBalance)} TL'),
          pw.Text('Oluşturulma: ${_fmtDateTime(DateTime.now())}'),
          pw.SizedBox(height: 8),
          pw.Text(
            'Giren: ${_fmtAmount(incoming)} TL',
            style: pw.TextStyle(color: PdfColors.green700),
          ),
          pw.Text(
            'Çıkan: ${_fmtAmount(outgoing)} TL',
            style: pw.TextStyle(color: PdfColors.red700),
          ),
          pw.Text(
            'Net: ${net >= 0 ? '+' : '-'}${_fmtAmount(net.abs())} TL',
            style: pw.TextStyle(color: PdfColors.blue700, font: bold),
          ),
          pw.SizedBox(height: 12),
          if (movements.isEmpty)
            pw.Text('Seçilen filtreye uygun hareket bulunamadı.')
          else
            pw.TableHelper.fromTextArray(
              headers: const ['Tarih', 'Tür', 'Kaynak', 'Açıklama', 'Tutar'],
              data: movements
                  .map(
                    (m) => [
                      _fmtDateTime(m.date),
                      m.typeLabel,
                      m.sourceLabel,
                      m.description,
                      '${m.amountSigned >= 0 ? '+' : '-'}${_fmtAmount(m.amountSigned.abs())}',
                    ],
                  )
                  .toList(),
              headerStyle: pw.TextStyle(font: bold, fontSize: 9),
              cellStyle: const pw.TextStyle(fontSize: 8.5),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
              columnWidths: {
                0: const pw.FlexColumnWidth(1.3),
                1: const pw.FlexColumnWidth(1.0),
                2: const pw.FlexColumnWidth(1.2),
                3: const pw.FlexColumnWidth(1.7),
                4: const pw.FlexColumnWidth(1.0),
              },
            ),
        ],
      ),
    );

    return doc.save();
  }

  void _openPdfPreview() {
    final account = _selectedAccount();
    if (account == null) return;
    final movements = _filteredMovements();
    final displayBalance = _selectedAccountDisplayBalance();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          drawer: buildAppMenuDrawer(),
          appBar: AppBar(
            leading: const BackButton(),
            title: Text('${account.name} - PDF'),
            actions: [buildHomeAction(context)],
          ),
          body: PdfPreview(
            build: (format) =>
                _buildPdf(account, movements, displayBalance, format),
            canChangePageFormat: false,
            canChangeOrientation: false,
            canDebug: false,
            allowPrinting: true,
            allowSharing: true,
            pdfFileName: 'hesap_hareket_${account.id}.pdf',
          ),
        ),
      ),
    );
  }

  List<DropdownMenuItem<_DatePreset>> _datePresetItems() {
    return const [
      DropdownMenuItem(value: _DatePreset.all, child: Text('Tümü')),
      DropdownMenuItem(value: _DatePreset.day, child: Text('Günlük')),
      DropdownMenuItem(value: _DatePreset.week, child: Text('Haftalık')),
      DropdownMenuItem(value: _DatePreset.month, child: Text('Aylık')),
      DropdownMenuItem(value: _DatePreset.year, child: Text('Yıllık')),
      DropdownMenuItem(value: _DatePreset.custom, child: Text('Özel')),
    ];
  }

  Future<void> _editMovement(_AccountMovement movement) async {
    bool? changed;
    if (movement.sourceType == _MovementSourceType.finance) {
      final tx = _financeById[movement.sourceId];
      if (tx == null) return;
      changed = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => tx.type == 'income'
              ? IncomeEntryScreen(initialTransaction: tx)
              : ExpenseEntryScreen(initialTransaction: tx),
        ),
      );
    } else if (movement.sourceType == _MovementSourceType.cari) {
      final tx = _cariById[movement.sourceId];
      if (tx == null) return;
      changed = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => CariAccountScreen(initialTransaction: tx),
        ),
      );
    } else if (movement.sourceType == _MovementSourceType.investment) {
      final tx = _investmentById[movement.sourceId];
      if (tx == null) return;
      changed = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => InvestmentEntryScreen(initialTransaction: tx),
        ),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transfer düzenleme bu ekranda yok.')),
      );
      return;
    }
    if (changed == true && mounted) {
      await _load();
    }
  }

  Future<void> _deleteMovement(_AccountMovement movement) async {
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
      if (movement.sourceType == _MovementSourceType.finance) {
        await FinanceTransactionService.deleteAndReturn(movement.sourceId);
      } else if (movement.sourceType == _MovementSourceType.cari) {
        await CariTransactionService.deleteAndReturn(movement.sourceId);
      } else if (movement.sourceType == _MovementSourceType.transfer) {
        await TransferTransactionService.deleteAndReturn(movement.sourceId);
      } else {
        await InvestmentTransactionService.deleteAndReturn(movement.sourceId);
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

  @override
  Widget build(BuildContext context) {
    final account = _selectedAccount();
    final movements = _filteredMovements();
    final displayBalance = _selectedAccountDisplayBalance();
    final availableYears = _availableYears();

    return Scaffold(
      drawer: buildAppMenuDrawer(),
      appBar: AppBar(
        leading: buildMenuLeading(),
        title: const Text('Hesap Geçmişi'),
        actions: [
          IconButton(
            onPressed: account == null ? null : _openPdfPreview,
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'PDF Raporla',
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
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(_error!, textAlign: TextAlign.center),
                  ),
                )
              : _accounts.isEmpty
                  ? const Center(child: Text('Hesap bulunamadı.'))
                  : Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                          child: Card(
                            child: ListTile(
                              title: Text(
                                account?.name ?? '-',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  decoration: (account?.isActive ?? true)
                                      ? null
                                      : TextDecoration.lineThrough,
                                ),
                              ),
                              subtitle: const Text('Güncel Bakiye'),
                              trailing: Text(
                                '${_fmtAmount(displayBalance)} TL',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: displayBalance >= 0
                                      ? Colors.blue
                                      : Colors.orange,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  DropdownButtonFormField<int>(
                                    initialValue: _selectedAccountId,
                                    decoration: const InputDecoration(
                                      labelText: 'Hesap Seç',
                                      border: OutlineInputBorder(),
                                      isDense: true,
                                    ),
                                    items: _accounts
                                        .map(
                                          (a) => DropdownMenuItem<int>(
                                            value: a.id,
                                            child: Text(
                                              a.name,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (v) {
                                      setState(() {
                                        _selectedAccountId = v;
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 10),
                                  DropdownButtonFormField<_DatePreset>(
                                    initialValue: _datePreset,
                                    decoration: const InputDecoration(
                                      labelText: 'Dönem',
                                      border: OutlineInputBorder(),
                                      isDense: true,
                                    ),
                                    items: _datePresetItems(),
                                    onChanged: (v) {
                                      if (v == null) return;
                                      _onDatePresetChanged(v);
                                    },
                                  ),
                                  if (_datePreset != _DatePreset.all) ...[
                                    const SizedBox(height: 10),
                                    if (_datePreset == _DatePreset.day)
                                      const Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text('Referans gün: Bugün'),
                                      )
                                    else if (_datePreset == _DatePreset.week)
                                      SizedBox(
                                        width: double.infinity,
                                        child: OutlinedButton.icon(
                                          onPressed: _pickReferenceDate,
                                          icon: const Icon(Icons.date_range),
                                          label: Text(
                                            'Hafta: ${_weekRangeLabel(_periodReferenceDate)}',
                                          ),
                                        ),
                                      )
                                    else if (_datePreset == _DatePreset.month)
                                      Row(
                                        children: [
                                          Expanded(
                                            child: DropdownButtonFormField<int>(
                                              initialValue: _periodReferenceDate.year,
                                              decoration: const InputDecoration(
                                                labelText: 'Yıl',
                                                border: OutlineInputBorder(),
                                                isDense: true,
                                              ),
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
                                              initialValue: _periodReferenceDate.month,
                                              decoration: const InputDecoration(
                                                labelText: 'Ay',
                                                border: OutlineInputBorder(),
                                                isDense: true,
                                              ),
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
                                        initialValue: _periodReferenceDate.year,
                                        decoration: const InputDecoration(
                                          labelText: 'Yıl',
                                          border: OutlineInputBorder(),
                                          isDense: true,
                                        ),
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
                                      )
                                    else if (_datePreset == _DatePreset.custom)
                                      Row(
                                        children: [
                                          Expanded(
                                            child: OutlinedButton.icon(
                                              onPressed: () => _pickCustomDate(start: true),
                                              icon: const Icon(Icons.event),
                                              label: Text(
                                                _customStart == null
                                                    ? 'Başlangıç'
                                                    : _fmtDate(_customStart!),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: OutlinedButton.icon(
                                              onPressed: () => _pickCustomDate(start: false),
                                              icon: const Icon(Icons.event),
                                              label: Text(
                                                _customEnd == null
                                                    ? 'Bitiş'
                                                    : _fmtDate(_customEnd!),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: movements.isEmpty
                              ? const Center(
                                  child: Text('Seçilen filtreye uygun hareket yok.'),
                                )
                              : ListView.separated(
                                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                                  itemCount: movements.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: 8),
                                  itemBuilder: (_, i) {
                                    final m = movements[i];
                                    final positive = m.amountSigned >= 0;
                                    return Card(
                                      child: ListTile(
                                        leading: Icon(
                                          positive
                                              ? Icons.arrow_downward
                                              : Icons.arrow_upward,
                                          color: positive ? Colors.green : Colors.red,
                                        ),
                                        title: Text('${m.typeLabel} • ${m.sourceLabel}'),
                                        subtitle: Text(
                                          '${_fmtDateTime(m.date)}\nAçıklama: ${m.description}',
                                        ),
                                        isThreeLine: true,
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              '${positive ? '+' : '-'}${_fmtAmount(m.amountSigned.abs())} TL',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: positive ? Colors.green : Colors.red,
                                              ),
                                            ),
                                            PopupMenuButton<String>(
                                              onSelected: (v) async {
                                                if (v == 'edit') {
                                                  await _editMovement(m);
                                                } else if (v == 'delete') {
                                                  await _deleteMovement(m);
                                                }
                                              },
                                              itemBuilder: (_) => [
                                                const PopupMenuItem<String>(
                                                  value: 'edit',
                                                  child: Text('Düzenle'),
                                                ),
                                                const PopupMenuItem<String>(
                                                  value: 'delete',
                                                  child: Text('Sil'),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
    );
  }
}

class _AccountMovement {
  final DateTime date;
  final String typeLabel;
  final String sourceLabel;
  final String description;
  final double amountSigned;
  final _MovementSourceType sourceType;
  final int sourceId;

  const _AccountMovement({
    required this.date,
    required this.typeLabel,
    required this.sourceLabel,
    required this.description,
    required this.amountSigned,
    required this.sourceType,
    required this.sourceId,
  });
}
