import '../../../models/cari_transaction.dart';

abstract class CariTransactionRepository {
  Future<List<CariTransaction>> getAll();
  Future<int> addDebtAndGetId({
    required int cariCardId,
    required int accountId,
    required double amount,
    double? quantity,
    double? unitPrice,
    required DateTime date,
    String? description,
  });
  Future<int> addCollectionAndGetId({
    required int cariCardId,
    required int accountId,
    required double amount,
    double? quantity,
    double? unitPrice,
    required DateTime date,
    String? description,
  });
  Future<void> updateTransaction({
    required int transactionId,
    required int cariCardId,
    required int accountId,
    required String type,
    required double amount,
    double? quantity,
    double? unitPrice,
    required DateTime date,
    String? description,
  });
  Future<CariTransaction> deleteAndReturn(int transactionId);
}
