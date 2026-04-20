import 'sync_metadata_store.dart';
import 'sync_record.dart';
import 'sync_state.dart';

class SyncChangeTracker {
  SyncChangeTracker({
    SyncMetadataStore? metadataStore,
  }) : _metadataStore = metadataStore ?? SyncMetadataStore();

  final SyncMetadataStore _metadataStore;

  Future<void> markUpsert({
    required String entityType,
    required int localId,
  }) async {
    final records = await _metadataStore.loadRecords();
    final key = '$entityType:$localId';
    final now = DateTime.now();
    final existing = records[key];

    if (existing == null) {
      records[key] = SyncRecord.initial(
        entityType: entityType,
        localId: localId,
        now: now,
      );
      await _metadataStore.saveRecords(records);
      return;
    }

    final nextState = switch (existing.state) {
      SyncState.synced => SyncState.pendingUpload,
      SyncState.conflict => SyncState.conflict,
      SyncState.pendingDelete => SyncState.pendingDelete,
      _ => SyncState.localOnly,
    };

    records[key] = existing.copyWith(
      updatedAt: now,
      state: nextState,
      deletedAt: nextState == SyncState.pendingDelete ? existing.deletedAt : null,
    );
    await _metadataStore.saveRecords(records);
  }

  Future<void> markDelete({
    required String entityType,
    required int localId,
  }) async {
    final records = await _metadataStore.loadRecords();
    final key = '$entityType:$localId';
    final existing = records[key];
    if (existing == null) {
      return;
    }

    if (existing.remoteId == null) {
      records.remove(key);
      await _metadataStore.saveRecords(records);
      return;
    }

    records[key] = existing.copyWith(
      updatedAt: DateTime.now(),
      state: SyncState.pendingDelete,
      deletedAt: DateTime.now(),
    );
    await _metadataStore.saveRecords(records);
  }
}
