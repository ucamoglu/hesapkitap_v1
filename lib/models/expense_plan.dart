import 'package:isar/isar.dart';

part 'expense_plan.g.dart';

@collection
class ExpensePlan {
  Id id = Isar.autoIncrement;

  // Planin bagli oldugu gider kategorisi.
  late int expenseCategoryId;
  // Giderin cekilecegi hesap.
  late int accountId;

  late double amount;
  String? description;

  // daily / weekly / monthly / yearly
  late String periodType;

  // Every N periodType units.
  int frequency = 1;

  // Gunluk planlarda bildirimin kac dakika once gelecegini tutar.
  int reminderMinutesBefore = 0;

  late DateTime startDate;
  DateTime? endDate;

  // Sonraki otomatik isleme alinacak tarih.
  late DateTime nextDueDate;

  bool isActive = true;

  late DateTime createdAt;
}
