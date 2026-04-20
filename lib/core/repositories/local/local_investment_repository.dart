import '../../../models/investment_transaction.dart';
import '../../../services/investment_transaction_service.dart';
import '../../sync/sync_change_tracker.dart';
import '../contracts/investment_repository.dart';

class LocalInvestmentRepository implements InvestmentRepository {
  LocalInvestmentRepository({
    SyncChangeTracker? changeTracker,
  }) : _changeTracker = changeTracker ?? SyncChangeTracker();

  final SyncChangeTracker _changeTracker;

  @override
  Future<int> addAndGetId({
    required int investmentAccountId,
    required int cashAccountId,
    required String symbol,
    required String type,
    required double quantity,
    required double unitPrice,
    required double total,
    required DateTime date,
    bool syncCreditCardStatement = true,
  }) async {
    final id = await InvestmentTransactionService.addAndGetId(
      investmentAccountId: investmentAccountId,
      cashAccountId: cashAccountId,
      symbol: symbol,
      type: type,
      quantity: quantity,
      unitPrice: unitPrice,
      total: total,
      date: date,
      syncCreditCardStatement: syncCreditCardStatement,
    );
    await _changeTracker.markUpsert(
      entityType: 'investment_transaction',
      localId: id,
    );
    return id;
  }

  @override
  Future<void> deleteAndReturn(int transactionId) async {
    await InvestmentTransactionService.deleteAndReturn(transactionId);
    await _changeTracker.markDelete(
      entityType: 'investment_transaction',
      localId: transactionId,
    );
  }

  @override
  Future<List<InvestmentTransaction>> getAll() {
    return InvestmentTransactionService.getAll();
  }

  @override
  Future<FifoSellPreview> previewSell({
    required int investmentAccountId,
    required String symbol,
    required double sellQuantity,
    required double sellUnitPrice,
  }) {
    return InvestmentTransactionService.previewSell(
      investmentAccountId: investmentAccountId,
      symbol: symbol,
      sellQuantity: sellQuantity,
      sellUnitPrice: sellUnitPrice,
    );
  }

  @override
  Future<void> updateTransaction({
    required int transactionId,
    required int investmentAccountId,
    required int cashAccountId,
    required String symbol,
    required String type,
    required double quantity,
    required double unitPrice,
    required double total,
    required DateTime date,
  }) async {
    await InvestmentTransactionService.updateTransaction(
      transactionId: transactionId,
      investmentAccountId: investmentAccountId,
      cashAccountId: cashAccountId,
      symbol: symbol,
      type: type,
      quantity: quantity,
      unitPrice: unitPrice,
      total: total,
      date: date,
    );
    await _changeTracker.markUpsert(
      entityType: 'investment_transaction',
      localId: transactionId,
    );
  }
}
