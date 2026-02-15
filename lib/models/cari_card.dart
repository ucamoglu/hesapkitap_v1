import 'package:isar/isar.dart';

part 'cari_card.g.dart';

@collection
class CariCard {
  Id id = Isar.autoIncrement;

  late String type;
  // person / company

  String? fullName;
  String? title;

  String? phone;
  String? email;
  String? note;
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
