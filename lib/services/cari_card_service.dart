import 'package:isar/isar.dart';

import '../database/isar_service.dart';
import '../models/cari_card.dart';

class CariCardService {
  static void _validateCard(CariCard card) {
    final validTypes = {'person', 'company'};
    if (!validTypes.contains(card.type)) {
      throw Exception('Geçersiz cari kart türü.');
    }

    final fullName = card.fullName?.trim() ?? '';
    final title = card.title?.trim() ?? '';
    if (card.type == 'person' && fullName.isEmpty) {
      throw Exception('Kişi kartında isim soyisim zorunludur.');
    }
    if (card.type == 'company' && title.isEmpty) {
      throw Exception('Firma kartında ünvan zorunludur.');
    }

    final validCurrencyTypes = {'tl', 'foreign'};
    if (!validCurrencyTypes.contains(card.currencyType)) {
      throw Exception('Geçersiz para birimi türü.');
    }

    if (card.currencyType != 'foreign') {
      card
        ..currencyType = 'tl'
        ..foreignMarketType = null
        ..foreignCode = null
        ..foreignName = null;
    } else {
      final validMarkets = {'currency', 'metal', 'stock', 'crypto'};
      final marketType = card.foreignMarketType?.trim();
      final code = card.foreignCode?.trim().toUpperCase() ?? '';
      final name = card.foreignName?.trim() ?? '';
      if (marketType == null || !validMarkets.contains(marketType)) {
        throw Exception('Yabancı para türü seçiniz.');
      }
      if (code.isEmpty) {
        throw Exception('Takip edilen enstrümanı seçiniz.');
      }
      if (name.isEmpty) {
        throw Exception('Seçilen enstrüman adı bulunamadı.');
      }
      card
        ..foreignMarketType = marketType
        ..foreignCode = code
        ..foreignName = name;
    }

    card
      ..fullName = fullName.isEmpty ? null : fullName
      ..title = title.isEmpty ? null : title
      ..phone = card.phone?.trim().isEmpty ?? true ? null : card.phone!.trim()
      ..email = card.email?.trim().isEmpty ?? true ? null : card.email!.trim()
      ..note = card.note?.trim().isEmpty ?? true ? null : card.note!.trim();
  }

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
    _validateCard(card);
    await isar.writeTxn(() async {
      await isar.cariCards.put(card);
    });
  }

  /// Cari kart uzerindeki alanlari gunceller.
  static Future<void> update(CariCard card) async {
    final isar = IsarService.isar;
    _validateCard(card);
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
