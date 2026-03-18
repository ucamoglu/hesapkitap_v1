import 'package:isar/isar.dart';

part 'credit_card_statement.g.dart';

@collection
class CreditCardStatement {
  Id id = Isar.autoIncrement;

  late int creditCardAccountId;
  late DateTime periodStart;
  late DateTime periodEnd;
  late DateTime statementDate;
  late DateTime dueDate;
  double totalAmount = 0;
  double paidAmount = 0;
  late DateTime createdAt;
}
