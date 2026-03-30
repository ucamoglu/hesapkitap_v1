import '../../../models/income_category.dart';
import '../../../services/income_category_service.dart';
import '../../sync/sync_change_tracker.dart';
import '../contracts/income_category_repository.dart';

class LocalIncomeCategoryRepository implements IncomeCategoryRepository {
  LocalIncomeCategoryRepository({
    SyncChangeTracker? changeTracker,
  }) : _changeTracker = changeTracker ?? SyncChangeTracker();

  final SyncChangeTracker _changeTracker;

  @override
  Future<void> add(String name) async {
    await IncomeCategoryService.add(name);
    final items = await IncomeCategoryService.getAll();
    final created = items
        .where((item) => item.name.trim() == name.trim())
        .fold<IncomeCategory?>(null, (latest, item) => latest == null || item.id > latest.id ? item : latest);
    if (created != null) {
      await _changeTracker.markUpsert(
        entityType: 'income_category',
        localId: created.id,
      );
    }
  }

  @override
  Future<void> delete(int id) async {
    await IncomeCategoryService.delete(id);
    await _changeTracker.markDelete(entityType: 'income_category', localId: id);
  }

  @override
  Future<List<IncomeCategory>> getAll() {
    return IncomeCategoryService.getAll();
  }

  @override
  Future<bool> isUsed(int categoryId) {
    return IncomeCategoryService.isCategoryUsed(categoryId);
  }

  @override
  Future<void> setActive(int id, bool value) async {
    await IncomeCategoryService.setActive(id, value);
    await _changeTracker.markUpsert(
      entityType: 'income_category',
      localId: id,
    );
  }

  @override
  Future<void> update(IncomeCategory category) async {
    await IncomeCategoryService.update(category);
    await _changeTracker.markUpsert(
      entityType: 'income_category',
      localId: category.id,
    );
  }
}
