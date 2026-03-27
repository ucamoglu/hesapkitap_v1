import 'package:flutter/material.dart';

class AppThemeOption {
  const AppThemeOption({
    required this.key,
    required this.name,
    required this.description,
    required this.seedColor,
    required this.surfaceTint,
    required this.surfaceColor,
    required this.heroGradient,
    required this.accentColor,
    required this.icon,
    this.requiresFanTeam = false,
  });

  final String key;
  final String name;
  final String description;
  final Color seedColor;
  final Color surfaceTint;
  final Color surfaceColor;
  final List<Color> heroGradient;
  final Color accentColor;
  final IconData icon;
  final bool requiresFanTeam;
}

class AppFanTeamOption {
  const AppFanTeamOption({
    required this.key,
    required this.name,
    required this.seedColor,
    required this.surfaceTint,
    required this.surfaceColor,
    required this.heroGradient,
    required this.accentColor,
  });

  final String key;
  final String name;
  final Color seedColor;
  final Color surfaceTint;
  final Color surfaceColor;
  final List<Color> heroGradient;
  final Color accentColor;
}

class AppTheme {
  static const String fanThemeKey = 'fan';

  static const List<AppThemeOption> options = [
    AppThemeOption(
      key: 'classic',
      name: 'Klasik',
      description: 'Temiz ve dengeli klasik finans görünümü.',
      seedColor: Color(0xFF5E4B8B),
      surfaceTint: Color(0xFFF0EAFE),
      surfaceColor: Color(0xFFF8F7FB),
      heroGradient: [Color(0xFF5E4B8B), Color(0xFF7D6AB5)],
      accentColor: Color(0xFFFF6B3D),
      icon: Icons.auto_awesome_outlined,
    ),
    AppThemeOption(
      key: 'night_ocean',
      name: 'Gece Mavisi',
      description: 'Daha premium, serin ve kontrastı güçlü bir stil.',
      seedColor: Color(0xFF143A5C),
      surfaceTint: Color(0xFFE7F1F8),
      surfaceColor: Color(0xFFF2F7FB),
      heroGradient: [Color(0xFF143A5C), Color(0xFF1F5D7A)],
      accentColor: Color(0xFF2FB8A7),
      icon: Icons.nights_stay_outlined,
    ),
    AppThemeOption(
      key: 'sunrise',
      name: 'Gun Isigi',
      description: 'Daha sıcak, daha canlı ve kişisel finans odaklı bir ton.',
      seedColor: Color(0xFF9D4E2E),
      surfaceTint: Color(0xFFFFF1E8),
      surfaceColor: Color(0xFFFCF7F3),
      heroGradient: [Color(0xFF9D4E2E), Color(0xFFC8753D)],
      accentColor: Color(0xFF2B7A5B),
      icon: Icons.wb_sunny_outlined,
    ),
    AppThemeOption(
      key: fanThemeKey,
      name: 'Taraftar',
      description: 'Takım renkleriyle daha karakterli bir arayüz.',
      seedColor: Color(0xFF8B1E3F),
      surfaceTint: Color(0xFFFFEFF4),
      surfaceColor: Color(0xFFF9F5F7),
      heroGradient: [Color(0xFF8B1E3F), Color(0xFFE5A81A)],
      accentColor: Color(0xFF102B5C),
      icon: Icons.flag_outlined,
      requiresFanTeam: true,
    ),
  ];

  static const List<AppFanTeamOption> fanTeams = [
    AppFanTeamOption(
      key: 'galatasaray',
      name: 'Galatasaray',
      seedColor: Color(0xFFA61D37),
      surfaceTint: Color(0xFFFFF0E5),
      surfaceColor: Color(0xFFFCF6F3),
      heroGradient: [Color(0xFFA61D37), Color(0xFFF2A900)],
      accentColor: Color(0xFF4B1832),
    ),
    AppFanTeamOption(
      key: 'fenerbahce',
      name: 'Fenerbahce',
      seedColor: Color(0xFF143A7B),
      surfaceTint: Color(0xFFFFF7D9),
      surfaceColor: Color(0xFFF7F8FB),
      heroGradient: [Color(0xFF143A7B), Color(0xFFF4C542)],
      accentColor: Color(0xFF1F4D2E),
    ),
    AppFanTeamOption(
      key: 'besiktas',
      name: 'Besiktas',
      seedColor: Color(0xFF1F1F1F),
      surfaceTint: Color(0xFFF2F2F2),
      surfaceColor: Color(0xFFF8F8F8),
      heroGradient: [Color(0xFF1F1F1F), Color(0xFFE53935)],
      accentColor: Color(0xFF575757),
    ),
    AppFanTeamOption(
      key: 'trabzonspor',
      name: 'Trabzonspor',
      seedColor: Color(0xFF7A1E48),
      surfaceTint: Color(0xFFE7F1F8),
      surfaceColor: Color(0xFFF7F8FB),
      heroGradient: [Color(0xFF7A1E48), Color(0xFF4F86C6)],
      accentColor: Color(0xFF1E365D),
    ),
  ];

  static String normalizeKey(String? themeKey) {
    if (themeKey == null || themeKey.trim().isEmpty) {
      return options.first.key;
    }
    final normalized = themeKey.trim();
    final exists = options.any((option) => option.key == normalized);
    return exists ? normalized : options.first.key;
  }

  static String normalizeFanTeamKey(String? teamKey) {
    if (teamKey == null || teamKey.trim().isEmpty) {
      return fanTeams.first.key;
    }
    final normalized = teamKey.trim();
    final exists = fanTeams.any((team) => team.key == normalized);
    return exists ? normalized : fanTeams.first.key;
  }

  static AppThemeOption optionFor(String? themeKey) {
    final normalized = normalizeKey(themeKey);
    return options.firstWhere((option) => option.key == normalized);
  }

  static AppFanTeamOption fanTeamFor(String? teamKey) {
    final normalized = normalizeFanTeamKey(teamKey);
    return fanTeams.firstWhere((team) => team.key == normalized);
  }

  static ThemeData resolve(String? themeKey, {String? fanTeamKey}) {
    final option = optionFor(themeKey);
    final fanTeam = option.requiresFanTeam ? fanTeamFor(fanTeamKey) : null;
    final seedColor = fanTeam?.seedColor ?? option.seedColor;
    final accentColor = fanTeam?.accentColor ?? option.accentColor;
    final heroGradient = fanTeam?.heroGradient ?? option.heroGradient;
    final surfaceTint = fanTeam?.surfaceTint ?? option.surfaceTint;
    final surfaceColor = fanTeam?.surfaceColor ?? option.surfaceColor;

    final baseScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.light,
    );
    final colorScheme = baseScheme.copyWith(
      primary: seedColor,
      secondary: accentColor,
      tertiary: heroGradient.last,
      surface: Colors.white,
      surfaceContainerHighest: surfaceTint,
      surfaceContainerHigh: surfaceTint.withValues(alpha: 0.65),
      outline: seedColor.withValues(alpha: 0.18),
      shadow: seedColor.withValues(alpha: 0.16),
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: 'SF Pro Display',
    );

    return base.copyWith(
      scaffoldBackgroundColor: surfaceColor,
      visualDensity: VisualDensity.compact,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white.withValues(alpha: 0.92),
        foregroundColor: const Color(0xFF1F1B24),
        surfaceTintColor: Colors.transparent,
        titleTextStyle: base.textTheme.titleLarge?.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF1F1B24),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        shadowColor: seedColor.withValues(alpha: 0.08),
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: seedColor.withValues(alpha: 0.08),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        isDense: true,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: seedColor.withValues(alpha: 0.16),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: seedColor.withValues(alpha: 0.14),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: seedColor, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: seedColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: seedColor,
          side: BorderSide(color: seedColor.withValues(alpha: 0.28)),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: seedColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: surfaceTint,
        foregroundColor: seedColor,
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: surfaceTint,
        side: BorderSide(
          color: seedColor.withValues(alpha: 0.16),
        ),
        labelStyle: base.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: seedColor.withValues(alpha: 0.10),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: seedColor,
        unselectedItemColor: const Color(0xFF7D758A),
        backgroundColor: Colors.white,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
