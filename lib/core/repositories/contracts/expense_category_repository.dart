import '../../../models/category.dart';

abstract class ExpenseCategoryRepository {
  Future<List<Category>> getAll();
  Future<void> add(String name);
  Future<void> update(Category category);
  Future<void> setActive(int id, bool value);
  Future<void> delete(int id);
  Future<bool> isUsed(int categoryId);
}
