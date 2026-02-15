import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'database/isar_service.dart';
import 'screens/accounts_screen.dart';
import 'screens/cari_account_screen.dart';
import 'screens/cari_cards_screen.dart';
import 'screens/cari_card_summary_screen.dart';
import 'screens/cari_card_summary_foreign_screen.dart';
import 'screens/expense_category_screen.dart';
import 'screens/expense_planning_screen.dart';
import 'screens/calendar_transactions_screen.dart';
import 'models/cari_card.dart';
import 'models/cari_transaction.dart';
import 'models/market_rate_item.dart';
import 'services/account_service.dart';
import 'services/cari_card_service.dart';
import 'services/cari_transaction_service.dart';
import 'services/investment_transaction_service.dart';
import 'services/market_rate_service.dart';
import 'services/tracked_currency_service.dart';
import 'services/tracked_metal_service.dart';
import 'services/tracked_stock_service.dart';
import 'services/tracked_crypto_service.dart';
import 'services/income_plan_service.dart';
import 'services/expense_plan_service.dart';
import 'services/finance_transaction_service.dart';
import 'screens/expense_entry_screen.dart';
import 'screens/income_category_screen.dart';
import 'screens/income_entry_screen.dart';
import 'screens/income_expense_transactions_screen.dart';
import 'screens/cari_transactions_screen.dart';
import 'screens/account_movements_screen.dart';
import 'screens/asset_status_screen.dart';
import 'screens/investment_tracking_screen.dart';
import 'screens/income_planning_screen.dart';
import 'screens/currency_tracking_screen.dart';
import 'screens/precious_metal_tracking_screen.dart';
import 'screens/stock_tracking_screen.dart';
import 'screens/crypto_tracking_screen.dart';
import 'screens/onboarding_welcome_screen.dart';
import 'services/local_notification_service.dart';
import 'services/user_profile_service.dart';
import 'theme/app_colors.dart';
import 'theme/app_theme.dart';
import 'screens/profile_screen.dart';
import 'screens/transfer_entry_screen.dart';
import 'screens/investment_entry_screen.dart';
import 'utils/navigation_helpers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('tr_TR');
  await IsarService.init();
  runApp(const MyApp());

  // Do not block first frame with notification setup.
  unawaited(
    LocalNotificationService.init().then((_) async {
      await LocalNotificationService.syncIncomePlanNotifications();
      await LocalNotificationService.syncExpensePlanNotifications();
    }),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HesapKitap',
      locale: const Locale('tr', 'TR'),
      supportedLocales: const [
        Locale('tr', 'TR'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: AppTheme.light,
      builder: (context, child) {
        final media = MediaQuery.of(context);
        final clampedScaler = media.textScaler.clamp(
          minScaleFactor: 0.95,
          maxScaleFactor: 1.0,
        );
        return MediaQuery(
          data: media.copyWith(textScaler: clampedScaler),
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const AppStartGate(),
    );
  }
}

class AppStartGate extends StatefulWidget {
  const AppStartGate({super.key});

  @override
  State<AppStartGate> createState() => _AppStartGateState();
}

class _AppStartGateState extends State<AppStartGate> {
  bool _loading = true;
  bool _needsOnboarding = false;

  @override
  void initState() {
    super.initState();
    _checkProfile();
  }

  Future<void> _checkProfile() async {
    final profile = await UserProfileService.getProfile();
    if (!mounted) return;

    setState(() {
      _needsOnboarding = profile == null ||
          profile.firstName.trim().isEmpty ||
          profile.lastName.trim().isEmpty;
      _loading = false;
    });
  }

  Future<void> _completeOnboarding() async {
    setState(() {
      _needsOnboarding = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_needsOnboarding) {
      return OnboardingWelcomeScreen(
        onCompleted: _completeOnboarding,
      );
    }

    return const DashboardScreen();
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int totalAccounts = 0;
  int cashBankAccounts = 0;
  int investmentAccounts = 0;
  double totalBalance = 0;
  double cashTotal = 0;
  double bankTotal = 0;
  double investmentCurrentTotal = 0;
  bool hasMissingInvestmentPrice = false;
  double cariReceivableTotal = 0;
  double cariDebtTotal = 0;
  double cariNetTotal = 0;
  List<_TrackedQuoteRow> trackedQuotes = [];
  double plannedIncomeTotal = 0;
  double plannedExpenseTotal = 0;
  List<_TodayPlanRow> todayPlans = [];
  List<_AccountPreviewRow> cashPreviewRows = [];
  List<_AccountPreviewRow> bankPreviewRows = [];
  List<_AccountPreviewRow> investmentPreviewRows = [];
  String? selectedAccountTypePreview;
  List<_CariPreviewRow> cariPreviewRows = [];
  bool showCariPreview = false;
  bool showTrackedPreview = false;
  final Set<String> expandedTrackedMarkets = <String>{};
  String profileName = 'Kullanıcı Profili';
  Uint8List? profilePhoto;

  @override
  void initState() {
    super.initState();
    loadDashboard();
  }

  @override
  void reassemble() {
    super.reassemble();
    unawaited(loadDashboard());
  }

  Future<void> loadDashboard() async {
    final accounts = await AccountService.getAllAccounts();
    final cariCards = await CariCardService.getAll();
    final cariTx = await CariTransactionService.getAll();
    final investmentTx = await InvestmentTransactionService.getAll();
    final profile = await UserProfileService.getProfile();
    final trackedCurrencies = await TrackedCurrencyService.getAll();
    final trackedMetals = await TrackedMetalService.getAll();
    final trackedStocks = await TrackedStockService.getAll();
    final trackedCryptos = await TrackedCryptoService.getAll();
    final dueIncomePlans = await IncomePlanService.getDuePlans(DateTime.now());
    final dueExpensePlans = await ExpensePlanService.getDuePlans(DateTime.now());
    final allIncomePlans = await IncomePlanService.getAll();
    final allExpensePlans = await ExpensePlanService.getAll();
    final allFinanceTx = await FinanceTransactionService.getAll();

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
      if (subtype != 'stock') continue;
      final symbol = (a.investmentSymbol ?? '').trim().toUpperCase();
      if (symbol.isNotEmpty) stockSymbolsForRates.add(symbol);
    }
    for (final s in trackedStocks.where((e) => e.isActive)) {
      final code = s.code.trim().toUpperCase();
      if (code.isNotEmpty) stockSymbolsForRates.add(code);
    }
    if (stockSymbolsForRates.isNotEmpty) {
      try {
        final stockRates =
            await MarketRateService.fetchStocksByCodes(stockSymbolsForRates.toList());
        for (final r in stockRates) {
          final fallbackPrice = r.sell > 0 ? r.sell : r.buy;
          if (fallbackPrice > 0) {
            ratesByCode[r.code.toUpperCase()] = fallbackPrice;
          }
        }
      } catch (_) {}
    }
    for (final a in accounts) {
      if (a.type != 'investment' || !a.isActive) continue;
      final subtype = (a.investmentSubtype ?? '').trim().toLowerCase();
      if (subtype != 'crypto') continue;
      final symbol = (a.investmentSymbol ?? '').trim().toUpperCase();
      if (symbol.isNotEmpty) cryptoSymbolsForRates.add(symbol);
    }
    for (final c in trackedCryptos.where((e) => e.isActive)) {
      final code = c.code.trim().toUpperCase();
      if (code.isNotEmpty) cryptoSymbolsForRates.add(code);
    }
    if (cryptoSymbolsForRates.isNotEmpty) {
      try {
        final cryptoRates =
            await MarketRateService.fetchCryptosByCodes(cryptoSymbolsForRates.toList());
        for (final r in cryptoRates) {
          final fallbackPrice = r.sell > 0 ? r.sell : r.buy;
          if (fallbackPrice > 0) {
            ratesByCode[r.code.toUpperCase()] = fallbackPrice;
          }
        }
      } catch (_) {}
    }

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
    final cashRows = <_AccountPreviewRow>[];
    final bankRows = <_AccountPreviewRow>[];
    final investmentRows = <_AccountPreviewRow>[];
    final cariRows = <_CariPreviewRow>[];
    bool missingInvestmentPrice = false;
    for (final a in accounts) {
      final type = a.type;
      if (type == 'cash') {
        cash += a.balance;
        cashRows.add(
          _AccountPreviewRow(
            name: a.name,
            valueText: '${_fmtAmount(a.balance)} TL',
            color: Colors.blue,
          ),
        );
      } else if (type == 'bank') {
        bank += a.balance;
        bankRows.add(
          _AccountPreviewRow(
            name: a.name,
            valueText: '${_fmtAmount(a.balance)} TL',
            color: Colors.indigo,
          ),
        );
      } else if (type == 'investment') {
        final symbol = (a.investmentSymbol ?? '').trim().toUpperCase();
        final price = ratesByCode[symbol];
        if (symbol.isNotEmpty && price != null) {
          final currentValue = (a.balance * price);
          investmentCurrent += currentValue;
          investmentRows.add(
            _AccountPreviewRow(
              name: a.name,
              valueText: '${_fmtAmount(currentValue)} TL',
              subtitle: '${_fmtAmount(a.balance)} $symbol',
              color: Colors.teal,
            ),
          );
        } else {
          missingInvestmentPrice = true;
          investmentRows.add(
            _AccountPreviewRow(
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
    double foreignSignedTotal = 0;
    for (final entry in foreignNetQtyByCard.entries) {
      final card = foreignCardsById[entry.key];
      if (card == null) continue;
      final code = (card.foreignCode ?? '').trim().toUpperCase();
      if (code.isEmpty) continue;
      final unitPrice = ratesByCode[code];
      if (unitPrice == null || unitPrice <= 0) continue;
      final signedValue = entry.value * unitPrice;
      foreignSignedTotal += signedValue;
      cariNetByCard[entry.key] = signedValue;
    }
    final cardNameById = <int, String>{};
    final cardCurrencyById = <int, String>{};
    for (final c in cariCards) {
      final full = (c.fullName ?? '').trim();
      final title = (c.title ?? '').trim();
      final name = full.isNotEmpty ? full : (title.isNotEmpty ? title : 'Cari #${c.id}');
      final currency = _cariCurrencyLabel(c);
      cardNameById[c.id] = name;
      cardCurrencyById[c.id] = currency;
    }
    for (final e in cariNetByCard.entries) {
      cariRows.add(
        _CariPreviewRow(
          ownerName: cardNameById[e.key] ?? 'Cari #${e.key}',
          currencyLabel: cardCurrencyById[e.key] ?? 'TL',
          net: e.value,
        ),
      );
    }
    cariRows.sort((a, b) {
      if (a.currencyLabel == b.currencyLabel) {
        return a.ownerName.compareTo(b.ownerName);
      }
      if (a.currencyLabel == 'TL') return -1;
      if (b.currencyLabel == 'TL') return 1;
      return a.currencyLabel.compareTo(b.currencyLabel);
    });

    final trackedRows = <_TrackedQuoteRow>[];
    final duePlanRows = <_TodayPlanRow>[];
    double dueIncomeTotal = 0;
    double dueExpenseTotal = 0;
    final now = DateTime.now();
    final dayStart = DateTime(now.year, now.month, now.day);
    final dayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
    final completedIncomePlansToday = <int, DateTime>{};
    final completedExpensePlansToday = <int, DateTime>{};
    final completedIncomeAmountsToday = <int, double>{};
    final completedExpenseAmountsToday = <int, double>{};
    for (final c in trackedCurrencies) {
      if (!c.isActive) continue;
      final code = c.code.trim().toUpperCase();
      if (code.isEmpty) continue;
      trackedRows.add(
        _TrackedQuoteRow(
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
        _TrackedQuoteRow(
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
      final live = ratesByCode[code];
      final displayName = trackedStockNameByCode[code] ?? code;
      trackedRows.add(
        _TrackedQuoteRow(
          market: 'Borsa',
          code: code,
          name: displayName,
          sell: live ?? latestUnitPriceBySymbol[code],
        ),
      );
    }
    for (final code in cryptoSymbols) {
      final live = ratesByCode[code];
      final displayName = trackedCryptoNameByCode[code] ?? code;
      trackedRows.add(
        _TrackedQuoteRow(
          market: 'Kripto',
          code: code,
          name: displayName,
          sell: live ?? latestUnitPriceBySymbol[code],
        ),
      );
    }
    trackedRows.sort((a, b) {
      final byMarket = a.market.compareTo(b.market);
      if (byMarket != 0) return byMarket;
      return a.code.compareTo(b.code);
    });
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

    for (final p in dueIncomePlans) {
      final desc = (p.description ?? '').trim();
      dueIncomeTotal += p.amount;
      duePlanRows.add(
        _TodayPlanRow(
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
        _TodayPlanRow(
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
          _TodayPlanRow(
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
          _TodayPlanRow(
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
          _TodayPlanRow(
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
          _TodayPlanRow(
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
          _TodayPlanRow(
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
          _TodayPlanRow(
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
      final key = '${r.typeLabel}|${r.description}|${r.statusLabel}|${r.amount}|${r.dueDate.toIso8601String()}';
      if (uniquePlanKeys.contains(key)) return true;
      uniquePlanKeys.add(key);
      return false;
    });
    duePlanRows.sort((a, b) => a.dueDate.compareTo(b.dueDate));

    final displayName = profile == null
        ? 'Kullanıcı Profili'
        : '${profile.firstName} ${profile.lastName}'.trim();
    final photoBytes = profile?.photoBytes;

    setState(() {
      totalAccounts = accounts.length;
      cashBankAccounts = accounts
          .where((a) => a.type == "cash" || a.type == "bank")
          .length;
      investmentAccounts = accounts.where((a) => a.type == "investment").length;
      cashTotal = cash;
      bankTotal = bank;
      investmentCurrentTotal = investmentCurrent;
      hasMissingInvestmentPrice = missingInvestmentPrice;
      cariReceivableTotal = cariReceivable;
      cariDebtTotal = cariDebt;
      cariNetTotal = (cariReceivable - cariDebt) + foreignSignedTotal;
      trackedQuotes = trackedRows;
      plannedIncomeTotal = dueIncomeTotal;
      plannedExpenseTotal = dueExpenseTotal;
      todayPlans = duePlanRows;
      cashPreviewRows = cashRows;
      bankPreviewRows = bankRows;
      investmentPreviewRows = investmentRows;
      cariPreviewRows = cariRows;
      totalBalance = cash + bank + investmentCurrent;
      profileName = displayName;
      profilePhoto = photoBytes == null ? null : Uint8List.fromList(photoBytes);
    });
  }

  Future<void> _openProfileScreen() async {
    rememberDrawerSelectionForScreen(const ProfileScreen());
    Navigator.pop(context);
    await Future.delayed(const Duration(milliseconds: 120));
    if (!mounted) return;
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ProfileScreen(),
      ),
    );
    if (!mounted) return;
    if (result == 'reset') {
      await Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const AppStartGate(),
        ),
        (_) => false,
      );
      return;
    }
    await loadDashboard();
  }

  Future<void> _openFromDrawer(
    Widget screen, {
    bool reloadOnReturn = false,
  }) async {
    rememberDrawerSelectionForScreen(screen);
    Navigator.pop(context);
    await Future.delayed(const Duration(milliseconds: 120));
    if (!mounted) return;
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
    if (!mounted) return;
    if (reloadOnReturn || result == true) {
      await loadDashboard();
    }
  }

  Future<void> _openIncomeEntry() async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const IncomeEntryScreen(),
      ),
    );
    if (saved == true) {
      await loadDashboard();
    }
  }

  Future<void> _openExpenseEntry() async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const ExpenseEntryScreen(),
      ),
    );
    if (saved == true) {
      await loadDashboard();
    }
  }

  Future<void> _openCariEntry() async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const CariAccountScreen(),
      ),
    );
    if (saved == true) {
      await loadDashboard();
    }
  }

  Future<void> _openTransferEntry() async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const TransferEntryScreen(),
      ),
    );
    if (saved == true) {
      await loadDashboard();
    }
  }

  Future<void> _openInvestmentEntry() async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const InvestmentEntryScreen(),
      ),
    );
    if (saved == true) {
      await loadDashboard();
    }
  }

  void _openAboutDialog() {
    Navigator.pop(context);
    Future<void>.delayed(const Duration(milliseconds: 120), () {
      if (!mounted) return;
      showAboutDialog(
        context: context,
        applicationName: 'HesapKitap',
        applicationVersion: 'v1',
        children: const [
          Text('Bu uygulama UC Digital Studio tarafından oluşturulmaktadır.'),
        ],
      );
    });
  }

  Widget _buildAboutFooter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: Material(
        color: Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: _openAboutDialog,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(
                      color: Colors.black.withValues(alpha: 0.08),
                    ),
                  ),
                  child: const Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Hakkında',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Text(
                  'v1',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
              decoration: const BoxDecoration(
                color: AppColors.brand,
              ),
              margin: EdgeInsets.zero,
              padding: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.white24,
                          backgroundImage: profilePhoto != null
                              ? MemoryImage(profilePhoto!)
                              : null,
                          child: profilePhoto == null
                              ? const Icon(Icons.person, color: Colors.white, size: 30)
                              : null,
                        ),
                        const SizedBox(width: 10),
                        InkWell(
                          onTap: _openProfileScreen,
                          borderRadius: BorderRadius.circular(18),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: Colors.white54),
                              color: Colors.white.withValues(alpha: 0.08),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.account_circle, color: Colors.white, size: 18),
                                SizedBox(width: 6),
                                Text(
                                  'Profil',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      profileName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'by UC Digital Studio',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ExpansionTile(
              leading: const Icon(Icons.folder_open, color: Colors.blueGrey),
              title: const Text('Tanım'),
              children: [
                ListTile(
                  leading: const Icon(Icons.account_balance, color: Colors.blueGrey),
                  title: const Text('Hesap Tanım'),
                  onTap: () async {
                    await _openFromDrawer(
                      const AccountsScreen(),
                      reloadOnReturn: true,
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.category, color: AppColors.income),
                  title: const Text('Gelir Kategorileri'),
                  onTap: () async {
                    await _openFromDrawer(const IncomeCategoryScreen());
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.sell, color: AppColors.expense),
                  title: const Text('Gider Kategorileri'),
                  onTap: () async {
                    await _openFromDrawer(const ExpenseCategoryScreen());
                  },
                ),
              ],
            ),
            ExpansionTile(
              leading: const Icon(Icons.receipt_long, color: AppColors.info),
              title: const Text('İşlemler'),
              children: [
                ListTile(
                  leading: const Icon(Icons.swap_vert_circle, color: AppColors.info),
                  title: const Text('İşlem Geçmişi'),
                  onTap: () async {
                    await _openFromDrawer(
                      const IncomeExpenseTransactionsScreen(),
                      reloadOnReturn: true,
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.account_tree_outlined, color: Colors.indigo),
                  title: const Text('Hesap Geçmişi'),
                  onTap: () async {
                    await _openFromDrawer(
                      const AccountMovementsScreen(),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.analytics_outlined, color: Colors.teal),
                  title: const Text('Yatırım Portföyü'),
                  onTap: () async {
                    await _openFromDrawer(
                      const InvestmentTrackingScreen(),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.inventory_2_outlined, color: Colors.teal),
                  title: const Text('Finans Özet'),
                  onTap: () async {
                    await _openFromDrawer(
                      const AssetStatusScreen(),
                    );
                  },
                ),
              ],
            ),
            ExpansionTile(
              leading: const Icon(Icons.people_alt_outlined, color: Colors.orange),
              title: const Text('Cari Kart İşlemleri'),
              children: [
                ListTile(
                  leading: const Icon(Icons.badge, color: AppColors.brand),
                  title: const Text('Cari Kart Tanım'),
                  onTap: () async {
                    await _openFromDrawer(const CariCardsScreen());
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.circle, color: Colors.orange, size: 12),
                  title: const Text('Cari Kart Özet (TL)'),
                  onTap: () async {
                    await _openFromDrawer(
                      const CariCardSummaryScreen(),
                      reloadOnReturn: true,
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.circle, color: Colors.deepOrange, size: 12),
                  title: const Text('Cari Kart Özet (Dış Finans)'),
                  onTap: () async {
                    await _openFromDrawer(
                      const CariCardSummaryForeignScreen(),
                      reloadOnReturn: true,
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.swap_vert_circle, color: Colors.orange),
                  title: const Text('Cari Kart İşlem Geçmişi'),
                  onTap: () async {
                    await _openFromDrawer(
                      const CariTransactionsScreen(),
                      reloadOnReturn: true,
                    );
                  },
                ),
              ],
            ),
            ExpansionTile(
              leading: const Icon(Icons.event_available, color: AppColors.planIncome),
              title: const Text('Planlamalar'),
              children: [
                ListTile(
                  leading: const Icon(Icons.event_note, color: AppColors.income),
                  title: const Text('Gelir Planlama'),
                  onTap: () async {
                    await _openFromDrawer(const IncomePlanningScreen());
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.event_busy, color: AppColors.expense),
                  title: const Text('Gider Planlama'),
                  onTap: () async {
                    await _openFromDrawer(const ExpensePlanningScreen());
                  },
                ),
              ],
            ),
            ListTile(
              leading: const Icon(Icons.calendar_month, color: AppColors.info),
              title: const Text('Takvim'),
              onTap: () async {
                await _openFromDrawer(const CalendarTransactionsScreen());
              },
            ),
            ExpansionTile(
              leading: const Icon(Icons.currency_exchange, color: Colors.teal),
              title: const Text('Yatırımcı'),
              children: [
                ListTile(
                  leading: const Icon(Icons.attach_money, color: Colors.teal),
                  title: const Text('Döviz Takip'),
                  onTap: () async {
                    await _openFromDrawer(const CurrencyTrackingScreen());
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.workspace_premium, color: Colors.amber),
                  title: const Text('Kıymetli Maden Takip'),
                  onTap: () async {
                    await _openFromDrawer(const PreciousMetalTrackingScreen());
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.show_chart, color: Colors.green),
                  title: const Text('Borsa Takip'),
                  onTap: () async {
                    await _openFromDrawer(const StockTrackingScreen());
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.currency_bitcoin, color: Colors.deepOrange),
                  title: const Text('Kripto Para Takip'),
                  onTap: () async {
                    await _openFromDrawer(const CryptoTrackingScreen());
                  },
                ),
              ],
            ),
                ],
              ),
            ),
            const Divider(height: 1),
            _buildAboutFooter(),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          height: 74,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: _quickActionItem(
                  icon: Icons.swap_horiz,
                  label: 'Transfer',
                  color: Colors.blue,
                  onTap: _openTransferEntry,
                ),
              ),
              Expanded(
                child: _quickActionItem(
                  icon: Icons.handshake,
                  label: 'Cari',
                  color: Colors.orange,
                  onTap: _openCariEntry,
                ),
              ),
              Expanded(
                child: _quickActionItem(
                  icon: Icons.trending_up,
                  label: 'Yatırım',
                  color: AppColors.brand,
                  onTap: _openInvestmentEntry,
                ),
              ),
              Expanded(
                child: _quickActionItem(
                  icon: Icons.arrow_downward,
                  label: 'Gelir',
                  color: AppColors.income,
                  onTap: _openIncomeEntry,
                ),
              ),
              Expanded(
                child: _quickActionItem(
                  icon: Icons.arrow_upward,
                  label: 'Gider',
                  color: AppColors.expense,
                  onTap: _openExpenseEntry,
                ),
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        title: const Text('Finansal Özet'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.brand.withValues(alpha: 0.08),
              Colors.white,
            ],
          ),
        ),
        child: RefreshIndicator(
          onRefresh: loadDashboard,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              _buildHeroSummaryCard(),
              const SizedBox(height: 12),
              _buildAccountTypeSummaryRow(),
              if (selectedAccountTypePreview != null) ...[
                const SizedBox(height: 8),
                _buildAccountTypePreviewCard(),
              ],
              const SizedBox(height: 10),
              _buildCariAndTrackedRow(),
              const SizedBox(height: 10),
              _buildPlannedTodayCard(),
              const SizedBox(height: 14),
              _buildActionHintCard(),
            ],
          ),
        ),
      ),
    );
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

  Widget _buildHeroSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.brand,
            Color(0xFF6D5AA8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.brand.withValues(alpha: 0.22),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Genel Durum',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${_fmtAmount(totalBalance)} TL',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          const Row(
            children: [
              Icon(Icons.verified, color: Colors.white70, size: 14),
              SizedBox(width: 6),
              Text(
                'Toplam bakiye ve hesap verileri güncel',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          if (hasMissingInvestmentPrice) ...[
            const SizedBox(height: 8),
            const Text(
              'Bazı yatırım kurları alınamadı; toplam değere dahil edilmeyebilir.',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 10,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAccountTypeSummaryRow() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 760;
        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTypeBalanceCard(
                title: 'Kasa',
                value: cashTotal,
                icon: Icons.account_balance_wallet,
                color: Colors.blue,
                onTap: () => _toggleAccountTypePreview('cash'),
                isSelected: selectedAccountTypePreview == 'cash',
              ),
              const SizedBox(height: 8),
              _buildTypeBalanceCard(
                title: 'Banka',
                value: bankTotal,
                icon: Icons.account_balance,
                color: Colors.indigo,
                onTap: () => _toggleAccountTypePreview('bank'),
                isSelected: selectedAccountTypePreview == 'bank',
              ),
              const SizedBox(height: 8),
              _buildTypeBalanceCard(
                title: 'Yatırım',
                value: investmentCurrentTotal,
                icon: Icons.trending_up,
                color: Colors.teal,
                onTap: () => _toggleAccountTypePreview('investment'),
                isSelected: selectedAccountTypePreview == 'investment',
              ),
            ],
          );
        }
        return Row(
          children: [
            Expanded(
              child: _buildTypeBalanceCard(
                title: 'Kasa',
                value: cashTotal,
                icon: Icons.account_balance_wallet,
                color: Colors.blue,
                onTap: () => _toggleAccountTypePreview('cash'),
                isSelected: selectedAccountTypePreview == 'cash',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildTypeBalanceCard(
                title: 'Banka',
                value: bankTotal,
                icon: Icons.account_balance,
                color: Colors.indigo,
                onTap: () => _toggleAccountTypePreview('bank'),
                isSelected: selectedAccountTypePreview == 'bank',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildTypeBalanceCard(
                title: 'Yatırım',
                value: investmentCurrentTotal,
                icon: Icons.trending_up,
                color: Colors.teal,
                onTap: () => _toggleAccountTypePreview('investment'),
                isSelected: selectedAccountTypePreview == 'investment',
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCariSummaryCard() {
    final netPositive = cariNetTotal >= 0;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          setState(() {
            showCariPreview = !showCariPreview;
          });
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: showCariPreview
                  ? Colors.orange.withValues(alpha: 0.45)
                  : Colors.black.withValues(alpha: 0.06),
              width: showCariPreview ? 1.4 : 1,
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.people_alt_outlined, color: Colors.orange, size: 18),
              const SizedBox(width: 8),
              const Text(
                'CARI HESAP BAKİYESİ',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              Text(
                '${netPositive ? '+' : '-'}${_fmtAmount(cariNetTotal.abs())} TL',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: netPositive ? Colors.blue : Colors.orange,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  (int, int) _cariTrackedFlexes() {
    final cash = cashTotal.abs();
    final bank = bankTotal.abs();
    final sum = cash + bank;
    if (sum <= 0) return (3, 2);

    final left = ((cash / sum) * 10).round().clamp(2, 8);
    final right = (10 - left).clamp(2, 8);
    return (left, right);
  }

  Widget _buildCariAndTrackedRow() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 1080;
        if (compact) {
          return Column(
            children: [
              _buildCariSummaryCard(),
              if (showCariPreview) ...[
                const SizedBox(height: 8),
                _buildCariPreviewCard(),
              ],
              const SizedBox(height: 8),
              _buildTrackedSummaryCard(),
              if (showTrackedPreview) ...[
                const SizedBox(height: 8),
                _buildTrackedItemsCard(compact: true, showHeader: false),
              ],
            ],
          );
        }
        final flexes = _cariTrackedFlexes();
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: flexes.$1,
              child: Column(
                children: [
                  _buildCariSummaryCard(),
                  if (showCariPreview) ...[
                    const SizedBox(height: 8),
                    _buildCariPreviewCard(),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: flexes.$2,
              child: Column(
                children: [
                  _buildTrackedSummaryCard(),
                  if (showTrackedPreview) ...[
                    const SizedBox(height: 8),
                    _buildTrackedItemsCard(compact: true, showHeader: false),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCariPreviewCard() {
    final grouped = <String, List<_CariPreviewRow>>{};
    for (final row in cariPreviewRows) {
      grouped.putIfAbsent(row.currencyLabel, () => []).add(row);
    }
    final groupKeys = grouped.keys.toList()
      ..sort((a, b) {
        if (a == 'TL' && b != 'TL') return -1;
        if (b == 'TL' && a != 'TL') return 1;
        return a.compareTo(b);
      });

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.receipt_long, color: Colors.orange, size: 18),
              SizedBox(width: 8),
              Text(
                'Cari Kart On Izleme',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (cariPreviewRows.isEmpty)
            const Text(
              'Cari kart hareketi bulunamadi.',
              style: TextStyle(color: Colors.black54),
            )
          else
            ...groupKeys.expand(
              (group) => [
                Padding(
                  padding: const EdgeInsets.only(top: 2, bottom: 4),
                  child: Text(
                    'Para Birimi: $group',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                ),
                ...grouped[group]!.map(
                  (r) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${r.ownerName} / ${r.currencyLabel}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${r.net >= 0 ? '+' : '-'}${_fmtAmount(r.net.abs())} TL',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: r.net >= 0 ? Colors.orange : Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 4),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildTrackedSummaryCard() {
    final count = trackedQuotes.length;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          setState(() {
            showTrackedPreview = !showTrackedPreview;
          });
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: showTrackedPreview
                  ? AppColors.brand.withValues(alpha: 0.45)
                  : Colors.black.withValues(alpha: 0.06),
              width: showTrackedPreview ? 1.4 : 1,
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.visibility_outlined, color: AppColors.brand, size: 18),
              const SizedBox(width: 8),
              const Text(
                'Takip Ettiklerim',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              Text(
                '$count enstruman',
                style: const TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrackedItemsCard({
    bool compact = false,
    bool showHeader = true,
  }) {
    final fxItems = trackedQuotes.where((q) => q.market == 'Döviz').toList();
    final metalItems = trackedQuotes.where((q) => q.market == 'Kıymetli Maden').toList();
    final stockItems = trackedQuotes.where((q) => q.market == 'Borsa').toList();
    final cryptoItems = trackedQuotes.where((q) => q.market == 'Kripto').toList();
    final perCardLimit = compact ? 2 : 4;
    final marketCards = <_TrackedMarketCardData>[
      if (fxItems.isNotEmpty)
        _TrackedMarketCardData(
          title: 'Doviz',
          icon: Icons.attach_money,
          color: Colors.teal,
          rows: fxItems,
        ),
      if (metalItems.isNotEmpty)
        _TrackedMarketCardData(
          title: 'Kiymetli Maden',
          icon: Icons.workspace_premium,
          color: Colors.amber.shade700,
          rows: metalItems,
        ),
      if (stockItems.isNotEmpty)
        _TrackedMarketCardData(
          title: 'Borsa',
          icon: Icons.show_chart,
          color: Colors.green,
          rows: stockItems,
        ),
      if (cryptoItems.isNotEmpty)
        _TrackedMarketCardData(
          title: 'Kripto',
          icon: Icons.currency_bitcoin,
          color: Colors.deepOrange,
          rows: cryptoItems,
        ),
    ];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showHeader) ...[
            const Row(
              children: [
                Icon(Icons.visibility_outlined, color: AppColors.brand, size: 18),
                SizedBox(width: 8),
                Text(
                  'Takip Ettiklerim',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
          if (marketCards.isEmpty)
            const Text(
              'Takibe alınmış enstrüman bulunamadı.',
              style: TextStyle(color: Colors.black54),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final twoCols = constraints.maxWidth >= 520;
                if (!twoCols) {
                  return Column(
                    children: [
                      for (int i = 0; i < marketCards.length; i++) ...[
                        _buildTrackedMarketCard(
                          marketKey: marketCards[i].title,
                          title: marketCards[i].title,
                          icon: marketCards[i].icon,
                          color: marketCards[i].color,
                          rows: marketCards[i].rows,
                          limit: perCardLimit,
                        ),
                        if (i != marketCards.length - 1) const SizedBox(height: 8),
                      ],
                    ],
                  );
                }

                return Column(
                  children: [
                    for (int i = 0; i < marketCards.length; i += 2) ...[
                      Builder(
                        builder: (_) {
                          final left = marketCards[i];
                          final right = (i + 1) < marketCards.length ? marketCards[i + 1] : null;
                          final leftHeight = _trackedCardMinHeight(
                            left.rows.length,
                            perCardLimit,
                          );
                          final rightHeight = right == null
                              ? leftHeight
                              : _trackedCardMinHeight(
                                  right.rows.length,
                                  perCardLimit,
                                );
                          final rowHeight = leftHeight > rightHeight ? leftHeight : rightHeight;

                          if (right == null) {
                            return _buildTrackedMarketCard(
                              marketKey: left.title,
                              title: left.title,
                              icon: left.icon,
                              color: left.color,
                              rows: left.rows,
                              limit: perCardLimit,
                              minHeight: rowHeight,
                            );
                          }

                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _buildTrackedMarketCard(
                                  marketKey: left.title,
                                  title: left.title,
                                  icon: left.icon,
                                  color: left.color,
                                  rows: left.rows,
                                  limit: perCardLimit,
                                  minHeight: rowHeight,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildTrackedMarketCard(
                                  marketKey: right.title,
                                  title: right.title,
                                  icon: right.icon,
                                  color: right.color,
                                  rows: right.rows,
                                  limit: perCardLimit,
                                  minHeight: rowHeight,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      if (i + 2 < marketCards.length) const SizedBox(height: 8),
                    ],
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildTrackedMarketCard({
    required String marketKey,
    required String title,
    required IconData icon,
    required Color color,
    required List<_TrackedQuoteRow> rows,
    required int limit,
    double? minHeight,
  }) {
    final expanded = expandedTrackedMarkets.contains(marketKey);
    final visibleCount = expanded ? rows.length : limit;
    final visibleRows = rows.take(visibleCount);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      constraints: (!expanded && minHeight != null)
          ? BoxConstraints(minHeight: minHeight)
          : null,
      child: Material(
        color: const Color(0xFFF8F8FE),
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            setState(() {
              if (expanded) {
                expandedTrackedMarkets.remove(marketKey);
              } else {
                expandedTrackedMarkets.add(marketKey);
              }
            });
          },
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: color.withValues(alpha: 0.18)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, color: color, size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                    ),
                    Icon(
                      expanded ? Icons.expand_less : Icons.expand_more,
                      size: 18,
                      color: Colors.black45,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...visibleRows.map(
                  (q) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '${q.name.trim().isEmpty ? q.code : q.name.trim()} - ${q.sell == null ? 'Veri yok' : '${_fmtAmount(q.sell!)} TL'}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                if (!expanded && rows.length > limit)
                  Text(
                    '+${rows.length - limit} daha',
                    style: const TextStyle(fontSize: 11, color: Colors.black54),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  double _trackedCardMinHeight(int totalRows, int limit) {
    final visible = totalRows > limit ? limit : totalRows;
    final hasMore = totalRows > limit;
    final lineCount = visible + (hasMore ? 1 : 0);
    return 46 + (lineCount * 22);
  }

  Widget _buildTypeBalanceCard({
    required String title,
    required double value,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
    bool isSelected = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? color.withValues(alpha: 0.5)
                  : Colors.black.withValues(alpha: 0.06),
              width: isSelected ? 1.4 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(height: 6),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${_fmtAmount(value)} TL',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleAccountTypePreview(String type) {
    setState(() {
      selectedAccountTypePreview =
          selectedAccountTypePreview == type ? null : type;
    });
  }

  Widget _buildAccountTypePreviewCard() {
    final type = selectedAccountTypePreview;
    if (type == null) return const SizedBox.shrink();

    late final String title;
    late final Color color;
    late final List<_AccountPreviewRow> rows;
    if (type == 'cash') {
      title = 'Kasa Hesap On Izleme';
      color = Colors.blue;
      rows = cashPreviewRows;
    } else if (type == 'bank') {
      title = 'Banka Hesap On Izleme';
      color = Colors.indigo;
      rows = bankPreviewRows;
    } else {
      title = 'Yatirim Hesap On Izleme';
      color = Colors.teal;
      rows = investmentPreviewRows;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.visibility_outlined, color: color, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (rows.isEmpty)
            const Text(
              'Bu turde hesap bulunamadi.',
              style: TextStyle(color: Colors.black54),
            )
          else
            ...rows.map(
              (r) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            r.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          if (r.subtitle != null)
                            Text(
                              r.subtitle!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.black54,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      r.valueText,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: r.color,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPlannedTodayCard() {
    final net = plannedIncomeTotal - plannedExpenseTotal;
    final netPositive = net >= 0;
    final maxItems = 5;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.event_note, color: AppColors.info, size: 18),
              SizedBox(width: 8),
              Text(
                'Planlananlar',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              Text(
                'Gelir: +${_fmtAmount(plannedIncomeTotal)} TL',
                style: const TextStyle(
                  color: AppColors.income,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'Gider: -${_fmtAmount(plannedExpenseTotal)} TL',
                style: const TextStyle(
                  color: AppColors.expense,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'Net: ${netPositive ? '+' : '-'}${_fmtAmount(net.abs())} TL',
                style: TextStyle(
                  color: netPositive ? Colors.blue : Colors.orange,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (todayPlans.isEmpty)
            const Text(
              'Bugun icin planlanan gelir veya gider bulunamadi.',
              style: TextStyle(color: Colors.black54),
            )
          else
            ...todayPlans.take(maxItems).map(
              (p) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: p.color,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${p.typeLabel} • ${p.description}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${p.dueDate.hour.toString().padLeft(2, '0')}:${p.dueDate.minute.toString().padLeft(2, '0')}  ${p.typeLabel == 'Gelir' ? '+' : '-'}${_fmtAmount(p.amount)}',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: p.color,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: p.statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: p.statusColor.withValues(alpha: 0.22),
                        ),
                      ),
                      child: Text(
                        p.statusLabel,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: p.statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (todayPlans.length > maxItems)
            Text(
              '+${todayPlans.length - maxItems} plan daha...',
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
        ],
      ),
    );
  }

  Widget _buildActionHintCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8FE),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.brand.withValues(alpha: 0.16)),
      ),
      child: const Row(
        children: [
          Icon(Icons.tips_and_updates_outlined, color: AppColors.brand),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Alt çubuktan Gelir/Gider/Transfer işlemlerini hızlıca başlatabilirsin.',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
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

  Widget _quickActionItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _TrackedQuoteRow {
  final String market;
  final String code;
  final String name;
  final double? sell;

  const _TrackedQuoteRow({
    required this.market,
    required this.code,
    required this.name,
    required this.sell,
  });
}

class _TrackedMarketCardData {
  final String title;
  final IconData icon;
  final Color color;
  final List<_TrackedQuoteRow> rows;

  const _TrackedMarketCardData({
    required this.title,
    required this.icon,
    required this.color,
    required this.rows,
  });
}

class _AccountPreviewRow {
  final String name;
  final String valueText;
  final String? subtitle;
  final Color color;

  const _AccountPreviewRow({
    required this.name,
    required this.valueText,
    required this.color,
    this.subtitle,
  });
}

class _CariPreviewRow {
  final String ownerName;
  final String currencyLabel;
  final double net;

  const _CariPreviewRow({
    required this.ownerName,
    required this.currencyLabel,
    required this.net,
  });
}

class _TodayPlanRow {
  final String typeLabel;
  final double amount;
  final DateTime dueDate;
  final String description;
  final Color color;
  final String statusLabel;
  final Color statusColor;

  const _TodayPlanRow({
    required this.typeLabel,
    required this.amount,
    required this.dueDate,
    required this.description,
    required this.color,
    required this.statusLabel,
    required this.statusColor,
  });
}
