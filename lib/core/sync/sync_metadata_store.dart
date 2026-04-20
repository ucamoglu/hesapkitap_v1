import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'sync_bootstrap_preference.dart';
import 'sync_record.dart';

class SyncMetadataStore {
  SyncMetadataStore({
    Future<Directory> Function()? directoryProvider,
  }) : _directoryProvider =
            directoryProvider ?? getApplicationDocumentsDirectory;

  final Future<Directory> Function() _directoryProvider;

  static const _recordsFileName = 'sync_metadata_v1.json';
  static const _preferencesFileName = 'sync_preferences_v1.json';

  /// Daha once uretilmis sync metadata kayitlarini diskten okur.
  Future<Map<String, SyncRecord>> loadRecords() async {
    final file = await _fileFor(_recordsFileName);
    if (!await file.exists()) return <String, SyncRecord>{};

    final raw = jsonDecode(await file.readAsString());
    if (raw is! Map<String, dynamic>) return <String, SyncRecord>{};

    return raw.map(
      (key, value) => MapEntry(
        key,
        SyncRecord.fromJson(Map<String, dynamic>.from(value as Map)),
      ),
    );
  }

  /// Tum metadata kayitlarini tek dosyada tutar.
  Future<void> saveRecords(Map<String, SyncRecord> records) async {
    final file = await _fileFor(_recordsFileName);
    final payload = <String, dynamic>{
      for (final entry in records.entries) entry.key: entry.value.toJson(),
    };
    await file.writeAsString(jsonEncode(payload));
  }

  /// Sadece eksik olan kayitlar icin metadata uretir; var olanlari ezmez.
  Future<int> ensureRecords(Iterable<SyncRecord> records) async {
    final current = await loadRecords();
    var created = 0;

    for (final record in records) {
      if (current.containsKey(record.key)) continue;
      current[record.key] = record;
      created += 1;
    }

    if (created > 0) {
      await saveRecords(current);
    }
    return created;
  }

  /// Engine tarafinda toplu guncelleme sonrasi son hali disk uzerine yazar.
  Future<void> saveAllRecords(Iterable<SyncRecord> records) async {
    final payload = <String, SyncRecord>{
      for (final record in records) record.key: record,
    };
    await saveRecords(payload);
  }

  /// Kullanicinin ilk sync tercihini geri yukler.
  Future<SyncBootstrapPreference?> loadPreference() async {
    final file = await _fileFor(_preferencesFileName);
    if (!await file.exists()) return null;
    final raw = jsonDecode(await file.readAsString());
    if (raw is! Map<String, dynamic>) return null;
    return SyncBootstrapPreference.fromJson(raw);
  }

  /// Ilk sync tercihini disk uzerinde kalici hale getirir.
  Future<void> savePreference(SyncBootstrapPreference preference) async {
    final file = await _fileFor(_preferencesFileName);
    await file.writeAsString(jsonEncode(preference.toJson()));
  }

  Future<File> _fileFor(String name) async {
    // Metadata, uygulamanin documents klasorunde JSON olarak saklanir.
    final directory = await _directoryProvider();
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return File('${directory.path}/$name');
  }
}
