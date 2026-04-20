import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/dashboard/dashboard_loader.dart';
import 'core/dashboard/dashboard_view_data.dart';
import 'core/runtime/app_messenger.dart';
import 'core/runtime/app_runtime.dart';
import 'database/isar_service.dart';
import 'screens/cari_account_screen.dart';
import 'screens/asset_operation_screen.dart';
import 'screens/expense_entry_screen.dart';
import 'screens/fixed_payment_entry_screen.dart';
import 'screens/income_entry_screen.dart';
import 'screens/onboarding_welcome_screen.dart';
import 'services/local_notification_service.dart';
import 'services/user_profile_service.dart';
import 'theme/app_colors.dart';
import 'theme/app_theme.dart';
import 'theme/app_theme_controller.dart';
import 'screens/transfer_entry_screen.dart';
import 'screens/investment_entry_screen.dart';
import 'utils/navigation_helpers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('tr_TR');
  await IsarService.init();
  await AppRuntime.initialize();
  await AppThemeController.instance.initialize();
  runApp(const MyApp());

  // Do not block first frame with notification setup.
  unawaited(
    LocalNotificationService.init().then((_) async {
      await LocalNotificationService.syncIncomePlanNotifications();
      await LocalNotificationService.syncExpensePlanNotifications();
    }),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppThemeController.instance,
      builder: (context, _) {
        return MaterialApp(
          title: 'Varlık360',
          scaffoldMessengerKey: appScaffoldMessengerKey,
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
          theme: AppTheme.resolve(
            AppThemeController.instance.themeKey,
            fanTeamKey: AppThemeController.instance.fanTeamKey,
          ),
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
      },
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
  static const double _zeroEpsilon = 1e-9;
  DashboardViewData _dashboardData = DashboardViewData.initial();
  String? selectedAccountTypePreview;
  bool showAssetBreakdown = false;
  bool showOwnedAssetPreview = false;
  bool showCariPreview = false;
  bool showSubscriptionPreview = false;
  bool showTrackedPreview = false;
  final Set<String> expandedTrackedMarkets = <String>{};

  int get totalAccounts => _dashboardData.totalAccounts;
  int get cashBankAccounts => _dashboardData.cashBankAccounts;
  int get investmentAccounts => _dashboardData.investmentAccounts;
  double get totalBalance => _dashboardData.totalBalance;
  double get cashTotal => _dashboardData.cashTotal;
  double get bankTotal => _dashboardData.bankTotal;
  double get investmentCurrentTotal => _dashboardData.investmentCurrentTotal;
  double get activeAssetTotal => _dashboardData.activeAssetTotal;
  bool get hasMissingInvestmentPrice => _dashboardData.hasMissingInvestmentPrice;
  double get cariReceivableTotal => _dashboardData.cariReceivableTotal;
  double get cariDebtTotal => _dashboardData.cariDebtTotal;
  double get cariNetTotal => _dashboardData.cariNetTotal;
  List<TrackedQuoteRow> get trackedQuotes => _dashboardData.trackedQuotes;
  double get plannedIncomeTotal => _dashboardData.plannedIncomeTotal;
  double get plannedExpenseTotal => _dashboardData.plannedExpenseTotal;
  List<TodayPlanRow> get todayPlans => _dashboardData.todayPlans;
  List<AccountPreviewRow> get cashPreviewRows => _dashboardData.cashPreviewRows;
  List<AccountPreviewRow> get bankPreviewRows => _dashboardData.bankPreviewRows;
  List<AccountPreviewRow> get investmentPreviewRows =>
      _dashboardData.investmentPreviewRows;
  List<AccountPreviewRow> get assetPreviewRows => _dashboardData.assetPreviewRows;
  int get activeSubscriptionCount => _dashboardData.activeSubscriptionCount;
  int get dueSubscriptionCount => _dashboardData.dueSubscriptionCount;
  List<SubscriptionReminderRow> get subscriptionPreviewRows =>
      _dashboardData.subscriptionPreviewRows;
  List<CariPreviewRow> get cariPreviewRows => _dashboardData.cariPreviewRows;
  bool get hasCariPreviewData => cariPreviewRows.isNotEmpty;
  String get profileName => _dashboardData.profileName;
  Uint8List? get profilePhoto => _dashboardData.profilePhoto;

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
    final nextData = await DashboardLoader.load();
    setState(() {
      _dashboardData = nextData;
      if (nextData.dueSubscriptionCount == 0) {
        showSubscriptionPreview = false;
      }
      if (nextData.cariPreviewRows.isEmpty) {
        showCariPreview = false;
      }
      if (nextData.assetPreviewRows.isEmpty) {
        showOwnedAssetPreview = false;
      }
      if (selectedAccountTypePreview == 'cash' &&
          nextData.cashTotal.abs() <= _zeroEpsilon) {
        selectedAccountTypePreview = null;
      } else if (selectedAccountTypePreview == 'bank' &&
          nextData.bankTotal.abs() <= _zeroEpsilon) {
        selectedAccountTypePreview = null;
      } else if (selectedAccountTypePreview == 'investment' &&
          nextData.investmentCurrentTotal.abs() <= _zeroEpsilon) {
        selectedAccountTypePreview = null;
      }
      if (nextData.cashTotal.abs() <= _zeroEpsilon &&
          nextData.bankTotal.abs() <= _zeroEpsilon &&
          nextData.investmentCurrentTotal.abs() <= _zeroEpsilon) {
        showAssetBreakdown = false;
      }
      if (nextData.trackedQuotes.isEmpty) {
        showTrackedPreview = false;
      }
    });
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

  Future<void> _openFixedPaymentEntry() async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const FixedPaymentEntryScreen(),
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

  Future<void> _openAssetBuyEntry() async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const AssetOperationScreen(mode: AssetOperationMode.buy),
      ),
    );
    if (saved == true) {
      await loadDashboard();
    }
  }

  Future<void> _openAssetSellEntry() async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const AssetOperationScreen(mode: AssetOperationMode.sell),
      ),
    );
    if (saved == true) {
      await loadDashboard();
    }
  }

  Future<void> _openQuickActionSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Yeni Islem',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Kaydetmek istedigin islemi sec.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _quickSheetAction(
                    icon: Icons.swap_horiz,
                    label: 'Transfer',
                    color: Colors.blue,
                    onTap: () {
                      Navigator.pop(sheetContext);
                      _openTransferEntry();
                    },
                  ),
                  _quickSheetAction(
                    icon: Icons.handshake,
                    label: 'Cari',
                    color: Colors.orange,
                    onTap: () {
                      Navigator.pop(sheetContext);
                      _openCariEntry();
                    },
                  ),
                  _quickSheetAction(
                    icon: Icons.trending_up,
                    label: 'Yatirim',
                    color: AppColors.brand,
                    onTap: () {
                      Navigator.pop(sheetContext);
                      _openInvestmentEntry();
                    },
                  ),
                  _quickSheetAction(
                    icon: Icons.domain_add_outlined,
                    label: 'Varlık İşlem',
                    color: Colors.brown,
                    onTap: () {
                      Navigator.pop(sheetContext);
                      _openAssetActionPopup();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openAssetActionPopup() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Varlık İşlem',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Yapmak istedigin varlık operasyonunu sec.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: _quickSheetAction(
                        icon: Icons.add_home_work_outlined,
                        label: 'Satın Al',
                        color: AppColors.income,
                        useHalfSheetWidth: false,
                        onTap: () {
                          Navigator.pop(dialogContext);
                          _openAssetBuyEntry();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _quickSheetAction(
                        icon: Icons.sell_outlined,
                        label: 'Sat',
                        color: Colors.orange,
                        useHalfSheetWidth: false,
                        onTap: () {
                          Navigator.pop(dialogContext);
                          _openAssetSellEntry();
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('İptal'),
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
    return Scaffold(
      drawer: buildAppMenuDrawer(),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          height: 92,
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.97),
            border: Border(
              top: BorderSide(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.16),
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.08),
                blurRadius: 14,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: _quickActionFabItem(
                  onTap: _openQuickActionSheet,
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
                  icon: Icons.payments_outlined,
                  label: 'Fatura',
                  color: Colors.deepOrange,
                  onTap: _openFixedPaymentEntry,
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
        title: const Text('Finansal Durum'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.10),
              Theme.of(context).scaffoldBackgroundColor,
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
              _buildAssetBreakdownSection(),
              if (assetPreviewRows.isNotEmpty) ...[
                const SizedBox(height: 10),
                _buildOwnedAssetsSection(),
                if (showOwnedAssetPreview) ...[
                  const SizedBox(height: 8),
                  _buildOwnedAssetsPreviewCard(),
                ],
              ],
              const SizedBox(height: 10),
              _buildCariAndTrackedRow(),
              if (plannedIncomeTotal.abs() > _zeroEpsilon ||
                  plannedExpenseTotal.abs() > _zeroEpsilon ||
                  todayPlans.isNotEmpty) ...[
                const SizedBox(height: 10),
                _buildPlannedTodayCard(),
              ],
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

  Widget _buildHeroSummaryCard() {
    final colorScheme = Theme.of(context).colorScheme;
    final hasAssets = cashTotal.abs() > _zeroEpsilon ||
        bankTotal.abs() > _zeroEpsilon ||
        investmentCurrentTotal.abs() > _zeroEpsilon;
    final hasCariSummary = cariNetTotal.abs() > _zeroEpsilon;
    final hasOwnedAssetSummary = activeAssetTotal.abs() > _zeroEpsilon;
    final overallStatusTotal = totalBalance + cariNetTotal + activeAssetTotal;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: hasAssets ? _toggleAssetBreakdown : null,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.primary,
                colorScheme.tertiary,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withValues(alpha: 0.22),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Genel Durum',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (hasAssets)
                    Icon(
                      showAssetBreakdown
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                ],
              ),
              const SizedBox(height: 8),
              _buildHeroAmountLine(
                label: 'Nakit Durum',
                value: totalBalance,
              ),
              if (hasCariSummary) ...[
                const SizedBox(height: 6),
                _buildHeroAmountLine(
                  label: 'Cari Durum',
                  value: cariNetTotal,
                ),
              ],
              if (hasOwnedAssetSummary) ...[
                const SizedBox(height: 6),
                _buildHeroAmountLine(
                  label: 'Varliklarim',
                  value: activeAssetTotal,
                ),
              ],
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.16),
                  ),
                ),
                child: _buildHeroAmountLine(
                  label: 'Toplam Durum',
                  value: overallStatusTotal,
                  emphasized: true,
                ),
              ),
              const SizedBox(height: 14),
              if (dueSubscriptionCount > 0)
                _heroInfoChip(
                  icon: Icons.payments_outlined,
                  label: '$dueSubscriptionCount bugun odeme',
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
        ),
      ),
    );
  }

  Widget _buildHeroAmountLine({
    required String label,
    required double value,
    bool emphasized = false,
  }) {
    final valueText =
        '${value < 0 ? '-' : ''}${_fmtAmount(value.abs())} TL';
    return Row(
      children: [
        Expanded(
          child: Text(
            '$label:',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: emphasized ? Colors.white : Colors.white70,
              fontSize: emphasized ? 16 : 14,
              fontWeight: emphasized ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            valueText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
            style: TextStyle(
              color: Colors.white,
              fontSize: emphasized ? 20 : 18,
              fontWeight: emphasized ? FontWeight.w800 : FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  void _toggleAssetBreakdown() {
    setState(() {
      showAssetBreakdown = !showAssetBreakdown;
      if (!showAssetBreakdown) {
        selectedAccountTypePreview = null;
      }
    });
  }

  Widget _buildAssetBreakdownSection() {
    final hasAssets = cashTotal.abs() > _zeroEpsilon ||
        bankTotal.abs() > _zeroEpsilon ||
        investmentCurrentTotal.abs() > _zeroEpsilon;
    if (!hasAssets) return const SizedBox.shrink();

    return AnimatedCrossFade(
      duration: const Duration(milliseconds: 220),
      crossFadeState: showAssetBreakdown
          ? CrossFadeState.showSecond
          : CrossFadeState.showFirst,
      firstChild: const SizedBox.shrink(),
      secondChild: Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Column(
          children: [
            _buildAccountTypeSummaryRow(),
          ],
        ),
      ),
    );
  }

  Widget _buildOwnedAssetsSection() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () {
          setState(() {
            showOwnedAssetPreview = !showOwnedAssetPreview;
          });
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: showOwnedAssetPreview
                  ? Colors.brown.withValues(alpha: 0.45)
                  : Colors.brown.withValues(alpha: 0.18),
              width: showOwnedAssetPreview ? 1.4 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.05),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.brown.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.domain_add_outlined,
                      color: Colors.brown,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Varlıklarım',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  Text(
                    '${_fmtAmount(activeAssetTotal)} TL',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Colors.brown,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    showOwnedAssetPreview
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: Colors.brown,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOwnedAssetsPreviewCard() {
    final grouped = <String, List<AccountPreviewRow>>{};
    for (final row in assetPreviewRows.where(
      (entry) => entry.groupLabel != 'Demirbaşlar',
    )) {
      final key = row.groupLabel ?? 'Varlıklar';
      grouped.putIfAbsent(key, () => []).add(row);
    }
    const orderedGroups = ['Varlıklar'];
    final groupKeys = grouped.keys.toList()
      ..sort((a, b) {
        final aIndex = orderedGroups.indexOf(a);
        final bIndex = orderedGroups.indexOf(b);
        if (aIndex == -1 && bIndex == -1) return a.compareTo(b);
        if (aIndex == -1) return 1;
        if (bIndex == -1) return -1;
        return aIndex.compareTo(bIndex);
      });

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.brown.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.inventory_2_outlined, color: Colors.brown, size: 18),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Varlık Bilgi Paneli',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...groupKeys.expand(
            (group) => [
              Padding(
                padding: const EdgeInsets.only(top: 2, bottom: 6),
                child: Text(
                  group,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ),
              ...grouped[group]!.map(
                (row) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              row.name,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            if (row.subtitle?.isNotEmpty == true)
                              Text(
                                row.subtitle!,
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        row.valueText,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroInfoChip({
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountTypeSummaryRow() {
    final cards = <Widget>[];
    if (cashTotal.abs() > _zeroEpsilon) {
      cards.add(
        _buildTypeBalanceCard(
          title: 'Kasa',
          value: cashTotal,
          icon: Icons.account_balance_wallet,
          color: Colors.blue,
          onTap: () => _toggleAccountTypePreview('cash'),
          isSelected: selectedAccountTypePreview == 'cash',
        ),
      );
      if (selectedAccountTypePreview == 'cash') {
        cards.add(_buildInlineAccountTypePreviewCard());
      }
    }
    if (bankTotal.abs() > _zeroEpsilon) {
      cards.add(
        _buildTypeBalanceCard(
          title: 'Banka',
          value: bankTotal,
          icon: Icons.account_balance,
          color: Colors.indigo,
          onTap: () => _toggleAccountTypePreview('bank'),
          isSelected: selectedAccountTypePreview == 'bank',
        ),
      );
      if (selectedAccountTypePreview == 'bank') {
        cards.add(_buildInlineAccountTypePreviewCard());
      }
    }
    if (investmentCurrentTotal.abs() > _zeroEpsilon) {
      cards.add(
        _buildTypeBalanceCard(
          title: 'Yatırım',
          value: investmentCurrentTotal,
          icon: Icons.trending_up,
          color: Colors.teal,
          onTap: () => _toggleAccountTypePreview('investment'),
          isSelected: selectedAccountTypePreview == 'investment',
        ),
      );
      if (selectedAccountTypePreview == 'investment') {
        cards.add(_buildInlineAccountTypePreviewCard());
      }
    }
    if (cards.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 760;
        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (int i = 0; i < cards.length; i++) ...[
                cards[i],
                if (i != cards.length - 1) const SizedBox(height: 8),
              ],
            ],
          );
        }
        return Row(
          children: [
            for (int i = 0; i < cards.length; i++) ...[
              Expanded(child: cards[i]),
              if (i != cards.length - 1) const SizedBox(width: 8),
            ],
          ],
        );
      },
    );
  }

  Widget _buildCariSummaryCard() {
    final netPositive = cariNetTotal >= 0;
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () {
          setState(() {
            showCariPreview = !showCariPreview;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: showCariPreview
                  ? Colors.orange.withValues(alpha: 0.45)
                  : colorScheme.outline.withValues(alpha: 0.22),
              width: showCariPreview ? 1.4 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.05),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.people_alt_outlined,
                  color: Colors.orange,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
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
    final hasCari = hasCariPreviewData;
    final hasTracked = trackedQuotes.isNotEmpty;
    final hasSubscriptions = dueSubscriptionCount > 0;
    if (!hasCari && !hasTracked && !hasSubscriptions) {
      return const SizedBox.shrink();
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 1080;
        if (compact) {
          return Column(
            children: [
              if (hasCari) _buildCariSummaryCard(),
              if (hasCari && showCariPreview) ...[
                const SizedBox(height: 8),
                _buildCariPreviewCard(),
              ],
              if (hasSubscriptions) ...[
                const SizedBox(height: 8),
                _buildSubscriptionPaymentCard(),
                if (showSubscriptionPreview) ...[
                  const SizedBox(height: 8),
                  _buildSubscriptionPreviewCard(),
                ],
              ],
              if (hasTracked) ...[
                const SizedBox(height: 8),
                _buildTrackedSummaryCard(),
                if (showTrackedPreview) ...[
                  const SizedBox(height: 8),
                  _buildTrackedItemsCard(compact: true, showHeader: false),
                ],
              ],
            ],
          );
        }
        if (!hasTracked) {
          return Column(
            children: [
              if (hasCari) _buildCariSummaryCard(),
              if (hasCari && showCariPreview) ...[
                const SizedBox(height: 8),
                _buildCariPreviewCard(),
              ],
              if (hasSubscriptions) ...[
                const SizedBox(height: 8),
                _buildSubscriptionPaymentCard(),
                if (showSubscriptionPreview) ...[
                  const SizedBox(height: 8),
                  _buildSubscriptionPreviewCard(),
                ],
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
                  if (hasCari) _buildCariSummaryCard(),
                  if (hasCari && showCariPreview) ...[
                    const SizedBox(height: 8),
                    _buildCariPreviewCard(),
                  ],
                  if (hasSubscriptions) ...[
                    const SizedBox(height: 8),
                    _buildSubscriptionPaymentCard(),
                    if (showSubscriptionPreview) ...[
                      const SizedBox(height: 8),
                      _buildSubscriptionPreviewCard(),
                    ],
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
    final grouped = <String, List<CariPreviewRow>>{};
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
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () {
          setState(() {
            showTrackedPreview = !showTrackedPreview;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: showTrackedPreview
                  ? AppColors.brand.withValues(alpha: 0.45)
                  : colorScheme.outline.withValues(alpha: 0.22),
              width: showTrackedPreview ? 1.4 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.05),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.brand.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.visibility_outlined,
                  color: AppColors.brand,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
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
    final metalItems =
        trackedQuotes.where((q) => q.market == 'Kıymetli Maden').toList();
    final stockItems = trackedQuotes.where((q) => q.market == 'Borsa').toList();
    final cryptoItems =
        trackedQuotes.where((q) => q.market == 'Kripto').toList();
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.22),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showHeader) ...[
            const Row(
              children: [
                Icon(Icons.visibility_outlined,
                    color: AppColors.brand, size: 18),
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
                        if (i != marketCards.length - 1)
                          const SizedBox(height: 8),
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
                          final right = (i + 1) < marketCards.length
                              ? marketCards[i + 1]
                              : null;
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
                          final rowHeight = leftHeight > rightHeight
                              ? leftHeight
                              : rightHeight;

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
    required List<TrackedQuoteRow> rows,
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
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 13),
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
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w600),
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
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isSelected
                  ? color
                  : colorScheme.outline.withValues(alpha: 0.22),
              width: isSelected ? 1.4 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.05),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 17, color: color),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Colors.black45,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_fmtAmount(value)} TL',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
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
    late final List<AccountPreviewRow> rows;
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

  Widget _buildInlineAccountTypePreviewCard() {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: _buildAccountTypePreviewCard(),
    );
  }

  Widget _buildPlannedTodayCard() {
    final hasPlannedContent = plannedIncomeTotal.abs() > _zeroEpsilon ||
        plannedExpenseTotal.abs() > _zeroEpsilon ||
        todayPlans.isNotEmpty;
    if (!hasPlannedContent) return const SizedBox.shrink();

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

  Widget _buildSubscriptionPaymentCard() {
    final hasDueSubscriptions = dueSubscriptionCount > 0;
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () {
          setState(() {
            showSubscriptionPreview = !showSubscriptionPreview;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: showSubscriptionPreview
                  ? Colors.deepOrange.withValues(alpha: 0.45)
                  : colorScheme.outline.withValues(alpha: 0.22),
              width: showSubscriptionPreview ? 1.4 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.05),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.deepOrange.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.payments_outlined,
                  color: Colors.deepOrange,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'SABIT ODEME',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              Text(
                '$dueSubscriptionCount bugun',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: hasDueSubscriptions ? Colors.deepOrange : Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubscriptionPreviewCard() {
    final previewItems = subscriptionPreviewRows;
    final hasDueSubscriptions = dueSubscriptionCount > 0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasDueSubscriptions
              ? Colors.deepOrange.withValues(alpha: 0.22)
              : AppColors.brand.withValues(alpha: 0.16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bugun odenecek $dueSubscriptionCount sabit odeme var.',
            style: TextStyle(
              color: hasDueSubscriptions ? Colors.deepOrange : Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Sadece bugun vadesi gelen sabit odemeler listeleniyor.',
            style: TextStyle(
              color: Colors.blueGrey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (previewItems.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...previewItems.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 5),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: item.isDue ? Colors.deepOrange : AppColors.brand,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.caption,
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      item.dateLabel,
                      style: TextStyle(
                        color: item.isDue ? Colors.deepOrange : AppColors.brand,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _quickActionItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withValues(alpha: 0.14)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 21),
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
      ),
    );
  }

  Widget _quickSheetAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    bool useHalfSheetWidth = true,
  }) {
    final child = Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: color.withValues(alpha: 0.18)),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (!useHalfSheetWidth) return child;
    return SizedBox(
      width: (MediaQuery.of(context).size.width - 56) / 2,
      child: child,
    );
  }

  Widget _quickActionFabItem({
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorScheme.primary,
                    colorScheme.secondary,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.22),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Icon(
                Icons.add,
                color: colorScheme.onPrimary,
                size: 26,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Islem',
              style: TextStyle(
                color: colorScheme.primary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrackedMarketCardData {
  final String title;
  final IconData icon;
  final Color color;
  final List<TrackedQuoteRow> rows;

  const _TrackedMarketCardData({
    required this.title,
    required this.icon,
    required this.color,
    required this.rows,
  });
}
