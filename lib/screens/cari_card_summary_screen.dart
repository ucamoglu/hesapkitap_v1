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
import '../utils/navigation_helpers.dart';

class CariCardSummaryScreen extends StatefulWidget {
  const CariCardSummaryScreen({super.key});

  @override
  State<CariCardSummaryScreen> createState() => _CariCardSummaryScreenState();
}

class _CariCardSummaryScreenState extends State<CariCardSummaryScreen> {
  bool _loading = true;
  String? _error;
  List<_CariCardSummary> _items = [];
  Map<int, String> _accountNames = {};

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
      final cards = allCards
          .where((c) => (c.currencyType).trim().toLowerCase() != 'foreign')
          .toList();
      final txs = await CariTransactionService.getAll();
      final accounts = await AccountService.getAllAccounts();

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

        return _CariCardSummary(
          card: card,
          transactions: list,
          totalCollection: collection,
          totalPayment: payment,
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
        title: const Text('Cari Kart Özet (TL)'),
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
                            final net = item.totalCollection - item.totalPayment;
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
                                child: ListTile(
                                  onTap: () => _openMovements(item),
                                  title: Text(
                                    _cardName(item.card),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      decoration:
                                          item.card.isActive ? null : TextDecoration.lineThrough,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Gelen: ${_fmtAmount(item.totalCollection)} TL'
                                    ' - Giden: ${_fmtAmount(item.totalPayment)} TL',
                                  ),
                                  trailing: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      const Icon(Icons.chevron_left,
                                          size: 18, color: Colors.black45),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Net: ${net >= 0 ? '+' : '-'}${_fmtAmount(net.abs())}',
                                        style: TextStyle(
                                          color: net >= 0 ? Colors.blue : Colors.orange,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
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

  const _CariCardSummary({
    required this.card,
    required this.transactions,
    required this.totalCollection,
    required this.totalPayment,
  });
}
