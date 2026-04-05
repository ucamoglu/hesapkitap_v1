import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../models/account.dart';
import '../../models/asset_record.dart';
import '../../models/cari_card.dart';
import '../../models/cari_transaction.dart';
import '../../models/market_rate_item.dart';
import '../../models/subscription_definition.dart';
import '../../models/user_profile.dart';
import '../../services/account_service.dart';
import '../../services/asset_record_service.dart';
import '../../services/cari_card_service.dart';
import '../../services/cari_transaction_service.dart';
import '../../services/expense_plan_service.dart';
import '../../services/finance_transaction_service.dart';
import '../../services/income_plan_service.dart';
import '../../services/investment_transaction_service.dart';
import '../../services/market_rate_service.dart';
import '../../services/subscription_definition_service.dart';
import '../../services/tracked_crypto_service.dart';
import '../../services/tracked_currency_service.dart';
import '../../services/tracked_metal_service.dart';
import '../../services/tracked_stock_service.dart';
import '../../services/user_profile_service.dart';
import '../../theme/app_colors.dart';
import 'dashboard_view_data.dart';

class DashboardLoader {
  static Future<DashboardViewData> load() async {
    final now = DateTime.now();
    final dayStart = DateTime(now.year, now.month, now.day);
    final dayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
    final results = await Future.wait([
      AccountService.getAllAccounts(),
      CariCardService.getAll(),
      CariTransactionService.getAll(),
      InvestmentTransactionService.getAll(),
      UserProfileService.getProfile(),
      TrackedCurrencyService.getActive(),
      TrackedMetalService.getActive(),
      TrackedStockService.getActive(),
      TrackedCryptoService.getActive(),
      IncomePlanService.getDuePlans(now),
      ExpensePlanService.getDuePlans(now),
      IncomePlanService.getAll(),
      ExpensePlanService.getAll(),
      FinanceTransactionService.getByDateRange(start: dayStart, end: dayEnd),
      SubscriptionDefinitionService.getActive(),
      AssetRecordService.getActive(),
    ]);

    final accounts = results[0] as List<Account>;
    final cariCards = results[1] as List<CariCard>;
    final cariTx = results[2] as List<CariTransaction>;
    final investmentTx = results[3] as List<dynamic>;
    final profile = results[4] as UserProfile?;
    final trackedCurrencies = results[5] as List<dynamic>;
    final trackedMetals = results[6] as List<dynamic>;
    final trackedStocks = results[7] as List<dynamic>;
    final trackedCryptos = results[8] as List<dynamic>;
    final dueIncomePlans = results[9] as List<dynamic>;
    final dueExpensePlans = results[10] as List<dynamic>;
    final allIncomePlans = results[11] as List<dynamic>;
    final allExpensePlans = results[12] as List<dynamic>;
    final allFinanceTx = results[13] as List<dynamic>;
    final subscriptions = results[14] as List<SubscriptionDefinition>;
    final activeAssets = results[15] as List<AssetRecord>;

    final ratesByCode = await _loadRates(
      accounts: accounts,
      cariCards: cariCards,
      trackedStocks: trackedStocks,
      trackedCryptos: trackedCryptos,
    );

    final latestUnitPriceBySymbol = <String, double>{};
    for (final tx in investmentTx) {
      final symbol = tx.symbol.trim().toUpperCase();
      if (symbol.isEmpty) continue;
      latestUnitPriceBySymbol.putIfAbsent(symbol, () => tx.unitPrice);
    }

    double cash = 0;
    double bank = 0;
    double investmentCurrent = 0;
    double cariReceivable = 0;
    double cariDebt = 0;
    final cashRows = <AccountPreviewRow>[];
    final bankRows = <AccountPreviewRow>[];
    final investmentRows = <AccountPreviewRow>[];
    final assetRows = <AccountPreviewRow>[];
    final cariRows = <CariPreviewRow>[];
    bool missingInvestmentPrice = false;

    final visibleAccounts = accounts
        .where((account) => !AccountService.isGhostAccount(account))
        .toList();

    for (final a in visibleAccounts) {
      final type = a.type;
      if (type == 'cash') {
        cash += a.balance;
        cashRows.add(
          AccountPreviewRow(
            name: a.name,
            valueText: '${_fmtAmount(a.balance)} TL',
            color: Colors.blue,
          ),
        );
      } else if (type == 'bank') {
        bank += a.balance;
        bankRows.add(
          AccountPreviewRow(
            name: a.name,
            valueText: '${_fmtAmount(a.balance)} TL',
            color: Colors.indigo,
          ),
        );
      } else if (type == 'investment') {
        final symbol = (a.investmentSymbol ?? '').trim().toUpperCase();
        final price = ratesByCode[symbol];
        if (symbol.isNotEmpty && price != null) {
          final currentValue = a.balance * price;
          investmentCurrent += currentValue;
          investmentRows.add(
            AccountPreviewRow(
              name: a.name,
              valueText: '${_fmtAmount(currentValue)} TL',
              subtitle: '${_fmtAmount(a.balance)} $symbol',
              color: Colors.teal,
            ),
          );
        } else {
          missingInvestmentPrice = true;
          investmentRows.add(
            AccountPreviewRow(
              name: a.name,
              valueText: 'Kur yok',
              subtitle: symbol.isEmpty
                  ? '${_fmtAmount(a.balance)} birim'
                  : '${_fmtAmount(a.balance)} $symbol',
              color: Colors.teal,
            ),
          );
        }
      }
    }
    cashRows.sort((a, b) => a.name.compareTo(b.name));
    bankRows.sort((a, b) => a.name.compareTo(b.name));
    investmentRows.sort((a, b) => a.name.compareTo(b.name));
    var activeAssetTotal = 0.0;
    for (final asset in activeAssets) {
      final value = asset.effectiveDashboardValue;
      if (asset.assetType != 'fixture') {
        activeAssetTotal += value;
      }
      assetRows.add(
        AccountPreviewRow(
          name: asset.displayName,
          summaryName: _assetSummaryName(asset),
          valueText: '${_fmtAmount(value)} TL',
          subtitle: asset.currentValue != null ? 'Güncel değer' : 'Edinim değeri',
          groupLabel: asset.assetType == 'fixture' ? 'Demirbaşlar' : 'Varlıklar',
          color: Colors.brown,
        ),
      );
    }
    assetRows.sort((a, b) => a.name.compareTo(b.name));

    for (final tx in cariTx) {
      if (tx.type == 'collection') {
        cariReceivable += tx.amount;
      } else if (tx.type == 'debt') {
        cariDebt += tx.amount;
      }
    }

    final cariNetByCard = <int, double>{};
    for (final tx in cariTx) {
      final prev = cariNetByCard[tx.cariCardId] ?? 0;
      final next = tx.type == 'debt' ? (prev + tx.amount) : (prev - tx.amount);
      cariNetByCard[tx.cariCardId] = next;
    }

    final foreignCardsById = <int, CariCard>{
      for (final c in cariCards)
        if ((c.currencyType).trim().toLowerCase() == 'foreign') c.id: c,
    };
    final foreignNetQtyByCard = <int, double>{};
    for (final tx in cariTx) {
      final foreignCard = foreignCardsById[tx.cariCardId];
      if (foreignCard == null) continue;
      final qty = _cariTxQuantity(tx);
      if (qty == null || qty <= 0) continue;
      final prev = foreignNetQtyByCard[tx.cariCardId] ?? 0;
      final next = tx.type == 'debt' ? (prev + qty) : (prev - qty);
      foreignNetQtyByCard[tx.cariCardId] = next;
    }
    for (final entry in foreignNetQtyByCard.entries) {
      final card = foreignCardsById[entry.key];
      if (card == null) continue;
      final code = (card.foreignCode ?? '').trim().toUpperCase();
      if (code.isEmpty) continue;
      final unitPrice = ratesByCode[code];
      if (unitPrice == null || unitPrice <= 0) continue;
      cariNetByCard[entry.key] = entry.value * unitPrice;
    }

    final cardNameById = <int, String>{};
    final cardCurrencyById = <int, String>{};
    for (final c in cariCards) {
      final full = (c.fullName ?? '').trim();
      final title = (c.title ?? '').trim();
      cardNameById[c.id] =
          full.isNotEmpty ? full : (title.isNotEmpty ? title : 'Cari #${c.id}');
      cardCurrencyById[c.id] = _cariCurrencyLabel(c);
    }
    for (final e in cariNetByCard.entries) {
      cariRows.add(
        CariPreviewRow(
          ownerName: cardNameById[e.key] ?? 'Cari #${e.key}',
          currencyLabel: cardCurrencyById[e.key] ?? 'TL',
          net: e.value,
        ),
      );
    }
    final cariNetPreviewTotal =
        cariRows.fold<double>(0, (sum, row) => sum + row.net);
    cariRows.sort((a, b) {
      if (a.currencyLabel == b.currencyLabel) {
        return a.ownerName.compareTo(b.ownerName);
      }
      if (a.currencyLabel == 'TL') return -1;
      if (b.currencyLabel == 'TL') return 1;
      return a.currencyLabel.compareTo(b.currencyLabel);
    });

    final trackedRows = <TrackedQuoteRow>[];
    for (final c in trackedCurrencies) {
      if (!c.isActive) continue;
      final code = c.code.trim().toUpperCase();
      if (code.isEmpty) continue;
      trackedRows.add(
        TrackedQuoteRow(
          market: 'Döviz',
          code: code,
          name: c.name,
          sell: ratesByCode[code],
        ),
      );
    }
    for (final m in trackedMetals) {
      if (!m.isActive) continue;
      final code = m.code.trim().toUpperCase();
      if (code.isEmpty) continue;
      trackedRows.add(
        TrackedQuoteRow(
          market: 'Kıymetli Maden',
          code: code,
          name: m.name,
          sell: ratesByCode[code],
        ),
      );
    }

    final stockSymbols = <String>{};
    final cryptoSymbols = <String>{};
    for (final a in accounts) {
      if (a.type != 'investment' || !a.isActive) continue;
      final symbol = (a.investmentSymbol ?? '').trim().toUpperCase();
      final subtype = (a.investmentSubtype ?? '').trim().toLowerCase();
      if (symbol.isEmpty) continue;
      if (subtype == 'stock') {
        stockSymbols.add(symbol);
      } else if (subtype == 'crypto') {
        cryptoSymbols.add(symbol);
      }
    }
    for (final s in trackedStocks.where((e) => e.isActive)) {
      final code = s.code.toUpperCase();
      if (code.isNotEmpty) stockSymbols.add(code);
    }
    for (final c in trackedCryptos.where((e) => e.isActive)) {
      final code = c.code.toUpperCase();
      if (code.isNotEmpty) cryptoSymbols.add(code);
    }
    final trackedStockNameByCode = <String, String>{
      for (final s in trackedStocks.where((e) => e.isActive))
        s.code.toUpperCase(): s.name,
    };
    final trackedCryptoNameByCode = <String, String>{
      for (final c in trackedCryptos.where((e) => e.isActive))
        c.code.toUpperCase(): c.name,
    };
    for (final code in stockSymbols) {
      trackedRows.add(
        TrackedQuoteRow(
          market: 'Borsa',
          code: code,
          name: trackedStockNameByCode[code] ?? code,
          sell: ratesByCode[code] ?? latestUnitPriceBySymbol[code],
        ),
      );
    }
    for (final code in cryptoSymbols) {
      trackedRows.add(
        TrackedQuoteRow(
          market: 'Kripto',
          code: code,
          name: trackedCryptoNameByCode[code] ?? code,
          sell: ratesByCode[code] ?? latestUnitPriceBySymbol[code],
        ),
      );
    }
    trackedRows.sort((a, b) {
      final byMarket = a.market.compareTo(b.market);
      return byMarket != 0 ? byMarket : a.code.compareTo(b.code);
    });

    final completedIncomePlansToday = <int, DateTime>{};
    final completedExpensePlansToday = <int, DateTime>{};
    final completedIncomeAmountsToday = <int, double>{};
    final completedExpenseAmountsToday = <int, double>{};
    for (final tx in allFinanceTx) {
      final inToday = !tx.date.isBefore(dayStart) && !tx.date.isAfter(dayEnd);
      if (!inToday) continue;
      if (tx.incomePlanId != null) {
        completedIncomePlansToday[tx.incomePlanId!] = tx.date;
        completedIncomeAmountsToday[tx.incomePlanId!] = tx.amount;
      }
      if (tx.expensePlanId != null) {
        completedExpensePlansToday[tx.expensePlanId!] = tx.date;
        completedExpenseAmountsToday[tx.expensePlanId!] = tx.amount;
      }
    }

    final duePlanRows = <TodayPlanRow>[];
    double dueIncomeTotal = 0;
    double dueExpenseTotal = 0;

    for (final p in dueIncomePlans) {
      final desc = (p.description ?? '').trim();
      dueIncomeTotal += p.amount;
      duePlanRows.add(
        TodayPlanRow(
          typeLabel: 'Gelir',
          amount: p.amount,
          dueDate: p.nextDueDate,
          description: desc.isEmpty ? 'Planlı gelir' : desc,
          color: AppColors.income,
          statusLabel: 'Beklemede',
          statusColor: Colors.orange,
        ),
      );
    }
    for (final p in dueExpensePlans) {
      final desc = (p.description ?? '').trim();
      dueExpenseTotal += p.amount;
      duePlanRows.add(
        TodayPlanRow(
          typeLabel: 'Gider',
          amount: p.amount,
          dueDate: p.nextDueDate,
          description: desc.isEmpty ? 'Planlı gider' : desc,
          color: AppColors.expense,
          statusLabel: 'Beklemede',
          statusColor: Colors.orange,
        ),
      );
    }
    for (final p in allIncomePlans) {
      final completedAt = completedIncomePlansToday[p.id];
      if (completedAt != null) {
        final desc = (p.description ?? '').trim();
        final amount = completedIncomeAmountsToday[p.id] ?? p.amount;
        dueIncomeTotal += amount;
        duePlanRows.add(
          TodayPlanRow(
            typeLabel: 'Gelir',
            amount: amount,
            dueDate: completedAt,
            description: desc.isEmpty ? 'Planlı gelir' : desc,
            color: AppColors.income,
            statusLabel: 'Gerçekleşti',
            statusColor: Colors.green,
          ),
        );
        continue;
      }
      if (!p.isActive && _isSameDay(p.nextDueDate, dayStart)) {
        final desc = (p.description ?? '').trim();
        duePlanRows.add(
          TodayPlanRow(
            typeLabel: 'Gelir',
            amount: p.amount,
            dueDate: p.nextDueDate,
            description: desc.isEmpty ? 'Planlı gelir' : desc,
            color: AppColors.income,
            statusLabel: 'İptal Edildi',
            statusColor: Colors.red,
          ),
        );
        continue;
      }
      if (p.isActive &&
          p.nextDueDate.isAfter(dayEnd) &&
          _isLikelyPostponedToday(
            nextDue: p.nextDueDate,
            periodType: p.periodType,
            frequency: p.frequency,
            today: dayStart,
          )) {
        final desc = (p.description ?? '').trim();
        dueIncomeTotal += p.amount;
        duePlanRows.add(
          TodayPlanRow(
            typeLabel: 'Gelir',
            amount: p.amount,
            dueDate: p.nextDueDate,
            description: desc.isEmpty ? 'Planlı gelir' : desc,
            color: AppColors.income,
            statusLabel: 'Ertelendi',
            statusColor: Colors.deepOrange,
          ),
        );
      }
    }
    for (final p in allExpensePlans) {
      final completedAt = completedExpensePlansToday[p.id];
      if (completedAt != null) {
        final desc = (p.description ?? '').trim();
        final amount = completedExpenseAmountsToday[p.id] ?? p.amount;
        dueExpenseTotal += amount;
        duePlanRows.add(
          TodayPlanRow(
            typeLabel: 'Gider',
            amount: amount,
            dueDate: completedAt,
            description: desc.isEmpty ? 'Planlı gider' : desc,
            color: AppColors.expense,
            statusLabel: 'Gerçekleşti',
            statusColor: Colors.green,
          ),
        );
        continue;
      }
      if (!p.isActive && _isSameDay(p.nextDueDate, dayStart)) {
        final desc = (p.description ?? '').trim();
        duePlanRows.add(
          TodayPlanRow(
            typeLabel: 'Gider',
            amount: p.amount,
            dueDate: p.nextDueDate,
            description: desc.isEmpty ? 'Planlı gider' : desc,
            color: AppColors.expense,
            statusLabel: 'İptal Edildi',
            statusColor: Colors.red,
          ),
        );
        continue;
      }
      if (p.isActive &&
          p.nextDueDate.isAfter(dayEnd) &&
          _isLikelyPostponedToday(
            nextDue: p.nextDueDate,
            periodType: p.periodType,
            frequency: p.frequency,
            today: dayStart,
          )) {
        final desc = (p.description ?? '').trim();
        dueExpenseTotal += p.amount;
        duePlanRows.add(
          TodayPlanRow(
            typeLabel: 'Gider',
            amount: p.amount,
            dueDate: p.nextDueDate,
            description: desc.isEmpty ? 'Planlı gider' : desc,
            color: AppColors.expense,
            statusLabel: 'Ertelendi',
            statusColor: Colors.deepOrange,
          ),
        );
      }
    }

    final uniquePlanKeys = <String>{};
    duePlanRows.removeWhere((r) {
      final key =
          '${r.typeLabel}|${r.description}|${r.statusLabel}|${r.amount}|${r.dueDate.toIso8601String()}';
      if (uniquePlanKeys.contains(key)) return true;
      uniquePlanKeys.add(key);
      return false;
    });
    duePlanRows.sort((a, b) => a.dueDate.compareTo(b.dueDate));

    final subscriptionRows = subscriptions
        .map((item) => _buildSubscriptionReminderRow(item, dayStart))
        .where((item) => _isSameDay(item.reminderDate, dayStart))
        .toList()
      ..sort((a, b) => a.title.compareTo(b.title));

    final displayName = profile == null
        ? 'Kullanıcı Profili'
        : '${profile.firstName} ${profile.lastName}'.trim();
    final photoBytes = profile?.photoBytes;

    return DashboardViewData(
      cashBankAccounts: visibleAccounts
          .where((a) => a.type == 'cash' || a.type == 'bank')
          .length,
      investmentAccounts:
          visibleAccounts.where((a) => a.type == 'investment').length,
      totalAccounts: visibleAccounts.length,
      totalBalance: cash + bank + investmentCurrent,
      cashTotal: cash,
      bankTotal: bank,
      investmentCurrentTotal: investmentCurrent,
      activeAssetTotal: activeAssetTotal,
      hasMissingInvestmentPrice: missingInvestmentPrice,
      cariReceivableTotal: cariReceivable,
      cariDebtTotal: cariDebt,
      cariNetTotal: cariNetPreviewTotal,
      trackedQuotes: trackedRows,
      plannedIncomeTotal: dueIncomeTotal,
      plannedExpenseTotal: dueExpenseTotal,
      todayPlans: duePlanRows,
      cashPreviewRows: cashRows,
      bankPreviewRows: bankRows,
      investmentPreviewRows: investmentRows,
      assetPreviewRows: assetRows,
      activeSubscriptionCount: subscriptions.length,
      dueSubscriptionCount: subscriptionRows.length,
      subscriptionPreviewRows: subscriptionRows,
      cariPreviewRows: cariRows,
      profileName: displayName,
      profilePhoto: photoBytes == null ? null : Uint8List.fromList(photoBytes),
    );
  }
}

Future<Map<String, double>> _loadRates({
  required List<Account> accounts,
  required List<CariCard> cariCards,
  required List<dynamic> trackedStocks,
  required List<dynamic> trackedCryptos,
}) async {
  final ratesByCode = <String, double>{};
  try {
    final rateResults = await Future.wait([
      MarketRateService.fetchAllCurrencies(),
      MarketRateService.fetchAllMetals(),
    ]);
    final currencyRates = (rateResults[0] as CurrencyRateListResult).items;
    final metalRates = (rateResults[1] as MetalRateListResult).items;
    final allRates = <MarketRateItem>[...currencyRates, ...metalRates];
    for (final rate in allRates) {
      final fallbackPrice = rate.sell > 0 ? rate.sell : rate.buy;
      ratesByCode[rate.code.toUpperCase()] = fallbackPrice;
    }
  } catch (_) {}

  final stockSymbolsForRates = <String>{};
  final cryptoSymbolsForRates = <String>{};
  for (final c in cariCards) {
    if ((c.currencyType).trim().toLowerCase() != 'foreign') continue;
    final code = (c.foreignCode ?? '').trim().toUpperCase();
    if (code.isEmpty) continue;
    final marketType = (c.foreignMarketType ?? '').trim().toLowerCase();
    if (marketType == 'stock') {
      stockSymbolsForRates.add(code);
    } else if (marketType == 'crypto') {
      cryptoSymbolsForRates.add(code);
    }
  }
  for (final a in accounts) {
    if (a.type != 'investment' || !a.isActive) continue;
    final subtype = (a.investmentSubtype ?? '').trim().toLowerCase();
    final symbol = (a.investmentSymbol ?? '').trim().toUpperCase();
    if (symbol.isEmpty) continue;
    if (subtype == 'stock') {
      stockSymbolsForRates.add(symbol);
    } else if (subtype == 'crypto') {
      cryptoSymbolsForRates.add(symbol);
    }
  }
  for (final s in trackedStocks.where((e) => e.isActive)) {
    final code = s.code.trim().toUpperCase();
    if (code.isNotEmpty) stockSymbolsForRates.add(code);
  }
  if (stockSymbolsForRates.isNotEmpty) {
    try {
      final stockRates = await MarketRateService.fetchStocksByCodes(
        stockSymbolsForRates.toList(),
      );
      for (final r in stockRates) {
        final fallbackPrice = r.sell > 0 ? r.sell : r.buy;
        if (fallbackPrice > 0) {
          ratesByCode[r.code.toUpperCase()] = fallbackPrice;
        }
      }
    } catch (_) {}
  }
  for (final c in trackedCryptos.where((e) => e.isActive)) {
    final code = c.code.trim().toUpperCase();
    if (code.isNotEmpty) cryptoSymbolsForRates.add(code);
  }
  if (cryptoSymbolsForRates.isNotEmpty) {
    try {
      final cryptoRates = await MarketRateService.fetchCryptosByCodes(
        cryptoSymbolsForRates.toList(),
      );
      for (final r in cryptoRates) {
        final fallbackPrice = r.sell > 0 ? r.sell : r.buy;
        if (fallbackPrice > 0) {
          ratesByCode[r.code.toUpperCase()] = fallbackPrice;
        }
      }
    } catch (_) {}
  }
  return ratesByCode;
}

String _assetSummaryName(AssetRecord asset) {
  final explicitName = asset.name.trim();
  if (explicitName.isNotEmpty) return explicitName;
  if (asset.assetType == 'vehicle') return asset.assetTypeLabel;
  return asset.displayName;
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

double? _cariTxQuantity(CariTransaction tx) {
  final q = tx.quantity;
  if (q != null && q > 0) return q;
  final unitPrice = tx.unitPrice;
  if (unitPrice != null && unitPrice > 0) {
    final fallback = tx.amount / unitPrice;
    if (fallback > 0) return fallback;
  }
  return null;
}

String _cariCurrencyLabel(CariCard c) {
  if (c.currencyType != 'foreign') return 'TL';
  final explicitName = (c.foreignName ?? '').trim();
  if (explicitName.isNotEmpty) return explicitName;

  final code = (c.foreignCode ?? '').trim().toUpperCase();
  if (code.isEmpty) return 'Yabanci Para';
  switch (code) {
    case 'USD':
      return 'Dolar';
    case 'EUR':
      return 'Euro';
    case 'GBP':
      return 'Sterlin';
    case 'GA':
      return 'Gram Altin';
    default:
      return code;
  }
}

SubscriptionReminderRow _buildSubscriptionReminderRow(
  SubscriptionDefinition item,
  DateTime today,
) {
  final reminderDate = _subscriptionReminderDate(item, today);
  final provider = item.providerName.trim();
  final title = provider.isEmpty ? item.name : '${item.name} - $provider';
  final caption = item.dueDay == null
      ? 'Son odeme tarihi yok, ay sonunda sorulacak'
      : item.duePeriod == 'yearly'
          ? 'Yillik sabit son odeme tarihi'
          : 'Aylik sabit son odeme tarihi';
  final dateLabel = item.dueDay == null
      ? 'Ay Sonu'
      : item.duePeriod == 'yearly'
          ? '${reminderDate.day}.${reminderDate.month}'
          : '${reminderDate.day}. gun';

  return SubscriptionReminderRow(
    title: title,
    caption: caption,
    dateLabel: dateLabel,
    reminderDate: reminderDate,
    isDue: !reminderDate.isAfter(today),
  );
}

DateTime _subscriptionReminderDate(
  SubscriptionDefinition item,
  DateTime today,
) {
  if (item.dueDay == null) {
    final lastDay = DateUtils.getDaysInMonth(today.year, today.month);
    return DateTime(today.year, today.month, lastDay);
  }
  if (item.duePeriod == 'yearly' && item.dueMonth != null) {
    final currentYearDate = DateTime(
      today.year,
      item.dueMonth!,
      item.dueDay!.clamp(1, DateUtils.getDaysInMonth(today.year, item.dueMonth!)),
    );
    if (currentYearDate.month < today.month) {
      return DateTime(
        today.year + 1,
        item.dueMonth!,
        item.dueDay!.clamp(
          1,
          DateUtils.getDaysInMonth(today.year + 1, item.dueMonth!),
        ),
      );
    }
    return currentYearDate;
  }
  final lastDayOfMonth = DateUtils.getDaysInMonth(today.year, today.month);
  final day = item.dueDay!.clamp(1, lastDayOfMonth);
  return DateTime(today.year, today.month, day);
}

bool _isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

bool _isLikelyPostponedToday({
  required DateTime nextDue,
  required String periodType,
  required int frequency,
  required DateTime today,
}) {
  final prev = _previousByPlan(nextDue, periodType, frequency);
  return _isSameDay(prev, today);
}

DateTime _previousByPlan(DateTime from, String periodType, int frequency) {
  final f = frequency < 1 ? 1 : frequency;
  if (periodType == 'daily') {
    return DateTime(from.year, from.month, from.day - f);
  }
  if (periodType == 'weekly') {
    return DateTime(from.year, from.month, from.day - (7 * f));
  }
  if (periodType == 'yearly') {
    return DateTime(from.year - f, from.month, from.day);
  }
  return DateTime(from.year, from.month - f, from.day);
}
