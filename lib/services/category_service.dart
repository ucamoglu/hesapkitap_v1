import 'package:isar/isar.dart';

import '../database/isar_service.dart';
import '../models/category.dart';
import '../models/finance_transaction.dart';

class CategoryService {
  static Future<List<Category>> getAllExpenseCategories() async {
    final isar = IsarService.isar;

    return await isar.categorys
        .where()
        .filter()
        .typeEqualTo("expense")
        .findAll();
  }

  static Future<List<Category>> getActiveExpenseCategories() async {
    final isar = IsarService.isar;

    return await isar.categorys
        .where()
        .filter()
        .typeEqualTo("expense")
        .and()
        .isActiveEqualTo(true)
        .findAll();
  }

  static Future<List<Category>> getActiveManualExpenseCategories() async {
    final isar = IsarService.isar;

    return await isar.categorys
        .where()
        .filter()
        .typeEqualTo("expense")
        .and()
        .isActiveEqualTo(true)
        .and()
        .isSystemGeneratedEqualTo(false)
        .findAll();
  }

  static Future<List<Category>> getAllManualExpenseCategories() async {
    final isar = IsarService.isar;

    return await isar.categorys
        .where()
        .filter()
        .typeEqualTo("expense")
        .and()
        .isSystemGeneratedEqualTo(false)
        .findAll();
  }

  static Future<void> addExpenseCategory(String name) async {
    final isar = IsarService.isar;

    final category = Category()
      ..name = name
      ..type = "expense"
      ..isActive = true
      ..createdAt = DateTime.now();

    await isar.writeTxn(() async {
      await isar.categorys.put(category);
    });
  }

  static Future<void> updateExpenseCategory(Category category) async {
    final isar = IsarService.isar;
    if (category.isSystemGenerated) {
      throw Exception('Sistem kategorisi duzenlenemez.');
    }

    await isar.writeTxn(() async {
      await isar.categorys.put(category);
    });
  }

  static Future<void> deleteExpenseCategory(int id) async {
    final isar = IsarService.isar;
    final existing = await isar.categorys.get(id);
    if (existing?.isSystemGenerated == true) {
      throw Exception('Sistem kategorisi silinemez.');
    }

    await isar.writeTxn(() async {
      await isar.categorys.delete(id);
    });
  }

  static Future<bool> isExpenseCategoryUsed(int categoryId) async {
    final isar = IsarService.isar;

    final count = await isar.financeTransactions
        .where()
        .filter()
        .categoryIdEqualTo(categoryId)
        .and()
        .typeEqualTo("expense")
        .count();

    return count > 0;
  }

  static Future<void> setActive(int id, bool value) async {
    final isar = IsarService.isar;
    final category = await isar.categorys.get(id);
    if (category == null) return;
    if (category.isSystemGenerated) {
      throw Exception('Sistem kategorisi degistirilemez.');
    }

    await isar.writeTxn(() async {
      category.isActive = value;
      await isar.categorys.put(category);
    });
  }

  static Future<void> seedExpenseDefaultsIfEmpty() async {
    final isar = IsarService.isar;
    final existing = await isar.categorys
        .where()
        .filter()
        .typeEqualTo("expense")
        .and()
        .isSystemGeneratedEqualTo(false)
        .findAll();

    if (existing.isNotEmpty) return;

    final defaults = [
      "Market",
      "Fatura",
      "Ulaşım",
    ];

    await isar.writeTxn(() async {
      for (final name in defaults) {
        final category = Category()
          ..name = name
          ..type = "expense"
          ..isActive = true
          ..createdAt = DateTime.now();

        await isar.categorys.put(category);
      }
    });
  }
}
