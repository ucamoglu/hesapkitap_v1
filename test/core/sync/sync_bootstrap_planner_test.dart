import 'package:flutter_test/flutter_test.dart';
import 'package:hesapkitap_v1/core/sync/cloud_data_state.dart';
import 'package:hesapkitap_v1/core/sync/sync_bootstrap_choice.dart';
import 'package:hesapkitap_v1/core/sync/sync_bootstrap_plan.dart';
import 'package:hesapkitap_v1/core/sync/sync_conflict_policy.dart';
import 'package:hesapkitap_v1/core/sync/sync_readiness_report.dart';

void main() {
  const report = SyncReadinessReport(
    collections: [],
    totalRecords: 12,
    attachmentBytes: 0,
    metadataCoverage: 0,
    fingerprint: 'account:2|finance_transaction:10',
  );

  test('upload plan prefers device and pushes all local data into empty cloud', () {
    final plan = SyncBootstrapPlanner.build(
      report: report,
      cloudState: CloudDataState.empty,
      choice: SyncBootstrapChoice.uploadDeviceData,
    );

    expect(plan.conflictPolicy, SyncConflictPolicy.preferDevice);
    expect(plan.estimatedPushCount, 12);
    expect(plan.estimatedPullCount, 0);
    expect(plan.requiresConfirmation, isFalse);
  });

  test('merge plan requires confirmation when cloud already has data', () {
    final plan = SyncBootstrapPlanner.build(
      report: report,
      cloudState: CloudDataState.hasData,
      choice: SyncBootstrapChoice.mergeSafely,
    );

    expect(plan.conflictPolicy, SyncConflictPolicy.manualReview);
    expect(plan.estimatedPushCount, 12);
    expect(plan.estimatedPullCount, 12);
    expect(plan.requiresConfirmation, isTrue);
    expect(plan.warnings, isNotEmpty);
  });
}
