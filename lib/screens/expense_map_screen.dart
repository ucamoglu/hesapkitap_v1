import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/finance_transaction.dart';
import '../services/finance_transaction_service.dart';
import '../theme/app_colors.dart';
import '../utils/navigation_helpers.dart';

class ExpenseMapScreen extends StatefulWidget {
  const ExpenseMapScreen({super.key});

  @override
  State<ExpenseMapScreen> createState() => _ExpenseMapScreenState();
}

class _ExpenseMapScreenState extends State<ExpenseMapScreen> {
  bool _loading = true;
  String? _error;
  List<FinanceTransaction> _expensesWithLocation = [];
  FinanceTransaction? _selectedExpense;

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
      final all = await FinanceTransactionService.getAll();
      final items = all
          .where(
            (tx) =>
                tx.type == 'expense' &&
                tx.latitude != null &&
                tx.longitude != null,
          )
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));

      if (!mounted) return;
      setState(() {
        _expensesWithLocation = items;
        _selectedExpense = items.isNotEmpty ? items.first : null;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Harcama haritası verileri yüklenemedi: $e';
        _loading = false;
      });
    }
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

  String _fmtDate(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    return '$day.$month.${value.year}';
  }

  LatLng _initialCenter() {
    if (_selectedExpense?.latitude != null && _selectedExpense?.longitude != null) {
      return LatLng(
        _selectedExpense!.latitude!,
        _selectedExpense!.longitude!,
      );
    }
    if (_expensesWithLocation.isEmpty) {
      return const LatLng(39.0, 35.0);
    }
    final totalLat = _expensesWithLocation.fold<double>(
      0,
      (sum, tx) => sum + (tx.latitude ?? 0),
    );
    final totalLng = _expensesWithLocation.fold<double>(
      0,
      (sum, tx) => sum + (tx.longitude ?? 0),
    );
    return LatLng(
      totalLat / _expensesWithLocation.length,
      totalLng / _expensesWithLocation.length,
    );
  }

  Widget _statChip({
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black87),
          children: [
            TextSpan(
              text: '$label: ',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }

  Widget _selectedExpenseCard() {
    final tx = _selectedExpense;
    if (tx == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.black12),
        ),
        child: const Text(
          'Bir gider pimine dokunarak detayını görebilirsin.',
          style: TextStyle(color: Colors.black54),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.expenseSoft,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.expense.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Seçili Harcama',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          Text(
            tx.description?.trim().isNotEmpty == true
                ? tx.description!.trim()
                : 'Konumlu Gider',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text('${_fmtDate(tx.date)} • ${_fmtMoney(tx.amount)} TL'),
          const SizedBox(height: 4),
          Text(
            'Konum: ${tx.latitude!.toStringAsFixed(5)}, ${tx.longitude!.toStringAsFixed(5)}',
            style: const TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _mapSection() {
    if (_expensesWithLocation.isEmpty) {
      return Container(
        height: 320,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black12),
        ),
        child: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Henüz haritada gösterecek konumlu gider bulunmuyor.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            ),
          ),
        ),
      );
    }

    final center = _initialCenter();
    return Container(
      height: 360,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.black12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: FlutterMap(
        options: MapOptions(
          initialCenter: center,
          initialZoom: 12,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.pagumex.hesapkitap_v1',
          ),
          MarkerLayer(
            markers: [
              for (final tx in _expensesWithLocation)
                Marker(
                  point: LatLng(tx.latitude!, tx.longitude!),
                  width: 56,
                  height: 56,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedExpense = tx;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: _selectedExpense?.id == tx.id
                            ? AppColors.expense
                            : Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.expense,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.14),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.location_on,
                        color: _selectedExpense?.id == tx.id
                            ? Colors.white
                            : AppColors.expense,
                        size: 28,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    rememberDrawerSelectionForScreen(widget);

    return Scaffold(
      drawer: buildAppMenuDrawer(),
      appBar: AppBar(
        leading: buildMenuLeading(),
        title: const Text('Harcama Haritası'),
        actions: [buildHomeAction(context)],
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
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.planIncomeSoft,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: AppColors.planIncome.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Konumlu Harcama Haritası',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Kaydedilmiş konumlu giderlerini harita üzerinde pin olarak gör. Bir pine dokunduğunda seçili harcama detayı aşağıda görünür.',
                              style: TextStyle(color: Colors.black87),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _statChip(
                                  label: 'Konumlu Gider',
                                  value: '${_expensesWithLocation.length}',
                                  color: AppColors.expense,
                                ),
                                _statChip(
                                  label: 'Toplam Tutar',
                                  value:
                                      '${_fmtMoney(_expensesWithLocation.fold<double>(0, (sum, tx) => sum + tx.amount))} TL',
                                  color: AppColors.info,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _mapSection(),
                      const SizedBox(height: 16),
                      _selectedExpenseCard(),
                      const SizedBox(height: 16),
                      const Text(
                        'Son Konumlu Harcamalar',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (_expensesWithLocation.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Text(
                            'Henüz konumla kaydedilmiş gider bulunmuyor.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.black54),
                          ),
                        )
                      else
                        ..._expensesWithLocation.take(15).map(
                              (tx) => Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: _selectedExpense?.id == tx.id
                                      ? AppColors.expenseSoft
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: _selectedExpense?.id == tx.id
                                        ? AppColors.expense.withValues(alpha: 0.28)
                                        : Colors.black12,
                                  ),
                                ),
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      _selectedExpense = tx;
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(16),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: AppColors.expense
                                              .withValues(alpha: 0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.location_on_outlined,
                                          color: AppColors.expense,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              tx.description?.trim().isNotEmpty ==
                                                      true
                                                  ? tx.description!.trim()
                                                  : 'Konumlu Gider',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${_fmtDate(tx.date)} • ${tx.latitude!.toStringAsFixed(5)}, ${tx.longitude!.toStringAsFixed(5)}',
                                              style: const TextStyle(
                                                color: Colors.black54,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        '${_fmtMoney(tx.amount)} TL',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.expense,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
    );
  }
}
