import 'package:isar/isar.dart';

part 'income_category.g.dart';

@collection
class IncomeCategory {
  Id id = Isar.autoIncrement;

  late String name;

  bool isActive = true;
  bool isSystemGenerated = false;
  String? systemKey;

  late DateTime createdAt;
}
