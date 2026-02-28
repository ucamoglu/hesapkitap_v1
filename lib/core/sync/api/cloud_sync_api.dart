import 'remote_sync_record.dart';

abstract class CloudSyncApi {
  /// Yerel degisiklikleri cloud tarafina yollar ve sunucunun son halini geri alir.
  Future<List<RemoteSyncRecord>> pushRecords({
    required String userId,
    required List<RemoteSyncRecord> records,
  });

  /// Belirli bir andan sonra olusan cloud degisikliklerini ceker.
  Future<List<RemoteSyncRecord>> pullChanges({
    required String userId,
    DateTime? since,
  });
}
