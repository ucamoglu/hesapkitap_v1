import 'package:isar/isar.dart';

part 'transfer_transaction.g.dart';

@collection
class TransferTransaction {
  Id id = Isar.autoIncrement;

  late int fromAccountId;
  late int toAccountId;

  late double amount;
  String? description;
  late DateTime date;
  late DateTime createdAt;
}
