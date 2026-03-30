import '../../../models/cari_transaction.dart';
import '../../../services/cari_transaction_service.dart';
import '../../sync/sync_change_tracker.dart';
import '../contracts/cari_transaction_repository.dart';

class LocalCariTransactionRepository implements CariTransactionRepository {
  LocalCariTransactionRepository({
    SyncChangeTracker? changeTracker,
  }) : _changeTracker = changeTracker ?? SyncChangeTracker();

  final SyncChangeTracker _changeTracker;

  @override
  Future<int> addCollectionAndGetId({
    required int cariCardId,
    required int accountId,
    required double amount,
    double? quantity,
    double? unitPrice,
    required DateTime date,
    String? description,
  }) async {
    final id = await CariTransactionService.addCollectionAndGetId(
      cariCardId: cariCardId,
      accountId: accountId,
      amount: amount,
      quantity: quantity,
      unitPrice: unitPrice,
      date: date,
      description: description,
    );
    await _changeTracker.markUpsert(
      entityType: 'cari_transaction',
      localId: id,
    );
    return id;
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
  }) async {
    final id = await CariTransactionService.addDebtAndGetId(
      cariCardId: cariCardId,
      accountId: accountId,
      amount: amount,
      quantity: quantity,
      unitPrice: unitPrice,
      date: date,
      description: description,
    );
    await _changeTracker.markUpsert(
      entityType: 'cari_transaction',
      localId: id,
    );
    return id;
  }

  @override
  Future<CariTransaction> deleteAndReturn(int transactionId) async {
    final deleted = await CariTransactionService.deleteAndReturn(transactionId);
    await _changeTracker.markDelete(
      entityType: 'cari_transaction',
      localId: transactionId,
    );
    return deleted;
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
  }) async {
    await CariTransactionService.updateTransaction(
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
    await _changeTracker.markUpsert(
      entityType: 'cari_transaction',
      localId: transactionId,
    );
  }
}
