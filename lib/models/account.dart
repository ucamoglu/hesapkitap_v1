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
  // Banka hesabinin kullanabilecegi eksi limit.
  double overdraftLimit = 0;
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
  bool isSystemGenerated = false;
  String? systemKey;

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

  bool get isBalanceAccount => type == 'balance';

  bool get supportsOverdraft =>
      type == 'bank' && effectiveBankSubtype == 'bank_account';

  double get effectiveOverdraftLimit =>
      supportsOverdraft && overdraftLimit > 0 ? overdraftLimit : 0;

  bool canWithdraw(double amount) {
    if (amount <= 0) return true;
    if (isBalanceAccount) return true;
    if (isCreditCard) return true;
    return balance + effectiveOverdraftLimit + 1e-9 >= amount;
  }
}
