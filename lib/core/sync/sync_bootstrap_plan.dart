import 'cloud_data_state.dart';
import 'sync_bootstrap_choice.dart';
import 'sync_conflict_policy.dart';
import 'sync_readiness_report.dart';

class SyncBootstrapPlan {
  final CloudDataState cloudState;
  final SyncBootstrapChoice choice;
  final SyncConflictPolicy conflictPolicy;
  final int estimatedPushCount;
  final int estimatedPullCount;
  final bool requiresConfirmation;
  final List<String> warnings;

  const SyncBootstrapPlan({
    required this.cloudState,
    required this.choice,
    required this.conflictPolicy,
    required this.estimatedPushCount,
    required this.estimatedPullCount,
    required this.requiresConfirmation,
    required this.warnings,
  });
}

class SyncBootstrapPlanner {
  const SyncBootstrapPlanner._();

  static SyncConflictPolicy defaultPolicyForChoice(
    SyncBootstrapChoice choice,
  ) {
    switch (choice) {
      case SyncBootstrapChoice.uploadDeviceData:
        return SyncConflictPolicy.preferDevice;
      case SyncBootstrapChoice.downloadCloudData:
        return SyncConflictPolicy.preferCloud;
      case SyncBootstrapChoice.mergeSafely:
        return SyncConflictPolicy.manualReview;
    }
  }

  static SyncBootstrapPlan build({
    required SyncReadinessReport report,
    required CloudDataState cloudState,
    required SyncBootstrapChoice choice,
    SyncConflictPolicy? conflictPolicy,
  }) {
    final resolvedPolicy = conflictPolicy ?? defaultPolicyForChoice(choice);
    final warnings = <String>[];
    var pushCount = 0;
    var pullCount = 0;
    var requiresConfirmation = false;

    switch (cloudState) {
      case CloudDataState.empty:
        if (report.hasLocalData) {
          pushCount = report.totalRecords;
        } else {
          warnings.add('Cihazda senkronize edilecek veri bulunmuyor.');
        }
        break;
      case CloudDataState.hasData:
        requiresConfirmation = true;
        switch (choice) {
          case SyncBootstrapChoice.uploadDeviceData:
            pushCount = report.totalRecords;
            warnings.add(
              'Bulutta mevcut veri varsa cihaz verisi baskin kaynak olarak ele alinacak.',
            );
            break;
          case SyncBootstrapChoice.downloadCloudData:
            pullCount = report.totalRecords == 0 ? 1 : report.totalRecords;
            warnings.add(
              'Bulut verisi cihaza indirildiginde yerel veriyle cakisma riski vardir.',
            );
            break;
          case SyncBootstrapChoice.mergeSafely:
            pushCount = report.totalRecords;
            pullCount = report.totalRecords == 0 ? 1 : report.totalRecords;
            warnings.add(
              'Cakişan kayitlar inceleme gerektirebilir; en guvenli secenek budur.',
            );
            break;
        }
        break;
      case CloudDataState.unknown:
        requiresConfirmation = true;
        pushCount = choice == SyncBootstrapChoice.downloadCloudData
            ? 0
            : report.totalRecords;
        pullCount = choice == SyncBootstrapChoice.uploadDeviceData ? 0 : 1;
        warnings.add(
          'Sunucu durumu bilinmedigi icin ilk baglantida ek dogrulama gerekir.',
        );
        break;
    }

    if (report.attachmentBytes > 5 * 1024 * 1024) {
      warnings.add(
        'Eklerin boyutu yuksek; ilk cloud esitlemesi daha uzun surebilir.',
      );
    }

    return SyncBootstrapPlan(
      cloudState: cloudState,
      choice: choice,
      conflictPolicy: resolvedPolicy,
      estimatedPushCount: pushCount,
      estimatedPullCount: pullCount,
      requiresConfirmation: requiresConfirmation,
      warnings: warnings,
    );
  }
}
