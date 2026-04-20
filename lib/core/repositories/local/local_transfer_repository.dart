import '../../../models/transfer_transaction.dart';
import '../../../services/transfer_transaction_service.dart';
import '../../sync/sync_change_tracker.dart';
import '../contracts/transfer_repository.dart';

class LocalTransferRepository implements TransferRepository {
  LocalTransferRepository({
    SyncChangeTracker? changeTracker,
  }) : _changeTracker = changeTracker ?? SyncChangeTracker();

  final SyncChangeTracker _changeTracker;

  @override
  Future<int> addTransfer({
    required int fromAccountId,
    required int toAccountId,
    required double amount,
    required DateTime date,
    String? description,
  }) async {
    final id = await TransferTransactionService.addTransfer(
      fromAccountId: fromAccountId,
      toAccountId: toAccountId,
      amount: amount,
      date: date,
      description: description,
    );
    await _changeTracker.markUpsert(
      entityType: 'transfer_transaction',
      localId: id,
    );
    return id;
  }

  @override
  Future<TransferTransaction> deleteAndReturn(int transactionId) async {
    final deleted = await TransferTransactionService.deleteAndReturn(
      transactionId,
    );
    await _changeTracker.markDelete(
      entityType: 'transfer_transaction',
      localId: transactionId,
    );
    return deleted;
  }

  @override
  Future<List<TransferTransaction>> getAll() {
    return TransferTransactionService.getAll();
  }
}
