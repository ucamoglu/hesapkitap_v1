import 'package:isar/isar.dart';

part 'transfer_transaction.g.dart';

@collection
class TransferTransaction {
  Id id = Isar.autoIncrement;

  // Paranin ciktigi hesap.
  late int fromAccountId;
  // Paranin girdigi hesap.
  late int toAccountId;

  late double amount;
  String? description;
  late DateTime date;
  late DateTime createdAt;
}
