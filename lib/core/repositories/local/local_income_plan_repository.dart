import '../../../models/income_plan.dart';
import '../../../services/income_plan_service.dart';
import '../../sync/sync_change_tracker.dart';
import '../contracts/income_plan_repository.dart';

class LocalIncomePlanRepository implements IncomePlanRepository {
  LocalIncomePlanRepository({
    SyncChangeTracker? changeTracker,
  }) : _changeTracker = changeTracker ?? SyncChangeTracker();

  final SyncChangeTracker _changeTracker;

  @override
  Future<void> cancel(IncomePlan plan) async {
    await IncomePlanService.cancel(plan);
    await _changeTracker.markUpsert(entityType: 'income_plan', localId: plan.id);
  }

  @override
  Future<void> delete(int id) async {
    await IncomePlanService.delete(id);
    await _changeTracker.markDelete(entityType: 'income_plan', localId: id);
  }

  @override
  Future<List<IncomePlan>> getAll() {
    return IncomePlanService.getAll();
  }

  @override
  Future<List<IncomePlan>> getDuePlans(DateTime now) {
    return IncomePlanService.getDuePlans(now);
  }

  @override
  Future<void> markCompleted(IncomePlan plan) async {
    final result = await IncomePlanService.markCompleted(plan);
    await _changeTracker.markUpsert(entityType: 'income_plan', localId: plan.id);
    await _changeTracker.markUpsert(
      entityType: 'finance_transaction',
      localId: result.transactionId,
    );
  }

  @override
  Future<void> postpone(IncomePlan plan, DateTime newDate) async {
    await IncomePlanService.postpone(plan, newDate);
    await _changeTracker.markUpsert(entityType: 'income_plan', localId: plan.id);
  }

  @override
  Future<void> save(IncomePlan plan) async {
    await IncomePlanService.save(plan);
    await _changeTracker.markUpsert(entityType: 'income_plan', localId: plan.id);
  }
}
