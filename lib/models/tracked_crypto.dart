import 'package:isar/isar.dart';

part 'tracked_crypto.g.dart';

@collection
class TrackedCrypto {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String code;

  late String name;

  late DateTime createdAt;
}

