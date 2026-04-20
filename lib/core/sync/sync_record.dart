import 'sync_state.dart';

class SyncRecord {
  final String entityType;
  final int localId;
  final String? remoteId;
  final int version;
  final DateTime updatedAt;
  final DateTime? lastSyncedAt;
  final SyncState state;
  final DateTime? deletedAt;

  const SyncRecord({
    required this.entityType,
    required this.localId,
    required this.remoteId,
    required this.version,
    required this.updatedAt,
    required this.lastSyncedAt,
    required this.state,
    required this.deletedAt,
  });

  factory SyncRecord.initial({
    required String entityType,
    required int localId,
    required DateTime now,
  }) {
    return SyncRecord(
      entityType: entityType,
      localId: localId,
      remoteId: null,
      version: 1,
      updatedAt: now,
      lastSyncedAt: null,
      state: SyncState.localOnly,
      deletedAt: null,
    );
  }

  String get key => '$entityType:$localId';

  SyncRecord copyWith({
    String? remoteId,
    int? version,
    DateTime? updatedAt,
    DateTime? lastSyncedAt,
    SyncState? state,
    DateTime? deletedAt,
  }) {
    return SyncRecord(
      entityType: entityType,
      localId: localId,
      remoteId: remoteId ?? this.remoteId,
      version: version ?? this.version,
      updatedAt: updatedAt ?? this.updatedAt,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      state: state ?? this.state,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'entityType': entityType,
      'localId': localId,
      'remoteId': remoteId,
      'version': version,
      'updatedAt': updatedAt.toIso8601String(),
      'lastSyncedAt': lastSyncedAt?.toIso8601String(),
      'state': state.name,
      'deletedAt': deletedAt?.toIso8601String(),
    };
  }

  factory SyncRecord.fromJson(Map<String, dynamic> json) {
    return SyncRecord(
      entityType: json['entityType'] as String,
      localId: json['localId'] as int,
      remoteId: json['remoteId'] as String?,
      version: json['version'] as int? ?? 1,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      lastSyncedAt: json['lastSyncedAt'] == null
          ? null
          : DateTime.parse(json['lastSyncedAt'] as String),
      state: SyncState.values.byName(json['state'] as String? ?? 'localOnly'),
      deletedAt: json['deletedAt'] == null
          ? null
          : DateTime.parse(json['deletedAt'] as String),
    );
  }
}
