import 'package:isar/isar.dart';

import '../database/isar_service.dart';
import '../models/account.dart';
import '../models/credit_card_installment.dart';
import 'credit_card_statement_service.dart';

class CreditCardInstallmentPreview {
  final int installmentNumber;
  final int installmentCount;
  final double amount;
  final DateTime installmentDate;
  final DateTime statementDate;
  final DateTime dueDate;

  const CreditCardInstallmentPreview({
    required this.installmentNumber,
    required this.installmentCount,
    required this.amount,
    required this.installmentDate,
    required this.statementDate,
    required this.dueDate,
  });
}

class CreditCardInstallmentService {
  static DateTime _addMonthsKeepingDay(DateTime date, int monthsToAdd) {
    final targetMonthIndex = date.month - 1 + monthsToAdd;
    final targetYear = date.year + (targetMonthIndex ~/ 12);
    final targetMonth = (targetMonthIndex % 12) + 1;
    final lastDay = DateTime(targetYear, targetMonth + 1, 0).day;
    final day = date.day.clamp(1, lastDay);
    return DateTime(targetYear, targetMonth, day);
  }

  static List<double> _splitAmount(double totalAmount, int installmentCount) {
    final totalCents = (totalAmount * 100).round();
    final base = totalCents ~/ installmentCount;
    final remainder = totalCents % installmentCount;
    return List<double>.generate(installmentCount, (index) {
      final cents = base + (index < remainder ? 1 : 0);
      return cents / 100.0;
    });
  }

  static List<CreditCardInstallmentPreview> previewInstallments({
    required Account creditCardAccount,
    required DateTime transactionDate,
    required double totalAmount,
    required int installmentCount,
  }) {
    if (!creditCardAccount.isCreditCard) {
      throw Exception(
          'Taksit planı yalnızca kredi kartı için oluşturulabilir.');
    }
    if (installmentCount < 2) {
      throw Exception('Taksit sayısı en az 2 olmalıdır.');
    }

    final pieces = _splitAmount(totalAmount, installmentCount);
    return List<CreditCardInstallmentPreview>.generate(installmentCount, (
      index,
    ) {
      final installmentDate = _addMonthsKeepingDay(transactionDate, index);
      final cycle = CreditCardStatementService.resolveCycle(
        creditCardAccount: creditCardAccount,
        transactionDate: installmentDate,
      );
      return CreditCardInstallmentPreview(
        installmentNumber: index + 1,
        installmentCount: installmentCount,
        amount: pieces[index],
        installmentDate: installmentDate,
        statementDate: cycle.statementDate,
        dueDate: cycle.dueDate,
      );
    });
  }

  static Future<void> createInstallmentsForExpense({
    required int financeTransactionId,
    required Account creditCardAccount,
    required DateTime transactionDate,
    required double totalAmount,
    required int installmentCount,
  }) async {
    final plan = previewInstallments(
      creditCardAccount: creditCardAccount,
      transactionDate: transactionDate,
      totalAmount: totalAmount,
      installmentCount: installmentCount,
    );
    final isar = IsarService.isar;

    await isar.writeTxn(() async {
      for (final item in plan) {
        final installment = CreditCardInstallment()
          ..financeTransactionId = financeTransactionId
          ..investmentTransactionId = null
          ..creditCardAccountId = creditCardAccount.id
          ..installmentNumber = item.installmentNumber
          ..installmentCount = item.installmentCount
          ..amount = item.amount
          ..installmentDate = item.installmentDate
          ..statementDate = item.statementDate
          ..dueDate = item.dueDate
          ..createdAt = DateTime.now();
        await isar.creditCardInstallments.put(installment);
      }
    });

    for (final item in plan) {
      await CreditCardStatementService.adjustExpenseImpact(
        creditCardAccount: creditCardAccount,
        transactionDate: item.installmentDate,
        deltaAmount: item.amount,
      );
    }
  }

  static Future<void> createInstallmentsForInvestment({
    required int investmentTransactionId,
    required Account creditCardAccount,
    required DateTime transactionDate,
    required double totalAmount,
    required int installmentCount,
  }) async {
    final plan = previewInstallments(
      creditCardAccount: creditCardAccount,
      transactionDate: transactionDate,
      totalAmount: totalAmount,
      installmentCount: installmentCount,
    );
    final isar = IsarService.isar;

    await isar.writeTxn(() async {
      for (final item in plan) {
        final installment = CreditCardInstallment()
          ..financeTransactionId = null
          ..investmentTransactionId = investmentTransactionId
          ..creditCardAccountId = creditCardAccount.id
          ..installmentNumber = item.installmentNumber
          ..installmentCount = item.installmentCount
          ..amount = item.amount
          ..installmentDate = item.installmentDate
          ..statementDate = item.statementDate
          ..dueDate = item.dueDate
          ..createdAt = DateTime.now();
        await isar.creditCardInstallments.put(installment);
      }
    });

    for (final item in plan) {
      await CreditCardStatementService.adjustExpenseImpact(
        creditCardAccount: creditCardAccount,
        transactionDate: item.installmentDate,
        deltaAmount: item.amount,
      );
    }
  }

  static Future<bool> hasInstallments(int financeTransactionId) async {
    final isar = IsarService.isar;
    final count = await isar.creditCardInstallments
        .filter()
        .financeTransactionIdEqualTo(financeTransactionId)
        .count();
    return count > 0;
  }

  static Future<bool> hasInstallmentsForInvestment(
    int investmentTransactionId,
  ) async {
    final isar = IsarService.isar;
    final count = await isar.creditCardInstallments
        .filter()
        .investmentTransactionIdEqualTo(investmentTransactionId)
        .count();
    return count > 0;
  }

  static Future<List<CreditCardInstallment>> getByFinanceTransactionId(
    int financeTransactionId,
  ) async {
    final isar = IsarService.isar;
    return isar.creditCardInstallments
        .filter()
        .financeTransactionIdEqualTo(financeTransactionId)
        .findAll();
  }

  static Future<List<CreditCardInstallment>> getByInvestmentTransactionId(
    int investmentTransactionId,
  ) async {
    final isar = IsarService.isar;
    return isar.creditCardInstallments
        .filter()
        .investmentTransactionIdEqualTo(investmentTransactionId)
        .findAll();
  }

  static Future<List<CreditCardInstallment>> getAll() async {
    final isar = IsarService.isar;
    final items = await isar.creditCardInstallments.where().anyId().findAll();
    items.sort((a, b) {
      final statementCompare = b.statementDate.compareTo(a.statementDate);
      if (statementCompare != 0) return statementCompare;
      return a.installmentNumber.compareTo(b.installmentNumber);
    });
    return items;
  }

  static Future<void> deleteByFinanceTransactionId({
    required int financeTransactionId,
    required Account creditCardAccount,
  }) async {
    final isar = IsarService.isar;
    final items = await getByFinanceTransactionId(financeTransactionId);
    if (items.isEmpty) return;

    await isar.writeTxn(() async {
      for (final item in items) {
        await isar.creditCardInstallments.delete(item.id);
      }
    });

    for (final item in items) {
      await CreditCardStatementService.adjustExpenseImpact(
        creditCardAccount: creditCardAccount,
        transactionDate: item.installmentDate,
        deltaAmount: -item.amount,
      );
    }
  }

  static Future<void> deleteByInvestmentTransactionId({
    required int investmentTransactionId,
    required Account creditCardAccount,
  }) async {
    final isar = IsarService.isar;
    final items = await getByInvestmentTransactionId(investmentTransactionId);
    if (items.isEmpty) return;

    await isar.writeTxn(() async {
      for (final item in items) {
        await isar.creditCardInstallments.delete(item.id);
      }
    });

    for (final item in items) {
      await CreditCardStatementService.adjustExpenseImpact(
        creditCardAccount: creditCardAccount,
        transactionDate: item.installmentDate,
        deltaAmount: -item.amount,
      );
    }
  }
}
