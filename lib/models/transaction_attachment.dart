import 'package:isar/isar.dart';

part 'transaction_attachment.g.dart';

@collection
class TransactionAttachment {
  Id id = Isar.autoIncrement;

  late String ownerType;
  // finance / cari / investment

  late int ownerId;
  List<int> imageBytes = [];
  late DateTime createdAt;
}
