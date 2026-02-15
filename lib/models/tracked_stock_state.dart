import 'package:isar/isar.dart';

part 'tracked_stock_state.g.dart';

@collection
class TrackedStockState {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String code;

  bool isActive = true;
}

