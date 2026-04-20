import 'package:isar/isar.dart';

import '../theme/app_theme.dart';
import '../database/isar_service.dart';
import '../models/user_profile.dart';

class UserProfileService {
  /// Tekil profil kaydini getirir; schema uyumsuzlugunda veritabani instance'ini yeniler.
  static Future<UserProfile?> getProfile() async {
    try {
      final isar = IsarService.isar;
      final profiles = await isar.userProfiles.where().findAll();
      if (profiles.isEmpty) return null;
      final profile = profiles.first;
      profile.themeKey = _normalizeThemeKey(profile.themeKey);
      profile.fanTeamKey = _normalizeFanTeamKey(profile.fanTeamKey);
      return profile;
    } on IsarError catch (e) {
      // Recover from schema mismatch after hot-reload/update.
      if (e.message.contains('MissingTypeSchema')) {
        await IsarService.init();
        final isar = IsarService.isar;
        final profiles = await isar.userProfiles.where().findAll();
        if (profiles.isEmpty) return null;
        final profile = profiles.first;
        profile.themeKey = _normalizeThemeKey(profile.themeKey);
        profile.fanTeamKey = _normalizeFanTeamKey(profile.fanTeamKey);
        return profile;
      }
      rethrow;
    }
  }

  /// Profili ekler ya da tek kayit mantigiyla mevcut profilin ustune yazar.
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

  /// Tek profil kaydi ilkesini koruyarak create/update islemini yapar.
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

      profile.themeKey = _normalizeThemeKey(profile.themeKey);
      profile.fanTeamKey = _normalizeFanTeamKey(profile.fanTeamKey);
      profile.updatedAt = DateTime.now();
      await isar.userProfiles.put(profile);
    });
  }

  static String _normalizeThemeKey(String? themeKey) {
    return AppTheme.normalizeKey(themeKey);
  }

  static String _normalizeFanTeamKey(String? fanTeamKey) {
    return AppTheme.normalizeFanTeamKey(fanTeamKey);
  }
}
