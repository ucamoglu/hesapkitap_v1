import 'package:isar/isar.dart';

import '../database/isar_service.dart';
import '../models/account.dart';
import '../models/expense_plan.dart';
import '../models/finance_transaction.dart';
import '../models/income_plan.dart';
import '../models/transaction_attachment.dart';

class FinanceTransactionService {
  static Future<List<FinanceTransaction>> getAll() async {
    final isar = IsarService.isar;
    final items = await isar.financeTransactions.where().anyId().findAll();
    items.sort((a, b) => b.date.compareTo(a.date));
    return items;
  }

  static Future<void> addIncome({
    required int accountId,
    required int categoryId,
    required double amount,
    required DateTime date,
    String? description,
    int? incomePlanId,
    int? expensePlanId,
  }) async {
    await addIncomeAndGetId(
      accountId: accountId,
      categoryId: categoryId,
      amount: amount,
      date: date,
      description: description,
      incomePlanId: incomePlanId,
      expensePlanId: expensePlanId,
    );
  }

  static Future<int> addIncomeAndGetId({
    required int accountId,
    required int categoryId,
    required double amount,
    required DateTime date,
    String? description,
    int? incomePlanId,
    int? expensePlanId,
  }) async {
    final isar = IsarService.isar;
    late int createdId;

    await isar.writeTxn(() async {
      final account = await isar.accounts.get(accountId);
      if (account == null) {
        throw Exception("Hesap bulunamadı.");
      }

      final tx = FinanceTransaction()
        ..accountId = accountId
        ..categoryId = categoryId
        ..type = "income"
        ..amount = amount
        ..date = date
        ..description = description?.trim().isEmpty == true
            ? null
            : description?.trim()
        ..incomePlanId = incomePlanId
        ..expensePlanId = expensePlanId
        ..createdAt = DateTime.now();

      account.balance += amount;

      createdId = await isar.financeTransactions.put(tx);
      await isar.accounts.put(account);
    });

    return createdId;
  }

  static Future<void> addExpense({
    required int accountId,
    required int categoryId,
    required double amount,
    required DateTime date,
    String? description,
    int? expensePlanId,
  }) async {
    await addExpenseAndGetId(
      accountId: accountId,
      categoryId: categoryId,
      amount: amount,
      date: date,
      description: description,
      expensePlanId: expensePlanId,
    );
  }

  static Future<int> addExpenseAndGetId({
    required int accountId,
    required int categoryId,
    required double amount,
    required DateTime date,
    String? description,
    int? expensePlanId,
  }) async {
    final isar = IsarService.isar;
    late int createdId;

    await isar.writeTxn(() async {
      final account = await isar.accounts.get(accountId);
      if (account == null) {
        throw Exception("Hesap bulunamadı.");
      }

      final tx = FinanceTransaction()
        ..accountId = accountId
        ..categoryId = categoryId
        ..type = "expense"
        ..amount = amount
        ..date = date
        ..description = description?.trim().isEmpty == true
            ? null
            : description?.trim()
        ..incomePlanId = null
        ..expensePlanId = expensePlanId
        ..createdAt = DateTime.now();

      account.balance -= amount;

      createdId = await isar.financeTransactions.put(tx);
      await isar.accounts.put(account);
    });

    return createdId;
  }

  static Future<void> deleteIncomeAndRevertBalance(int transactionId) async {
    final isar = IsarService.isar;

    await isar.writeTxn(() async {
      final tx = await isar.financeTransactions.get(transactionId);
      if (tx == null) {
        throw Exception('İşlem bulunamadı.');
      }
      if (tx.type != 'income') {
        throw Exception('Sadece gelir işlemi geri alınabilir.');
      }

      final account = await isar.accounts.get(tx.accountId);
      if (account == null) {
        throw Exception('İşlem hesabı bulunamadı.');
      }

      account.balance -= tx.amount;
      await isar.accounts.put(account);
      await isar.financeTransactions.delete(transactionId);
    });
  }

  static Future<void> updateTransaction({
    required int transactionId,
    required int accountId,
    required int categoryId,
    required String type,
    required double amount,
    required DateTime date,
    String? description,
    int? incomePlanId,
    int? expensePlanId,
  }) async {
    final isar = IsarService.isar;

    await isar.writeTxn(() async {
      final oldTx = await isar.financeTransactions.get(transactionId);
      if (oldTx == null) throw Exception('İşlem bulunamadı.');
      final oldType = oldTx.type;
      final oldAmount = oldTx.amount;

      final oldAccount = await isar.accounts.get(oldTx.accountId);
      if (oldAccount == null) {
        throw Exception('Hesap bulunamadı.');
      }

      Account? newAccount;
      if (oldTx.accountId != accountId) {
        newAccount = await isar.accounts.get(accountId);
        if (newAccount == null) throw Exception('Hesap bulunamadı.');
      }

      oldTx
        ..accountId = accountId
        ..categoryId = categoryId
        ..type = type
        ..amount = amount
        ..date = date
        ..description = description?.trim().isEmpty == true
            ? null
            : description?.trim()
        ..incomePlanId = incomePlanId
        ..expensePlanId = expensePlanId;

      if (newAccount == null) {
        if (oldType == 'income') {
          oldAccount.balance -= oldAmount;
        } else {
          oldAccount.balance += oldAmount;
        }
        if (type == 'income') {
          oldAccount.balance += amount;
        } else {
          oldAccount.balance -= amount;
        }
        await isar.accounts.put(oldAccount);
      } else {
        if (oldType == 'income') {
          oldAccount.balance -= oldAmount;
        } else {
          oldAccount.balance += oldAmount;
        }
        if (type == 'income') {
          newAccount.balance += amount;
        } else {
          newAccount.balance -= amount;
        }
        await isar.accounts.put(oldAccount);
        await isar.accounts.put(newAccount);
      }

      await isar.financeTransactions.put(oldTx);
    });
  }

  static Future<FinanceTransaction> deleteAndReturn(int transactionId) async {
    final isar = IsarService.isar;
    late FinanceTransaction deleted;

    await isar.writeTxn(() async {
      final tx = await isar.financeTransactions.get(transactionId);
      if (tx == null) throw Exception('İşlem bulunamadı.');

      final account = await isar.accounts.get(tx.accountId);
      if (account == null) throw Exception('Hesap bulunamadı.');

      if (tx.type == 'income') {
        account.balance -= tx.amount;
      } else {
        account.balance += tx.amount;
      }

      if (tx.incomePlanId != null) {
        final plan = await isar.incomePlans.get(tx.incomePlanId!);
        if (plan != null) {
          plan
            ..nextDueDate = DateTime(tx.date.year, tx.date.month, tx.date.day)
            ..isActive = true;
          await isar.incomePlans.put(plan);
        }
      }
      if (tx.expensePlanId != null) {
        final plan = await isar.expensePlans.get(tx.expensePlanId!);
        if (plan != null) {
          plan
            ..nextDueDate = DateTime(tx.date.year, tx.date.month, tx.date.day)
            ..isActive = true;
          await isar.expensePlans.put(plan);
        }
      }

      await isar.accounts.put(account);
      final attachmentIds = await isar.transactionAttachments
          .where()
          .filter()
          .ownerTypeEqualTo('finance')
          .and()
          .ownerIdEqualTo(tx.id)
          .idProperty()
          .findAll();
      if (attachmentIds.isNotEmpty) {
        await isar.transactionAttachments.deleteAll(attachmentIds);
      }
      await isar.financeTransactions.delete(tx.id);
      deleted = tx;
    });

    return deleted;
  }
}
