import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../screens/account_movements_screen.dart';
import '../screens/accounts_screen.dart';
import '../screens/asset_status_screen.dart';
import '../screens/calendar_transactions_screen.dart';
import '../screens/cari_card_summary_screen.dart';
import '../screens/cari_cards_screen.dart';
import '../screens/crypto_tracking_screen.dart';
import '../screens/currency_tracking_screen.dart';
import '../screens/expense_category_screen.dart';
import '../screens/expense_planning_screen.dart';
import '../screens/income_category_screen.dart';
import '../screens/income_expense_transactions_screen.dart';
import '../screens/income_planning_screen.dart';
import '../screens/investment_tracking_screen.dart';
import '../screens/precious_metal_tracking_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/stock_tracking_screen.dart';
import '../services/user_profile_service.dart';
import '../theme/app_colors.dart';

enum _MenuSection { definition, transactions, planning, rates }

_MenuSection? _lastExpandedSection;

enum _MenuItem {
  profile,
  accounts,
  incomeCategories,
  expenseCategories,
  cariCards,
  transactionsHistory,
  accountHistory,
  investmentTracking,
  assetStatus,
  cariSummary,
  incomePlanning,
  expensePlanning,
  calendar,
  currencyTracking,
  metalTracking,
  stockTracking,
  cryptoTracking,
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
  if (screen is CariCardsScreen) {
    _lastSelectedMenuItem = _MenuItem.cariCards;
    _lastExpandedSection = _MenuSection.definition;
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
    _lastExpandedSection = _MenuSection.transactions;
    return;
  }
  if (screen is AssetStatusScreen) {
    _lastSelectedMenuItem = _MenuItem.assetStatus;
    _lastExpandedSection = _MenuSection.transactions;
    return;
  }
  if (screen is CariCardSummaryScreen) {
    _lastSelectedMenuItem = _MenuItem.cariSummary;
    _lastExpandedSection = _MenuSection.transactions;
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
  }
}

void popToDashboard(BuildContext context) {
  Navigator.of(context).popUntil((route) => route.isFirst);
}

Widget buildMenuLeading() {
  return Builder(
    builder: (context) => IconButton(
      icon: const Icon(Icons.arrow_back),
      tooltip: 'Menü',
      onPressed: () => Scaffold.of(context).openDrawer(),
    ),
  );
}

IconButton buildHomeAction(BuildContext context) {
  return IconButton(
    icon: const Icon(Icons.home_outlined),
    tooltip: 'Ana Ekran',
    onPressed: () => popToDashboard(context),
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
          Text('Bu uygulama UC Digital Studio tarafından oluşturulmaktadır.'),
        ],
      );
    });
  }

  Widget _buildAboutFooter() {
    final selected = _lastSelectedMenuItem == _MenuItem.about;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: Material(
        color: selected
            ? AppColors.brand.withValues(alpha: 0.12)
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
    return Drawer(
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
                        backgroundImage:
                            _profilePhoto != null ? MemoryImage(_profilePhoto!) : null,
                        child: _profilePhoto == null
                            ? const Icon(Icons.person, color: Colors.white, size: 30)
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
                    _profileName,
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
            initiallyExpanded: _lastExpandedSection == _MenuSection.definition,
            onExpansionChanged: (expanded) {
              if (expanded) {
                _lastExpandedSection = _MenuSection.definition;
              } else if (_lastExpandedSection == _MenuSection.definition) {
                _lastExpandedSection = null;
              }
            },
            children: [
              _menuItem(
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
              _menuItem(
                item: _MenuItem.cariCards,
                icon: Icons.badge,
                color: AppColors.brand,
                title: 'Cari Kartlar',
                onTap: () {
                  _rememberSelection(
                    item: _MenuItem.cariCards,
                    section: _MenuSection.definition,
                  );
                  _openScreen(const CariCardsScreen());
                },
              ),
            ],
          ),
          ExpansionTile(
            leading: const Icon(Icons.receipt_long, color: AppColors.info),
            title: const Text('İşlemler'),
            initiallyExpanded: _lastExpandedSection == _MenuSection.transactions,
            onExpansionChanged: (expanded) {
              if (expanded) {
                _lastExpandedSection = _MenuSection.transactions;
              } else if (_lastExpandedSection == _MenuSection.transactions) {
                _lastExpandedSection = null;
              }
            },
            children: [
              _menuItem(
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
                item: _MenuItem.investmentTracking,
                icon: Icons.analytics_outlined,
                color: Colors.teal,
                title: 'Yatırım Portföyü',
                onTap: () {
                  _rememberSelection(
                    item: _MenuItem.investmentTracking,
                    section: _MenuSection.transactions,
                  );
                  _openScreen(const InvestmentTrackingScreen());
                },
              ),
              _menuItem(
                item: _MenuItem.assetStatus,
                icon: Icons.inventory_2_outlined,
                color: Colors.teal,
                title: 'Finans Özet',
                onTap: () {
                  _rememberSelection(
                    item: _MenuItem.assetStatus,
                    section: _MenuSection.transactions,
                  );
                  _openScreen(const AssetStatusScreen());
                },
              ),
              _menuItem(
                item: _MenuItem.cariSummary,
                icon: Icons.people_alt_outlined,
                color: Colors.orange,
                title: 'Cari Kart Özet',
                onTap: () {
                  _rememberSelection(
                    item: _MenuItem.cariSummary,
                    section: _MenuSection.transactions,
                  );
                  _openScreen(const CariCardSummaryScreen());
                },
              ),
            ],
          ),
          ExpansionTile(
            leading: const Icon(Icons.event_available, color: AppColors.planIncome),
            title: const Text('Planlamalar'),
            initiallyExpanded: _lastExpandedSection == _MenuSection.planning,
            onExpansionChanged: (expanded) {
              if (expanded) {
                _lastExpandedSection = _MenuSection.planning;
              } else if (_lastExpandedSection == _MenuSection.planning) {
                _lastExpandedSection = null;
              }
            },
            children: [
              _menuItem(
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
          ListTile(
            leading: const Icon(Icons.calendar_month, color: AppColors.info),
            title: const Text('Takvim'),
            selected: _lastSelectedMenuItem == _MenuItem.calendar,
            selectedTileColor: Colors.black.withValues(alpha: 0.05),
            onTap: () {
              _rememberSelection(item: _MenuItem.calendar);
              _openScreen(const CalendarTransactionsScreen());
            },
          ),
          ExpansionTile(
            leading: const Icon(Icons.currency_exchange, color: Colors.teal),
            title: const Text('Yatırımcı'),
            initiallyExpanded: _lastExpandedSection == _MenuSection.rates,
            onExpansionChanged: (expanded) {
              if (expanded) {
                _lastExpandedSection = _MenuSection.rates;
              } else if (_lastExpandedSection == _MenuSection.rates) {
                _lastExpandedSection = null;
              }
            },
            children: [
              _menuItem(
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
              ],
            ),
          ),
          const Divider(height: 1),
          _buildAboutFooter(),
        ],
      ),
    );
  }
}

Widget _menuItem({
  required _MenuItem item,
  required IconData icon,
  required Color color,
  required String title,
  required VoidCallback onTap,
}) {
  return ListTile(
    leading: Icon(icon, color: color),
    title: Text(title),
    selected: _lastSelectedMenuItem == item,
    selectedTileColor: Colors.black.withValues(alpha: 0.05),
    onTap: onTap,
  );
}
