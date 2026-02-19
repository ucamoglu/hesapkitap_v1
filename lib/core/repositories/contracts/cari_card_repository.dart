import '../../../models/cari_card.dart';

abstract class CariCardRepository {
  Future<List<CariCard>> getAll();
  Future<List<CariCard>> getActive();
  Future<void> add(CariCard card);
  Future<void> update(CariCard card);
  Future<void> setActive(int id, bool value);
}
