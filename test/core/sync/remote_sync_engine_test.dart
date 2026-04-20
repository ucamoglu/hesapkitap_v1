import 'dart:ffi';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hesapkitap_v1/core/sync/api/memory_cloud_sync_api.dart';
import 'package:hesapkitap_v1/core/sync/api/remote_sync_record.dart';
import 'package:hesapkitap_v1/core/sync/mappers/default_sync_mappers.dart';
import 'package:hesapkitap_v1/core/sync/mappers/sync_entity_mapper.dart';
import 'package:hesapkitap_v1/core/sync/mappers/sync_mapper_registry.dart';
import 'package:hesapkitap_v1/core/sync/sync_direction.dart';
import 'package:hesapkitap_v1/core/sync/sync_engine.dart';
import 'package:hesapkitap_v1/core/sync/sync_metadata_store.dart';
import 'package:hesapkitap_v1/core/sync/sync_record.dart';
import 'package:hesapkitap_v1/core/sync/sync_state.dart';
import 'package:hesapkitap_v1/database/isar_service.dart';
import 'package:hesapkitap_v1/models/account.dart';
import 'package:hesapkitap_v1/models/category.dart';
import 'package:hesapkitap_v1/models/finance_transaction.dart';
import 'package:isar/isar.dart';

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

  test('remote sync engine preserves finance transaction coordinates on pull', () async {
    final metadataDirectory = await Directory.systemTemp.createTemp(
      'remote-sync-finance-coordinates',
    );
    final isarDirectory = await Directory.systemTemp.createTemp(
      'remote-sync-finance-coordinates-isar',
    );
    final isar = await _openTestIsar(isarDirectory.path);
    addTearDown(() async {
      await _closeTestIsar(isar, isarDirectory);
      if (await metadataDirectory.exists()) {
        await metadataDirectory.delete(recursive: true);
      }
    });

    final accountId = await isar.writeTxn(() async {
      final account = Account()
        ..name = 'Wallet'
        ..type = 'cash'
        ..balance = 0
        ..isActive = true
        ..createdAt = DateTime.utc(2026, 3, 1);
      return isar.accounts.put(account);
    });
    final categoryId = await isar.writeTxn(() async {
      final category = Category()
        ..name = 'Food'
        ..type = 'expense'
        ..isActive = true
        ..isSystemGenerated = false
        ..createdAt = DateTime.utc(2026, 3, 1);
      return isar.categorys.put(category);
    });

    final store = SyncMetadataStore(directoryProvider: () async => metadataDirectory);
    await store.saveAllRecords([
      SyncRecord(
        entityType: 'account',
        localId: accountId,
        remoteId: 'account-1',
        version: 1,
        updatedAt: DateTime.utc(2026, 3, 1, 9),
        lastSyncedAt: DateTime.utc(2026, 3, 1, 9),
        state: SyncState.synced,
        deletedAt: null,
      ),
      SyncRecord(
        entityType: 'category',
        localId: categoryId,
        remoteId: 'category-1',
        version: 1,
        updatedAt: DateTime.utc(2026, 3, 1, 9),
        lastSyncedAt: DateTime.utc(2026, 3, 1, 9),
        state: SyncState.synced,
        deletedAt: null,
      ),
    ]);

    final api = MemoryCloudSyncApi();
    await api.pushRecords(
      userId: 'test-user',
      records: [
        RemoteSyncRecord(
          entityType: 'finance_transaction',
          remoteId: '',
          version: 1,
          updatedAt: DateTime.utc(2026, 3, 1, 10),
          deletedAt: null,
          payload: {
            'accountRemoteId': 'account-1',
            'categoryRemoteId': 'category-1',
            'type': 'expense',
            'amount': 250.75,
            'latitude': 41.0082,
            'longitude': 28.9784,
            'description': 'Lunch',
            'incomePlanRemoteId': null,
            'expensePlanRemoteId': null,
            'date': DateTime.utc(2026, 3, 1, 10).toIso8601String(),
            'createdAt': DateTime.utc(2026, 3, 1, 10).toIso8601String(),
          },
        ),
      ],
    );

    final engine = RemoteSyncEngine(
      cloudApi: api,
      metadataStore: store,
      mapperRegistry: SyncMapperRegistry(buildDefaultSyncMappers()),
      userIdProvider: () async => 'test-user',
    );

    final result = await engine.run(direction: SyncDirection.pull);
    final transactions = await isar.financeTransactions.where().findAll();

    expect(result.pulled, 1);
    expect(transactions, hasLength(1));
    expect(transactions.single.latitude, 41.0082);
    expect(transactions.single.longitude, 28.9784);
  });

  test('remote sync engine deletes local finance transaction on remote tombstone', () async {
    final metadataDirectory = await Directory.systemTemp.createTemp(
      'remote-sync-finance-delete',
    );
    final isarDirectory = await Directory.systemTemp.createTemp(
      'remote-sync-finance-delete-isar',
    );
    final isar = await _openTestIsar(isarDirectory.path);
    addTearDown(() async {
      await _closeTestIsar(isar, isarDirectory);
      if (await metadataDirectory.exists()) {
        await metadataDirectory.delete(recursive: true);
      }
    });

    final financeId = await isar.writeTxn(() async {
      final transaction = FinanceTransaction()
        ..accountId = 1
        ..categoryId = 1
        ..type = 'expense'
        ..amount = 99.9
        ..latitude = 41.015
        ..longitude = 28.99
        ..description = 'Existing'
        ..date = DateTime.utc(2026, 3, 2, 9)
        ..createdAt = DateTime.utc(2026, 3, 2, 9);
      return isar.financeTransactions.put(transaction);
    });

    final store = SyncMetadataStore(directoryProvider: () async => metadataDirectory);
    await store.saveAllRecords([
      SyncRecord(
        entityType: 'finance_transaction',
        localId: financeId,
        remoteId: 'finance-1',
        version: 1,
        updatedAt: DateTime.utc(2026, 3, 2, 9),
        lastSyncedAt: DateTime.utc(2026, 3, 2, 9),
        state: SyncState.synced,
        deletedAt: null,
      ),
    ]);

    final api = MemoryCloudSyncApi();
    await api.pushRecords(
      userId: 'test-user',
      records: [
        RemoteSyncRecord(
          entityType: 'finance_transaction',
          remoteId: 'finance-1',
          version: 1,
          updatedAt: DateTime.utc(2026, 3, 2, 10),
          deletedAt: DateTime.utc(2026, 3, 2, 10),
          payload: const {},
        ),
      ],
    );

    final engine = RemoteSyncEngine(
      cloudApi: api,
      metadataStore: store,
      mapperRegistry: SyncMapperRegistry(buildDefaultSyncMappers()),
      userIdProvider: () async => 'test-user',
    );

    final result = await engine.run(direction: SyncDirection.pull);
    final deleted = await isar.financeTransactions.get(financeId);
    final records = await store.loadRecords();

    expect(result.pulled, 1);
    expect(deleted, isNull);
    expect(records.containsKey('finance_transaction:$financeId'), isFalse);
  });
}

Future<Isar> _openTestIsar(String directory) async {
  for (final name in Isar.instanceNames) {
    await Isar.getInstance(name)?.close(deleteFromDisk: true);
  }
  await Isar.initializeIsarCore(
    libraries: {
      Abi.current(): '/Users/ucamoglu/.pub-cache/hosted/pub.dev/isar_flutter_libs-3.1.0+1/macos/libisar.dylib',
    },
  );
  final isar = await Isar.open(
    [
      AccountSchema,
      CategorySchema,
      FinanceTransactionSchema,
    ],
    directory: directory,
    name: 'test',
  );
  IsarService.isar = isar;
  return isar;
}

Future<void> _closeTestIsar(Isar isar, Directory directory) async {
  await isar.close(deleteFromDisk: true);
  if (await directory.exists()) {
    await directory.delete(recursive: true);
  }
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
