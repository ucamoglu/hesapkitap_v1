import 'package:isar/isar.dart';

part 'tracked_metal_state.g.dart';

@collection
class TrackedMetalState {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String code;

  bool isActive = true;
}
