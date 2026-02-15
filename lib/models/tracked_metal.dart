import 'package:isar/isar.dart';

part 'tracked_metal.g.dart';

@collection
class TrackedMetal {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String code;

  late String name;

  late DateTime createdAt;
}
