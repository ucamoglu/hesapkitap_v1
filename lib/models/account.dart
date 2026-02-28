import 'package:isar/isar.dart';

part 'account.g.dart';

@collection
class Account {
  Id id = Isar.autoIncrement;

  // Kullanici tarafinda gorunen hesap adidir.
  late String name;
  // cash / bank / investment
  late String type; 

  // Yatirim hesaplarinda alt tur bilgisini tutar.
  String? investmentSubtype;
  // Yatirim hesaplarinda bagli sembolu tutar.
  String? investmentSymbol;

  // Hizli raporlama icin materialized bakiye alani olarak saklanir.
  double balance = 0;
  @Name('zz_is_active')
  bool isActive = true;

  // Hesabin ilk olusturulma zamani.
  late DateTime createdAt;
}
