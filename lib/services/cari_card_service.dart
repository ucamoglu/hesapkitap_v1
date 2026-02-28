import 'package:isar/isar.dart';

import '../database/isar_service.dart';
import '../models/cari_card.dart';

class CariCardService {
  /// Tum cari kartlari oldugu gibi getirir.
  static Future<List<CariCard>> getAll() async {
    final isar = IsarService.isar;
    return await isar.cariCards.where().findAll();
  }

  /// Sadece aktif cari kartlari filtreler.
  static Future<List<CariCard>> getActive() async {
    final isar = IsarService.isar;
    return await isar.cariCards.where().filter().isActiveEqualTo(true).findAll();
  }

  /// Yeni cari kart kaydeder.
  static Future<void> add(CariCard card) async {
    final isar = IsarService.isar;
    await isar.writeTxn(() async {
      await isar.cariCards.put(card);
    });
  }

  /// Cari kart uzerindeki alanlari gunceller.
  static Future<void> update(CariCard card) async {
    final isar = IsarService.isar;
    await isar.writeTxn(() async {
      await isar.cariCards.put(card);
    });
  }

  /// Cari karti silmeden aktif/pasif duruma alir.
  static Future<void> setActive(int id, bool value) async {
    final isar = IsarService.isar;
    final card = await isar.cariCards.get(id);
    if (card == null) return;

    await isar.writeTxn(() async {
      card.isActive = value;
      await isar.cariCards.put(card);
    });
  }
}
