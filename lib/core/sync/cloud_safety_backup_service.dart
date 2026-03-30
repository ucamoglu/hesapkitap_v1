import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../../database/isar_service.dart';
import 'cloud_safety_backup.dart';
import 'sync_readiness_report.dart';

class CloudSafetyBackupService {
  static const _backupRootName = 'cloud_sync_backups';
  static const _manifestName = 'manifest.json';
  static const _databaseFileName = 'local_database_backup.isar';

  Future<CloudSafetyBackup> createBackup({
    required SyncReadinessReport report,
  }) async {
    final appDir = await getApplicationDocumentsDirectory();
    final backupRoot = Directory('${appDir.path}/$_backupRootName');
    if (!await backupRoot.exists()) {
      await backupRoot.create(recursive: true);
    }

    final stamp = DateTime.now().toUtc().toIso8601String().replaceAll(
          RegExp(r'[:.]'),
          '-',
        );
    final backupDir = Directory('${backupRoot.path}/backup_$stamp');
    await backupDir.create(recursive: true);

    final databaseFile = File('${backupDir.path}/$_databaseFileName');
    await IsarService.isar.copyToFile(databaseFile.path);

    final supportFilePaths = <String>[];
    for (final fileName in IsarService.supportFileNames) {
      final source = File('${appDir.path}/$fileName');
      if (!await source.exists()) continue;
      final target = File('${backupDir.path}/$fileName');
      await source.copy(target.path);
      supportFilePaths.add(target.path);
    }

    final manifest = CloudSafetyBackup(
      backupDirectoryPath: backupDir.path,
      databaseFilePath: databaseFile.path,
      supportFilePaths: supportFilePaths,
      manifestFilePath: '${backupDir.path}/$_manifestName',
      createdAt: DateTime.now(),
      fingerprint: report.fingerprint,
      totalRecords: report.totalRecords,
      attachmentBytes: report.attachmentBytes,
    );

    final manifestFile = File(manifest.manifestFilePath);
    await manifestFile.writeAsString(
      jsonEncode({
        ...manifest.toJson(),
        'collections': [
          for (final item in report.collections)
            {
              'entityType': item.entityType,
              'count': item.count,
            },
        ],
      }),
    );

    return manifest;
  }

  Future<CloudSafetyBackup?> loadLatestBackup() async {
    final appDir = await getApplicationDocumentsDirectory();
    final backupRoot = Directory('${appDir.path}/$_backupRootName');
    if (!await backupRoot.exists()) return null;

    final directories = await backupRoot
        .list()
        .where((entity) => entity is Directory)
        .cast<Directory>()
        .toList();
    if (directories.isEmpty) return null;

    final backups = <CloudSafetyBackup>[];
    for (final directory in directories) {
      final manifestFile = File('${directory.path}/$_manifestName');
      if (!await manifestFile.exists()) continue;
      try {
        final json = jsonDecode(await manifestFile.readAsString());
        if (json is! Map<String, dynamic>) continue;
        backups.add(CloudSafetyBackup.fromJson(json));
      } catch (_) {
        continue;
      }
    }
    if (backups.isEmpty) return null;
    backups.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return backups.first;
  }
}
