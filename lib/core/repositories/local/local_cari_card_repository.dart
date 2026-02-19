import '../../../models/cari_card.dart';
import '../../../services/cari_card_service.dart';
import '../contracts/cari_card_repository.dart';

class LocalCariCardRepository implements CariCardRepository {
  const LocalCariCardRepository();

  @override
  Future<void> add(CariCard card) {
    return CariCardService.add(card);
  }

  @override
  Future<List<CariCard>> getActive() {
    return CariCardService.getActive();
  }

  @override
  Future<List<CariCard>> getAll() {
    return CariCardService.getAll();
  }

  @override
  Future<void> setActive(int id, bool value) {
    return CariCardService.setActive(id, value);
  }

  @override
  Future<void> update(CariCard card) {
    return CariCardService.update(card);
  }
}
