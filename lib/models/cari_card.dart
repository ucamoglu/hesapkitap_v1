import 'package:isar/isar.dart';

part 'cari_card.g.dart';

@collection
class CariCard {
  Id id = Isar.autoIncrement;

  // person / company
  late String type;

  // Kisi kayitlarinda gorunen ad soyad.
  String? fullName;
  // Sirket kayitlarinda gorunen unvan.
  String? title;

  String? phone;
  String? email;
  String? note;
  // Kart seviyesinde profil resmi/logo bytes verisini tutar.
  List<int>? photoBytes;

  // tl / foreign
  String currencyType = 'tl';

  // currency / metal / crypto / stock
  String? foreignMarketType;
  String? foreignCode;
  String? foreignName;

  bool isActive = true;

  late DateTime createdAt;
}
