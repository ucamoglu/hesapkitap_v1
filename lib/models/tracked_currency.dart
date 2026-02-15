import 'package:isar/isar.dart';

part 'tracked_currency.g.dart';

@collection
class TrackedCurrency {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String code;

  late String name;

  late DateTime createdAt;
}
