import '../../../models/category.dart';
import '../../../services/category_service.dart';
import '../../sync/sync_change_tracker.dart';
import '../contracts/expense_category_repository.dart';

class LocalExpenseCategoryRepository implements ExpenseCategoryRepository {
  LocalExpenseCategoryRepository({
    SyncChangeTracker? changeTracker,
  }) : _changeTracker = changeTracker ?? SyncChangeTracker();

  final SyncChangeTracker _changeTracker;

  @override
  Future<void> add(String name) async {
    await CategoryService.addExpenseCategory(name);
    final items = await CategoryService.getAllExpenseCategories();
    final created = items
        .where((item) => item.name.trim() == name.trim())
        .fold<Category?>(null, (latest, item) => latest == null || item.id > latest.id ? item : latest);
    if (created != null) {
      await _changeTracker.markUpsert(entityType: 'category', localId: created.id);
    }
  }

  @override
  Future<void> delete(int id) async {
    await CategoryService.deleteExpenseCategory(id);
    await _changeTracker.markDelete(entityType: 'category', localId: id);
  }

  @override
  Future<List<Category>> getAll() {
    return CategoryService.getAllExpenseCategories();
  }

  @override
  Future<bool> isUsed(int categoryId) {
    return CategoryService.isExpenseCategoryUsed(categoryId);
  }

  @override
  Future<void> setActive(int id, bool value) async {
    await CategoryService.setActive(id, value);
    await _changeTracker.markUpsert(entityType: 'category', localId: id);
  }

  @override
  Future<void> update(Category category) async {
    await CategoryService.updateExpenseCategory(category);
    await _changeTracker.markUpsert(entityType: 'category', localId: category.id);
  }
}
