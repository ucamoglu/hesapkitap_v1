import 'package:isar/isar.dart';

part 'tracked_crypto.g.dart';

@collection
class TrackedCrypto {
  Id id = Isar.autoIncrement;

  // Her kripto kodu tekil kayit olarak tutulur.
  @Index(unique: true, replace: true)
  late String code;

  late String name;

  // Takip listesine eklenme zamani.
  late DateTime createdAt;
}
