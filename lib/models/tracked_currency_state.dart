import 'package:isar/isar.dart';

part 'tracked_currency_state.g.dart';

@collection
class TrackedCurrencyState {
  Id id = Isar.autoIncrement;

  // State tablosu, dovizin tanimindan ayri olarak UI aktiflik durumunu tutar.
  @Index(unique: true, replace: true)
  late String code;

  bool isActive = true;
}
