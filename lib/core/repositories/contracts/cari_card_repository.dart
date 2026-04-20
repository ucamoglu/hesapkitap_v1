import '../../../models/cari_card.dart';

abstract class CariCardRepository {
  // Tum cari kartlari getirir.
  Future<List<CariCard>> getAll();
  // Aktif cari kartlari getirir.
  Future<List<CariCard>> getActive();
  // Yeni cari kart ekler.
  Future<void> add(CariCard card);
  // Cari karti gunceller.
  Future<void> update(CariCard card);
  // Cari karti aktif/pasif hale getirir.
  Future<void> setActive(int id, bool value);
}
