import '../../../models/cari_card.dart';
import '../../../services/cari_card_service.dart';
import '../../sync/sync_change_tracker.dart';
import '../contracts/cari_card_repository.dart';

class LocalCariCardRepository implements CariCardRepository {
  LocalCariCardRepository({
    SyncChangeTracker? changeTracker,
  }) : _changeTracker = changeTracker ?? SyncChangeTracker();

  final SyncChangeTracker _changeTracker;

  @override
  Future<void> add(CariCard card) async {
    await CariCardService.add(card);
    await _changeTracker.markUpsert(
      entityType: 'cari_card',
      localId: card.id,
    );
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
  Future<void> setActive(int id, bool value) async {
    await CariCardService.setActive(id, value);
    await _changeTracker.markUpsert(
      entityType: 'cari_card',
      localId: id,
    );
  }

  @override
  Future<void> update(CariCard card) async {
    await CariCardService.update(card);
    await _changeTracker.markUpsert(
      entityType: 'cari_card',
      localId: card.id,
    );
  }
}
