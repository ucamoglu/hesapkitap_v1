import '../../../models/finance_transaction.dart';

abstract class FinanceRepository {
  Future<List<FinanceTransaction>> getAll();
  Future<int> addIncomeAndGetId({
    required int accountId,
    required int categoryId,
    required double amount,
    required DateTime date,
    String? description,
    int? incomePlanId,
    int? expensePlanId,
  });
  Future<int> addExpenseAndGetId({
    required int accountId,
    required int categoryId,
    required double amount,
    required DateTime date,
    String? description,
    int? expensePlanId,
  });
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
  });
  Future<FinanceTransaction> deleteAndReturn(int transactionId);
}
