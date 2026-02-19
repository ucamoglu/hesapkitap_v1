import '../sync/sync_engine.dart';
import 'contracts/account_repository.dart';
import 'contracts/cari_card_repository.dart';
import 'contracts/cari_transaction_repository.dart';
import 'contracts/finance_repository.dart';
import 'contracts/investment_repository.dart';
import 'local/local_account_repository.dart';
import 'local/local_cari_card_repository.dart';
import 'local/local_cari_transaction_repository.dart';
import 'local/local_finance_repository.dart';
import 'local/local_investment_repository.dart';

class DataLayer {
  final AccountRepository accounts;
  final FinanceRepository finance;
  final CariCardRepository cariCards;
  final CariTransactionRepository cariTransactions;
  final InvestmentRepository investments;
  final SyncEngine syncEngine;

  const DataLayer({
    required this.accounts,
    required this.finance,
    required this.cariCards,
    required this.cariTransactions,
    required this.investments,
    required this.syncEngine,
  });

  factory DataLayer.localOnly() {
    return const DataLayer(
      accounts: LocalAccountRepository(),
      finance: LocalFinanceRepository(),
      cariCards: LocalCariCardRepository(),
      cariTransactions: LocalCariTransactionRepository(),
      investments: LocalInvestmentRepository(),
      syncEngine: NoopSyncEngine(),
    );
  }
}
