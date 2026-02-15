import 'package:isar/isar.dart';

part 'category.g.dart';

@collection
class Category {
  Id id = Isar.autoIncrement;

  late String name;

  late String type; 
  // income / expense

  int? parentId; 
  // null ise ana kategori

  bool isActive = true;
  bool isSystemGenerated = false;
  String? systemKey;

  late DateTime createdAt;
}
