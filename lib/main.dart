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
import 'screens/expense_category_screen.dart';
import 'screens/expense_planning_screen.dart';
import 'screens/calendar_transactions_screen.dart';
import 'services/account_service.dart';
import 'screens/expense_entry_screen.dart';
import 'screens/income_category_screen.dart';
import 'screens/income_entry_screen.dart';
import 'screens/income_expense_transactions_screen.dart';
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
  String profileName = 'Kullanıcı Profili';
  Uint8List? profilePhoto;

  @override
  void initState() {
    super.initState();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    final accounts = await AccountService.getAllAccounts();
    final profile = await UserProfileService.getProfile();
    final displayName = profile == null
        ? 'Kullanıcı Profili'
        : '${profile.firstName} ${profile.lastName}'.trim();
    final photoBytes = profile?.photoBytes;

    setState(() {
      totalAccounts = accounts.length;
      cashBankAccounts = accounts
          .where((a) => a.type == "cash" || a.type == "bank")
          .length;
      investmentAccounts =
          accounts.where((a) => a.type == "investment").length;
      totalBalance = accounts.fold(
        0.0,
        (sum, a) => sum + a.balance,
      );
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
                ListTile(
                  leading: const Icon(Icons.badge, color: AppColors.brand),
                  title: const Text('Cari Kartlar'),
                  onTap: () async {
                    await _openFromDrawer(const CariCardsScreen());
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
                ListTile(
                  leading: const Icon(Icons.people_alt_outlined, color: Colors.orange),
                  title: const Text('Cari Kart Özet'),
                  onTap: () async {
                    await _openFromDrawer(
                      const CariCardSummaryScreen(),
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
        title: const Text("Dashboard"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildCard(
              "Toplam Bakiye (TL)",
              totalBalance.toStringAsFixed(2),
              Icons.attach_money,
            ),
            const SizedBox(height: 12),
            _buildCard(
              "Toplam Hesap",
              totalAccounts.toString(),
              Icons.account_balance,
            ),
            const SizedBox(height: 12),
            _buildCard(
              "Kasa + Banka",
              cashBankAccounts.toString(),
              Icons.account_balance_wallet,
            ),
            const SizedBox(height: 12),
            _buildCard(
              "Yatırım Hesabı",
              investmentAccounts.toString(),
              Icons.trending_up,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(String title, String value, IconData icon) {
    return Card(
      elevation: 4,
      child: ListTile(
        leading: Icon(icon, size: 32, color: AppColors.brand),
        title: Text(title),
        trailing: Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
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
