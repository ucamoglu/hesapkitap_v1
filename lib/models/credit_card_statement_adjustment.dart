import 'package:isar/isar.dart';

part 'credit_card_statement_adjustment.g.dart';

@collection
class CreditCardStatementAdjustment {
  Id id = Isar.autoIncrement;

  late int creditCardStatementId;
  late int creditCardAccountId;
  int? financeTransactionId;
  late double amount;
  late String direction;
  String? note;
  late DateTime adjustmentDate;
  late DateTime createdAt;
}
