class CloudSafetyBackup {
  final String backupDirectoryPath;
  final String databaseFilePath;
  final List<String> supportFilePaths;
  final String manifestFilePath;
  final DateTime createdAt;
  final String fingerprint;
  final int totalRecords;
  final int attachmentBytes;

  const CloudSafetyBackup({
    required this.backupDirectoryPath,
    required this.databaseFilePath,
    required this.supportFilePaths,
    required this.manifestFilePath,
    required this.createdAt,
    required this.fingerprint,
    required this.totalRecords,
    required this.attachmentBytes,
  });

  Map<String, dynamic> toJson() {
    return {
      'backupDirectoryPath': backupDirectoryPath,
      'databaseFilePath': databaseFilePath,
      'supportFilePaths': supportFilePaths,
      'manifestFilePath': manifestFilePath,
      'createdAt': createdAt.toIso8601String(),
      'fingerprint': fingerprint,
      'totalRecords': totalRecords,
      'attachmentBytes': attachmentBytes,
    };
  }

  factory CloudSafetyBackup.fromJson(Map<String, dynamic> json) {
    return CloudSafetyBackup(
      backupDirectoryPath: json['backupDirectoryPath'] as String? ?? '',
      databaseFilePath: json['databaseFilePath'] as String? ?? '',
      supportFilePaths: (json['supportFilePaths'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(growable: false),
      manifestFilePath: json['manifestFilePath'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
      fingerprint: json['fingerprint'] as String? ?? '',
      totalRecords: json['totalRecords'] as int? ?? 0,
      attachmentBytes: json['attachmentBytes'] as int? ?? 0,
    );
  }
}
