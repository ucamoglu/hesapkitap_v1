import 'package:isar/isar.dart';

part 'tracked_stock.g.dart';

@collection
class TrackedStock {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String code;

  late String name;

  late DateTime createdAt;
}

