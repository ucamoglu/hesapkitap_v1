import 'package:isar/isar.dart';

part 'category.g.dart';

@collection
class Category {
  Id id = Isar.autoIncrement;

  // Gider kategorisinin ekranda gorunen adidir.
  late String name;

  late String type; 
  // income / expense

  // Alt kategori yapisi icin ebeveyn referansi.
  int? parentId; 
  // null ise ana kategori

  bool isActive = true;
  bool isSystemGenerated = false;
  String? systemKey;

  late DateTime createdAt;
}
