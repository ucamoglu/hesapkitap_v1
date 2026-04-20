import 'package:isar/isar.dart';

part 'finance_transaction.g.dart';

@collection
class FinanceTransaction {
  Id id = Isar.autoIncrement;

  // Gelir/giderin yansidigi hesap.
  late int accountId;

  // Gelir veya gider kategorisine isaret eder.
  late int categoryId;

  late String type; 
  // income / expense

  late double amount;

  double? latitude;
  double? longitude;

  String? description;
  // Plan uzerinden olusan gelirlerde kaynagi izlemek icin tutulur.
  int? incomePlanId;
  // Plan uzerinden olusan giderlerde kaynagi izlemek icin tutulur.
  int? expensePlanId;

  late DateTime date;

  late DateTime createdAt;
}
