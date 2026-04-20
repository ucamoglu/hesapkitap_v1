import '../../../models/user_profile.dart';
import '../../../services/user_profile_service.dart';
import '../../sync/sync_change_tracker.dart';
import '../contracts/user_profile_repository.dart';

class LocalUserProfileRepository implements UserProfileRepository {
  LocalUserProfileRepository({
    SyncChangeTracker? changeTracker,
  }) : _changeTracker = changeTracker ?? SyncChangeTracker();

  final SyncChangeTracker _changeTracker;

  @override
  Future<UserProfile?> getProfile() {
    return UserProfileService.getProfile();
  }

  @override
  Future<void> save(UserProfile profile) async {
    await UserProfileService.save(profile);
    await _changeTracker.markUpsert(
      entityType: 'user_profile',
      localId: profile.id,
    );
  }
}
