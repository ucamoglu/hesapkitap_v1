import 'package:isar/isar.dart';

part 'tracked_currency.g.dart';

@collection
class TrackedCurrency {
  Id id = Isar.autoIncrement;

  // Her doviz kodu tek bir kayda karsilik gelir.
  @Index(unique: true, replace: true)
  late String code;

  late String name;

  // Takibe eklenme zamani ile listeleme sirasi korunur.
  late DateTime createdAt;
}
