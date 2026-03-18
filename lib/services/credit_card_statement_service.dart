import 'package:isar/isar.dart';

import '../database/isar_service.dart';
import '../models/account.dart';
import '../models/credit_card_statement.dart';

class CreditCardStatementCycle {
  final DateTime periodStart;
  final DateTime periodEnd;
  final DateTime statementDate;
  final DateTime dueDate;

  const CreditCardStatementCycle({
    required this.periodStart,
    required this.periodEnd,
    required this.statementDate,
    required this.dueDate,
  });
}

class CreditCardStatementService {
  static int _daysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  static DateTime _safeDate(int year, int month, int day) {
    final lastDay = _daysInMonth(year, month);
    final normalizedDay = day.clamp(1, lastDay);
    return DateTime(year, month, normalizedDay);
  }

  static CreditCardStatementCycle resolveCycle({
    required Account creditCardAccount,
    required DateTime transactionDate,
  }) {
    if (!creditCardAccount.isCreditCard) {
      throw Exception('Ekstre döngüsü yalnızca kredi kartı için üretilebilir.');
    }

    final statementDay = creditCardAccount.statementDay;
    final dueDay = creditCardAccount.paymentDueDay;
    if (statementDay == null || dueDay == null) {
      throw Exception(
          'Kredi kartı için kesim ve son ödeme günü tanımlı olmalıdır.');
    }

    final txDate = DateTime(
      transactionDate.year,
      transactionDate.month,
      transactionDate.day,
    );
    final sameMonthStatementDate = _safeDate(
      txDate.year,
      txDate.month,
      statementDay,
    );
    final statementDate = txDate.isAfter(sameMonthStatementDate)
        ? _safeDate(txDate.year, txDate.month + 1, statementDay)
        : sameMonthStatementDate;
    final previousStatementDate = _safeDate(
      statementDate.year,
      statementDate.month - 1,
      statementDay,
    );

    final periodStart = DateTime(
      previousStatementDate.year,
      previousStatementDate.month,
      previousStatementDate.day + 1,
    );
    final periodEnd = DateTime(
      statementDate.year,
      statementDate.month,
      statementDate.day,
      23,
      59,
      59,
      999,
    );
    final dueMonthOffset = dueDay <= statementDate.day ? 1 : 0;
    final dueDate = _safeDate(
      statementDate.year,
      statementDate.month + dueMonthOffset,
      dueDay,
    );

    return CreditCardStatementCycle(
      periodStart: periodStart,
      periodEnd: periodEnd,
      statementDate: statementDate,
      dueDate: dueDate,
    );
  }

  static Future<void> adjustExpenseImpact({
    required Account creditCardAccount,
    required DateTime transactionDate,
    required double deltaAmount,
  }) async {
    if (!creditCardAccount.isCreditCard) return;
    if (deltaAmount.abs() <= 1e-9) return;

    final cycle = resolveCycle(
      creditCardAccount: creditCardAccount,
      transactionDate: transactionDate,
    );
    final isar = IsarService.isar;

    await isar.writeTxn(() async {
      final statement = await isar.creditCardStatements
          .filter()
          .creditCardAccountIdEqualTo(creditCardAccount.id)
          .statementDateEqualTo(cycle.statementDate)
          .findFirst();

      if (statement == null) {
        if (deltaAmount < 0) return;
        final created = CreditCardStatement()
          ..creditCardAccountId = creditCardAccount.id
          ..periodStart = cycle.periodStart
          ..periodEnd = cycle.periodEnd
          ..statementDate = cycle.statementDate
          ..dueDate = cycle.dueDate
          ..totalAmount = deltaAmount
          ..paidAmount = 0
          ..createdAt = DateTime.now();
        await isar.creditCardStatements.put(created);
        return;
      }

      statement
        ..periodStart = cycle.periodStart
        ..periodEnd = cycle.periodEnd
        ..statementDate = cycle.statementDate
        ..dueDate = cycle.dueDate
        ..totalAmount += deltaAmount;

      if (statement.totalAmount < 0) {
        statement.totalAmount = 0;
      }
      if (statement.totalAmount <= 1e-9 && statement.paidAmount <= 1e-9) {
        await isar.creditCardStatements.delete(statement.id);
        return;
      }
      await isar.creditCardStatements.put(statement);
    });
  }

  static Future<List<CreditCardStatement>> getAll() async {
    final isar = IsarService.isar;
    final items = await isar.creditCardStatements.where().anyId().findAll();
    items.sort((a, b) => b.statementDate.compareTo(a.statementDate));
    return items;
  }
}
