import 'sync_direction.dart';
import 'sync_result.dart';

abstract class SyncEngine {
  Future<SyncResult> run({required SyncDirection direction});
}

class NoopSyncEngine implements SyncEngine {
  const NoopSyncEngine();

  @override
  Future<SyncResult> run({required SyncDirection direction}) async {
    return SyncResult.empty;
  }
}
