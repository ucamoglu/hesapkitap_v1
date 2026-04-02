import 'package:isar/isar.dart';

import '../database/isar_service.dart';
import '../models/category.dart';
import '../models/finance_transaction.dart';

class CategoryService {
  static const String assetPurchaseSystemKey = 'asset_purchase';

  static void _validateExpenseCategory(Category category) {
    final name = category.name.trim();
    if (name.isEmpty) {
      throw Exception('Kategori adı zorunludur.');
    }

    if (category.type != 'expense') {
      throw Exception('Geçersiz gider kategori türü.');
    }

    category.name = name;
  }

  /// Tum gider kategorilerini getirir.
  static Future<List<Category>> getAllExpenseCategories() async {
    final isar = IsarService.isar;

    return await isar.categorys
        .where()
        .filter()
        .typeEqualTo("expense")
        .findAll();
  }

  /// Aktif gider kategorilerini form ekranlari icin filtreler.
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

  /// Sistem tarafindan olusturulmamis aktif gider kategorilerini getirir.
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

  /// Manuel tum gider kategorilerini yonetim ekranlari icin dondurur.
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

  /// Yeni manuel gider kategorisi olusturur.
  static Future<void> addExpenseCategory(String name) async {
    final isar = IsarService.isar;

    final category = Category()
      ..name = name
      ..type = "expense"
      ..isActive = true
      ..createdAt = DateTime.now();
    _validateExpenseCategory(category);

    await isar.writeTxn(() async {
      await isar.categorys.put(category);
    });
  }

  /// Sistem kategorilerinin duzenlenmesini engelleyerek mevcut kaydi gunceller.
  static Future<void> updateExpenseCategory(Category category) async {
    final isar = IsarService.isar;
    if (category.isSystemGenerated) {
      throw Exception('Sistem kategorisi duzenlenemez.');
    }
    _validateExpenseCategory(category);

    await isar.writeTxn(() async {
      await isar.categorys.put(category);
    });
  }

  /// Sistem kategorilerinin silinmesini engelleyerek kaydi kaldirir.
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

  /// Bir gider kategorisinin hareketlerde kullanilip kullanilmadigini denetler.
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

  /// Kategoriyi ekrandan gizlemek icin aktiflik bayragini degistirir.
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

  /// Uygulama ilk acildiginda temel gider kategorilerini bos veritabanina ekler.
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

  static Future<Category> ensureAssetPurchaseCategory() async {
    final isar = IsarService.isar;
    final existing = await isar.categorys
        .where()
        .filter()
        .typeEqualTo('expense')
        .and()
        .systemKeyEqualTo(assetPurchaseSystemKey)
        .findFirst();
    if (existing != null) {
      if (!existing.isActive || !existing.isSystemGenerated) {
        await isar.writeTxn(() async {
          existing
            ..name = 'Varlık Alımı'
            ..isActive = true
            ..isSystemGenerated = true
            ..systemKey = assetPurchaseSystemKey;
          await isar.categorys.put(existing);
        });
      }
      return existing;
    }

    final category = Category()
      ..name = 'Varlık Alımı'
      ..type = 'expense'
      ..isActive = true
      ..isSystemGenerated = true
      ..systemKey = assetPurchaseSystemKey
      ..createdAt = DateTime.now();
    await isar.writeTxn(() async {
      await isar.categorys.put(category);
    });
    return category;
  }
}
