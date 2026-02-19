import 'sync_state.dart';

class SyncMetadata {
  final String? remoteId;
  final int version;
  final DateTime updatedAt;
  final DateTime? lastSyncedAt;
  final SyncState state;

  const SyncMetadata({
    required this.remoteId,
    required this.version,
    required this.updatedAt,
    required this.lastSyncedAt,
    required this.state,
  });

  factory SyncMetadata.initial(DateTime now) {
    return SyncMetadata(
      remoteId: null,
      version: 1,
      updatedAt: now,
      lastSyncedAt: null,
      state: SyncState.localOnly,
    );
  }

  SyncMetadata copyWith({
    String? remoteId,
    int? version,
    DateTime? updatedAt,
    DateTime? lastSyncedAt,
    SyncState? state,
  }) {
    return SyncMetadata(
      remoteId: remoteId ?? this.remoteId,
      version: version ?? this.version,
      updatedAt: updatedAt ?? this.updatedAt,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      state: state ?? this.state,
    );
  }
}
