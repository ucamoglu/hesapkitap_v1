import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../screens/account_movements_screen.dart';
import '../screens/accounts_screen.dart';
import '../screens/asset_status_screen.dart';
import '../screens/calendar_transactions_screen.dart';
import '../screens/cari_card_summary_screen.dart';
import '../screens/cari_card_summary_foreign_screen.dart';
import '../screens/cari_cards_screen.dart';
import '../screens/cari_transactions_screen.dart';
import '../screens/crypto_tracking_screen.dart';
import '../screens/currency_tracking_screen.dart';
import '../screens/credit_card_statements_screen.dart';
import '../screens/expense_category_screen.dart';
import '../screens/expense_map_screen.dart';
import '../screens/expense_planning_screen.dart';
import '../screens/financial_analysis_screen.dart';
import '../screens/fixed_incomes_screen.dart';
import '../screens/help_documentation_screen.dart';
import '../screens/income_category_screen.dart';
import '../screens/income_expense_transactions_screen.dart';
import '../screens/income_planning_screen.dart';
import '../screens/investment_tracking_screen.dart';
import '../screens/precious_metal_tracking_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/stock_tracking_screen.dart';
import '../screens/subscriptions_screen.dart';
import '../services/user_profile_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme_helpers.dart';

enum _MenuSection {
  definition,
  transactions,
  analysis,
  cariOperations,
  planning,
  rates,
}

_MenuSection? _lastExpandedSection;

enum _MenuItem {
  profile,
  accounts,
  fixedIncomes,
  subscriptions,
  creditCardStatements,
  financialAnalysis,
  incomeCategories,
  expenseCategories,
  expenseMap,
  cariCards,
  cariTransactionsHistory,
  transactionsHistory,
  accountHistory,
  investmentTracking,
  assetStatus,
  cariSummary,
  cariSummaryForeign,
  incomePlanning,
  expensePlanning,
  calendar,
  currencyTracking,
  metalTracking,
  stockTracking,
  cryptoTracking,
  helpDocumentation,
  about,
}

_MenuItem? _lastSelectedMenuItem;

void rememberDrawerSelectionForScreen(Widget screen) {
  if (screen is ProfileScreen) {
    _lastSelectedMenuItem = _MenuItem.profile;
    _lastExpandedSection = _MenuSection.definition;
    return;
  }
  if (screen is AccountsScreen) {
    _lastSelectedMenuItem = _MenuItem.accounts;
    _lastExpandedSection = _MenuSection.definition;
    return;
  }
  if (screen is FixedIncomesScreen) {
    _lastSelectedMenuItem = _MenuItem.fixedIncomes;
    _lastExpandedSection = _MenuSection.definition;
    return;
  }
  if (screen is SubscriptionsScreen) {
    _lastSelectedMenuItem = _MenuItem.subscriptions;
    _lastExpandedSection = _MenuSection.definition;
    return;
  }
  if (screen is CreditCardStatementsScreen) {
    _lastSelectedMenuItem = _MenuItem.creditCardStatements;
    _lastExpandedSection = _MenuSection.transactions;
    return;
  }
  if (screen is FinancialAnalysisScreen) {
    _lastSelectedMenuItem = _MenuItem.financialAnalysis;
    _lastExpandedSection = _MenuSection.analysis;
    return;
  }
  if (screen is IncomeCategoryScreen) {
    _lastSelectedMenuItem = _MenuItem.incomeCategories;
    _lastExpandedSection = _MenuSection.definition;
    return;
  }
  if (screen is ExpenseCategoryScreen) {
    _lastSelectedMenuItem = _MenuItem.expenseCategories;
    _lastExpandedSection = _MenuSection.definition;
    return;
  }
  if (screen is ExpenseMapScreen) {
    _lastSelectedMenuItem = _MenuItem.expenseMap;
    _lastExpandedSection = null;
    return;
  }
  if (screen is CariCardsScreen) {
    _lastSelectedMenuItem = _MenuItem.cariCards;
    _lastExpandedSection = _MenuSection.cariOperations;
    return;
  }
  if (screen is CariTransactionsScreen) {
    _lastSelectedMenuItem = _MenuItem.cariTransactionsHistory;
    _lastExpandedSection = _MenuSection.cariOperations;
    return;
  }
  if (screen is IncomeExpenseTransactionsScreen) {
    _lastSelectedMenuItem = _MenuItem.transactionsHistory;
    _lastExpandedSection = _MenuSection.transactions;
    return;
  }
  if (screen is AccountMovementsScreen) {
    _lastSelectedMenuItem = _MenuItem.accountHistory;
    _lastExpandedSection = _MenuSection.transactions;
    return;
  }
  if (screen is InvestmentTrackingScreen) {
    _lastSelectedMenuItem = _MenuItem.investmentTracking;
    _lastExpandedSection = _MenuSection.analysis;
    return;
  }
  if (screen is AssetStatusScreen) {
    _lastSelectedMenuItem = _MenuItem.assetStatus;
    _lastExpandedSection = _MenuSection.analysis;
    return;
  }
  if (screen is CariCardSummaryScreen) {
    _lastSelectedMenuItem = _MenuItem.cariSummary;
    _lastExpandedSection = _MenuSection.cariOperations;
    return;
  }
  if (screen is CariCardSummaryForeignScreen) {
    _lastSelectedMenuItem = _MenuItem.cariSummaryForeign;
    _lastExpandedSection = _MenuSection.cariOperations;
    return;
  }
  if (screen is IncomePlanningScreen) {
    _lastSelectedMenuItem = _MenuItem.incomePlanning;
    _lastExpandedSection = _MenuSection.planning;
    return;
  }
  if (screen is ExpensePlanningScreen) {
    _lastSelectedMenuItem = _MenuItem.expensePlanning;
    _lastExpandedSection = _MenuSection.planning;
    return;
  }
  if (screen is CalendarTransactionsScreen) {
    _lastSelectedMenuItem = _MenuItem.calendar;
    _lastExpandedSection = null;
    return;
  }
  if (screen is CurrencyTrackingScreen) {
    _lastSelectedMenuItem = _MenuItem.currencyTracking;
    _lastExpandedSection = _MenuSection.rates;
    return;
  }
  if (screen is PreciousMetalTrackingScreen) {
    _lastSelectedMenuItem = _MenuItem.metalTracking;
    _lastExpandedSection = _MenuSection.rates;
    return;
  }
  if (screen is StockTrackingScreen) {
    _lastSelectedMenuItem = _MenuItem.stockTracking;
    _lastExpandedSection = _MenuSection.rates;
    return;
  }
  if (screen is CryptoTrackingScreen) {
    _lastSelectedMenuItem = _MenuItem.cryptoTracking;
    _lastExpandedSection = _MenuSection.rates;
    return;
  }
  if (screen is HelpDocumentationScreen) {
    _lastSelectedMenuItem = _MenuItem.helpDocumentation;
    _lastExpandedSection = null;
  }
}

void popToDashboard(BuildContext context) {
  Navigator.of(context).popUntil((route) => route.isFirst);
}

// Ust bar ikonlarini tum ekranlarda ayni gorsel dilde tutar.
ButtonStyle _pageBarIconStyle(BuildContext context) {
  final colorScheme = Theme.of(context).colorScheme;
  return IconButton.styleFrom(
    backgroundColor: Colors.white.withValues(alpha: 0.86),
    foregroundColor: colorScheme.onSurface,
    minimumSize: const Size(48, 48),
    padding: EdgeInsets.zero,
    iconSize: 28,
  );
}

IconButton buildBackAction(
  BuildContext context, {
  required VoidCallback onPressed,
  String tooltip = 'Geri',
}) {
  return IconButton(
    style: _pageBarIconStyle(context),
    icon: const Icon(Icons.arrow_back),
    tooltip: tooltip,
    onPressed: onPressed,
  );
}

IconButton buildBarIconAction(
  BuildContext context, {
  required IconData icon,
  required VoidCallback onPressed,
  required String tooltip,
}) {
  return IconButton(
    style: _pageBarIconStyle(context),
    icon: Icon(icon),
    tooltip: tooltip,
    onPressed: onPressed,
  );
}

Widget buildMenuLeading() {
  return Builder(
    builder: (context) => IconButton(
      style: _pageBarIconStyle(context),
      icon: const Icon(Icons.arrow_back),
      tooltip: 'Menü',
      onPressed: () => Scaffold.of(context).openDrawer(),
    ),
  );
}

IconButton buildHomeAction(BuildContext context) {
  return buildBarIconAction(
    context,
    icon: Icons.home_outlined,
    tooltip: 'Ana Ekran',
    onPressed: () => popToDashboard(context),
  );
}

// Bos durum veya yonlendirici aciklamalari tek kart kalibinda toplar.
Widget buildInfoGuideCard(
  BuildContext context, {
  required Color accentColor,
  required IconData icon,
  required String title,
  required String message,
  EdgeInsetsGeometry padding = const EdgeInsets.all(20),
}) {
  final colorScheme = Theme.of(context).colorScheme;

  return Padding(
    padding: padding,
    child: Container(
      constraints: const BoxConstraints(maxWidth: 520),
      decoration: context.surfaceDecoration(
        accent: accentColor,
        fillColor: accentColor.withValues(alpha: 0.10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(22),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: accentColor),
                    const SizedBox(width: 10),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: colorScheme.onSurface.withValues(alpha: 0.82),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Widget buildAppMenuDrawer() {
  return const _AppMenuDrawer();
}

class _AppMenuDrawer extends StatefulWidget {
  const _AppMenuDrawer();

  @override
  State<_AppMenuDrawer> createState() => _AppMenuDrawerState();
}

class _AppMenuDrawerState extends State<_AppMenuDrawer> {
  String _profileName = 'Kullanıcı Profili';
  Uint8List? _profilePhoto;
  final ScrollController _drawerScrollController = ScrollController();
  final GlobalKey _drawerListKey = GlobalKey();
  final Map<_MenuSection, GlobalKey> _sectionKeys = {
    _MenuSection.definition: GlobalKey(),
    _MenuSection.transactions: GlobalKey(),
    _MenuSection.analysis: GlobalKey(),
    _MenuSection.cariOperations: GlobalKey(),
    _MenuSection.planning: GlobalKey(),
    _MenuSection.rates: GlobalKey(),
  };
  final Map<_MenuSection, GlobalKey> _sectionContentKeys = {
    _MenuSection.definition: GlobalKey(),
    _MenuSection.transactions: GlobalKey(),
    _MenuSection.analysis: GlobalKey(),
    _MenuSection.cariOperations: GlobalKey(),
    _MenuSection.planning: GlobalKey(),
    _MenuSection.rates: GlobalKey(),
  };

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await UserProfileService.getProfile();
    if (!mounted) return;

    setState(() {
      if (profile != null) {
        _profileName = '${profile.firstName} ${profile.lastName}'.trim();
        final bytes = profile.photoBytes;
        _profilePhoto = bytes == null ? null : Uint8List.fromList(bytes);
      }
    });
  }

  Future<void> _openScreen(Widget screen) async {
    Navigator.pop(context);
    await Future.delayed(const Duration(milliseconds: 120));
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  void _rememberSelection({
    required _MenuItem item,
    _MenuSection? section,
  }) {
    _lastSelectedMenuItem = item;
    _lastExpandedSection = section;
  }

  void _handleSectionToggle(_MenuSection section) {
    final shouldExpand = _lastExpandedSection != section;
    setState(() {
      _lastExpandedSection = shouldExpand ? section : null;
    });
    if (shouldExpand) {
      _scrollSectionIntoView(section);
    }
  }

  void _scrollSectionIntoView(_MenuSection section) {
    final targetContext = _sectionKeys[section]?.currentContext;
    if (targetContext == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _animateDrawerToSection(_sectionKeys[section]);
      _retryScrollSectionContent(section, attempt: 0);
    });
  }

  void _retryScrollSectionContent(_MenuSection section, {required int attempt}) {
    if (!mounted) return;
    final contentKey = _sectionContentKeys[section];
    final contentContext = contentKey?.currentContext;
    if (contentContext != null) {
      _animateDrawerToSection(_sectionKeys[section]);
      return;
    }
    if (attempt >= 6) {
      _animateDrawerToSection(_sectionKeys[section]);
      return;
    }
    Future<void>.delayed(const Duration(milliseconds: 90), () {
      _retryScrollSectionContent(section, attempt: attempt + 1);
    });
  }

  void _animateDrawerToSection(GlobalKey? key) {
    if (!_drawerScrollController.hasClients || key == null) return;
    final listContext = _drawerListKey.currentContext;
    final targetContext = key.currentContext;
    if (listContext == null || targetContext == null) return;
    final listBox = listContext.findRenderObject() as RenderBox?;
    final targetBox = targetContext.findRenderObject() as RenderBox?;
    if (listBox == null || targetBox == null) return;
    if (!listBox.attached || !targetBox.attached) return;
    final targetOffsetInList =
        targetBox.localToGlobal(Offset.zero, ancestor: listBox).dy;
    final position = _drawerScrollController.position;
    final desiredOffset =
        position.pixels + targetOffsetInList - 12;
    final targetOffset = desiredOffset.clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );
    _drawerScrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _drawerScrollController.dispose();
    super.dispose();
  }

  Future<void> _openProfile() async {
    _rememberSelection(
      item: _MenuItem.profile,
      section: _MenuSection.definition,
    );
    await _openScreen(const ProfileScreen());
  }

  void _openAbout() {
    _rememberSelection(item: _MenuItem.about);
    Navigator.pop(context);
    Future<void>.delayed(const Duration(milliseconds: 120), () {
      if (!mounted) return;
      showAboutDialog(
        context: context,
        applicationName: 'HesapKitap',
        applicationVersion: 'v1',
        children: const [
          Text('Bu uygulama Pagumex Teknoloji tarafından oluşturulmaktadır.'),
        ],
      );
    });
  }

  Future<void> _openHelp() async {
    _rememberSelection(item: _MenuItem.helpDocumentation);
    await _openScreen(const HelpDocumentationScreen());
  }

  Widget _buildHelpFooter() {
    final selected = _lastSelectedMenuItem == _MenuItem.helpDocumentation;
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Material(
        color: selected
            ? colorScheme.primary.withValues(alpha: 0.14)
            : colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: _openHelp,
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
                  child: Icon(
                    Icons.menu_book_outlined,
                    size: 16,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Yardım Dökümanı',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(
                  selected ? Icons.check_circle : Icons.chevron_right,
                  size: 16,
                  color: selected
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAboutFooter() {
    final selected = _lastSelectedMenuItem == _MenuItem.about;
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: Material(
        color: selected
            ? colorScheme.primary.withValues(alpha: 0.12)
            : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: _openAbout,
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
    final colorScheme = Theme.of(context).colorScheme;
    final onPrimary = colorScheme.onPrimary;
    final activeSection = _lastExpandedSection;
    final sectionEntries = <MapEntry<_MenuSection, Widget>>[
      MapEntry(
        _MenuSection.definition,
        _menuSection(
          sectionContentKey: _sectionContentKeys[_MenuSection.definition],
          sectionKey: _sectionKeys[_MenuSection.definition],
          context: context,
          icon: Icons.folder_open,
          color: Colors.blueGrey,
          title: 'Tanım',
          isExpanded: activeSection == _MenuSection.definition,
          onToggle: () => _handleSectionToggle(_MenuSection.definition),
          children: [
            _menuItem(
              context: context,
              item: _MenuItem.accounts,
              icon: Icons.account_balance,
              color: Colors.blueGrey,
              title: 'Hesap Tanım',
              onTap: () {
                _rememberSelection(
                  item: _MenuItem.accounts,
                  section: _MenuSection.definition,
                );
                _openScreen(const AccountsScreen());
              },
            ),
            _menuItem(
              context: context,
              item: _MenuItem.fixedIncomes,
              icon: Icons.savings_outlined,
              color: Colors.green,
              title: 'Sabit Gelirlerim',
              onTap: () {
                _rememberSelection(
                  item: _MenuItem.fixedIncomes,
                  section: _MenuSection.definition,
                );
                _openScreen(const FixedIncomesScreen());
              },
            ),
            _menuItem(
              context: context,
              item: _MenuItem.subscriptions,
              icon: Icons.repeat_on_outlined,
              color: Colors.deepOrange,
              title: 'Sabit Odemelerim',
              onTap: () {
                _rememberSelection(
                  item: _MenuItem.subscriptions,
                  section: _MenuSection.definition,
                );
                _openScreen(const SubscriptionsScreen());
              },
            ),
            _menuItem(
              context: context,
              item: _MenuItem.incomeCategories,
              icon: Icons.category,
              color: AppColors.income,
              title: 'Gelir Kategorileri',
              onTap: () {
                _rememberSelection(
                  item: _MenuItem.incomeCategories,
                  section: _MenuSection.definition,
                );
                _openScreen(const IncomeCategoryScreen());
              },
            ),
            _menuItem(
              context: context,
              item: _MenuItem.expenseCategories,
              icon: Icons.sell,
              color: AppColors.expense,
              title: 'Gider Kategorileri',
              onTap: () {
                _rememberSelection(
                  item: _MenuItem.expenseCategories,
                  section: _MenuSection.definition,
                );
                _openScreen(const ExpenseCategoryScreen());
              },
            ),
          ],
        ),
      ),
      MapEntry(
        _MenuSection.transactions,
        _menuSection(
          sectionContentKey: _sectionContentKeys[_MenuSection.transactions],
          sectionKey: _sectionKeys[_MenuSection.transactions],
          context: context,
          icon: Icons.receipt_long,
          color: AppColors.info,
          title: 'İşlemler',
          isExpanded: activeSection == _MenuSection.transactions,
          onToggle: () => _handleSectionToggle(_MenuSection.transactions),
          children: [
            _menuItem(
              context: context,
              item: _MenuItem.transactionsHistory,
              icon: Icons.swap_vert_circle,
              color: AppColors.info,
              title: 'İşlem Geçmişi',
              onTap: () {
                _rememberSelection(
                  item: _MenuItem.transactionsHistory,
                  section: _MenuSection.transactions,
                );
                _openScreen(const IncomeExpenseTransactionsScreen());
              },
            ),
            _menuItem(
              context: context,
              item: _MenuItem.accountHistory,
              icon: Icons.account_tree_outlined,
              color: Colors.indigo,
              title: 'Hesap Geçmişi',
              onTap: () {
                _rememberSelection(
                  item: _MenuItem.accountHistory,
                  section: _MenuSection.transactions,
                );
                _openScreen(const AccountMovementsScreen());
              },
            ),
            _menuItem(
              context: context,
              item: _MenuItem.creditCardStatements,
              icon: Icons.receipt_long_outlined,
              color: Colors.indigo,
              title: 'Kredi Kartı Ekstreleri',
              onTap: () {
                _rememberSelection(
                  item: _MenuItem.creditCardStatements,
                  section: _MenuSection.transactions,
                );
                _openScreen(const CreditCardStatementsScreen());
              },
            ),
          ],
        ),
      ),
      MapEntry(
        _MenuSection.analysis,
        _menuSection(
          sectionContentKey: _sectionContentKeys[_MenuSection.analysis],
          sectionKey: _sectionKeys[_MenuSection.analysis],
          context: context,
          icon: Icons.query_stats,
          color: AppColors.brand,
          title: 'Analiz',
          isExpanded: activeSection == _MenuSection.analysis,
          onToggle: () => _handleSectionToggle(_MenuSection.analysis),
          children: [
            _menuItem(
              context: context,
              item: _MenuItem.financialAnalysis,
              icon: Icons.query_stats,
              color: AppColors.brand,
              title: 'Finansal Analiz',
              onTap: () {
                _rememberSelection(
                  item: _MenuItem.financialAnalysis,
                  section: _MenuSection.analysis,
                );
                _openScreen(const FinancialAnalysisScreen());
              },
            ),
            _menuItem(
              context: context,
              item: _MenuItem.investmentTracking,
              icon: Icons.analytics_outlined,
              color: Colors.teal,
              title: 'Yatırım Portföyü',
              onTap: () {
                _rememberSelection(
                  item: _MenuItem.investmentTracking,
                  section: _MenuSection.analysis,
                );
                _openScreen(const InvestmentTrackingScreen());
              },
            ),
            _menuItem(
              context: context,
              item: _MenuItem.assetStatus,
              icon: Icons.inventory_2_outlined,
              color: Colors.teal,
              title: 'Finans Özet',
              onTap: () {
                _rememberSelection(
                  item: _MenuItem.assetStatus,
                  section: _MenuSection.analysis,
                );
                _openScreen(const AssetStatusScreen());
              },
            ),
          ],
        ),
      ),
      MapEntry(
        _MenuSection.cariOperations,
        _menuSection(
          sectionContentKey: _sectionContentKeys[_MenuSection.cariOperations],
          sectionKey: _sectionKeys[_MenuSection.cariOperations],
          context: context,
          icon: Icons.people_alt_outlined,
          color: Colors.orange,
          title: 'Cari Kart İşlemleri',
          isExpanded: activeSection == _MenuSection.cariOperations,
          onToggle: () => _handleSectionToggle(_MenuSection.cariOperations),
          children: [
            _menuItem(
              context: context,
              item: _MenuItem.cariCards,
              icon: Icons.badge,
              color: AppColors.brand,
              title: 'Cari Kart Tanım',
              onTap: () {
                _rememberSelection(
                  item: _MenuItem.cariCards,
                  section: _MenuSection.cariOperations,
                );
                _openScreen(const CariCardsScreen());
              },
            ),
            _menuItem(
              context: context,
              item: _MenuItem.cariSummary,
              icon: Icons.circle,
              color: Colors.orange,
              title: 'Cari Kart Özet (TL)',
              onTap: () {
                _rememberSelection(item: _MenuItem.cariSummary);
                _openScreen(const CariCardSummaryScreen());
              },
            ),
            _menuItem(
              context: context,
              item: _MenuItem.cariSummaryForeign,
              icon: Icons.circle,
              color: Colors.deepOrange,
              title: 'Cari Kart Özet (Yabancı Kaynak)',
              onTap: () {
                _rememberSelection(item: _MenuItem.cariSummaryForeign);
                _openScreen(const CariCardSummaryForeignScreen());
              },
            ),
            _menuItem(
              context: context,
              item: _MenuItem.cariTransactionsHistory,
              icon: Icons.swap_vert_circle,
              color: Colors.orange,
              title: 'Cari Kart İşlem Geçmişi',
              onTap: () {
                _rememberSelection(
                  item: _MenuItem.cariTransactionsHistory,
                  section: _MenuSection.cariOperations,
                );
                _openScreen(const CariTransactionsScreen());
              },
            ),
          ],
        ),
      ),
      MapEntry(
        _MenuSection.planning,
        _menuSection(
          sectionContentKey: _sectionContentKeys[_MenuSection.planning],
          sectionKey: _sectionKeys[_MenuSection.planning],
          context: context,
          icon: Icons.event_available,
          color: AppColors.planIncome,
          title: 'Planlamalar',
          isExpanded: activeSection == _MenuSection.planning,
          onToggle: () => _handleSectionToggle(_MenuSection.planning),
          children: [
            _menuItem(
              context: context,
              item: _MenuItem.incomePlanning,
              icon: Icons.event_note,
              color: AppColors.income,
              title: 'Gelir Planlama',
              onTap: () {
                _rememberSelection(
                  item: _MenuItem.incomePlanning,
                  section: _MenuSection.planning,
                );
                _openScreen(const IncomePlanningScreen());
              },
            ),
            _menuItem(
              context: context,
              item: _MenuItem.expensePlanning,
              icon: Icons.event_busy,
              color: AppColors.expense,
              title: 'Gider Planlama',
              onTap: () {
                _rememberSelection(
                  item: _MenuItem.expensePlanning,
                  section: _MenuSection.planning,
                );
                _openScreen(const ExpensePlanningScreen());
              },
            ),
          ],
        ),
      ),
      MapEntry(
        _MenuSection.rates,
        _menuSection(
          sectionContentKey: _sectionContentKeys[_MenuSection.rates],
          sectionKey: _sectionKeys[_MenuSection.rates],
          context: context,
          icon: Icons.currency_exchange,
          color: Colors.teal,
          title: 'Yatırımcı',
          isExpanded: activeSection == _MenuSection.rates,
          onToggle: () => _handleSectionToggle(_MenuSection.rates),
          children: [
            _menuItem(
              context: context,
              item: _MenuItem.currencyTracking,
              icon: Icons.attach_money,
              color: Colors.teal,
              title: 'Döviz Takip',
              onTap: () {
                _rememberSelection(
                  item: _MenuItem.currencyTracking,
                  section: _MenuSection.rates,
                );
                _openScreen(const CurrencyTrackingScreen());
              },
            ),
            _menuItem(
              context: context,
              item: _MenuItem.metalTracking,
              icon: Icons.workspace_premium,
              color: Colors.amber,
              title: 'Kıymetli Maden Takip',
              onTap: () {
                _rememberSelection(
                  item: _MenuItem.metalTracking,
                  section: _MenuSection.rates,
                );
                _openScreen(const PreciousMetalTrackingScreen());
              },
            ),
            _menuItem(
              context: context,
              item: _MenuItem.stockTracking,
              icon: Icons.show_chart,
              color: Colors.green,
              title: 'Borsa Takip',
              onTap: () {
                _rememberSelection(
                  item: _MenuItem.stockTracking,
                  section: _MenuSection.rates,
                );
                _openScreen(const StockTrackingScreen());
              },
            ),
            _menuItem(
              context: context,
              item: _MenuItem.cryptoTracking,
              icon: Icons.currency_bitcoin,
              color: Colors.deepOrange,
              title: 'Kripto Para Takip',
              onTap: () {
                _rememberSelection(
                  item: _MenuItem.cryptoTracking,
                  section: _MenuSection.rates,
                );
                _openScreen(const CryptoTrackingScreen());
              },
            ),
          ],
        ),
      ),
    ];
    final menuWidgets = <Widget>[
      ...sectionEntries.map((entry) => entry.value),
      _menuStandaloneItem(
        context: context,
        item: _MenuItem.expenseMap,
        icon: Icons.map_outlined,
        color: Colors.redAccent,
        title: 'Harcama Haritası',
        onTap: () {
          _rememberSelection(item: _MenuItem.expenseMap);
          _openScreen(const ExpenseMapScreen());
        },
      ),
      _menuStandaloneItem(
        context: context,
        item: _MenuItem.calendar,
        icon: Icons.calendar_month,
        color: AppColors.info,
        title: 'Takvim',
        onTap: () {
          _rememberSelection(item: _MenuItem.calendar);
          _openScreen(const CalendarTransactionsScreen());
        },
      ),
    ];

    return Drawer(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              key: _drawerListKey,
              controller: _drawerScrollController,
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        colorScheme.primary,
                        colorScheme.tertiary,
                      ],
                    ),
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
                              backgroundColor: onPrimary.withValues(alpha: 0.18),
                              backgroundImage: _profilePhoto != null
                                  ? MemoryImage(_profilePhoto!)
                                  : null,
                              child: _profilePhoto == null
                                  ? Icon(Icons.person,
                                      color: onPrimary, size: 30)
                                  : null,
                            ),
                            const SizedBox(width: 10),
                            InkWell(
                              onTap: _openProfile,
                              borderRadius: BorderRadius.circular(18),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: onPrimary.withValues(alpha: 0.42),
                                  ),
                                  color: onPrimary.withValues(alpha: 0.08),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.account_circle,
                                        color: onPrimary, size: 18),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Profil',
                                      style: TextStyle(
                                        color: onPrimary,
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
                          _profileName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: onPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'by Pagumex Teknoloji',
                          style: TextStyle(
                            color: onPrimary.withValues(alpha: 0.78),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                  child: Column(
                    children: menuWidgets,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          _buildHelpFooter(),
          _buildAboutFooter(),
        ],
      ),
    );
  }
}

Widget _menuItem({
  required BuildContext context,
  required _MenuItem item,
  required IconData icon,
  required Color color,
  required String title,
  required VoidCallback onTap,
}) {
  final colorScheme = Theme.of(context).colorScheme;
  final isSelected = _lastSelectedMenuItem == item;

  return Padding(
    padding: const EdgeInsets.only(top: 6),
    child: Material(
      color: isSelected
          ? color
          : color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
          child: Row(
            children: [
              _menuBadgeIcon(icon: icon, color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isSelected ? Colors.white : null,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 18,
                color: isSelected ? Colors.white : colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _menuStandaloneItem({
  required BuildContext context,
  required _MenuItem item,
  required IconData icon,
  required Color color,
  required String title,
  required VoidCallback onTap,
}) {
  final colorScheme = Theme.of(context).colorScheme;
  final isSelected = _lastSelectedMenuItem == item;

  return Container(
    margin: const EdgeInsets.only(bottom: 8),
    decoration: BoxDecoration(
      color: isSelected ? color : Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(
        color: isSelected ? color : colorScheme.outline.withValues(alpha: 0.35),
      ),
      boxShadow: [
        BoxShadow(
          color: colorScheme.shadow.withValues(alpha: 0.05),
          blurRadius: 12,
          offset: const Offset(0, 5),
        ),
      ],
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          child: Row(
            children: [
              _menuBadgeIcon(icon: icon, color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isSelected ? Colors.white : null,
                  ),
                ),
              ),
              if (isSelected)
                const Icon(Icons.check_circle, color: Colors.white, size: 18)
              else
                Icon(
                  Icons.chevron_right,
                  color: colorScheme.onSurfaceVariant,
                  size: 18,
                ),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _menuSection({
  Key? sectionKey,
  Key? sectionContentKey,
  required BuildContext context,
  required IconData icon,
  required Color color,
  required String title,
  required bool isExpanded,
  required VoidCallback onToggle,
  required List<Widget> children,
}) {
  final colorScheme = Theme.of(context).colorScheme;

  return Container(
    key: sectionKey,
    margin: const EdgeInsets.only(bottom: 8),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: colorScheme.outline.withValues(alpha: 0.35)),
      boxShadow: [
        BoxShadow(
          color: colorScheme.shadow.withValues(alpha: 0.05),
          blurRadius: 12,
          offset: const Offset(0, 5),
        ),
      ],
    ),
    child: Material(
      color: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
              child: Row(
                children: [
                  _menuBadgeIcon(icon: icon, color: color),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    child: Icon(
                      Icons.expand_more,
                      color: isExpanded
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          ClipRect(
            child: AnimatedAlign(
              alignment: Alignment.topCenter,
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              heightFactor: isExpanded ? 1 : 0,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                child: Column(
                  key: sectionContentKey,
                  mainAxisSize: MainAxisSize.min,
                  children: children,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _menuBadgeIcon({
  required IconData icon,
  required Color color,
}) {
  return Container(
    width: 34,
    height: 34,
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(11),
    ),
    child: Icon(icon, color: color, size: 17),
  );
}
