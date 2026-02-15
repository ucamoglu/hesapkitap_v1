import 'package:isar/isar.dart';

part 'tracked_crypto_state.g.dart';

@collection
class TrackedCryptoState {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String code;

  bool isActive = true;
}

