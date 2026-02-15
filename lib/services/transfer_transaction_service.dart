import 'package:isar/isar.dart';

import '../database/isar_service.dart';
import '../models/account.dart';
import '../models/transfer_transaction.dart';

class TransferTransactionService {
  static Future<int> addTransfer({
    required int fromAccountId,
    required int toAccountId,
    required double amount,
    required DateTime date,
    String? description,
  }) async {
    if (fromAccountId == toAccountId) {
      throw Exception('Aynı hesaba transfer yapılamaz.');
    }
    if (amount <= 0) {
      throw Exception('Transfer tutarı sıfırdan büyük olmalıdır.');
    }

    final isar = IsarService.isar;
    late int createdId;

    await isar.writeTxn(() async {
      final from = await isar.accounts.get(fromAccountId);
      final to = await isar.accounts.get(toAccountId);
      if (from == null || to == null) {
        throw Exception('Hesap bulunamadı.');
      }

      from.balance -= amount;
      to.balance += amount;

      final tx = TransferTransaction()
        ..fromAccountId = fromAccountId
        ..toAccountId = toAccountId
        ..amount = amount
        ..date = date
        ..description = description?.trim().isEmpty == true
            ? null
            : description?.trim()
        ..createdAt = DateTime.now();

      await isar.accounts.put(from);
      await isar.accounts.put(to);
      createdId = await isar.transferTransactions.put(tx);
    });

    return createdId;
  }

  static Future<List<TransferTransaction>> getAll() async {
    final isar = IsarService.isar;
    final items = await isar.transferTransactions.where().anyId().findAll();
    items.sort((a, b) => b.date.compareTo(a.date));
    return items;
  }

  static Future<TransferTransaction> deleteAndReturn(int transactionId) async {
    final isar = IsarService.isar;
    late TransferTransaction deleted;

    await isar.writeTxn(() async {
      final tx = await isar.transferTransactions.get(transactionId);
      if (tx == null) throw Exception('Transfer işlemi bulunamadı.');

      final from = await isar.accounts.get(tx.fromAccountId);
      final to = await isar.accounts.get(tx.toAccountId);
      if (from == null || to == null) {
        throw Exception('Transfer hesapları bulunamadı.');
      }

      from.balance += tx.amount;
      to.balance -= tx.amount;

      await isar.accounts.put(from);
      await isar.accounts.put(to);
      await isar.transferTransactions.delete(tx.id);
      deleted = tx;
    });

    return deleted;
  }
}
