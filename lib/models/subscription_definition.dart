import 'package:isar/isar.dart';

part 'subscription_definition.g.dart';

@collection
class SubscriptionDefinition {
  Id id = Isar.autoIncrement;

  late String name;
  late String type;
  late String providerName;

  String? subscriberNumber;
  int? paymentAccountId;
  int? defaultExpenseCategoryId;
  int? dueDay;
  String? note;

  bool isAutoPay = false;
  bool isActive = true;

  late DateTime createdAt;
  DateTime? updatedAt;
}
