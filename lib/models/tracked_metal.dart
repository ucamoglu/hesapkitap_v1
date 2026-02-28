import 'package:isar/isar.dart';

part 'tracked_metal.g.dart';

@collection
class TrackedMetal {
  Id id = Isar.autoIncrement;

  // Her maden kodu tek bir kayda karsilik gelir.
  @Index(unique: true, replace: true)
  late String code;

  late String name;

  // Listeleme sirasi icin eklenme zamani saklanir.
  late DateTime createdAt;
}
