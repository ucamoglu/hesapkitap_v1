import '../../../models/income_plan.dart';

abstract class IncomePlanRepository {
  Future<List<IncomePlan>> getAll();
  Future<List<IncomePlan>> getDuePlans(DateTime now);
  Future<void> save(IncomePlan plan);
  Future<void> delete(int id);
  Future<void> postpone(IncomePlan plan, DateTime newDate);
  Future<void> cancel(IncomePlan plan);
  Future<void> markCompleted(IncomePlan plan);
}
