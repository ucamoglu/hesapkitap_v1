import 'package:isar/isar.dart';

import '../database/isar_service.dart';
import '../models/account.dart';
import '../models/credit_card_payment.dart';
import '../models/credit_card_statement.dart';

class CreditCardPaymentService {
  static Future<void> payStatement({
    required int statementId,
    required int bankAccountId,
    required double amount,
    required DateTime paymentDate,
    String? note,
  }) async {
    if (amount <= 0) {
      throw Exception('Ödeme tutarı sıfırdan büyük olmalıdır.');
    }

    final isar = IsarService.isar;

    await isar.writeTxn(() async {
      final statement = await isar.creditCardStatements.get(statementId);
      if (statement == null) {
        throw Exception('Ekstre bulunamadı.');
      }

      final bankAccount = await isar.accounts.get(bankAccountId);
      if (bankAccount == null) {
        throw Exception('Banka hesabı bulunamadı.');
      }
      if (!bankAccount.isActive || !bankAccount.isBankAccount) {
        throw Exception('Ödeme için aktif bir banka hesabı seçiniz.');
      }
      if (bankAccount.balance + 1e-9 < amount) {
        throw Exception('Seçilen banka hesabı bakiyesi ödeme için yetersiz.');
      }

      final creditCardAccount = await isar.accounts.get(
        statement.creditCardAccountId,
      );
      if (creditCardAccount == null || !creditCardAccount.isCreditCard) {
        throw Exception('Kredi kartı hesabı bulunamadı.');
      }

      final remaining = (statement.totalAmount - statement.paidAmount)
          .clamp(0, double.infinity)
          .toDouble();
      if (remaining <= 1e-9) {
        throw Exception('Bu ekstre zaten tamamen ödenmiş.');
      }
      if (amount - remaining > 1e-9) {
        throw Exception('Ödeme tutarı ekstre kalan borcunu aşamaz.');
      }

      statement.paidAmount += amount;
      bankAccount.balance -= amount;
      creditCardAccount.balance += amount;

      final payment = CreditCardPayment()
        ..creditCardStatementId = statement.id
        ..creditCardAccountId = creditCardAccount.id
        ..bankAccountId = bankAccount.id
        ..amount = amount
        ..note = note?.trim().isEmpty == true ? null : note?.trim()
        ..paymentDate = paymentDate
        ..createdAt = DateTime.now();

      await isar.creditCardStatements.put(statement);
      await isar.accounts.put(bankAccount);
      await isar.accounts.put(creditCardAccount);
      await isar.creditCardPayments.put(payment);
    });
  }

  static Future<List<CreditCardPayment>> getByStatementId(
      int statementId) async {
    final isar = IsarService.isar;
    final items = await isar.creditCardPayments
        .filter()
        .creditCardStatementIdEqualTo(statementId)
        .findAll();
    items.sort((a, b) => b.paymentDate.compareTo(a.paymentDate));
    return items;
  }

  static Future<List<CreditCardPayment>> getAll() async {
    final isar = IsarService.isar;
    final items = await isar.creditCardPayments.where().anyId().findAll();
    items.sort((a, b) => b.paymentDate.compareTo(a.paymentDate));
    return items;
  }
}
