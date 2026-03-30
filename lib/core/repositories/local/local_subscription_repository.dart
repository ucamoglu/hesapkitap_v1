import '../../../models/subscription_definition.dart';
import '../../../services/subscription_definition_service.dart';
import '../../sync/sync_change_tracker.dart';
import '../contracts/subscription_repository.dart';

class LocalSubscriptionRepository implements SubscriptionRepository {
  LocalSubscriptionRepository({
    SyncChangeTracker? changeTracker,
  }) : _changeTracker = changeTracker ?? SyncChangeTracker();

  final SyncChangeTracker _changeTracker;

  @override
  Future<void> add(SubscriptionDefinition item) async {
    await SubscriptionDefinitionService.add(item);
    await _changeTracker.markUpsert(
      entityType: 'subscription_definition',
      localId: item.id,
    );
  }

  @override
  Future<void> delete(int id) async {
    await SubscriptionDefinitionService.delete(id);
    await _changeTracker.markDelete(
      entityType: 'subscription_definition',
      localId: id,
    );
  }

  @override
  Future<List<SubscriptionDefinition>> getActive() {
    return SubscriptionDefinitionService.getActive();
  }

  @override
  Future<List<SubscriptionDefinition>> getAll() {
    return SubscriptionDefinitionService.getAll();
  }

  @override
  Future<void> setActive(int id, bool value) async {
    await SubscriptionDefinitionService.setActive(id, value);
    await _changeTracker.markUpsert(
      entityType: 'subscription_definition',
      localId: id,
    );
  }

  @override
  Future<void> update(SubscriptionDefinition item) async {
    await SubscriptionDefinitionService.update(item);
    await _changeTracker.markUpsert(
      entityType: 'subscription_definition',
      localId: item.id,
    );
  }
}
