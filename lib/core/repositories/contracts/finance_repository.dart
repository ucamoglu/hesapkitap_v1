import '../../../models/finance_transaction.dart';

abstract class FinanceRepository {
  // Tum gelir/gider hareketlerini getirir.
  Future<List<FinanceTransaction>> getAll();
  // Gelir hareketi ekler.
  Future<int> addIncomeAndGetId({
    required int accountId,
    required int categoryId,
    required double amount,
    required DateTime date,
    String? description,
    int? incomePlanId,
    int? expensePlanId,
  });
  // Gider hareketi ekler.
  Future<int> addExpenseAndGetId({
    required int accountId,
    required int categoryId,
    required double amount,
    required DateTime date,
    String? description,
    int? expensePlanId,
  });
  // Finans hareketini gunceller.
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
  // Finans hareketini geri sararak siler.
  Future<FinanceTransaction> deleteAndReturn(int transactionId);
}
