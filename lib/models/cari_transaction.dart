import 'package:isar/isar.dart';

part 'cari_transaction.g.dart';

@collection
class CariTransaction {
  Id id = Isar.autoIncrement;

  late int cariCardId;
  late int accountId;

  late String type;
  // debt / collection

  late double amount;
  double? quantity;
  double? unitPrice;
  String? description;
  late DateTime date;
  late DateTime createdAt;
}
