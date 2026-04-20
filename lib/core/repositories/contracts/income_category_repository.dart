import '../../../models/income_category.dart';

abstract class IncomeCategoryRepository {
  Future<List<IncomeCategory>> getAll();
  Future<void> add(String name);
  Future<void> update(IncomeCategory category);
  Future<void> setActive(int id, bool value);
  Future<void> delete(int id);
  Future<bool> isUsed(int categoryId);
}
