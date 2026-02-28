import 'package:isar/isar.dart';

part 'transaction_attachment.g.dart';

@collection
class TransactionAttachment {
  Id id = Isar.autoIncrement;

  // finance / cari / investment
  late String ownerType;

  // Ekin bagli oldugu yerel hareket ID'si.
  late int ownerId;
  // Gorsel veri su an dogrudan veritabani icinde saklanir.
  List<int> imageBytes = [];
  late DateTime createdAt;
}
