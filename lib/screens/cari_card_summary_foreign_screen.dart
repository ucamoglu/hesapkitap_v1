import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/cari_card.dart';
import '../models/cari_transaction.dart';
import '../services/account_service.dart';
import '../services/cari_card_service.dart';
import '../services/cari_transaction_service.dart';
import '../services/market_rate_service.dart';
import '../utils/navigation_helpers.dart';

class CariCardSummaryForeignScreen extends StatefulWidget {
  const CariCardSummaryForeignScreen({super.key});

  @override
  State<CariCardSummaryForeignScreen> createState() =>
      _CariCardSummaryForeignScreenState();
}

class _CariCardSummaryForeignScreenState extends State<CariCardSummaryForeignScreen> {
  static const Duration _networkTimeout = Duration(seconds: 8);
  bool _loading = true;
  String? _error;
  List<_CariCardSummary> _items = [];
  Map<int, String> _accountNames = {};
  final Set<int> _expandedTrackCards = <int>{};

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
      final allCards = await CariCardService.getAll();
      final cards =
          allCards.where((c) => (c.currencyType).trim().toLowerCase() == 'foreign').toList();
      final txs = await CariTransactionService.getAll();
      final accounts = await AccountService.getAllAccounts();
      final currencyCodes = <String>{};
      final metalCodes = <String>{};
      final stockCodes = <String>{};
      final cryptoCodes = <String>{};
      for (final c in cards) {
        final code = (c.foreignCode ?? '').trim().toUpperCase();
        if (code.isEmpty) continue;
        switch ((c.foreignMarketType ?? '').trim().toLowerCase()) {
          case 'currency':
            currencyCodes.add(code);
            break;
          case 'metal':
            metalCodes.add(code);
            break;
          case 'stock':
            stockCodes.add(code);
            break;
          case 'crypto':
            cryptoCodes.add(code);
            break;
        }
      }

      final currencyPriceByCode = <String, double>{};
      final metalPriceByCode = <String, double>{};
      final stockPriceByCode = <String, double>{};
      final cryptoPriceByCode = <String, double>{};
      try {
        final res = await MarketRateService.fetchAllCurrencies().timeout(_networkTimeout);
        for (final r in res.items) {
          currencyPriceByCode[r.code.toUpperCase()] = r.sell;
        }
      } catch (_) {}
      try {
        final res = await MarketRateService.fetchAllMetals().timeout(_networkTimeout);
        for (final r in res.items) {
          metalPriceByCode[r.code.toUpperCase()] = r.sell;
        }
      } catch (_) {}
      try {
        final list = await MarketRateService
            .fetchStocksByCodes(stockCodes.toList())
            .timeout(_networkTimeout);
        for (final r in list) {
          stockPriceByCode[r.code.toUpperCase()] = r.sell;
        }
      } catch (_) {}
      try {
        final list = await MarketRateService
            .fetchCryptosByCodes(cryptoCodes.toList())
            .timeout(_networkTimeout);
        for (final r in list) {
          cryptoPriceByCode[r.code.toUpperCase()] = r.sell;
        }
      } catch (_) {}

      final byCard = <int, List<CariTransaction>>{};
      for (final tx in txs) {
        byCard.putIfAbsent(tx.cariCardId, () => []).add(tx);
      }

      final items = cards.map((card) {
        final list = [...(byCard[card.id] ?? const <CariTransaction>[])]
          ..sort((a, b) => b.date.compareTo(a.date));

        double collection = 0;
        double payment = 0;
        for (final tx in list) {
          if (tx.type == 'collection') {
            collection += tx.amount;
          } else {
            payment += tx.amount;
          }
        }
        final currentUnitPrice = _resolveCurrentUnitPrice(
          card,
          currencyPriceByCode: currencyPriceByCode,
          metalPriceByCode: metalPriceByCode,
          stockPriceByCode: stockPriceByCode,
          cryptoPriceByCode: cryptoPriceByCode,
        );
        final metrics = _buildForeignMetrics(list, currentUnitPrice);

        return _CariCardSummary(
          card: card,
          transactions: list,
          totalCollection: collection,
          totalPayment: payment,
          metrics: metrics,
        );
      }).toList()
        ..sort((a, b) {
          final currencyCmp =
              _currencyLabel(a.card).compareTo(_currencyLabel(b.card));
          if (currencyCmp != 0) return currencyCmp;
          return _cardBaseName(a.card).compareTo(_cardBaseName(b.card));
        });

      if (!mounted) return;
      setState(() {
        _items = items;
        _accountNames = {for (final a in accounts) a.id: a.name};
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Cari kart özet verileri alınamadı: $e';
      });
    }
  }

  String _cardBaseName(CariCard c) {
    if (c.type == 'company') {
      return (c.title ?? '').trim().isNotEmpty ? c.title!.trim() : 'Firma #${c.id}';
    }
    return (c.fullName ?? '').trim().isNotEmpty
        ? c.fullName!.trim()
        : 'Kişi #${c.id}';
  }

  String _currencyLabel(CariCard c) {
    if (c.currencyType != 'foreign') return 'TL';

    final explicitName = (c.foreignName ?? '').trim();
    if (explicitName.isNotEmpty) return explicitName;

    final code = (c.foreignCode ?? '').trim().toUpperCase();
    if (code.isEmpty) return 'Yabancı Para';
    switch (code) {
      case 'USD':
        return 'Dolar';
      case 'EUR':
        return 'Euro';
      case 'GBP':
        return 'Sterlin';
      case 'GA':
        return 'Gram Altın';
      default:
        return code;
    }
  }

  String _cardName(CariCard c) => '${_cardBaseName(c)} - ${_currencyLabel(c)}';

  String _unitLabel(CariCard c) {
    final n = (c.foreignName ?? '').trim();
    if (n.isNotEmpty) return n;
    final code = (c.foreignCode ?? '').trim().toUpperCase();
    return code.isEmpty ? 'Birim' : code;
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

  String _fmtQuantity(double value) {
    var s = value.toStringAsFixed(4);
    while (s.contains('.') && (s.endsWith('0') || s.endsWith('.'))) {
      s = s.substring(0, s.length - 1);
    }
    return s.replaceAll('.', ',');
  }

  String _fmtSignedQuantity(double value) {
    final sign = value > 0 ? '+' : (value < 0 ? '-' : '');
    return '$sign${_fmtQuantity(value.abs())}';
  }

  String _fmtSignedAmount(double value) {
    final sign = value > 0 ? '+' : (value < 0 ? '-' : '');
    return '$sign${_fmtAmount(value.abs())}';
  }

  String _sentimentLabel(double? value) {
    if (value == null) return 'Bilinmiyor';
    return value >= 0 ? 'Olumlu' : 'Olumsuz';
  }

  Color _sentimentColor(double? value) {
    if (value == null) return Colors.black54;
    return value >= 0 ? Colors.green : Colors.red;
  }

  List<_CariLotView> _buildCariLotRows(List<CariTransaction> txs) {
    final sorted = [...txs]
      ..sort((a, b) {
        final byCreated = a.createdAt.compareTo(b.createdAt);
        if (byCreated != 0) return byCreated;
        return a.id.compareTo(b.id);
      });

    final lots = <_CariLotView>[];
    final openLotQueue = <int>[];
    const eps = 1e-9;

    for (final tx in sorted) {
      final qty = _txQuantity(tx);
      if (qty == null || qty <= 0) continue;
      final unitPrice = (tx.unitPrice != null && tx.unitPrice! > 0)
          ? tx.unitPrice!
          : (tx.amount / qty);
      final txIsDebt = tx.type == 'debt';
      var remaining = qty;

      while (remaining > eps && openLotQueue.isNotEmpty) {
        final lotIndex = openLotQueue.first;
        final lot = lots[lotIndex];
        if (lot.isDebtEntry == txIsDebt) break;
        if (lot.remainingQty <= eps) {
          openLotQueue.removeAt(0);
          continue;
        }

        final used = remaining <= lot.remainingQty ? remaining : lot.remainingQty;
        final exitTotal = used * unitPrice;
        final pnlPart = (used * lot.buyUnitPrice) - exitTotal;

        lots[lotIndex] = lot.copyWith(
          soldQty: lot.soldQty + used,
          soldTotal: lot.soldTotal + exitTotal,
          remainingQty: lot.remainingQty - used,
          lotPnl: lot.lotPnl + pnlPart,
        );

        remaining -= used;
        if (lots[lotIndex].remainingQty <= eps) {
          openLotQueue.removeAt(0);
        }
      }

      if (remaining > eps) {
        lots.add(
          _CariLotView(
            buyTxId: tx.id,
            buyDate: tx.date,
            buyQty: remaining,
            buyTotal: remaining * unitPrice,
            buyUnitPrice: unitPrice,
            soldQty: 0,
            soldTotal: 0,
            remainingQty: remaining,
            lotPnl: 0,
            isDebtEntry: txIsDebt,
          ),
        );
        openLotQueue.add(lots.length - 1);
      }
    }
    return lots;
  }

  double? _resolveCurrentUnitPrice(
    CariCard card, {
    required Map<String, double> currencyPriceByCode,
    required Map<String, double> metalPriceByCode,
    required Map<String, double> stockPriceByCode,
    required Map<String, double> cryptoPriceByCode,
  }) {
    final code = (card.foreignCode ?? '').trim().toUpperCase();
    if (code.isEmpty) return null;
    switch ((card.foreignMarketType ?? '').trim().toLowerCase()) {
      case 'currency':
        return currencyPriceByCode[code];
      case 'metal':
        return metalPriceByCode[code];
      case 'stock':
        return stockPriceByCode[code];
      case 'crypto':
        return cryptoPriceByCode[code];
      default:
        return null;
    }
  }

  double? _txQuantity(CariTransaction tx) {
    final q = tx.quantity;
    if (q != null && q > 0) return q;
    final up = tx.unitPrice;
    if (up != null && up > 0) {
      final fallback = tx.amount / up;
      if (fallback > 0) return fallback;
    }
    return null;
  }

  _ForeignMetrics _buildForeignMetrics(List<CariTransaction> txs, double? currentUnitPrice) {
    double inQty = 0;
    double outQty = 0;
    double inTl = 0;
    double outTl = 0;
    double realizedPnl = 0;
    final lots = <_FifoLot>[];
    const eps = 1e-9;

    final ordered = [...txs]..sort((a, b) => a.date.compareTo(b.date));
    for (final tx in ordered) {
      final q = _txQuantity(tx);
      if (q == null || q <= 0) continue;
      final unit = (tx.unitPrice != null && tx.unitPrice! > 0)
          ? tx.unitPrice!
          : (tx.amount / q);

      // Cari bakiye işaret kuralı:
      // debt (+): borcum artar
      // collection (-): alacağım artar
      double delta = tx.type == 'debt' ? q : -q;
      if (tx.type == 'debt') {
        inQty += q;
        inTl += tx.amount;
      } else {
        outQty += q;
        outTl += tx.amount;
      }

      while (delta.abs() > eps &&
          lots.isNotEmpty &&
          (lots.first.qtySigned > 0) != (delta > 0)) {
        final head = lots.first;
        final matchQty = head.qtySigned.abs() < delta.abs() ? head.qtySigned.abs() : delta.abs();

        if (head.qtySigned > 0 && delta < 0) {
          // Long lot kapanisi (giden): (satis - alis) * miktar
          realizedPnl += (unit - head.unitPrice) * matchQty;
        } else if (head.qtySigned < 0 && delta > 0) {
          // Short lot kapanisi (gelen): (acilis - kapanis) * miktar
          realizedPnl += (head.unitPrice - unit) * matchQty;
        }

        head.qtySigned -= head.qtySigned.sign * matchQty;
        delta -= delta.sign * matchQty;
        if (head.qtySigned.abs() <= eps) {
          lots.removeAt(0);
        }
      }

      if (delta.abs() > eps) {
        lots.add(_FifoLot(qtySigned: delta, unitPrice: unit));
      }
    }

    final displayNetQty = inQty - outQty;
    final openCostTl = lots.fold<double>(0, (sum, l) => sum + (l.qtySigned * l.unitPrice));
    final currentValue = currentUnitPrice == null ? null : (displayNetQty * currentUnitPrice);
    final unrealizedPnl = currentValue == null ? null : (currentValue - openCostTl);
    final totalPnl = unrealizedPnl == null ? null : (realizedPnl + unrealizedPnl);
    return _ForeignMetrics(
      totalInQty: inQty,
      totalOutQty: outQty,
      totalInTl: inTl,
      totalOutTl: outTl,
      netQty: displayNetQty,
      openCostTl: openCostTl,
      currentUnitPrice: currentUnitPrice,
      currentValueTl: currentValue,
      realizedPnlTl: realizedPnl,
      unrealizedPnlTl: unrealizedPnl,
      totalPnlTl: totalPnl,
    );
  }

  Future<Uint8List> _buildMovementsPdf(
    _CariCardSummary item,
    PdfPageFormat format,
  ) async {
    final font = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Roboto-Regular.ttf'),
    );
    final bold = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Roboto-Bold.ttf'),
    );

    final net = item.totalCollection - item.totalPayment;
    final doc = pw.Document(
      theme: pw.ThemeData.withFont(base: font, bold: bold),
    );

    doc.addPage(
      pw.MultiPage(
        pageFormat: format,
        margin: const pw.EdgeInsets.all(24),
        build: (_) => [
          pw.Text(
            'Cari Kart Hareket Dökümü',
            style: pw.TextStyle(font: bold, fontSize: 18),
          ),
          pw.SizedBox(height: 6),
          pw.Text('Cari Kart: ${_cardName(item.card)}'),
          pw.Text('Oluşturulma: ${_fmtDateTime(DateTime.now())}'),
          pw.SizedBox(height: 8),
          pw.Text(
            'Gelen: ${_fmtAmount(item.totalCollection)} TL',
            style: pw.TextStyle(color: PdfColors.green700),
          ),
          pw.Text(
            'Giden: ${_fmtAmount(item.totalPayment)} TL',
            style: pw.TextStyle(color: PdfColors.red700),
          ),
          pw.Text(
            'Net: ${net >= 0 ? '+' : '-'}${_fmtAmount(net.abs())} TL',
            style: pw.TextStyle(color: PdfColors.blue700, font: bold),
          ),
          pw.SizedBox(height: 12),
          if (item.transactions.isEmpty)
            pw.Text('Hareket bulunamadı.')
          else
            pw.TableHelper.fromTextArray(
              headers: const ['Tarih', 'Tür', 'Hesap', 'Açıklama', 'Tutar'],
              data: item.transactions
                  .map((tx) {
                    final isCollection = tx.type == 'collection';
                    final accountName =
                        _accountNames[tx.accountId] ?? 'Hesap #${tx.accountId}';
                    final note = (tx.description ?? '').trim().isEmpty
                        ? '-'
                        : tx.description!.trim();
                    return <String>[
                      _fmtDateTime(tx.date),
                      isCollection ? 'Gelen' : 'Giden',
                      accountName,
                      note,
                      '${isCollection ? '+' : '-'}${_fmtAmount(tx.amount)}',
                    ];
                  })
                  .toList(),
              headerStyle: pw.TextStyle(font: bold, fontSize: 9),
              cellStyle: const pw.TextStyle(fontSize: 8.5),
              cellAlignment: pw.Alignment.centerLeft,
              headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
              columnWidths: {
                0: const pw.FlexColumnWidth(1.3),
                1: const pw.FlexColumnWidth(0.8),
                2: const pw.FlexColumnWidth(1.0),
                3: const pw.FlexColumnWidth(1.8),
                4: const pw.FlexColumnWidth(0.9),
              },
            ),
        ],
      ),
    );

    return doc.save();
  }

  void _openMovementsPdfPreview(_CariCardSummary item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          drawer: buildAppMenuDrawer(),
          appBar: AppBar(
            leading: const BackButton(),
            title: Text('${_cardName(item.card)} - PDF'),
            actions: [buildHomeAction(context)],
          ),
          body: PdfPreview(
            build: (format) => _buildMovementsPdf(item, format),
            canChangePageFormat: false,
            canChangeOrientation: false,
            canDebug: false,
            allowPrinting: true,
            allowSharing: true,
            pdfFileName: 'cari_hareket_${item.card.id}.pdf',
          ),
        ),
      ),
    );
  }

  void _openMovements(_CariCardSummary item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return SafeArea(
          child: SizedBox(
            height: MediaQuery.of(ctx).size.height * 0.72,
            child: Column(
              children: [
                ListTile(
                  title: Text(
                    _cardName(item.card),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('${item.transactions.length} hareket'),
                  trailing: TextButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _openMovementsPdfPreview(item);
                    },
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text('PDF'),
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: item.transactions.isEmpty
                      ? const Center(
                          child: Text('Bu cari kart için hareket bulunamadı.'),
                        )
                      : ListView.separated(
                          itemCount: item.transactions.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (_, i) {
                            final tx = item.transactions[i];
                            final isCollection = tx.type == 'collection';
                            final amount = _fmtAmount(tx.amount);
                            final accountName =
                                _accountNames[tx.accountId] ?? 'Hesap #${tx.accountId}';

                            return ListTile(
                              leading: Icon(
                                isCollection ? Icons.arrow_downward : Icons.arrow_upward,
                                color: isCollection ? Colors.green : Colors.red,
                              ),
                              title: Text(isCollection ? 'Gelen' : 'Giden'),
                              subtitle: Text(
                                '${_fmtDateTime(tx.date)} • $accountName\n'
                                'Açıklama: ${(tx.description ?? '').trim().isEmpty ? '-' : tx.description!.trim()}',
                              ),
                              isThreeLine: true,
                              trailing: Text(
                                '${isCollection ? '+' : '-'}$amount TL',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isCollection ? Colors.green : Colors.red,
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final groupedItems = <String, List<_CariCardSummary>>{};
    for (final item in _items) {
      final key = _currencyLabel(item.card);
      groupedItems.putIfAbsent(key, () => []).add(item);
    }
    final groupKeys = groupedItems.keys.toList()
      ..sort((a, b) {
        if (a == 'TL' && b != 'TL') return -1;
        if (b == 'TL' && a != 'TL') return 1;
        return a.compareTo(b);
      });

    return Scaffold(
      drawer: buildAppMenuDrawer(),
      appBar: AppBar(
        leading: buildMenuLeading(),
        title: const Text('Cari Kart Özet (Dış Finans)'),
        actions: [
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
              ? Center(child: Padding(padding: const EdgeInsets.all(16), child: Text(_error!)))
              : _items.isEmpty
                  ? const Center(child: Text('Kayıtlı cari kart bulunamadı.'))
                  : ListView(
                      padding: const EdgeInsets.all(12),
                      children: [
                        for (final group in groupKeys) ...[
                          Padding(
                            padding: const EdgeInsets.only(left: 4, right: 4, top: 4, bottom: 6),
                            child: Text(
                              'Para Birimi: $group',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          ...groupedItems[group]!.map((item) {
                            final m = item.metrics;
                            final unit = _unitLabel(item.card);
                            final instrumentName = _currencyLabel(item.card);
                            final isExpanded = _expandedTrackCards.contains(item.card.id);
                            final valueText = m.currentValueTl == null
                                ? 'Tutar: veri yok'
                                : 'Tutar: ${_fmtSignedAmount(m.currentValueTl!)} TL';
                            final rateText = m.currentUnitPrice == null
                                ? 'veri yok'
                                : '${_fmtAmount(m.currentUnitPrice!)} TL';
                            final sentimentColor = _sentimentColor(m.currentValueTl);
                            return Dismissible(
                              key: ValueKey('cari-summary-$group-${item.card.id}'),
                              direction: DismissDirection.endToStart,
                              confirmDismiss: (_) async {
                                _openMovements(item);
                                return false;
                              },
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                color: Colors.deepPurple.shade100,
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Icon(Icons.chevron_left),
                                    SizedBox(width: 8),
                                    Text('Hareketleri Aç'),
                                  ],
                                ),
                              ),
                              child: Card(
                                child: Column(
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          if (isExpanded) {
                                            _expandedTrackCards.remove(item.card.id);
                                          } else {
                                            _expandedTrackCards.add(item.card.id);
                                          }
                                        });
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    _cardName(item.card),
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.w600,
                                                      decoration: item.card.isActive
                                                          ? null
                                                          : TextDecoration.lineThrough,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.end,
                                                  children: [
                                                    Icon(
                                                      isExpanded
                                                          ? Icons.keyboard_arrow_up
                                                          : Icons.chevron_left,
                                                      size: 20,
                                                      color: Colors.black45,
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      valueText,
                                                      style: TextStyle(
                                                        color: sentimentColor,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text('Cins: $instrumentName'),
                                                Text(
                                                  'Kalan Toplam: ${_fmtSignedQuantity(m.netQty)} $unit',
                                                ),
                                                Text(
                                                  'Güncel Kur (${_fmtDate(DateTime.now())}): $rateText',
                                                ),
                                                Text(
                                                  'Durum: ${_sentimentLabel(m.currentValueTl)}',
                                                  style: TextStyle(
                                                    color: sentimentColor,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                                Text(
                                                  valueText,
                                                  style: TextStyle(
                                                    color: sentimentColor,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    if (isExpanded) ...[
                                      const Divider(height: 1),
                                      Builder(
                                        builder: (_) {
                                          final rows = _buildCariLotRows(item.transactions);
                                          if (rows.isEmpty) {
                                            return const Padding(
                                              padding: EdgeInsets.all(12),
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  'Bu kart için lot bazlı takip verisi bulunamadı.',
                                                  style: TextStyle(color: Colors.black54),
                                                ),
                                              ),
                                            );
                                          }
                                          return Padding(
                                            padding: const EdgeInsets.all(10),
                                            child: SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              child: DataTable(
                                                columns: const [
                                                  DataColumn(label: Text('Giriş #')),
                                                  DataColumn(label: Text('Tarih')),
                                                  DataColumn(label: Text('Giriş Adet')),
                                                  DataColumn(label: Text('Giriş Tutarı')),
                                                  DataColumn(label: Text('Giriş Birim')),
                                                  DataColumn(label: Text('Çıkan Adet')),
                                                  DataColumn(label: Text('Çıkış Tutarı')),
                                                  DataColumn(label: Text('Kalan Adet')),
                                                  DataColumn(label: Text('Lot K/Z')),
                                                ],
                                                rows: rows
                                                    .map(
                                                      (r) {
                                                        final lotPnL =
                                                            (r.soldQty * r.buyUnitPrice) -
                                                                r.soldTotal;
                                                        return DataRow(
                                                          cells: [
                                                            DataCell(Text(r.buyTxId.toString())),
                                                            DataCell(Text(_fmtDateTime(r.buyDate))),
                                                            DataCell(Text(_fmtQuantity(r.buyQty))),
                                                            DataCell(Text('${_fmtAmount(r.buyTotal)} TL')),
                                                            DataCell(Text('${_fmtAmount(r.buyUnitPrice)} TL')),
                                                            DataCell(Text(_fmtQuantity(r.soldQty))),
                                                            DataCell(Text('${_fmtAmount(r.soldTotal)} TL')),
                                                            DataCell(Text(_fmtQuantity(r.remainingQty))),
                                                            DataCell(
                                                              Text(
                                                                '${lotPnL >= 0 ? '+' : '-'}${_fmtAmount(lotPnL.abs())} TL',
                                                                style: TextStyle(
                                                                  color: lotPnL >= 0
                                                                      ? Colors.green
                                                                      : Colors.red,
                                                                  fontWeight: FontWeight.w700,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    )
                                                    .toList(),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          }),
                          const SizedBox(height: 6),
                        ],
                      ],
                    ),
    );
  }
}

class _CariCardSummary {
  final CariCard card;
  final List<CariTransaction> transactions;
  final double totalCollection;
  final double totalPayment;
  final _ForeignMetrics metrics;

  const _CariCardSummary({
    required this.card,
    required this.transactions,
    required this.totalCollection,
    required this.totalPayment,
    required this.metrics,
  });
}

class _ForeignMetrics {
  final double totalInQty;
  final double totalOutQty;
  final double totalInTl;
  final double totalOutTl;
  final double netQty;
  final double openCostTl;
  final double? currentUnitPrice;
  final double? currentValueTl;
  final double realizedPnlTl;
  final double? unrealizedPnlTl;
  final double? totalPnlTl;

  const _ForeignMetrics({
    required this.totalInQty,
    required this.totalOutQty,
    required this.totalInTl,
    required this.totalOutTl,
    required this.netQty,
    required this.openCostTl,
    required this.currentUnitPrice,
    required this.currentValueTl,
    required this.realizedPnlTl,
    required this.unrealizedPnlTl,
    required this.totalPnlTl,
  });
}

class _FifoLot {
  double qtySigned;
  final double unitPrice;

  _FifoLot({
    required this.qtySigned,
    required this.unitPrice,
  });
}

class _CariLotView {
  final int buyTxId;
  final DateTime buyDate;
  final double buyQty;
  final double buyTotal;
  final double buyUnitPrice;
  final double soldQty;
  final double soldTotal;
  final double remainingQty;
  final double lotPnl;
  final bool isDebtEntry;

  const _CariLotView({
    required this.buyTxId,
    required this.buyDate,
    required this.buyQty,
    required this.buyTotal,
    required this.buyUnitPrice,
    required this.soldQty,
    required this.soldTotal,
    required this.remainingQty,
    required this.lotPnl,
    required this.isDebtEntry,
  });

  _CariLotView copyWith({
    double? soldQty,
    double? soldTotal,
    double? remainingQty,
    double? lotPnl,
  }) {
    return _CariLotView(
      buyTxId: buyTxId,
      buyDate: buyDate,
      buyQty: buyQty,
      buyTotal: buyTotal,
      buyUnitPrice: buyUnitPrice,
      soldQty: soldQty ?? this.soldQty,
      soldTotal: soldTotal ?? this.soldTotal,
      remainingQty: remainingQty ?? this.remainingQty,
      lotPnl: lotPnl ?? this.lotPnl,
      isDebtEntry: isDebtEntry,
    );
  }
}
