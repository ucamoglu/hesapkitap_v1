import 'package:isar/isar.dart';

part 'subscription_definition.g.dart';

@collection
class SubscriptionDefinition {
  Id id = Isar.autoIncrement;

  late String name;
  late String type;
  String paymentType = 'variable';
  String duePeriod = 'monthly';
  late String providerName;

  String? subscriberNumber;
  int? paymentAccountId;
  int? defaultExpenseCategoryId;
  double? defaultAmount;
  int? dueDay;
  int? dueMonth;
  String? note;

  bool isAutoPay = false;
  bool isActive = true;

  late DateTime createdAt;
  DateTime? updatedAt;
}
