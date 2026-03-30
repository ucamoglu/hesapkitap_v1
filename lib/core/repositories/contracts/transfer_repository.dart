import '../../../models/transfer_transaction.dart';

abstract class TransferRepository {
  Future<List<TransferTransaction>> getAll();

  Future<int> addTransfer({
    required int fromAccountId,
    required int toAccountId,
    required double amount,
    required DateTime date,
    String? description,
  });

  Future<TransferTransaction> deleteAndReturn(int transactionId);
}
