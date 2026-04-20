import 'sync_bootstrap_choice.dart';
import 'sync_conflict_policy.dart';

class SyncBootstrapPreference {
  final SyncBootstrapChoice choice;
  final SyncConflictPolicy conflictPolicy;
  final DateTime preparedAt;
  final String localFingerprint;

  const SyncBootstrapPreference({
    required this.choice,
    required this.conflictPolicy,
    required this.preparedAt,
    required this.localFingerprint,
  });

  Map<String, dynamic> toJson() {
    return {
      'choice': choice.name,
      'conflictPolicy': conflictPolicy.name,
      'preparedAt': preparedAt.toIso8601String(),
      'localFingerprint': localFingerprint,
    };
  }

  factory SyncBootstrapPreference.fromJson(Map<String, dynamic> json) {
    return SyncBootstrapPreference(
      choice: SyncBootstrapChoice.values.byName(json['choice'] as String),
      conflictPolicy: SyncConflictPolicy.values.byName(
        json['conflictPolicy'] as String,
      ),
      preparedAt: DateTime.parse(json['preparedAt'] as String),
      localFingerprint: json['localFingerprint'] as String? ?? '',
    );
  }
}
