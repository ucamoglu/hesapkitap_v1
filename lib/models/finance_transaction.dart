import 'package:isar/isar.dart';

part 'finance_transaction.g.dart';

@collection
class FinanceTransaction {
  Id id = Isar.autoIncrement;

  late int accountId;

  late int categoryId;

  late String type; 
  // income / expense

  late double amount;

  String? description;
  int? incomePlanId;
  int? expensePlanId;

  late DateTime date;

  late DateTime createdAt;
}
