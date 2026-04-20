import '../../../models/finance_transaction.dart';
import '../../../services/finance_transaction_service.dart';
import '../../sync/sync_change_tracker.dart';
import '../contracts/finance_repository.dart';

class LocalFinanceRepository implements FinanceRepository {
  LocalFinanceRepository({
    SyncChangeTracker? changeTracker,
  }) : _changeTracker = changeTracker ?? SyncChangeTracker();

  final SyncChangeTracker _changeTracker;

  @override
  Future<int> addExpenseAndGetId({
    required int accountId,
    required int categoryId,
    required double amount,
    required DateTime date,
    double? latitude,
    double? longitude,
    String? description,
    int? expensePlanId,
    bool syncCreditCardStatement = true,
  }) async {
    final id = await FinanceTransactionService.addExpenseAndGetId(
      accountId: accountId,
      categoryId: categoryId,
      amount: amount,
      date: date,
      latitude: latitude,
      longitude: longitude,
      description: description,
      expensePlanId: expensePlanId,
      syncCreditCardStatement: syncCreditCardStatement,
    );
    await _changeTracker.markUpsert(
      entityType: 'finance_transaction',
      localId: id,
    );
    return id;
  }

  @override
  Future<int> addIncomeAndGetId({
    required int accountId,
    required int categoryId,
    required double amount,
    required DateTime date,
    double? latitude,
    double? longitude,
    String? description,
    int? incomePlanId,
    int? expensePlanId,
  }) async {
    final id = await FinanceTransactionService.addIncomeAndGetId(
      accountId: accountId,
      categoryId: categoryId,
      amount: amount,
      date: date,
      latitude: latitude,
      longitude: longitude,
      description: description,
      incomePlanId: incomePlanId,
      expensePlanId: expensePlanId,
    );
    await _changeTracker.markUpsert(
      entityType: 'finance_transaction',
      localId: id,
    );
    return id;
  }

  @override
  Future<FinanceTransaction> deleteAndReturn(int transactionId) async {
    final deleted = await FinanceTransactionService.deleteAndReturn(transactionId);
    await _changeTracker.markDelete(
      entityType: 'finance_transaction',
      localId: transactionId,
    );
    return deleted;
  }

  @override
  Future<List<FinanceTransaction>> getAll() {
    return FinanceTransactionService.getAll();
  }

  @override
  Future<void> updateTransaction({
    required int transactionId,
    required int accountId,
    required int categoryId,
    required String type,
    required double amount,
    required DateTime date,
    double? latitude,
    double? longitude,
    String? description,
    int? incomePlanId,
    int? expensePlanId,
  }) async {
    await FinanceTransactionService.updateTransaction(
      transactionId: transactionId,
      accountId: accountId,
      categoryId: categoryId,
      type: type,
      amount: amount,
      date: date,
      latitude: latitude,
      longitude: longitude,
      description: description,
      incomePlanId: incomePlanId,
      expensePlanId: expensePlanId,
    );
    await _changeTracker.markUpsert(
      entityType: 'finance_transaction',
      localId: transactionId,
    );
  }
}
