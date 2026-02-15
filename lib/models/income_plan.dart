import 'package:isar/isar.dart';

part 'income_plan.g.dart';

@collection
class IncomePlan {
  Id id = Isar.autoIncrement;

  late int incomeCategoryId;
  late int accountId;

  late double amount;
  String? description;

  // daily / weekly / monthly / yearly
  late String periodType;

  // Every N periodType units.
  int frequency = 1;

  late DateTime startDate;
  DateTime? endDate;

  late DateTime nextDueDate;

  bool isActive = true;

  late DateTime createdAt;
}
