import '../api/remote_sync_record.dart';
import '../sync_record.dart';

abstract class SyncReferenceResolver {
  /// Yerel bir kaydin cloud tarafindaki kimligini dondurur.
  String? remoteIdFor(String entityType, int localId);

  /// Cloud kimliginden yerel kayda donus yapmak icin kullanilir.
  int? localIdFor(String entityType, String remoteId);
}

class SyncImportResult {
  final int? localId;
  final bool conflict;
  final String? reason;

  const SyncImportResult({
    required this.localId,
    required this.conflict,
    required this.reason,
  });

  factory SyncImportResult.applied(int localId) {
    return SyncImportResult(
      localId: localId,
      conflict: false,
      reason: null,
    );
  }

  factory SyncImportResult.conflict(String reason) {
    return SyncImportResult(
      localId: null,
      conflict: true,
      reason: reason,
    );
  }
}

abstract class SyncEntityMapper {
  String get entityType;

  /// Yerel kaydi remote envelope formatina cevirir.
  Future<RemoteSyncRecord?> exportRecord({
    required SyncRecord metadata,
    required SyncReferenceResolver resolver,
  });

  /// Remote envelope bilgisini yerel modele uygular.
  Future<SyncImportResult> importRecord({
    required RemoteSyncRecord remote,
    required SyncReferenceResolver resolver,
  });

  /// Cloud'da silinen kaydi isterse yerelden de temizler.
  Future<bool> deleteLocal(int localId) async {
    return false;
  }
}
