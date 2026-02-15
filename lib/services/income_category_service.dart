import 'package:isar/isar.dart';

import '../database/isar_service.dart';
import '../models/finance_transaction.dart';
import '../models/income_category.dart';

class IncomeCategoryService {

  static Future<List<IncomeCategory>> getAll() async {
    final isar = IsarService.isar;

    return await isar.incomeCategorys.where().findAll();
  }

  static Future<List<IncomeCategory>> getActive() async {
    final isar = IsarService.isar;

    return await isar.incomeCategorys
        .where()
        .filter()
        .isActiveEqualTo(true)
        .findAll();
  }

  static Future<List<IncomeCategory>> getActiveManual() async {
    final isar = IsarService.isar;

    return await isar.incomeCategorys
        .where()
        .filter()
        .isActiveEqualTo(true)
        .and()
        .isSystemGeneratedEqualTo(false)
        .findAll();
  }

  static Future<List<IncomeCategory>> getAllManual() async {
    final isar = IsarService.isar;

    return await isar.incomeCategorys
        .where()
        .filter()
        .isSystemGeneratedEqualTo(false)
        .findAll();
  }

  static Future<void> add(String name) async {
    final isar = IsarService.isar;

    final category = IncomeCategory()
      ..name = name
      ..createdAt = DateTime.now();

    await isar.writeTxn(() async {
      await isar.incomeCategorys.put(category);
    });
  }

  static Future<void> setActive(int id, bool value) async {
    final isar = IsarService.isar;

    final category = await isar.incomeCategorys.get(id);
    if (category == null) return;
    if (category.isSystemGenerated) {
      throw Exception('Sistem kategorisi degistirilemez.');
    }

    await isar.writeTxn(() async {
      category.isActive = value;
      await isar.incomeCategorys.put(category);
    });
  }

  static Future<void> update(IncomeCategory category) async {
    final isar = IsarService.isar;
    if (category.isSystemGenerated) {
      throw Exception('Sistem kategorisi duzenlenemez.');
    }

    await isar.writeTxn(() async {
      await isar.incomeCategorys.put(category);
    });
  }

  static Future<void> delete(int id) async {
    final isar = IsarService.isar;
    final existing = await isar.incomeCategorys.get(id);
    if (existing?.isSystemGenerated == true) {
      throw Exception('Sistem kategorisi silinemez.');
    }

    await isar.writeTxn(() async {
      await isar.incomeCategorys.delete(id);
    });
  }

  static Future<bool> isCategoryUsed(int categoryId) async {
    final isar = IsarService.isar;

    final count = await isar.financeTransactions
        .where()
        .filter()
        .categoryIdEqualTo(categoryId)
        .and()
        .typeEqualTo("income")
        .count();

    return count > 0;
  }

  static Future<void> seedDefaultsIfEmpty() async {
    final isar = IsarService.isar;

    final manualCount = await isar.incomeCategorys
        .where()
        .filter()
        .isSystemGeneratedEqualTo(false)
        .count();
    if (manualCount > 0) return;

    final defaults = [
      "Maaş",
      "Kira",
      "Başlangıç Bakiyesi",
    ];

    await isar.writeTxn(() async {
      for (final name in defaults) {
        final category = IncomeCategory()
          ..name = name
          ..createdAt = DateTime.now()
          ..isActive = true;

        await isar.incomeCategorys.put(category);
      }
    });
  }
}
