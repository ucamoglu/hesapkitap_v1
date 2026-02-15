import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/account.dart';
import '../models/investment_transaction.dart';
import '../services/account_service.dart';
import '../services/investment_transaction_service.dart';
import '../services/market_rate_service.dart';
import '../utils/navigation_helpers.dart';

class InvestmentTrackingScreen extends StatefulWidget {
  const InvestmentTrackingScreen({super.key});

  @override
  State<InvestmentTrackingScreen> createState() => _InvestmentTrackingScreenState();
}

class _InvestmentTrackingScreenState extends State<InvestmentTrackingScreen> {
  bool _loading = true;
  String? _error;

  List<InvestmentTransaction> _items = [];
  Map<int, String> _accountNames = {};
  Map<int, Account> _accountsById = {};
  Map<String, double> _livePriceBySymbol = {};
  DateTime? _priceFetchedAt;
  final Set<String> _expandedPortfolioKeys = <String>{};

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
        InvestmentTransactionService.getAll(),
        AccountService.getAllAccounts(),
      ]);
      final items = results[0] as List<InvestmentTransaction>;
      final accounts = results[1] as List<Account>;
      final accountsById = {for (final a in accounts) a.id: a};

      final currencySymbols = <String>{};
      final metalSymbols = <String>{};
      final stockSymbols = <String>{};
      final cryptoSymbols = <String>{};
      for (final a in accounts) {
        if (a.type != 'investment' || !a.isActive) continue;
        final symbol = (a.investmentSymbol ?? '').trim().toUpperCase();
        if (symbol.isEmpty) continue;
        final subtype = (a.investmentSubtype ?? '').trim().toLowerCase();
        if (subtype == 'currency') {
          currencySymbols.add(symbol);
        } else if (subtype == 'metal') {
          metalSymbols.add(symbol);
        } else if (subtype == 'stock') {
          stockSymbols.add(symbol);
        } else if (subtype == 'crypto') {
          cryptoSymbols.add(symbol);
        }
      }

      final livePriceBySymbol = <String, double>{};
      try {
        final currencies = await MarketRateService.fetchAllCurrencies();
        for (final r in currencies.items) {
          final code = r.code.toUpperCase();
          if (!currencySymbols.contains(code)) continue;
          final price = r.sell > 0 ? r.sell : r.buy;
          if (price > 0) livePriceBySymbol[code] = price;
        }
      } catch (_) {}
      try {
        final metals = await MarketRateService.fetchAllMetals();
        for (final r in metals.items) {
          final code = r.code.toUpperCase();
          if (!metalSymbols.contains(code)) continue;
          final price = r.sell > 0 ? r.sell : r.buy;
          if (price > 0) livePriceBySymbol[code] = price;
        }
      } catch (_) {}
      if (stockSymbols.isNotEmpty) {
        try {
          final stocks = await MarketRateService.fetchStocksByCodes(stockSymbols.toList());
          for (final r in stocks) {
            final price = r.sell > 0 ? r.sell : r.buy;
            if (price > 0) livePriceBySymbol[r.code.toUpperCase()] = price;
          }
        } catch (_) {}
      }
      if (cryptoSymbols.isNotEmpty) {
        try {
          final cryptos = await MarketRateService.fetchCryptosByCodes(cryptoSymbols.toList());
          for (final r in cryptos) {
            final price = r.sell > 0 ? r.sell : r.buy;
            if (price > 0) livePriceBySymbol[r.code.toUpperCase()] = price;
          }
        } catch (_) {}
      }

      if (!mounted) return;
      setState(() {
        _items = items;
        _accountNames = {for (final a in accounts) a.id: a.name};
        _accountsById = accountsById;
        _livePriceBySymbol = livePriceBySymbol;
        _priceFetchedAt = DateTime.now();
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Yatırım portföyü verileri yüklenemedi: $e';
      });
    }
  }

  bool _isBuy(String type) {
    final t = type.trim().toLowerCase();
    return t == 'buy' || t == 'alış' || t == 'alis';
  }

  bool _isSell(String type) {
    final t = type.trim().toLowerCase();
    return t == 'sell' || t == 'satış' || t == 'satis';
  }

  String _fmtDate(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '$dd.$mm.${d.year}';
  }

  String _fmtMoney(double value) {
    if (!value.isFinite) return '0,00';
    final fixed = value.toStringAsFixed(2);
    final parts = fixed.split('.');
    if (parts.length < 2) return '$fixed,00';
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

  String _fmtQty(double q) => q.toStringAsFixed(4);

  String _fmtSignedMoney(double value) {
    final sign = value >= 0 ? '+' : '-';
    return '$sign${_fmtMoney(value.abs())}';
  }

  String _fmtRateDate() {
    final d = _priceFetchedAt ?? DateTime.now();
    return _fmtDate(d);
  }

  Color _sentimentColor(double value) {
    return value >= 0 ? Colors.green : Colors.red;
  }

  String _sentimentLabel(double value) {
    return value >= 0 ? 'Olumlu' : 'Olumsuz';
  }

  Future<Uint8List> _buildPdf(PdfPageFormat format) async {
    final font = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Roboto-Regular.ttf'),
    );
    final bold = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Roboto-Bold.ttf'),
    );

    final grouped = <String, List<InvestmentTransaction>>{};
    for (final tx in _items) {
      final key = '${tx.investmentAccountId}|${tx.symbol.toUpperCase()}';
      grouped.putIfAbsent(key, () => []).add(tx);
    }
    final orderedKeys = grouped.keys.toList()..sort();

    final doc = pw.Document(
      theme: pw.ThemeData.withFont(base: font, bold: bold),
    );

    doc.addPage(
      pw.MultiPage(
        pageFormat: format,
        margin: const pw.EdgeInsets.all(20),
        build: (_) {
          final widgets = <pw.Widget>[
            pw.Text('Yatirim Portfoyu', style: pw.TextStyle(font: bold, fontSize: 18)),
            pw.SizedBox(height: 6),
            pw.Text('Olusturma: ${_fmtDate(DateTime.now())}'),
            pw.SizedBox(height: 12),
          ];

          for (final key in orderedKeys) {
            final parts = key.split('|');
            final accountId = int.parse(parts[0]);
            final symbol = parts[1];
            final accountName = _accountNames[accountId] ?? 'Hesap #$accountId';
            final rows = _buildLotRows(grouped[key]!);

            widgets.add(
              pw.Text(
                '$accountName - $symbol',
                style: pw.TextStyle(font: bold, fontSize: 12),
              ),
            );
            widgets.add(pw.SizedBox(height: 6));
            widgets.add(
              pw.TableHelper.fromTextArray(
                headers: const [
                  'Alis #',
                  'Tarih',
                  'Giris',
                  'Alis Tutar',
                  'Alis Birim',
                  'Cikan',
                  'Satis Tutar',
                  'Kalan',
                  'Lot K/Z',
                ],
                data: rows
                    .map(
                      (r) => [
                        r.buyTxId.toString(),
                        _fmtDate(r.buyDate),
                        _fmtQty(r.buyQty),
                        _fmtMoney(r.buyTotal),
                        _fmtMoney(r.buyUnitPrice),
                        _fmtQty(r.soldQty),
                        _fmtMoney(r.soldTotal),
                        _fmtQty(r.remainingQty),
                        '${r.lotPnl >= 0 ? '+' : '-'}${_fmtMoney(r.lotPnl.abs())}',
                      ],
                    )
                    .toList(),
                headerStyle: pw.TextStyle(font: bold, fontSize: 8.5),
                cellStyle: const pw.TextStyle(fontSize: 8),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
              ),
            );
            widgets.add(pw.SizedBox(height: 10));
          }
          return widgets;
        },
      ),
    );

    return doc.save();
  }

  void _openPdfPreview() {
    if (_items.isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          drawer: buildAppMenuDrawer(),
          appBar: AppBar(
            leading: const BackButton(),
            title: const Text('Yatirim Portfoyu - PDF'),
            actions: [buildHomeAction(context)],
          ),
          body: PdfPreview(
            build: (format) => _buildPdf(format),
            canChangePageFormat: false,
            canChangeOrientation: false,
            canDebug: false,
            allowPrinting: true,
            allowSharing: true,
            pdfFileName: 'yatirim_portfoyu.pdf',
          ),
        ),
      ),
    );
  }

  List<_LotView> _buildLotRows(List<InvestmentTransaction> txs) {
    final sorted = [...txs]
      ..sort((a, b) {
        final byCreated = a.createdAt.compareTo(b.createdAt);
        if (byCreated != 0) return byCreated;
        return a.id.compareTo(b.id);
      });

    final lots = <_LotView>[];

    for (final tx in sorted) {
      if (_isBuy(tx.type)) {
        lots.add(
          _LotView(
            buyTxId: tx.id,
            buyDate: tx.date,
            symbol: tx.symbol,
            buyQty: tx.quantity,
            buyTotal: tx.total,
            buyUnitPrice: tx.unitPrice,
            soldQty: 0,
            soldTotal: 0,
            remainingQty: tx.quantity,
            lotPnl: 0,
          ),
        );
        continue;
      }

      if (_isSell(tx.type)) {
        var remainingSellQty = tx.quantity;
        for (int i = 0; i < lots.length; i++) {
          if (remainingSellQty <= 0) break;
          final lot = lots[i];
          if (lot.remainingQty <= 0) continue;

          final used = remainingSellQty <= lot.remainingQty
              ? remainingSellQty
              : lot.remainingQty;
          final sellPartTotal = used * tx.unitPrice;
          final pnlPart = used * (tx.unitPrice - lot.buyUnitPrice);

          lots[i] = lot.copyWith(
            soldQty: lot.soldQty + used,
            soldTotal: lot.soldTotal + sellPartTotal,
            remainingQty: lot.remainingQty - used,
            lotPnl: lot.lotPnl + pnlPart,
          );
          remainingSellQty -= used;
        }
      }
    }

    return lots;
  }

  @override
  Widget build(BuildContext context) {
    final grouped = <String, List<InvestmentTransaction>>{};
    for (final tx in _items) {
      final key = '${tx.investmentAccountId}|${tx.symbol.toUpperCase()}';
      grouped.putIfAbsent(key, () => []).add(tx);
    }

    final orderedKeys = grouped.keys.toList()
      ..sort((a, b) {
        final aAcc = int.parse(a.split('|')[0]);
        final bAcc = int.parse(b.split('|')[0]);
        final aName = _accountNames[aAcc] ?? 'Hesap #$aAcc';
        final bName = _accountNames[bAcc] ?? 'Hesap #$bAcc';
        final byName = aName.compareTo(bName);
        if (byName != 0) return byName;
        return a.compareTo(b);
      });
    final lotRowsByKey = <String, List<_LotView>>{};
    for (final key in orderedKeys) {
      lotRowsByKey[key] = _buildLotRows(grouped[key]!);
    }
    double positiveTotal = 0;
    double negativeTotal = 0;
    for (final key in orderedKeys) {
      final parts = key.split('|');
      final symbol = parts[1].toUpperCase();
      final rate = _livePriceBySymbol[symbol];
      if (rate == null || rate <= 0) continue;
      final rows = lotRowsByKey[key] ?? const <_LotView>[];
      final remainingTotal = rows.fold<double>(0, (sum, row) => sum + row.remainingQty);
      final currentValue = remainingTotal * rate;
      if (currentValue >= 0) {
        positiveTotal += currentValue;
      } else {
        negativeTotal += currentValue.abs();
      }
    }
    final netPnl = positiveTotal - negativeTotal;

    return Scaffold(
      drawer: buildAppMenuDrawer(),
      appBar: AppBar(
        leading: buildMenuLeading(),
        title: const Text('Yatırım Portföyü'),
        actions: [
          IconButton(
            onPressed: _items.isEmpty ? null : _openPdfPreview,
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
              : grouped.isEmpty
                  ? const Center(child: Text('Yatırım işlemi bulunamadı.'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: orderedKeys.length + 1,
                      itemBuilder: (_, i) {
                        if (i == 0) {
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Wrap(
                                spacing: 16,
                                runSpacing: 8,
                                children: [
                                  Text(
                                    'Toplam Olumlu: ${_fmtMoney(positiveTotal)} TL',
                                    style: const TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    'Toplam Olumsuz: ${_fmtMoney(negativeTotal)} TL',
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    'Net K/Z: ${netPnl >= 0 ? '+' : '-'}${_fmtMoney(netPnl.abs())} TL',
                                    style: TextStyle(
                                      color: netPnl >= 0 ? Colors.green : Colors.red,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                        final idx = i - 1;
                        final key = orderedKeys[idx];
                        final parts = key.split('|');
                        final accountId = int.parse(parts[0]);
                        final symbol = parts[1];
                        final accountName = _accountNames[accountId] ?? 'Hesap #$accountId';
                        final account = _accountsById[accountId];
                        final lotRows = lotRowsByKey[key] ?? const <_LotView>[];
                        final remainingTotal = lotRows.fold<double>(
                          0,
                          (sum, row) => sum + row.remainingQty,
                        );
                        final lotPnlTotal = lotRows.fold<double>(
                          0,
                          (sum, row) => sum + row.lotPnl,
                        );
                        final rate = _livePriceBySymbol[symbol.toUpperCase()];
                        final currentValue = rate == null ? null : (remainingTotal * rate);
                        final sentimentValue = currentValue ?? lotPnlTotal;
                        final isExpanded = _expandedPortfolioKeys.contains(key);
                        final subtype = (account?.investmentSubtype ?? '').trim().toLowerCase();
                        final kindLabel = subtype == 'currency'
                            ? 'Döviz'
                            : subtype == 'metal'
                                ? 'Kıymetli Maden'
                                : subtype == 'stock'
                                    ? 'Borsa'
                                    : subtype == 'crypto'
                                        ? 'Kripto'
                                        : 'Yatırım';
                        final amountText = currentValue == null
                            ? 'Tutar: veri yok'
                            : 'Tutar: ${_fmtSignedMoney(currentValue)} TL';
                        final rateText =
                            rate == null ? 'veri yok' : '${_fmtMoney(rate)} TL';

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      if (isExpanded) {
                                        _expandedPortfolioKeys.remove(key);
                                      } else {
                                        _expandedPortfolioKeys.add(key);
                                      }
                                    });
                                  },
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              '$accountName • $symbol',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                          Icon(
                                            isExpanded
                                                ? Icons.keyboard_arrow_up
                                                : Icons.chevron_left,
                                            color: Colors.black45,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text('Cins: $kindLabel ($symbol)'),
                                      Text('Kalan Toplam: ${_fmtQty(remainingTotal)}'),
                                      Text('Güncel Kur (${_fmtRateDate()}): $rateText'),
                                      Text(
                                        'Durum: ${_sentimentLabel(sentimentValue)}',
                                        style: TextStyle(
                                          color: _sentimentColor(sentimentValue),
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      Text(
                                        amountText,
                                        style: TextStyle(
                                          color: _sentimentColor(sentimentValue),
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isExpanded) ...[
                                  const SizedBox(height: 8),
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: DataTable(
                                      columns: const [
                                        DataColumn(label: Text('Alış #')),
                                        DataColumn(label: Text('Tarih')),
                                        DataColumn(label: Text('Giriş Adet')),
                                        DataColumn(label: Text('Alış Tutarı')),
                                        DataColumn(label: Text('Alış Birim')),
                                        DataColumn(label: Text('Çıkan Adet')),
                                        DataColumn(label: Text('Satış Tutarı')),
                                        DataColumn(label: Text('Kalan Adet')),
                                        DataColumn(label: Text('Lot K/Z')),
                                      ],
                                      rows: lotRows
                                          .map(
                                            (r) => DataRow(
                                              cells: [
                                                DataCell(Text(r.buyTxId.toString())),
                                                DataCell(Text(_fmtDate(r.buyDate))),
                                                DataCell(Text(_fmtQty(r.buyQty))),
                                                DataCell(Text('${_fmtMoney(r.buyTotal)} TL')),
                                                DataCell(Text('${_fmtMoney(r.buyUnitPrice)} TL')),
                                                DataCell(Text(_fmtQty(r.soldQty))),
                                                DataCell(Text('${_fmtMoney(r.soldTotal)} TL')),
                                                DataCell(Text(_fmtQty(r.remainingQty))),
                                                DataCell(
                                                  Text(
                                                    '${r.lotPnl >= 0 ? '+' : '-'}${_fmtMoney(r.lotPnl.abs())} TL',
                                                    style: TextStyle(
                                                      color: r.lotPnl >= 0
                                                          ? Colors.green
                                                          : Colors.red,
                                                      fontWeight: FontWeight.w700,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                          .toList(),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}

class _LotView {
  final int buyTxId;
  final DateTime buyDate;
  final String symbol;
  final double buyQty;
  final double buyTotal;
  final double buyUnitPrice;
  final double soldQty;
  final double soldTotal;
  final double remainingQty;
  final double lotPnl;

  const _LotView({
    required this.buyTxId,
    required this.buyDate,
    required this.symbol,
    required this.buyQty,
    required this.buyTotal,
    required this.buyUnitPrice,
    required this.soldQty,
    required this.soldTotal,
    required this.remainingQty,
    required this.lotPnl,
  });

  _LotView copyWith({
    double? soldQty,
    double? soldTotal,
    double? remainingQty,
    double? lotPnl,
  }) {
    return _LotView(
      buyTxId: buyTxId,
      buyDate: buyDate,
      symbol: symbol,
      buyQty: buyQty,
      buyTotal: buyTotal,
      buyUnitPrice: buyUnitPrice,
      soldQty: soldQty ?? this.soldQty,
      soldTotal: soldTotal ?? this.soldTotal,
      remainingQty: remainingQty ?? this.remainingQty,
      lotPnl: lotPnl ?? this.lotPnl,
    );
  }
}
