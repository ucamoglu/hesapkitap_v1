import 'package:isar/isar.dart';

part 'account.g.dart';

@collection
class Account {
  Id id = Isar.autoIncrement;

  // Kullanici tarafinda gorunen hesap adidir.
  late String name;
  // cash / bank / investment
  late String type;

  // Banka hesaplarinda alt tur bilgisini tutar: bank_account / credit_card
  String? bankSubtype;
  // Kredi kartinin odemesinin yapilacagi bagli banka hesabi.
  int? linkedBankAccountId;
  // Kredi karti icin hesap kesim gunu.
  int? statementDay;
  // Kredi karti icin son odeme gunu.
  int? paymentDueDay;

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

  String get effectiveBankSubtype {
    if (type != 'bank') return '';
    final value = bankSubtype?.trim();
    if (value == null || value.isEmpty) return 'bank_account';
    return value;
  }

  bool get isBankAccount =>
      type == 'bank' && effectiveBankSubtype == 'bank_account';

  bool get isCreditCard =>
      type == 'bank' && effectiveBankSubtype == 'credit_card';
}
