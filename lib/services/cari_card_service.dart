import 'package:isar/isar.dart';

import '../database/isar_service.dart';
import '../models/cari_card.dart';

class CariCardService {
  static Future<List<CariCard>> getAll() async {
    final isar = IsarService.isar;
    return await isar.cariCards.where().findAll();
  }

  static Future<List<CariCard>> getActive() async {
    final isar = IsarService.isar;
    return await isar.cariCards.where().filter().isActiveEqualTo(true).findAll();
  }

  static Future<void> add(CariCard card) async {
    final isar = IsarService.isar;
    await isar.writeTxn(() async {
      await isar.cariCards.put(card);
    });
  }

  static Future<void> update(CariCard card) async {
    final isar = IsarService.isar;
    await isar.writeTxn(() async {
      await isar.cariCards.put(card);
    });
  }

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
