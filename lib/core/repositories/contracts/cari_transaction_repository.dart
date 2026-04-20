import '../../../models/cari_transaction.dart';

abstract class CariTransactionRepository {
  // Tum cari hareketleri getirir.
  Future<List<CariTransaction>> getAll();
  // Borc hareketi ekler ve olusan ID'yi dondurur.
  Future<int> addDebtAndGetId({
    required int cariCardId,
    required int accountId,
    required double amount,
    double? quantity,
    double? unitPrice,
    required DateTime date,
    String? description,
  });
  // Tahsilat hareketi ekler ve olusan ID'yi dondurur.
  Future<int> addCollectionAndGetId({
    required int cariCardId,
    required int accountId,
    required double amount,
    double? quantity,
    double? unitPrice,
    required DateTime date,
    String? description,
  });
  // Cari hareketi gunceller.
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
  // Cari hareketi geri sararak siler.
  Future<CariTransaction> deleteAndReturn(int transactionId);
}
