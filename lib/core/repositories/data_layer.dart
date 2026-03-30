import '../sync/sync_engine.dart';
import '../sync/sync_change_tracker.dart';
import 'contracts/account_repository.dart';
import 'contracts/cari_card_repository.dart';
import 'contracts/cari_transaction_repository.dart';
import 'contracts/expense_category_repository.dart';
import 'contracts/expense_plan_repository.dart';
import 'contracts/finance_repository.dart';
import 'contracts/income_category_repository.dart';
import 'contracts/income_plan_repository.dart';
import 'contracts/investment_repository.dart';
import 'contracts/subscription_repository.dart';
import 'contracts/transfer_repository.dart';
import 'contracts/user_profile_repository.dart';
import 'local/local_account_repository.dart';
import 'local/local_cari_card_repository.dart';
import 'local/local_cari_transaction_repository.dart';
import 'local/local_expense_category_repository.dart';
import 'local/local_expense_plan_repository.dart';
import 'local/local_finance_repository.dart';
import 'local/local_income_category_repository.dart';
import 'local/local_income_plan_repository.dart';
import 'local/local_investment_repository.dart';
import 'local/local_subscription_repository.dart';
import 'local/local_transfer_repository.dart';
import 'local/local_user_profile_repository.dart';

class DataLayer {
  // Hesap, finans ve sync bagimliliklarini tek yerde toplar.
  final AccountRepository accounts;
  final FinanceRepository finance;
  final CariCardRepository cariCards;
  final CariTransactionRepository cariTransactions;
  final ExpenseCategoryRepository expenseCategories;
  final IncomePlanRepository incomePlans;
  final IncomeCategoryRepository incomeCategories;
  final ExpensePlanRepository expensePlans;
  final InvestmentRepository investments;
  final SubscriptionRepository subscriptions;
  final TransferRepository transfers;
  final UserProfileRepository userProfile;
  final SyncEngine syncEngine;

  DataLayer({
    required this.accounts,
    required this.finance,
    required this.cariCards,
    required this.cariTransactions,
    required this.expenseCategories,
    required this.incomePlans,
    required this.incomeCategories,
    required this.expensePlans,
    required this.investments,
    required this.subscriptions,
    required this.transfers,
    required this.userProfile,
    required this.syncEngine,
  });

  factory DataLayer.localOnly() {
    // Bugun tum repository'ler local Isar servislerine bagli calisir.
    final changeTracker = SyncChangeTracker();
    return DataLayer(
      accounts: LocalAccountRepository(changeTracker: changeTracker),
      finance: LocalFinanceRepository(changeTracker: changeTracker),
      cariCards: LocalCariCardRepository(changeTracker: changeTracker),
      cariTransactions: LocalCariTransactionRepository(
        changeTracker: changeTracker,
      ),
      expenseCategories: LocalExpenseCategoryRepository(
        changeTracker: changeTracker,
      ),
      incomePlans: LocalIncomePlanRepository(changeTracker: changeTracker),
      incomeCategories: LocalIncomeCategoryRepository(
        changeTracker: changeTracker,
      ),
      expensePlans: LocalExpensePlanRepository(changeTracker: changeTracker),
      investments: LocalInvestmentRepository(changeTracker: changeTracker),
      subscriptions: LocalSubscriptionRepository(changeTracker: changeTracker),
      transfers: LocalTransferRepository(changeTracker: changeTracker),
      userProfile: LocalUserProfileRepository(changeTracker: changeTracker),
      syncEngine: RemoteSyncEngine(),
    );
  }
}
