import 'package:flutter/material.dart';

import '../models/account.dart';
import '../models/investment_transaction.dart';
import '../models/market_rate_item.dart';
import '../services/account_service.dart';
import '../services/investment_transaction_service.dart';
import '../services/market_rate_service.dart';
import '../utils/navigation_helpers.dart';

class AssetStatusScreen extends StatefulWidget {
  const AssetStatusScreen({super.key});

  @override
  State<AssetStatusScreen> createState() => _AssetStatusScreenState();
}

class _AssetStatusScreenState extends State<AssetStatusScreen> {
  bool _loading = true;
  String? _error;
  Map<String, List<Account>> _grouped = {};
  final Map<int, _InvestmentTotals> _investmentTotalsByAccountId = {};
  final Map<String, _InvestmentTotals> _investmentTotalsBySymbol = {};
  final Map<int, double> _realizedPnlByAccountId = {};
  final Map<String, double> _realizedPnlBySymbol = {};
  final Map<String, double> _livePriceBySymbol = {};

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
        InvestmentTransactionService.getAll(),
      ]);
      final accounts = results[0] as List<Account>;
      final investmentTx = results[1] as List<InvestmentTransaction>;
      final livePriceBySymbol = <String, double>{};
      try {
        final rateResults = await Future.wait([
          MarketRateService.fetchAllCurrencies(),
          MarketRateService.fetchAllMetals(),
        ]);
        final currencyRates = (rateResults[0] as CurrencyRateListResult).items;
        final metalRates = (rateResults[1] as MetalRateListResult).items;
        final allRates = <MarketRateItem>[...currencyRates, ...metalRates];
        for (final item in allRates) {
          livePriceBySymbol[item.code.toUpperCase()] = item.sell;
        }
      } catch (_) {
        // Keep summary visible when live market data is unavailable.
      }
      final grouped = <String, List<Account>>{};
      for (final a in accounts) {
        grouped.putIfAbsent(a.type, () => []).add(a);
      }
      for (final list in grouped.values) {
        list.sort((a, b) => a.name.compareTo(b.name));
      }
      final totalsByAccount = <int, _InvestmentTotals>{};
      final totalsBySymbol = <String, _InvestmentTotals>{};
      final realizedByAccount = <int, double>{};
      final realizedBySymbol = <String, double>{};
      for (final tx in investmentTx) {
        final type = tx.type.trim().toLowerCase();
        final isBuy = type == 'buy' || type == 'alış' || type == 'alis';
        final isSell = type == 'sell' || type == 'satış' || type == 'satis';
        final amount = tx.total > 0 ? tx.total : (tx.quantity * tx.unitPrice);

        final byAccount = totalsByAccount.putIfAbsent(
          tx.investmentAccountId,
          () => const _InvestmentTotals(),
        );
        final symbolKey = tx.symbol.trim().toUpperCase();
        final bySymbol = totalsBySymbol.putIfAbsent(
          symbolKey,
          () => const _InvestmentTotals(),
        );

        if (isBuy) {
          totalsByAccount[tx.investmentAccountId] =
              byAccount.copyWith(buy: byAccount.buy + amount);
          totalsBySymbol[symbolKey] = bySymbol.copyWith(buy: bySymbol.buy + amount);
        } else if (isSell) {
          totalsByAccount[tx.investmentAccountId] =
              byAccount.copyWith(sell: byAccount.sell + amount);
          totalsBySymbol[symbolKey] =
              bySymbol.copyWith(sell: bySymbol.sell + amount);

          final realized = tx.realizedPnl;
          realizedByAccount[tx.investmentAccountId] =
              (realizedByAccount[tx.investmentAccountId] ?? 0) + realized;
          realizedBySymbol[symbolKey] =
              (realizedBySymbol[symbolKey] ?? 0) + realized;
        }
      }

      if (!mounted) return;
      setState(() {
        _grouped = grouped;
        _investmentTotalsByAccountId
          ..clear()
          ..addAll(totalsByAccount);
        _investmentTotalsBySymbol
          ..clear()
          ..addAll(totalsBySymbol);
        _realizedPnlByAccountId
          ..clear()
          ..addAll(realizedByAccount);
        _realizedPnlBySymbol
          ..clear()
          ..addAll(realizedBySymbol);
        _livePriceBySymbol
          ..clear()
          ..addAll(livePriceBySymbol);
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Finans özet verileri yüklenemedi: $e';
        _loading = false;
      });
    }
  }

  String _typeLabel(String type) {
    switch (type) {
      case 'cash':
        return 'Kasa';
      case 'bank':
        return 'Banka';
      case 'investment':
        return 'Yatırım';
      default:
        return type;
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

  _InvestmentTotals _totalsForInvestmentAccount(Account account) {
    final direct = _investmentTotalsByAccountId[account.id];
    if (direct != null) return direct;

    // Legacy fallback: eski kayıtlar farklı hesap id ile taşınmış olabilir.
    final symbol = (account.investmentSymbol ?? '').trim().toUpperCase();
    if (symbol.isEmpty) return const _InvestmentTotals();
    return _investmentTotalsBySymbol[symbol] ?? const _InvestmentTotals();
  }

  double _realizedPnlForInvestmentAccount(Account account) {
    final direct = _realizedPnlByAccountId[account.id];
    if (direct != null) return direct;
    final symbol = (account.investmentSymbol ?? '').trim().toUpperCase();
    if (symbol.isEmpty) return 0;
    return _realizedPnlBySymbol[symbol] ?? 0;
  }

  String _acquisitionValueText(Account account) {
    if (account.type == 'investment') {
      final totals = _totalsForInvestmentAccount(account);
      final net = totals.net;
      return '${_fmtMoney(net)} TL';
    }
    return '${_fmtMoney(account.balance)} TL';
  }

  double? _currentUnitPrice(Account account) {
    final symbol = (account.investmentSymbol ?? '').trim().toUpperCase();
    if (symbol.isEmpty) return null;
    return _livePriceBySymbol[symbol];
  }

  double? _currentInvestmentValue(Account account) {
    if (account.type != 'investment') return null;
    final unitPrice = _currentUnitPrice(account);
    if (unitPrice == null) return null;
    return account.balance * unitPrice;
  }

  String _trailingValueText(Account account) {
    if (account.type != 'investment') {
      return _acquisitionValueText(account);
    }
    final currentValue = _currentInvestmentValue(account);
    if (currentValue == null) return _acquisitionValueText(account);
    return '${_fmtMoney(currentValue)} TL';
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'cash':
        return Icons.account_balance_wallet;
      case 'bank':
        return Icons.account_balance;
      case 'investment':
        return Icons.trending_up;
      default:
        return Icons.folder;
    }
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'cash':
        return Colors.blueGrey;
      case 'bank':
        return Colors.blue;
      case 'investment':
        return Colors.teal;
      default:
        return Colors.black54;
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderedTypes = ['cash', 'bank', 'investment'];
    final extraTypes = _grouped.keys
        .where((k) => !orderedTypes.contains(k))
        .toList()
      ..sort();
    final allTypes = [...orderedTypes, ...extraTypes]
        .where((k) => (_grouped[k] ?? const []).isNotEmpty)
        .toList();

    return Scaffold(
      drawer: buildAppMenuDrawer(),
      appBar: AppBar(
        leading: buildMenuLeading(),
        title: const Text('Finans Özet'),
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
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(_error!, textAlign: TextAlign.center),
                  ),
                )
              : allTypes.isEmpty
                  ? const Center(child: Text('Hesap bulunamadı.'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: allTypes.length,
                      itemBuilder: (_, index) {
                        final type = allTypes[index];
                        final items = _grouped[type] ?? const <Account>[];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(_typeIcon(type), color: _typeColor(type)),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${_typeLabel(type)} (${items.length})',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                const Divider(height: 1),
                                ...items.map(
                                  (a) {
                                    final totals = a.type == 'investment'
                                        ? _totalsForInvestmentAccount(a)
                                        : null;
                                    final realized = a.type == 'investment'
                                        ? _realizedPnlForInvestmentAccount(a)
                                        : 0.0;
                                    final currentValue = a.type == 'investment'
                                        ? _currentInvestmentValue(a)
                                        : null;
                                    final subtitle = a.type == 'investment'
                                        ? 'Miktar: ${_fmtQuantity(a.balance)} ${(a.investmentSymbol ?? '-').toUpperCase()}'
                                          '\nGüncel Değer: ${currentValue == null ? 'Veri yok' : '${_fmtMoney(currentValue)} TL'}'
                                          '\nEdinim Değeri (Bakiye)\nAlış: ${_fmtMoney(totals!.buy)} TL • Satış: ${_fmtMoney(totals.sell)} TL'
                                          '\nGerç. K/Z: ${_fmtMoney(realized.abs())} TL ${realized >= 0 ? '(Kar)' : '(Zarar)'}'
                                        : 'Edinim Değeri (Bakiye)';
                                    return ListTile(
                                      dense: true,
                                      contentPadding: EdgeInsets.zero,
                                      title: Text(
                                        a.name,
                                        style: TextStyle(
                                          decoration: a.isActive
                                              ? null
                                              : TextDecoration.lineThrough,
                                        ),
                                      ),
                                      subtitle: Text(subtitle),
                                      isThreeLine: a.type == 'investment',
                                      trailing: Text(
                                        _trailingValueText(a),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}

class _InvestmentTotals {
  final double buy;
  final double sell;

  const _InvestmentTotals({
    this.buy = 0,
    this.sell = 0,
  });

  double get net => buy - sell;

  _InvestmentTotals copyWith({
    double? buy,
    double? sell,
  }) {
    return _InvestmentTotals(
      buy: buy ?? this.buy,
      sell: sell ?? this.sell,
    );
  }
}
