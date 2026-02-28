import 'sync_collection_snapshot.dart';

class SyncReadinessReport {
  final List<SyncCollectionSnapshot> collections;
  final int totalRecords;
  final int attachmentBytes;
  final int metadataCoverage;
  final String fingerprint;

  const SyncReadinessReport({
    required this.collections,
    required this.totalRecords,
    required this.attachmentBytes,
    required this.metadataCoverage,
    required this.fingerprint,
  });

  bool get hasLocalData => totalRecords > 0;
}
