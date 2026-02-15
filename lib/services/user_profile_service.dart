import 'package:isar/isar.dart';

import '../database/isar_service.dart';
import '../models/user_profile.dart';

class UserProfileService {
  static Future<UserProfile?> getProfile() async {
    try {
      final isar = IsarService.isar;
      final profiles = await isar.userProfiles.where().findAll();
      if (profiles.isEmpty) return null;
      return profiles.first;
    } on IsarError catch (e) {
      // Recover from schema mismatch after hot-reload/update.
      if (e.message.contains('MissingTypeSchema')) {
        await IsarService.init();
        final isar = IsarService.isar;
        final profiles = await isar.userProfiles.where().findAll();
        if (profiles.isEmpty) return null;
        return profiles.first;
      }
      rethrow;
    }
  }

  static Future<void> save(UserProfile profile) async {
    try {
      await _saveInternal(profile);
    } on IsarError catch (e) {
      if (e.message.contains('MissingTypeSchema')) {
        await IsarService.init();
        await _saveInternal(profile);
        return;
      }
      rethrow;
    }
  }

  static Future<void> _saveInternal(UserProfile profile) async {
    final isar = IsarService.isar;
    final existing = await getProfile();

    await isar.writeTxn(() async {
      if (existing != null) {
        profile.id = existing.id;
        profile.createdAt = existing.createdAt;
      } else {
        profile.createdAt = DateTime.now();
      }

      profile.updatedAt = DateTime.now();
      await isar.userProfiles.put(profile);
    });
  }
}
