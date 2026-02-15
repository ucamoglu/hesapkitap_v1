import 'package:isar/isar.dart';

part 'account.g.dart';

@collection
class Account {
  Id id = Isar.autoIncrement;

  late String name;
  late String type; 

  String? investmentSubtype;
  String? investmentSymbol;

  double balance = 0;
  @Name('zz_is_active')
  bool isActive = true;

  late DateTime createdAt;
}
