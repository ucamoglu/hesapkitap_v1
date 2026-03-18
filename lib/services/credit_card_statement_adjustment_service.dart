import 'package:isar/isar.dart';

import '../database/isar_service.dart';
import '../models/account.dart';
import '../models/finance_transaction.dart';
import '../models/credit_card_statement_adjustment.dart';
import '../models/credit_card_statement.dart';
import 'credit_card_adjustment_category_service.dart';

class CreditCardStatementAdjustmentService {
  static const String increaseDirection = 'increase';
  static const String decreaseDirection = 'decrease';

  static String _financeDescription({
    required String direction,
    required String cardName,
    String? note,
  }) {
    final base = direction == increaseDirection
        ? 'Kredi kartı ekstre farkı artış • $cardName'
        : 'Kredi kartı ekstre farkı azalış • $cardName';
    final trimmedNote = note?.trim();
    if (trimmedNote == null || trimmedNote.isEmpty) {
      return base;
    }
    return '$base • $trimmedNote';
  }

  static Future<void> addAdjustment({
    required int statementId,
    required double amount,
    required String direction,
    required DateTime adjustmentDate,
    String? note,
  }) async {
    if (amount <= 0) {
      throw Exception('Düzeltme tutarı sıfırdan büyük olmalıdır.');
    }
    if (direction != increaseDirection && direction != decreaseDirection) {
      throw Exception('Geçersiz düzeltme yönü.');
    }

    final isar = IsarService.isar;

    await isar.writeTxn(() async {
      final statement = await isar.creditCardStatements.get(statementId);
      if (statement == null) {
        throw Exception('Ekstre bulunamadı.');
      }
      final creditCardAccount = await isar.accounts.get(
        statement.creditCardAccountId,
      );
      if (creditCardAccount == null || !creditCardAccount.isCreditCard) {
        throw Exception('Kredi kartı hesabı bulunamadı.');
      }
      final categoryPair =
          await CreditCardAdjustmentCategoryService.ensurePair(isar: isar);

      final signedAmount = direction == increaseDirection ? amount : -amount;
      final nextTotal = statement.totalAmount + signedAmount;
      if (nextTotal + 1e-9 < statement.paidAmount) {
        throw Exception(
          'Düzeltme sonrası ekstre tutarı ödenen tutardan düşük olamaz.',
        );
      }
      if (nextTotal < -1e-9) {
        throw Exception('Ekstre toplamı negatif olamaz.');
      }

      statement.totalAmount = nextTotal.clamp(0, double.infinity).toDouble();
      creditCardAccount.balance -= signedAmount;

      final adjustment = CreditCardStatementAdjustment()
        ..creditCardStatementId = statement.id
        ..creditCardAccountId = creditCardAccount.id
        ..financeTransactionId = null
        ..amount = amount
        ..direction = direction
        ..note = note?.trim().isEmpty == true ? null : note?.trim()
        ..adjustmentDate = adjustmentDate
        ..createdAt = DateTime.now();

      final financeTx = FinanceTransaction()
        ..accountId = creditCardAccount.id
        ..categoryId = direction == increaseDirection
            ? categoryPair.expense.id
            : categoryPair.income.id
        ..type = direction == increaseDirection ? 'expense' : 'income'
        ..amount = amount
        ..description = _financeDescription(
          direction: direction,
          cardName: creditCardAccount.name,
          note: note,
        )
        ..incomePlanId = null
        ..expensePlanId = null
        ..date = adjustmentDate
        ..createdAt = DateTime.now();

      final financeTxId = await isar.financeTransactions.put(financeTx);
      adjustment.financeTransactionId = financeTxId;
      await isar.creditCardStatements.put(statement);
      await isar.accounts.put(creditCardAccount);
      await isar.creditCardStatementAdjustments.put(adjustment);
    });
  }

  static Future<List<CreditCardStatementAdjustment>> getByStatementId(
    int statementId,
  ) async {
    final isar = IsarService.isar;
    final items = await isar.creditCardStatementAdjustments
        .filter()
        .creditCardStatementIdEqualTo(statementId)
        .findAll();
    items.sort((a, b) => b.adjustmentDate.compareTo(a.adjustmentDate));
    return items;
  }
}
