import 'package:isar/isar.dart';

import '../database/isar_service.dart';
import '../models/account.dart';
import '../models/credit_card_installment.dart';
import '../models/expense_plan.dart';
import '../models/finance_transaction.dart';
import '../models/income_plan.dart';
import '../models/transaction_attachment.dart';
import 'credit_card_installment_service.dart';
import 'credit_card_statement_service.dart';

class FinanceTransactionService {
  static void _validateFinanceType(String type) {
    if (type != 'income' && type != 'expense') {
      throw Exception('Geçersiz gelir/gider işlem türü.');
    }
  }

  static void _validateFinanceAccount(Account account, {required String type}) {
    if (account.type == 'investment') {
      throw Exception('Gelir/Gider işlemleri yatırım hesabına kaydedilemez.');
    }
    if (!account.isActive) {
      throw Exception('Pasif hesapta işlem yapılamaz.');
    }
    if (account.isCreditCard && type != 'expense') {
      throw Exception('Kredi kartına yalnızca gider işlemi kaydedilebilir.');
    }
  }

  static void _revertBalanceImpact({
    required Account account,
    required String type,
    required double amount,
  }) {
    if (type == 'income') {
      account.balance -= amount;
      return;
    }
    account.balance += amount;
  }

  static void _applyBalanceImpact({
    required Account account,
    required String type,
    required double amount,
  }) {
    if (type == 'income') {
      if (amount <= 0) {
        throw Exception('Gelir tutarı sıfırdan büyük olmalıdır.');
      }
      account.balance += amount;
      return;
    }

    if (amount <= 0) {
      throw Exception('Gider tutarı sıfırdan büyük olmalıdır.');
    }
    if (!account.isCreditCard && account.balance + 1e-9 < amount) {
      throw Exception('Hesap bakiyesi gider tutarı için yetersiz.');
    }
    account.balance -= amount;
  }

  /// Gelir ve gider hareketlerini tarihe gore yeni->eski sirada dondurur.
  static Future<List<FinanceTransaction>> getAll() async {
    final isar = IsarService.isar;
    final items = await isar.financeTransactions.where().anyId().findAll();
    items.sort((a, b) => b.date.compareTo(a.date));
    return items;
  }

  /// Gelir ekleme icin ID donmeyen kolay sarmalayici metottur.
  static Future<void> addIncome({
    required int accountId,
    required int categoryId,
    required double amount,
    required DateTime date,
    double? latitude,
    double? longitude,
    String? description,
    int? incomePlanId,
    int? expensePlanId,
  }) async {
    await addIncomeAndGetId(
      accountId: accountId,
      categoryId: categoryId,
      amount: amount,
      date: date,
      latitude: latitude,
      longitude: longitude,
      description: description,
      incomePlanId: incomePlanId,
      expensePlanId: expensePlanId,
    );
  }

  /// Gelir hareketini ekler ve hesap bakiyesini ayni transaction icinde artirir.
  static Future<int> addIncomeAndGetId({
    required int accountId,
    required int categoryId,
    required double amount,
    required DateTime date,
    double? latitude,
    double? longitude,
    String? description,
    int? incomePlanId,
    int? expensePlanId,
  }) async {
    _validateFinanceType('income');
    final isar = IsarService.isar;
    late int createdId;

    await isar.writeTxn(() async {
      final account = await isar.accounts.get(accountId);
      if (account == null) {
        throw Exception("Hesap bulunamadı.");
      }
      _validateFinanceAccount(account, type: 'income');
      if (amount <= 0) {
        throw Exception('Gelir tutarı sıfırdan büyük olmalıdır.');
      }

      final tx = FinanceTransaction()
        ..accountId = accountId
        ..categoryId = categoryId
        ..type = "income"
        ..amount = amount
        ..latitude = latitude
        ..longitude = longitude
        ..date = date
        ..description =
            description?.trim().isEmpty == true ? null : description?.trim()
        ..incomePlanId = incomePlanId
        ..expensePlanId = expensePlanId
        ..createdAt = DateTime.now();

      account.balance += amount;

      createdId = await isar.financeTransactions.put(tx);
      await isar.accounts.put(account);
    });

    return createdId;
  }

  /// Gider ekleme icin ID donmeyen kolay sarmalayici metottur.
  static Future<void> addExpense({
    required int accountId,
    required int categoryId,
    required double amount,
    required DateTime date,
    double? latitude,
    double? longitude,
    String? description,
    int? expensePlanId,
    bool syncCreditCardStatement = true,
  }) async {
    await addExpenseAndGetId(
      accountId: accountId,
      categoryId: categoryId,
      amount: amount,
      date: date,
      latitude: latitude,
      longitude: longitude,
      description: description,
      expensePlanId: expensePlanId,
      syncCreditCardStatement: syncCreditCardStatement,
    );
  }

  /// Gider hareketini ekler ve hesap bakiyesini ayni transaction icinde azaltir.
  static Future<int> addExpenseAndGetId({
    required int accountId,
    required int categoryId,
    required double amount,
    required DateTime date,
    double? latitude,
    double? longitude,
    String? description,
    int? expensePlanId,
    bool syncCreditCardStatement = true,
  }) async {
    _validateFinanceType('expense');
    final isar = IsarService.isar;
    late int createdId;

    await isar.writeTxn(() async {
      final account = await isar.accounts.get(accountId);
      if (account == null) {
        throw Exception("Hesap bulunamadı.");
      }
      _validateFinanceAccount(account, type: 'expense');
      if (amount <= 0) {
        throw Exception('Gider tutarı sıfırdan büyük olmalıdır.');
      }
      if (!account.isCreditCard && account.balance + 1e-9 < amount) {
        throw Exception('Hesap bakiyesi gider tutarı için yetersiz.');
      }

      final tx = FinanceTransaction()
        ..accountId = accountId
        ..categoryId = categoryId
        ..type = "expense"
        ..amount = amount
        ..latitude = latitude
        ..longitude = longitude
        ..date = date
        ..description =
            description?.trim().isEmpty == true ? null : description?.trim()
        ..incomePlanId = null
        ..expensePlanId = expensePlanId
        ..createdAt = DateTime.now();

      account.balance -= amount;

      createdId = await isar.financeTransactions.put(tx);
      await isar.accounts.put(account);
    });

    final account = await isar.accounts.get(accountId);
    if (syncCreditCardStatement && account != null && account.isCreditCard) {
      await CreditCardStatementService.adjustExpenseImpact(
        creditCardAccount: account,
        transactionDate: date,
        deltaAmount: amount,
      );
    }

    return createdId;
  }

  /// Sadece gelir tipi hareketler icin basit geri alma yardimcisidir.
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

  /// Hareket degisince eski etkisini geri alip yeni degerleri tekrar uygular.
  static Future<void> updateTransaction({
    required int transactionId,
    required int accountId,
    required int categoryId,
    required String type,
    required double amount,
    required DateTime date,
    double? latitude,
    double? longitude,
    String? description,
    int? incomePlanId,
    int? expensePlanId,
  }) async {
    _validateFinanceType(type);
    final isar = IsarService.isar;
    late int oldAccountId;
    late DateTime oldDate;
    late String oldType;
    late double oldAmount;

    await isar.writeTxn(() async {
      final oldTx = await isar.financeTransactions.get(transactionId);
      if (oldTx == null) throw Exception('İşlem bulunamadı.');
      oldType = oldTx.type;
      oldAmount = oldTx.amount;
      oldAccountId = oldTx.accountId;
      oldDate = oldTx.date;

      final oldAccount = await isar.accounts.get(oldTx.accountId);
      if (oldAccount == null) {
        throw Exception('Hesap bulunamadı.');
      }
      _validateFinanceAccount(oldAccount, type: oldType);

      Account? newAccount;
      if (oldTx.accountId != accountId) {
        newAccount = await isar.accounts.get(accountId);
        if (newAccount == null) throw Exception('Hesap bulunamadı.');
        _validateFinanceAccount(newAccount, type: type);
      } else {
        _validateFinanceAccount(oldAccount, type: type);
      }

      oldTx
        ..accountId = accountId
        ..categoryId = categoryId
        ..type = type
        ..amount = amount
        ..latitude = latitude ?? oldTx.latitude
        ..longitude = longitude ?? oldTx.longitude
        ..date = date
        ..description =
            description?.trim().isEmpty == true ? null : description?.trim()
        ..incomePlanId = incomePlanId
        ..expensePlanId = expensePlanId;

      if (newAccount == null) {
        _revertBalanceImpact(
          account: oldAccount,
          type: oldType,
          amount: oldAmount,
        );
        _applyBalanceImpact(account: oldAccount, type: type, amount: amount);
        await isar.accounts.put(oldAccount);
      } else {
        _revertBalanceImpact(
          account: oldAccount,
          type: oldType,
          amount: oldAmount,
        );
        _applyBalanceImpact(account: newAccount, type: type, amount: amount);
        await isar.accounts.put(oldAccount);
        await isar.accounts.put(newAccount);
      }

      await isar.financeTransactions.put(oldTx);
    });

    final oldAccountAfter = await isar.accounts.get(oldAccountId);
    final newAccountAfter = await isar.accounts.get(accountId);
    if (oldAccountAfter != null &&
        oldAccountAfter.isCreditCard &&
        oldType == 'expense') {
      await CreditCardStatementService.adjustExpenseImpact(
        creditCardAccount: oldAccountAfter,
        transactionDate: oldDate,
        deltaAmount: -oldAmount,
      );
    }
    if (newAccountAfter != null &&
        newAccountAfter.isCreditCard &&
        type == 'expense') {
      await CreditCardStatementService.adjustExpenseImpact(
        creditCardAccount: newAccountAfter,
        transactionDate: date,
        deltaAmount: amount,
      );
    }
  }

  /// Hareketi silmeden once bakiye, plan ve ek temizligini geri sarar.
  static Future<FinanceTransaction> deleteAndReturn(int transactionId) async {
    final isar = IsarService.isar;
    late FinanceTransaction deleted;
    late bool hasInstallments;

    await isar.writeTxn(() async {
      final tx = await isar.financeTransactions.get(transactionId);
      if (tx == null) throw Exception('İşlem bulunamadı.');
      hasInstallments = tx.type == 'expense'
          ? await isar.creditCardInstallments
                  .filter()
                  .financeTransactionIdEqualTo(tx.id)
                  .count() >
              0
          : false;

      final account = await isar.accounts.get(tx.accountId);
      if (account == null) throw Exception('Hesap bulunamadı.');

      _revertBalanceImpact(account: account, type: tx.type, amount: tx.amount);

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

    final account = await isar.accounts.get(deleted.accountId);
    if (account != null && account.isCreditCard && deleted.type == 'expense') {
      if (hasInstallments) {
        await CreditCardInstallmentService.deleteByFinanceTransactionId(
          financeTransactionId: deleted.id,
          creditCardAccount: account,
        );
      } else {
        await CreditCardStatementService.adjustExpenseImpact(
          creditCardAccount: account,
          transactionDate: deleted.date,
          deltaAmount: -deleted.amount,
        );
      }
    }

    return deleted;
  }
}
