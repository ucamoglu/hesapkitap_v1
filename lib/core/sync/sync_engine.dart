import '../../services/user_profile_service.dart';
import 'api/cloud_sync_api.dart';
import 'api/noop_cloud_sync_api.dart';
import 'api/remote_sync_record.dart';
import 'mappers/default_sync_mappers.dart';
import 'mappers/sync_entity_mapper.dart';
import 'mappers/sync_mapper_registry.dart';
import 'sync_conflict_policy.dart';
import 'sync_direction.dart';
import 'sync_metadata_store.dart';
import 'sync_record.dart';
import 'sync_result.dart';
import 'sync_state.dart';

abstract class SyncEngine {
  /// Verilen yonde senkronizasyonu baslatir ve sonuc ozetini dondurur.
  Future<SyncResult> run({required SyncDirection direction});
}

class NoopSyncEngine implements SyncEngine {
  const NoopSyncEngine();

  @override
  Future<SyncResult> run({required SyncDirection direction}) async {
    return SyncResult.empty;
  }
}

class RemoteSyncEngine implements SyncEngine {
  RemoteSyncEngine({
    CloudSyncApi? cloudApi,
    SyncMetadataStore? metadataStore,
    SyncMapperRegistry? mapperRegistry,
    Future<String> Function()? userIdProvider,
  })  : _cloudApi = cloudApi ?? const NoopCloudSyncApi(),
        _metadataStore = metadataStore ?? SyncMetadataStore(),
        _mapperRegistry = mapperRegistry ??
            SyncMapperRegistry(buildDefaultSyncMappers()),
        _userIdProvider = userIdProvider;

  final CloudSyncApi _cloudApi;
  final SyncMetadataStore _metadataStore;
  final SyncMapperRegistry _mapperRegistry;
  final Future<String> Function()? _userIdProvider;

  static const List<String> _pushOrder = <String>[
    'account',
    'category',
    'income_category',
    'user_profile',
    'tracked_currency',
    'tracked_currency_state',
    'tracked_metal',
    'tracked_metal_state',
    'tracked_stock',
    'tracked_stock_state',
    'tracked_crypto',
    'tracked_crypto_state',
    'cari_card',
    'subscription_definition',
    'income_plan',
    'expense_plan',
    'finance_transaction',
    'transfer_transaction',
    'investment_transaction',
    'cari_transaction',
    'transaction_attachment',
  ];

  @override
  /// Yerel metadata kayitlarina gore push ve/veya pull akisini sirayla calistirir.
  Future<SyncResult> run({required SyncDirection direction}) async {
    final records = await _metadataStore.loadRecords();
    final preference = await _metadataStore.loadPreference();
    final resolver = _MemorySyncReferenceResolver(records);
    final userId = await _resolveUserId();
    var pushed = 0;
    var pulled = 0;
    var conflicts = 0;

    if (direction == SyncDirection.push ||
        direction == SyncDirection.bidirectional) {
      pushed = await _pushPending(
        userId: userId,
        records: records,
        resolver: resolver,
      );
    }

    if (direction == SyncDirection.pull ||
        direction == SyncDirection.bidirectional) {
      final pullResult = await _pullChanges(
        userId: userId,
        records: records,
        resolver: resolver,
        conflictPolicy:
            preference?.conflictPolicy ?? SyncConflictPolicy.manualReview,
      );
      pulled = pullResult.pulled;
      conflicts += pullResult.conflicts;
    }

    await _metadataStore.saveRecords(records);
    return SyncResult(
      pushed: pushed,
      pulled: pulled,
      conflicts: conflicts,
    );
  }

  Future<int> _pushPending({
    required String userId,
    required Map<String, SyncRecord> records,
    required _MemorySyncReferenceResolver resolver,
  }) async {
    // Iliskili kayitlar once olussun diye push sirasi korunur.
    var pushed = 0;
    final ordered = records.values.toList()
      ..sort((a, b) {
        final ai = _pushOrder.indexOf(a.entityType);
        final bi = _pushOrder.indexOf(b.entityType);
        return (ai == -1 ? 999 : ai).compareTo(bi == -1 ? 999 : bi);
      });

    for (final metadata in ordered) {
      if (metadata.state == SyncState.synced || metadata.state == SyncState.conflict) {
        continue;
      }
      final mapper = _mapperRegistry.mapperFor(metadata.entityType);
      if (mapper == null) continue;

      // Silinmis kayitlar tombstone mantigiyla cloud'a bildirilir.
      final outbound = metadata.state == SyncState.pendingDelete
          ? RemoteSyncRecord(
              entityType: metadata.entityType,
              remoteId: metadata.remoteId ?? '',
              version: metadata.version,
              updatedAt: metadata.updatedAt.toUtc(),
              deletedAt: metadata.deletedAt?.toUtc() ?? DateTime.now().toUtc(),
              payload: const {},
            )
          : await mapper.exportRecord(metadata: metadata, resolver: resolver);
      if (outbound == null) continue;

      final ack = await _cloudApi.pushRecords(
        userId: userId,
        records: [outbound],
      );
      if (ack.isEmpty) continue;
      final synced = ack.first;
      final updated = metadata.copyWith(
        remoteId: synced.remoteId,
        version: synced.version,
        updatedAt: synced.updatedAt.toLocal(),
        lastSyncedAt: DateTime.now(),
        state: SyncState.synced,
      );
      records[updated.key] = updated;
      resolver.update(updated);
      pushed += 1;
    }

    return pushed;
  }

  Future<_PullResult> _pullChanges({
    required String userId,
    required Map<String, SyncRecord> records,
    required _MemorySyncReferenceResolver resolver,
    required SyncConflictPolicy conflictPolicy,
  }) async {
    // Son sync zamanindan sonra gelen cloud degisikliklerini uygular.
    var pulled = 0;
    var conflicts = 0;
    final since = records.values
        .map((record) => record.lastSyncedAt)
        .whereType<DateTime>()
        .fold<DateTime?>(null, (prev, next) {
      if (prev == null) return next;
      return prev.isAfter(next) ? prev : next;
    });
    final changes = await _cloudApi.pullChanges(
      userId: userId,
      since: since?.toUtc(),
    );

    for (final remote in changes) {
      final mapper = _mapperRegistry.mapperFor(remote.entityType);
      if (mapper == null) continue;
      final existing = resolver.byRemoteId(remote.entityType, remote.remoteId);

      if (remote.isDeleted) {
        if (existing != null) {
          await mapper.deleteLocal(existing.localId);
          records.remove(existing.key);
          resolver.remove(existing.key);
          pulled += 1;
        }
        continue;
      }

      if (existing != null &&
          (existing.state == SyncState.localOnly ||
              existing.state == SyncState.pendingUpload)) {
        // Yerelde henuz cloud'a gitmemis degisiklik varsa conflict politikasi devreye girer.
        final shouldApply = _shouldApplyRemote(
          local: existing,
          remote: remote,
          conflictPolicy: conflictPolicy,
        );
        if (!shouldApply) {
          conflicts += 1;
          if (conflictPolicy == SyncConflictPolicy.manualReview) {
            final conflictRecord = existing.copyWith(state: SyncState.conflict);
            records[conflictRecord.key] = conflictRecord;
            resolver.update(conflictRecord);
          }
          continue;
        }
      }

      final imported = await mapper.importRecord(
        remote: remote,
        resolver: resolver,
      );
      if (imported.conflict || imported.localId == null) {
        conflicts += 1;
        continue;
      }

      final key = '${remote.entityType}:${imported.localId}';
      final updated = SyncRecord(
        entityType: remote.entityType,
        localId: imported.localId!,
        remoteId: remote.remoteId,
        version: remote.version,
        updatedAt: remote.updatedAt.toLocal(),
        lastSyncedAt: DateTime.now(),
        state: SyncState.synced,
        deletedAt: null,
      );
      records[key] = updated;
      resolver.update(updated);
      pulled += 1;
    }

    return _PullResult(
      pulled: pulled,
      conflicts: conflicts,
    );
  }

  bool _shouldApplyRemote({
    required SyncRecord local,
    required RemoteSyncRecord remote,
    required SyncConflictPolicy conflictPolicy,
  }) {
    // Conflict aninda hangi kaynagin kazanacagini tek yerde belirler.
    switch (conflictPolicy) {
      case SyncConflictPolicy.preferDevice:
        return false;
      case SyncConflictPolicy.preferCloud:
        return true;
      case SyncConflictPolicy.preferLatestChange:
        return !local.updatedAt.isAfter(remote.updatedAt.toLocal());
      case SyncConflictPolicy.manualReview:
        return false;
    }
  }

  Future<String> _resolveUserId() async {
    // Gecici olarak kullanici anahtari profil e-posta/telefonundan turetiliyor.
    if (_userIdProvider != null) {
      return _userIdProvider!();
    }
    final profile = await UserProfileService.getProfile();
    final email = profile?.email?.trim();
    if (email != null && email.isNotEmpty) return email.toLowerCase();
    final phone = profile?.phone?.trim();
    if (phone != null && phone.isNotEmpty) return phone;
    return 'local-device';
  }
}

class _PullResult {
  final int pulled;
  final int conflicts;

  const _PullResult({
    required this.pulled,
    required this.conflicts,
  });
}

class _MemorySyncReferenceResolver implements SyncReferenceResolver {
  _MemorySyncReferenceResolver(this._records);

  final Map<String, SyncRecord> _records;

  @override
  int? localIdFor(String entityType, String remoteId) {
    for (final record in _records.values) {
      if (record.entityType == entityType && record.remoteId == remoteId) {
        return record.localId;
      }
    }
    return null;
  }

  SyncRecord? byRemoteId(String entityType, String remoteId) {
    for (final record in _records.values) {
      if (record.entityType == entityType && record.remoteId == remoteId) {
        return record;
      }
    }
    return null;
  }

  @override
  String? remoteIdFor(String entityType, int localId) {
    return _records['$entityType:$localId']?.remoteId;
  }

  /// Pull/push sonrasi bellekteki referans haritasini guncel tutar.
  void update(SyncRecord record) {
    _records[record.key] = record;
  }

  void remove(String key) {
    _records.remove(key);
  }
}
