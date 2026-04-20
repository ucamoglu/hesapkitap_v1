import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hesapkitap_v1/core/sync/sync_bootstrap_choice.dart';
import 'package:hesapkitap_v1/core/sync/sync_bootstrap_preference.dart';
import 'package:hesapkitap_v1/core/sync/sync_conflict_policy.dart';
import 'package:hesapkitap_v1/core/sync/sync_metadata_store.dart';
import 'package:hesapkitap_v1/core/sync/sync_record.dart';

void main() {
  test('store persists records and bootstrap preference', () async {
    final directory = await Directory.systemTemp.createTemp('sync-store-test');
    addTearDown(() async {
      if (await directory.exists()) {
        await directory.delete(recursive: true);
      }
    });

    final store = SyncMetadataStore(
      directoryProvider: () async => directory,
    );
    final now = DateTime.utc(2026, 2, 28, 12);

    final created = await store.ensureRecords([
      SyncRecord.initial(
        entityType: 'account',
        localId: 1,
        now: now,
      ),
    ]);

    await store.savePreference(
      SyncBootstrapPreference(
        choice: SyncBootstrapChoice.uploadDeviceData,
        conflictPolicy: SyncConflictPolicy.preferDevice,
        preparedAt: now,
        localFingerprint: 'account:1',
      ),
    );

    final records = await store.loadRecords();
    final preference = await store.loadPreference();

    expect(created, 1);
    expect(records.keys, contains('account:1'));
    expect(preference, isNotNull);
    expect(preference?.choice, SyncBootstrapChoice.uploadDeviceData);
  });
}
