import '../../../models/subscription_definition.dart';

abstract class SubscriptionRepository {
  Future<List<SubscriptionDefinition>> getAll();
  Future<List<SubscriptionDefinition>> getActive();
  Future<void> add(SubscriptionDefinition item);
  Future<void> update(SubscriptionDefinition item);
  Future<void> setActive(int id, bool value);
  Future<void> delete(int id);
}
