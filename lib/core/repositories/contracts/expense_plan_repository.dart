import '../../../models/expense_plan.dart';

abstract class ExpensePlanRepository {
  Future<List<ExpensePlan>> getAll();
  Future<List<ExpensePlan>> getDuePlans(DateTime now);
  Future<void> save(ExpensePlan plan);
  Future<void> delete(int id);
  Future<void> postpone(ExpensePlan plan, DateTime newDate);
  Future<void> cancel(ExpensePlan plan);
  Future<void> markCompleted(ExpensePlan plan);
}
