import 'cloud_sync_api.dart';
import 'remote_sync_record.dart';

class MemoryCloudSyncApi implements CloudSyncApi {
  final Map<String, RemoteSyncRecord> _records = <String, RemoteSyncRecord>{};
  int _idCounter = 0;

  @override
  Future<List<RemoteSyncRecord>> pullChanges({
    required String userId,
    DateTime? since,
  }) async {
    final values = _records.values.where((record) {
      if (since == null) return true;
      return record.updatedAt.isAfter(since);
    }).toList()
      ..sort((a, b) => a.updatedAt.compareTo(b.updatedAt));
    return values;
  }

  @override
  Future<List<RemoteSyncRecord>> pushRecords({
    required String userId,
    required List<RemoteSyncRecord> records,
  }) async {
    // Testlerde gercek backend yerine bellek ici bir cloud davranisi taklit edilir.
    final ack = <RemoteSyncRecord>[];
    for (final record in records) {
      final remoteId = record.remoteId.isEmpty ? _nextId(record.entityType) : record.remoteId;
      final existing = _records['${record.entityType}:$remoteId'];
      final nextVersion = existing == null ? record.version : existing.version + 1;
      final updated = RemoteSyncRecord(
        entityType: record.entityType,
        remoteId: remoteId,
        version: nextVersion,
        updatedAt: DateTime.now().toUtc(),
        deletedAt: record.deletedAt,
        payload: record.payload,
      );
      _records['${record.entityType}:$remoteId'] = updated;
      ack.add(updated);
    }
    return ack;
  }

  String _nextId(String entityType) {
    _idCounter += 1;
    return '$entityType-$_idCounter';
  }
}
