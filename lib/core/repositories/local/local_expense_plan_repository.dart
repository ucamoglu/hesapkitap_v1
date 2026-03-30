import '../../../models/expense_plan.dart';
import '../../../services/expense_plan_service.dart';
import '../../sync/sync_change_tracker.dart';
import '../contracts/expense_plan_repository.dart';

class LocalExpensePlanRepository implements ExpensePlanRepository {
  LocalExpensePlanRepository({
    SyncChangeTracker? changeTracker,
  }) : _changeTracker = changeTracker ?? SyncChangeTracker();

  final SyncChangeTracker _changeTracker;

  @override
  Future<void> cancel(ExpensePlan plan) async {
    await ExpensePlanService.cancel(plan);
    await _changeTracker.markUpsert(
      entityType: 'expense_plan',
      localId: plan.id,
    );
  }

  @override
  Future<void> delete(int id) async {
    await ExpensePlanService.delete(id);
    await _changeTracker.markDelete(entityType: 'expense_plan', localId: id);
  }

  @override
  Future<List<ExpensePlan>> getAll() {
    return ExpensePlanService.getAll();
  }

  @override
  Future<List<ExpensePlan>> getDuePlans(DateTime now) {
    return ExpensePlanService.getDuePlans(now);
  }

  @override
  Future<void> markCompleted(ExpensePlan plan) async {
    final transactionId = await ExpensePlanService.markCompleted(plan);
    await _changeTracker.markUpsert(
      entityType: 'expense_plan',
      localId: plan.id,
    );
    await _changeTracker.markUpsert(
      entityType: 'finance_transaction',
      localId: transactionId,
    );
  }

  @override
  Future<void> postpone(ExpensePlan plan, DateTime newDate) async {
    await ExpensePlanService.postpone(plan, newDate);
    await _changeTracker.markUpsert(
      entityType: 'expense_plan',
      localId: plan.id,
    );
  }

  @override
  Future<void> save(ExpensePlan plan) async {
    await ExpensePlanService.save(plan);
    await _changeTracker.markUpsert(
      entityType: 'expense_plan',
      localId: plan.id,
    );
  }
}
