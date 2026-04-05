import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../core/runtime/app_runtime.dart';
import '../models/account.dart';
import '../models/asset_record.dart';
import '../models/category.dart';
import '../models/income_category.dart';
import '../services/account_service.dart';
import '../services/category_service.dart';
import '../services/income_category_service.dart';
import '../utils/navigation_helpers.dart';
import '../utils/turkish_money_input_formatter.dart';
import 'asset_operation_screen.dart';

enum _AssetStatusFilter { all, active, passive }

enum _AssetKindFilter { all, assets, fixtures }

class MyAssetsScreen extends StatefulWidget {
  const MyAssetsScreen({super.key});

  @override
  State<MyAssetsScreen> createState() => _MyAssetsScreenState();
}

class _MyAssetsScreenState extends State<MyAssetsScreen> {
  bool _loading = true;
  String? _error;
  List<AssetRecord> _assets = <AssetRecord>[];
  Map<int, String> _accountNames = <int, String>{};
  Map<int, String> _expenseCategoryNames = <int, String>{};
  Map<int, String> _incomeCategoryNames = <int, String>{};
  _AssetStatusFilter _statusFilter = _AssetStatusFilter.all;
  _AssetKindFilter _kindFilter = _AssetKindFilter.all;

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
        AppRuntime.dataLayer.assets.getAll(),
        AccountService.getAllAccounts(),
        CategoryService.getAllExpenseCategories(),
        IncomeCategoryService.getAll(),
      ]);
      final assets = results[0] as List<AssetRecord>;
      final accounts = results[1] as List<Account>;
      final expenseCategories = results[2] as List<Category>;
      final incomeCategories = results[3] as List<IncomeCategory>;
      if (!mounted) return;
      setState(() {
        _assets = assets;
        _accountNames = {for (final account in accounts) account.id: account.name};
        _expenseCategoryNames = {
          for (final category in expenseCategories) category.id: category.name,
        };
        _incomeCategoryNames = {
          for (final category in incomeCategories) category.id: category.name,
        };
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Varlıklar yüklenemedi: $e';
        _loading = false;
      });
    }
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

  List<AssetRecord> get _filteredAssets {
    return _assets.where((asset) {
      final matchesStatus = switch (_statusFilter) {
        _AssetStatusFilter.all => true,
        _AssetStatusFilter.active => asset.isActive && !asset.isSold,
        _AssetStatusFilter.passive => !asset.isActive || asset.isSold,
      };
      final matchesKind = switch (_kindFilter) {
        _AssetKindFilter.all => true,
        _AssetKindFilter.assets => asset.assetType != 'fixture',
        _AssetKindFilter.fixtures => asset.assetType == 'fixture',
      };
      return matchesStatus && matchesKind;
    }).toList();
  }

  String _fmtDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day.$month.${date.year}';
  }

  String _statusFilterLabel() {
    return switch (_statusFilter) {
      _AssetStatusFilter.all => 'Tümü',
      _AssetStatusFilter.active => 'Aktif',
      _AssetStatusFilter.passive => 'Pasif',
    };
  }

  String _kindFilterLabel() {
    return switch (_kindFilter) {
      _AssetKindFilter.all => 'Tüm Türler',
      _AssetKindFilter.assets => 'Varlıklar',
      _AssetKindFilter.fixtures => 'Demirbaşlar',
    };
  }

  Widget _metricCell({
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: valueColor ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Future<Uint8List> _buildPdf(PdfPageFormat format) async {
    final items = _filteredAssets;
    final font = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Roboto-Regular.ttf'),
    );
    final bold = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Roboto-Bold.ttf'),
    );

    final doc = pw.Document(
      theme: pw.ThemeData.withFont(base: font, bold: bold),
    );

    doc.addPage(
      pw.MultiPage(
        pageFormat: format,
        margin: const pw.EdgeInsets.all(24),
        build: (_) => [
          pw.Text(
            'Varliklarim Dokumu',
            style: pw.TextStyle(font: bold, fontSize: 18),
          ),
          pw.SizedBox(height: 6),
          pw.Text('Durum Filtresi: ${_statusFilterLabel()}'),
          pw.Text('Tur Filtresi: ${_kindFilterLabel()}'),
          pw.Text('Kayit Sayisi: ${items.length}'),
          pw.Text('Olusturulma: ${_fmtDate(DateTime.now())}'),
          pw.SizedBox(height: 12),
          if (items.isEmpty)
            pw.Text('Secili filtreye uygun varlik bulunamadi.')
          else
            pw.TableHelper.fromTextArray(
              headers: const [
                'Tur',
                'Varlik',
                'Durum',
                'Edinim',
                'Guncel',
                'Satis',
                'Kar/Zarar',
              ],
              data: items
                  .map(
                    (asset) => [
                      asset.assetTypeLabel,
                      asset.displayName,
                      asset.isActive && !asset.isSold ? 'Aktif' : 'Pasif',
                      _fmtAmount(asset.acquisitionValue),
                      asset.currentValue == null
                          ? '-'
                          : _fmtAmount(asset.currentValue!),
                      asset.saleValue == null
                          ? '-'
                          : _fmtAmount(asset.saleValue!),
                      asset.profitOrLoss == null
                          ? '-'
                          : _fmtAmount(asset.profitOrLoss!),
                    ],
                  )
                  .toList(),
              headerStyle: pw.TextStyle(font: bold, fontSize: 9),
              cellStyle: const pw.TextStyle(fontSize: 8.5),
              headerDecoration:
                  const pw.BoxDecoration(color: PdfColors.grey300),
              columnWidths: {
                0: const pw.FlexColumnWidth(1.0),
                1: const pw.FlexColumnWidth(1.8),
                2: const pw.FlexColumnWidth(0.9),
                3: const pw.FlexColumnWidth(1.0),
                4: const pw.FlexColumnWidth(1.0),
                5: const pw.FlexColumnWidth(1.0),
                6: const pw.FlexColumnWidth(1.0),
              },
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
            title: const Text('Varlıklarım - PDF'),
            actions: [buildHomeAction(context)],
          ),
          body: PdfPreview(
            build: _buildPdf,
            canChangePageFormat: false,
            canChangeOrientation: false,
            canDebug: false,
            allowPrinting: true,
            allowSharing: true,
            pdfFileName: 'varliklarim_dokumu.pdf',
          ),
        ),
      ),
    );
  }

  Future<void> _showAssetDetails(AssetRecord asset) async {
    final currentValueController = TextEditingController(
      text: asset.currentValueInput ?? '',
    );
    var savingCurrentValue = false;
    final canEditCurrentValue = asset.isActive && !asset.isSold;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        final detailRows = <(String, String)>[
          ('Tür', asset.assetTypeLabel),
          ('Ad', asset.displayName),
          ('Edinim Değeri', '${_fmtAmount(asset.acquisitionValue)} TL'),
          ('Ödeme Yöntemi', asset.paymentMethod == 'split' ? 'Çift' : 'Tek'),
          ('1. Ödeme Hesabı', _accountNames[asset.expenseAccountId] ?? '-'),
          (
            '1. Ödeme Tutarı',
            asset.primaryPaymentAmount == null
                ? '-'
                : '${_fmtAmount(asset.primaryPaymentAmount!)} TL'
          ),
          (
            '2. Ödeme Hesabı',
            asset.secondaryExpenseAccountId == null
                ? '-'
                : (_accountNames[asset.secondaryExpenseAccountId!] ?? '-')
          ),
          (
            '2. Ödeme Tutarı',
            asset.secondaryPaymentAmount == null
                ? '-'
                : '${_fmtAmount(asset.secondaryPaymentAmount!)} TL'
          ),
          (
            'Kredi Kartı Taksit',
            asset.creditCardInstallmentCount == null
                ? '-'
                : '${asset.creditCardInstallmentCount} taksit'
          ),
          ('Satış Değeri', asset.saleValue == null
              ? '-'
              : '${_fmtAmount(asset.saleValue!)} TL'),
          ('Durum', asset.isActive ? 'Aktif' : 'Pasif'),
          ('Gider Kategorisi', _expenseCategoryNames[asset.expenseCategoryId] ?? '-'),
          ('Gelir Hesabı', asset.incomeAccountId == null
              ? '-'
              : (_accountNames[asset.incomeAccountId!] ?? '-')),
          ('Gelir Kategorisi', asset.incomeCategoryId == null
              ? '-'
              : (_incomeCategoryNames[asset.incomeCategoryId!] ?? '-')),
          if (asset.assetType == 'vehicle') ('Marka', asset.brand ?? '-'),
          if (asset.assetType == 'vehicle') ('Model', asset.model ?? '-'),
          if (asset.assetType == 'vehicle') ('Plaka', asset.plate ?? '-'),
          if (asset.assetType == 'fixture') ('Marka', asset.brand ?? '-'),
          if (asset.assetType != 'vehicle' && asset.assetType != 'fixture')
            ('m2', asset.areaSquareMeters ?? '-'),
          if (asset.assetType != 'vehicle' && asset.assetType != 'fixture')
            ('Adres', asset.address ?? '-'),
          ('Açıklama', asset.description ?? '-'),
        ];
        final maxHeight = MediaQuery.of(context).size.height * 0.82;
        return StatefulBuilder(
          builder: (context, setModalState) {
            final keyboardInset = MediaQuery.of(context).viewInsets.bottom;
            Future<void> saveCurrentValue() async {
              if (!canEditCurrentValue) return;
              if (savingCurrentValue) return;
              setModalState(() {
                savingCurrentValue = true;
              });
              try {
                await AppRuntime.dataLayer.assets.updateDefinition(
                  assetId: asset.id,
                  assetType: asset.assetType,
                  name: asset.name,
                  areaSquareMeters: asset.areaSquareMeters,
                  address: asset.address,
                  brand: asset.brand,
                  model: asset.model,
                  plate: asset.plate,
                  description: asset.description,
                  currentValueInput: currentValueController.text.trim(),
                  isActive: asset.isActive,
                );
                if (!mounted || !context.mounted) return;
                Navigator.pop(context);
                await _load();
                if (!mounted) return;
                ScaffoldMessenger.of(this.context).showSnackBar(
                  const SnackBar(content: Text('Güncel değer kaydedildi.')),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(this.context).showSnackBar(
                  SnackBar(
                    content: Text('Güncel değer kaydedilemedi: $e'),
                  ),
                );
              } finally {
                if (mounted) {
                  setModalState(() {
                    savingCurrentValue = false;
                  });
                }
              }
            }

            return AnimatedPadding(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              padding: EdgeInsets.only(bottom: keyboardInset),
              child: SafeArea(
                child: SizedBox(
                  height: maxHeight,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
                    child: ListView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      children: [
                        Text(
                          asset.displayName,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...detailRows.expand((row) => [
                              ListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                title: Text(row.$1),
                                trailing: SizedBox(
                                  width: 160,
                                  child: Text(
                                    row.$2,
                                    textAlign: TextAlign.right,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const Divider(height: 1),
                            ]),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: currentValueController,
                          enabled: canEditCurrentValue,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: const [TurkishMoneyInputFormatter()],
                          decoration: InputDecoration(
                            labelText: 'Güncel Değer',
                            hintText: 'Örn: 1.250.000,00',
                            helperText: canEditCurrentValue
                                ? null
                                : 'Pasif varlık için güncel değer girilemez.',
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: savingCurrentValue ||
                                        !canEditCurrentValue
                                    ? null
                                    : saveCurrentValue,
                                child: Text(
                                  savingCurrentValue
                                      ? 'Kaydediliyor...'
                                      : 'Güncel Değeri Kaydet',
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () async {
                                  Navigator.pop(context);
                                  final saved = await Navigator.push<bool>(
                                    this.context,
                                    MaterialPageRoute(
                                      builder: (_) => AssetOperationScreen(
                                        mode: AssetOperationMode.edit,
                                        initialAsset: asset,
                                      ),
                                    ),
                                  );
                                  if (saved == true) {
                                    await _load();
                                  }
                                },
                                child: const Text('Düzenle'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredAssets = _filteredAssets;
    return Scaffold(
      drawer: buildAppMenuDrawer(),
      appBar: AppBar(
        leading: buildBackAction(
          context,
          onPressed: () => popToDashboard(context),
        ),
        title: const Text('Varlıklarım'),
        actions: [
          IconButton(
            onPressed: _loading ? null : _openPdfPreview,
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'PDF Döküm',
          ),
          buildHomeAction(context),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _assets.isEmpty
                  ? const Center(child: Text('Kayıtlı varlık bulunamadı.'))
                  : Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Filtreler',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  ChoiceChip(
                                    label: const Text('Tümü'),
                                    selected:
                                        _statusFilter == _AssetStatusFilter.all,
                                    onSelected: (_) {
                                      setState(() {
                                        _statusFilter = _AssetStatusFilter.all;
                                      });
                                    },
                                  ),
                                  ChoiceChip(
                                    label: const Text('Aktif'),
                                    selected: _statusFilter ==
                                        _AssetStatusFilter.active,
                                    onSelected: (_) {
                                      setState(() {
                                        _statusFilter =
                                            _AssetStatusFilter.active;
                                      });
                                    },
                                  ),
                                  ChoiceChip(
                                    label: const Text('Pasif'),
                                    selected: _statusFilter ==
                                        _AssetStatusFilter.passive,
                                    onSelected: (_) {
                                      setState(() {
                                        _statusFilter =
                                            _AssetStatusFilter.passive;
                                      });
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  ChoiceChip(
                                    label: const Text('Tüm Türler'),
                                    selected:
                                        _kindFilter == _AssetKindFilter.all,
                                    onSelected: (_) {
                                      setState(() {
                                        _kindFilter = _AssetKindFilter.all;
                                      });
                                    },
                                  ),
                                  ChoiceChip(
                                    label: const Text('Varlıklar'),
                                    selected:
                                        _kindFilter == _AssetKindFilter.assets,
                                    onSelected: (_) {
                                      setState(() {
                                        _kindFilter = _AssetKindFilter.assets;
                                      });
                                    },
                                  ),
                                  ChoiceChip(
                                    label: const Text('Demirbaşlar'),
                                    selected: _kindFilter ==
                                        _AssetKindFilter.fixtures,
                                    onSelected: (_) {
                                      setState(() {
                                        _kindFilter =
                                            _AssetKindFilter.fixtures;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: RefreshIndicator(
                            onRefresh: _load,
                            child: filteredAssets.isEmpty
                                ? ListView(
                                    padding:
                                        const EdgeInsets.fromLTRB(24, 24, 24, 24),
                                    children: const [
                                      SizedBox(height: 72),
                                      Center(
                                        child: Text(
                                          'Seçili filtreye uygun varlık bulunamadı.',
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  )
                                : ListView.builder(
                                    padding:
                                        const EdgeInsets.fromLTRB(12, 0, 12, 12),
                                    itemCount: filteredAssets.length,
                                    itemBuilder: (context, index) {
                                      final asset = filteredAssets[index];
                                      final profit = asset.profitOrLoss;
                                      final isActive =
                                          asset.isActive && !asset.isSold;
                                      return Dismissible(
                                        key: ValueKey('asset-${asset.id}'),
                                        direction: DismissDirection.endToStart,
                                        confirmDismiss: (_) async {
                                          await _showAssetDetails(asset);
                                          return false;
                                        },
                                        background: Container(
                                          alignment: Alignment.centerRight,
                                          padding: const EdgeInsets.only(right: 20),
                                          margin: const EdgeInsets.symmetric(
                                              vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.indigo.withValues(
                                                alpha: 0.12),
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                          child: const Icon(Icons.info_outline),
                                        ),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 12,
                                          ),
                                          margin: const EdgeInsets.symmetric(
                                              vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            border: Border.all(
                                              color: isActive
                                                  ? Colors.green.withValues(
                                                      alpha: 0.28)
                                                  : Colors.black.withValues(
                                                      alpha: 0.08),
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          asset.displayName,
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style:
                                                              const TextStyle(
                                                            fontWeight:
                                                                FontWeight.w700,
                                                          ),
                                                        ),
                                                        const SizedBox(height: 4),
                                                        Text(
                                                          asset.assetTypeLabel,
                                                          style:
                                                              const TextStyle(
                                                            color:
                                                                Colors.black54,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      horizontal: 10,
                                                      vertical: 6,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: isActive
                                                          ? Colors.green
                                                              .withValues(
                                                                  alpha: 0.12)
                                                          : Colors.black
                                                              .withValues(
                                                                  alpha: 0.06),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              999),
                                                    ),
                                                    child: Text(
                                                      isActive
                                                          ? 'Aktif'
                                                          : 'Pasif',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: isActive
                                                            ? Colors.green
                                                            : Colors.black54,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 12),
                                              GridView.count(
                                                crossAxisCount: 2,
                                                crossAxisSpacing: 10,
                                                mainAxisSpacing: 10,
                                                childAspectRatio: 2.1,
                                                shrinkWrap: true,
                                                physics:
                                                    const NeverScrollableScrollPhysics(),
                                                children: [
                                                  _metricCell(
                                                    label: 'Edinim',
                                                    value:
                                                        _fmtAmount(asset.acquisitionValue),
                                                  ),
                                                  _metricCell(
                                                    label: 'Güncel',
                                                    value: asset.currentValue ==
                                                            null
                                                        ? '-'
                                                        : _fmtAmount(
                                                            asset.currentValue!),
                                                  ),
                                                  _metricCell(
                                                    label: 'Satış',
                                                    value: asset.saleValue ==
                                                            null
                                                        ? '-'
                                                        : _fmtAmount(
                                                            asset.saleValue!),
                                                  ),
                                                  _metricCell(
                                                    label: 'Kar / Zarar',
                                                    value: profit == null
                                                        ? '-'
                                                        : _fmtAmount(profit),
                                                    valueColor: profit == null
                                                        ? Colors.black87
                                                        : (profit >= 0
                                                            ? Colors.green
                                                            : Colors.red),
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
                        ),
                      ],
                    ),
    );
  }
}
