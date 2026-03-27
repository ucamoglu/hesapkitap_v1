import 'package:flutter/material.dart';

extension AppThemeContext on BuildContext {
  ColorScheme get scheme => Theme.of(this).colorScheme;

  BoxDecoration surfaceDecoration({
    Color? accent,
    bool selected = false,
    double radius = 22,
    Color? fillColor,
  }) {
    final accentColor = accent ?? scheme.primary;
    return BoxDecoration(
      color: fillColor ?? Colors.white,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: selected
            ? accentColor.withValues(alpha: 0.55)
            : scheme.outline.withValues(alpha: 0.22),
        width: selected ? 1.4 : 1,
      ),
      boxShadow: [
        BoxShadow(
          color: scheme.shadow.withValues(alpha: 0.05),
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  Color softAccent(Color accent, [double alpha = 0.12]) {
    return accent.withValues(alpha: alpha);
  }
}
