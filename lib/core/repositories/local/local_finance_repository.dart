import '../../../models/finance_transaction.dart';
import '../../../services/finance_transaction_service.dart';
import '../contracts/finance_repository.dart';

class LocalFinanceRepository implements FinanceRepository {
  const LocalFinanceRepository();

  @override
  Future<int> addExpenseAndGetId({
    required int accountId,
    required int categoryId,
    required double amount,
    required DateTime date,
    String? description,
    int? expensePlanId,
  }) {
    return FinanceTransactionService.addExpenseAndGetId(
      accountId: accountId,
      categoryId: categoryId,
      amount: amount,
      date: date,
      description: description,
      expensePlanId: expensePlanId,
    );
  }

  @override
  Future<int> addIncomeAndGetId({
    required int accountId,
    required int categoryId,
    required double amount,
    required DateTime date,
    String? description,
    int? incomePlanId,
    int? expensePlanId,
  }) {
    return FinanceTransactionService.addIncomeAndGetId(
      accountId: accountId,
      categoryId: categoryId,
      amount: amount,
      date: date,
      description: description,
      incomePlanId: incomePlanId,
      expensePlanId: expensePlanId,
    );
  }

  @override
  Future<FinanceTransaction> deleteAndReturn(int transactionId) {
    return FinanceTransactionService.deleteAndReturn(transactionId);
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
    String? description,
    int? incomePlanId,
    int? expensePlanId,
  }) {
    return FinanceTransactionService.updateTransaction(
      transactionId: transactionId,
      accountId: accountId,
      categoryId: categoryId,
      type: type,
      amount: amount,
      date: date,
      description: description,
      incomePlanId: incomePlanId,
      expensePlanId: expensePlanId,
    );
  }
}
