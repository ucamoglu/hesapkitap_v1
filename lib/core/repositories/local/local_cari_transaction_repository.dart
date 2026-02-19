import '../../../models/cari_transaction.dart';
import '../../../services/cari_transaction_service.dart';
import '../contracts/cari_transaction_repository.dart';

class LocalCariTransactionRepository implements CariTransactionRepository {
  const LocalCariTransactionRepository();

  @override
  Future<int> addCollectionAndGetId({
    required int cariCardId,
    required int accountId,
    required double amount,
    double? quantity,
    double? unitPrice,
    required DateTime date,
    String? description,
  }) {
    return CariTransactionService.addCollectionAndGetId(
      cariCardId: cariCardId,
      accountId: accountId,
      amount: amount,
      quantity: quantity,
      unitPrice: unitPrice,
      date: date,
      description: description,
    );
  }

  @override
  Future<int> addDebtAndGetId({
    required int cariCardId,
    required int accountId,
    required double amount,
    double? quantity,
    double? unitPrice,
    required DateTime date,
    String? description,
  }) {
    return CariTransactionService.addDebtAndGetId(
      cariCardId: cariCardId,
      accountId: accountId,
      amount: amount,
      quantity: quantity,
      unitPrice: unitPrice,
      date: date,
      description: description,
    );
  }

  @override
  Future<CariTransaction> deleteAndReturn(int transactionId) {
    return CariTransactionService.deleteAndReturn(transactionId);
  }

  @override
  Future<List<CariTransaction>> getAll() {
    return CariTransactionService.getAll();
  }

  @override
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
  }) {
    return CariTransactionService.updateTransaction(
      transactionId: transactionId,
      cariCardId: cariCardId,
      accountId: accountId,
      type: type,
      amount: amount,
      quantity: quantity,
      unitPrice: unitPrice,
      date: date,
      description: description,
    );
  }
}
