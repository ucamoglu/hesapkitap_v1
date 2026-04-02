import 'package:flutter/material.dart';

import '../core/runtime/app_runtime.dart';
import '../models/account.dart';
import '../models/asset_record.dart';
import '../models/category.dart';
import '../models/income_category.dart';
import '../services/account_service.dart';
import '../services/category_service.dart';
import '../services/income_category_service.dart';
import '../utils/navigation_helpers.dart';
import 'asset_operation_screen.dart';

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

  Future<void> _showAssetDetails(AssetRecord asset) async {
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
          ('Güncel Değer', asset.currentValueInput?.isNotEmpty == true
              ? '${asset.currentValueInput} TL'
              : '-'),
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
          if (asset.assetType == 'fixture') ('Marka', asset.brand ?? '-'),
          if (asset.assetType != 'vehicle' && asset.assetType != 'fixture')
            ('m2', asset.areaSquareMeters ?? '-'),
          if (asset.assetType != 'vehicle' && asset.assetType != 'fixture')
            ('Adres', asset.address ?? '-'),
          ('Açıklama', asset.description ?? '-'),
        ];
        final maxHeight = MediaQuery.of(context).size.height * 0.82;
        return SafeArea(
          child: SizedBox(
            height: maxHeight,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
              child: ListView(
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
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        const Divider(height: 1),
                      ]),
                  const SizedBox(height: 12),
                  Row(
                    children: [
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
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            Navigator.pop(context);
                            await AppRuntime.dataLayer.assets
                                .setActive(asset.id, !asset.isActive);
                            await _load();
                          },
                          child: Text(asset.isActive ? 'Pasif Yap' : 'Aktif Yap'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: buildAppMenuDrawer(),
      appBar: AppBar(
        leading: buildBackAction(
          context,
          onPressed: () => popToDashboard(context),
        ),
        title: const Text('Varlıklarım'),
        actions: [buildHomeAction(context)],
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          margin: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(
                                  'Varlık Adı',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  'Edinim',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  'Güncel',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  'Satış',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  'Kar/Zarar',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: RefreshIndicator(
                            onRefresh: _load,
                            child: ListView.builder(
                              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                              itemCount: _assets.length,
                              itemBuilder: (context, index) {
                                final asset = _assets[index];
                                final profit = asset.profitOrLoss;
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
                                    margin: const EdgeInsets.symmetric(vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.indigo.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: const Icon(Icons.info_outline),
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 12,
                                    ),
                                    margin: const EdgeInsets.symmetric(vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: asset.isActive
                                            ? Colors.green.withValues(alpha: 0.28)
                                            : Colors.black.withValues(alpha: 0.08),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                asset.displayName,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              Text(
                                                asset.isActive ? 'Aktif' : 'Pasif',
                                                style: TextStyle(
                                                  color: asset.isActive
                                                      ? Colors.green
                                                      : Colors.black54,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            _fmtAmount(asset.acquisitionValue),
                                            textAlign: TextAlign.right,
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            asset.currentValue == null
                                                ? '-'
                                                : _fmtAmount(asset.currentValue!),
                                            textAlign: TextAlign.right,
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            asset.saleValue == null
                                                ? '-'
                                                : _fmtAmount(asset.saleValue!),
                                            textAlign: TextAlign.right,
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            profit == null
                                                ? '-'
                                                : _fmtAmount(profit),
                                            textAlign: TextAlign.right,
                                            style: TextStyle(
                                              color: profit == null
                                                  ? Colors.black87
                                                  : (profit >= 0
                                                      ? Colors.green
                                                      : Colors.red),
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
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
