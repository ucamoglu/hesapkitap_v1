import 'cloud_sync_api.dart';
import 'remote_sync_record.dart';

class NoopCloudSyncApi implements CloudSyncApi {
  const NoopCloudSyncApi();

  @override
  Future<List<RemoteSyncRecord>> pullChanges({
    required String userId,
    DateTime? since,
  }) async {
    return const [];
  }

  @override
  Future<List<RemoteSyncRecord>> pushRecords({
    required String userId,
    required List<RemoteSyncRecord> records,
  }) async {
    return const [];
  }
}
