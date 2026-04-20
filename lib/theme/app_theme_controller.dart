import 'package:flutter/foundation.dart';

import '../models/user_profile.dart';
import '../services/user_profile_service.dart';
import 'app_theme.dart';

class AppThemeController extends ChangeNotifier {
  AppThemeController._();

  static final AppThemeController instance = AppThemeController._();

  String _themeKey = UserProfile.defaultThemeKey;
  String _fanTeamKey = UserProfile.defaultFanTeamKey;

  String get themeKey => _themeKey;
  String get fanTeamKey => _fanTeamKey;
  AppThemeOption get themeOption => AppTheme.optionFor(_themeKey);

  Future<void> initialize() async {
    final profile = await UserProfileService.getProfile();
    _themeKey = AppTheme.normalizeKey(profile?.themeKey);
    _fanTeamKey = AppTheme.normalizeFanTeamKey(profile?.fanTeamKey);
  }

  Future<void> applyTheme(
    String themeKey, {
    String? fanTeamKey,
  }) async {
    final normalizedKey = AppTheme.normalizeKey(themeKey);
    final normalizedFanTeamKey = AppTheme.normalizeFanTeamKey(
      fanTeamKey ?? _fanTeamKey,
    );
    if (_themeKey == normalizedKey && _fanTeamKey == normalizedFanTeamKey) {
      return;
    }
    _themeKey = normalizedKey;
    _fanTeamKey = normalizedFanTeamKey;
    notifyListeners();
  }
}
