import 'package:isar/isar.dart';

part 'tracked_stock.g.dart';

@collection
class TrackedStock {
  Id id = Isar.autoIncrement;

  // Her hisse cloud ve local tarafta kodu ile tekil tutulur.
  @Index(unique: true, replace: true)
  late String code;

  late String name;

  // Takibe ne zaman eklendigini korur.
  late DateTime createdAt;
}
