import 'package:isar/isar.dart';

part 'cari_transaction.g.dart';

@collection
class CariTransaction {
  Id id = Isar.autoIncrement;

  // Hareketin bagli oldugu cari kart.
  late int cariCardId;
  // Tahsilat/odemenin yansidigi hesap.
  late int accountId;

  late String type;
  // debt / collection

  late double amount;
  // Tutarin dayandigi adet bilgisi varsa saklanir.
  double? quantity;
  // Birim fiyatli yabanci cari hareketlerde kullanilir.
  double? unitPrice;
  String? description;
  late DateTime date;
  late DateTime createdAt;
}
