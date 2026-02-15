import 'package:isar/isar.dart';

part 'tracked_currency_state.g.dart';

@collection
class TrackedCurrencyState {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String code;

  bool isActive = true;
}
