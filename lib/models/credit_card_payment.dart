import 'package:isar/isar.dart';

part 'credit_card_payment.g.dart';

@collection
class CreditCardPayment {
  Id id = Isar.autoIncrement;

  late int creditCardStatementId;
  late int creditCardAccountId;
  late int bankAccountId;
  late double amount;
  String? note;
  late DateTime paymentDate;
  late DateTime createdAt;
}
