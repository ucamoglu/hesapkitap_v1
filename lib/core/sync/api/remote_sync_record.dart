class RemoteSyncRecord {
  final String entityType;
  final String remoteId;
  final int version;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final Map<String, dynamic> payload;

  const RemoteSyncRecord({
    required this.entityType,
    required this.remoteId,
    required this.version,
    required this.updatedAt,
    required this.deletedAt,
    required this.payload,
  });

  bool get isDeleted => deletedAt != null;

  Map<String, dynamic> toJson() {
    return {
      'entityType': entityType,
      'remoteId': remoteId,
      'version': version,
      'updatedAt': updatedAt.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
      'payload': payload,
    };
  }

  factory RemoteSyncRecord.fromJson(Map<String, dynamic> json) {
    return RemoteSyncRecord(
      entityType: json['entityType'] as String,
      remoteId: json['remoteId'] as String,
      version: json['version'] as int? ?? 1,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      deletedAt: json['deletedAt'] == null
          ? null
          : DateTime.parse(json['deletedAt'] as String),
      payload: Map<String, dynamic>.from(
        json['payload'] as Map? ?? const {},
      ),
    );
  }
}
