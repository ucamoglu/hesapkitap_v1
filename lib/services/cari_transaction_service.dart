import 'package:isar/isar.dart';

import '../database/isar_service.dart';
import '../models/account.dart';
import '../models/cari_transaction.dart';
import '../models/transaction_attachment.dart';

class CariTransactionService {
  static Future<List<CariTransaction>> getAll() async {
    final isar = IsarService.isar;
    final items = await isar.cariTransactions.where().anyId().findAll();
    items.sort((a, b) => b.date.compareTo(a.date));
    return items;
  }

  static Future<void> addDebt({
    required int cariCardId,
    required int accountId,
    required double amount,
    double? quantity,
    double? unitPrice,
    required DateTime date,
    String? description,
  }) async {
    await addDebtAndGetId(
      cariCardId: cariCardId,
      accountId: accountId,
      amount: amount,
      quantity: quantity,
      unitPrice: unitPrice,
      date: date,
      description: description,
    );
  }

  static Future<int> addDebtAndGetId({
    required int cariCardId,
    required int accountId,
    required double amount,
    double? quantity,
    double? unitPrice,
    required DateTime date,
    String? description,
  }) async {
    final isar = IsarService.isar;
    late int createdId;

    await isar.writeTxn(() async {
      final account = await isar.accounts.get(accountId);
      if (account == null) {
        throw Exception('Hesap bulunamadı.');
      }

      final tx = CariTransaction()
        ..cariCardId = cariCardId
        ..accountId = accountId
        ..type = 'debt'
        ..amount = amount
        ..quantity = quantity
        ..unitPrice = unitPrice
        ..date = date
        ..description = description?.trim().isEmpty == true
            ? null
            : description?.trim()
        ..createdAt = DateTime.now();

      account.balance -= amount;

      createdId = await isar.cariTransactions.put(tx);
      await isar.accounts.put(account);
    });

    return createdId;
  }

  static Future<void> addCollection({
    required int cariCardId,
    required int accountId,
    required double amount,
    double? quantity,
    double? unitPrice,
    required DateTime date,
    String? description,
  }) async {
    await addCollectionAndGetId(
      cariCardId: cariCardId,
      accountId: accountId,
      amount: amount,
      quantity: quantity,
      unitPrice: unitPrice,
      date: date,
      description: description,
    );
  }

  static Future<int> addCollectionAndGetId({
    required int cariCardId,
    required int accountId,
    required double amount,
    double? quantity,
    double? unitPrice,
    required DateTime date,
    String? description,
  }) async {
    final isar = IsarService.isar;
    late int createdId;

    await isar.writeTxn(() async {
      final account = await isar.accounts.get(accountId);
      if (account == null) {
        throw Exception('Hesap bulunamadı.');
      }

      final tx = CariTransaction()
        ..cariCardId = cariCardId
        ..accountId = accountId
        ..type = 'collection'
        ..amount = amount
        ..quantity = quantity
        ..unitPrice = unitPrice
        ..date = date
        ..description = description?.trim().isEmpty == true
            ? null
            : description?.trim()
        ..createdAt = DateTime.now();

      account.balance += amount;

      createdId = await isar.cariTransactions.put(tx);
      await isar.accounts.put(account);
    });

    return createdId;
  }

  static Future<void> updateTransaction({
    required int transactionId,
    required int cariCardId,
    required int accountId,
    required String type, // debt / collection
    required double amount,
    double? quantity,
    double? unitPrice,
    required DateTime date,
    String? description,
  }) async {
    final isar = IsarService.isar;

    await isar.writeTxn(() async {
      final oldTx = await isar.cariTransactions.get(transactionId);
      if (oldTx == null) throw Exception('Cari işlem bulunamadı.');

      final oldType = oldTx.type;
      final oldAmount = oldTx.amount;

      final oldAccount = await isar.accounts.get(oldTx.accountId);
      if (oldAccount == null) throw Exception('Hesap bulunamadı.');

      Account? newAccount;
      if (oldTx.accountId != accountId) {
        newAccount = await isar.accounts.get(accountId);
        if (newAccount == null) throw Exception('Hesap bulunamadı.');
      }

      if (newAccount == null) {
        if (oldType == 'collection') {
          oldAccount.balance -= oldAmount;
        } else {
          oldAccount.balance += oldAmount;
        }
        if (type == 'collection') {
          oldAccount.balance += amount;
        } else {
          oldAccount.balance -= amount;
        }
        await isar.accounts.put(oldAccount);
      } else {
        if (oldType == 'collection') {
          oldAccount.balance -= oldAmount;
        } else {
          oldAccount.balance += oldAmount;
        }
        if (type == 'collection') {
          newAccount.balance += amount;
        } else {
          newAccount.balance -= amount;
        }
        await isar.accounts.put(oldAccount);
        await isar.accounts.put(newAccount);
      }

      oldTx
        ..cariCardId = cariCardId
        ..accountId = accountId
        ..type = type
        ..amount = amount
        ..quantity = quantity
        ..unitPrice = unitPrice
        ..date = date
        ..description = description?.trim().isEmpty == true
            ? null
            : description?.trim();

      await isar.cariTransactions.put(oldTx);
    });
  }

  static Future<CariTransaction> deleteAndReturn(int transactionId) async {
    final isar = IsarService.isar;
    late CariTransaction deleted;

    await isar.writeTxn(() async {
      final tx = await isar.cariTransactions.get(transactionId);
      if (tx == null) throw Exception('Cari işlem bulunamadı.');

      final account = await isar.accounts.get(tx.accountId);
      if (account == null) throw Exception('Hesap bulunamadı.');

      if (tx.type == 'collection') {
        account.balance -= tx.amount;
      } else {
        account.balance += tx.amount;
      }
      await isar.accounts.put(account);
      final attachmentIds = await isar.transactionAttachments
          .where()
          .filter()
          .ownerTypeEqualTo('cari')
          .and()
          .ownerIdEqualTo(tx.id)
          .idProperty()
          .findAll();
      if (attachmentIds.isNotEmpty) {
        await isar.transactionAttachments.deleteAll(attachmentIds);
      }
      await isar.cariTransactions.delete(tx.id);
      deleted = tx;
    });

    return deleted;
  }
}
