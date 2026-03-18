import 'package:isar/isar.dart';

part 'credit_card_installment.g.dart';

@collection
class CreditCardInstallment {
  Id id = Isar.autoIncrement;

  int? financeTransactionId;
  int? investmentTransactionId;
  late int creditCardAccountId;
  late int installmentNumber;
  late int installmentCount;
  late double amount;
  late DateTime installmentDate;
  late DateTime statementDate;
  late DateTime dueDate;
  late DateTime createdAt;
}
