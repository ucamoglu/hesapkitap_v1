import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hesapkitap_v1/core/sync/api/memory_cloud_sync_api.dart';
import 'package:hesapkitap_v1/core/sync/api/remote_sync_record.dart';
import 'package:hesapkitap_v1/core/sync/mappers/sync_entity_mapper.dart';
import 'package:hesapkitap_v1/core/sync/mappers/sync_mapper_registry.dart';
import 'package:hesapkitap_v1/core/sync/sync_direction.dart';
import 'package:hesapkitap_v1/core/sync/sync_engine.dart';
import 'package:hesapkitap_v1/core/sync/sync_metadata_store.dart';
import 'package:hesapkitap_v1/core/sync/sync_record.dart';
import 'package:hesapkitap_v1/core/sync/sync_state.dart';

void main() {
  test('remote sync engine pushes local records and stores remote metadata', () async {
    final directory = await Directory.systemTemp.createTemp('remote-sync-push');
    addTearDown(() async {
      if (await directory.exists()) {
        await directory.delete(recursive: true);
      }
    });

    final store = SyncMetadataStore(directoryProvider: () async => directory);
    final mapper = _FakeMapper();
    mapper.items[1] = <String, dynamic>{'name': 'Wallet'};
    await store.saveAllRecords([
      SyncRecord.initial(
        entityType: 'fake_entity',
        localId: 1,
        now: DateTime.utc(2026, 2, 28, 10),
      ),
    ]);

    final engine = RemoteSyncEngine(
      cloudApi: MemoryCloudSyncApi(),
      metadataStore: store,
      mapperRegistry: SyncMapperRegistry([mapper]),
      userIdProvider: () async => 'test-user',
    );

    final result = await engine.run(direction: SyncDirection.push);
    final records = await store.loadRecords();
    final metadata = records['fake_entity:1'];

    expect(result.pushed, 1);
    expect(metadata, isNotNull);
    expect(metadata?.remoteId, isNotEmpty);
    expect(metadata?.state, SyncState.synced);
  });

  test('remote sync engine pulls remote records into local mapper', () async {
    final directory = await Directory.systemTemp.createTemp('remote-sync-pull');
    addTearDown(() async {
      if (await directory.exists()) {
        await directory.delete(recursive: true);
      }
    });

    final store = SyncMetadataStore(directoryProvider: () async => directory);
    final api = MemoryCloudSyncApi();
    final mapper = _FakeMapper();
    final ack = await api.pushRecords(
      userId: 'test-user',
      records: [
        RemoteSyncRecord(
          entityType: 'fake_entity',
          remoteId: '',
          version: 1,
          updatedAt: DateTime.utc(2026, 2, 28, 11),
          deletedAt: null,
          payload: const {'name': 'Imported'},
        ),
      ],
    );

    expect(ack, hasLength(1));

    final engine = RemoteSyncEngine(
      cloudApi: api,
      metadataStore: store,
      mapperRegistry: SyncMapperRegistry([mapper]),
      userIdProvider: () async => 'test-user',
    );

    final result = await engine.run(direction: SyncDirection.pull);

    expect(result.pulled, 1);
    expect(mapper.items.values.single['name'], 'Imported');
    final records = await store.loadRecords();
    expect(records.values.single.remoteId, ack.single.remoteId);
  });
}

class _FakeMapper implements SyncEntityMapper {
  final Map<int, Map<String, dynamic>> items = <int, Map<String, dynamic>>{};
  int _nextId = 100;

  @override
  String get entityType => 'fake_entity';

  @override
  Future<bool> deleteLocal(int localId) async {
    return items.remove(localId) != null;
  }

  @override
  Future<RemoteSyncRecord?> exportRecord({
    required SyncRecord metadata,
    required SyncReferenceResolver resolver,
  }) async {
    final payload = items[metadata.localId];
    if (payload == null) return null;
    return RemoteSyncRecord(
      entityType: entityType,
      remoteId: metadata.remoteId ?? '',
      version: metadata.version,
      updatedAt: metadata.updatedAt.toUtc(),
      deletedAt: metadata.deletedAt?.toUtc(),
      payload: payload,
    );
  }

  @override
  Future<SyncImportResult> importRecord({
    required RemoteSyncRecord remote,
    required SyncReferenceResolver resolver,
  }) async {
    final existingId = resolver.localIdFor(entityType, remote.remoteId);
    final localId = existingId ?? _nextId++;
    items[localId] = Map<String, dynamic>.from(remote.payload);
    return SyncImportResult.applied(localId);
  }
}
