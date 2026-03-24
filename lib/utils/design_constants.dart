import 'package:flutter/material.dart';

/// Design system constants for consistent UI styling
class AppColors {
  static const Color primary = Color(0xFFFF9A8B);
  static const Color primaryLight = Color(0xFFFFB3BA);
  static const Color secondary = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF9FAFB);

  static const Color surface = Color(0xFFFFFFFF);
  static const Color error = Color(0xFFEF4444);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSecondary = Color(0xFF1F2937);
  static const Color onBackground = Color(0xFF1F2937);
  static const Color onSurface = Color(0xFF1F2937);

  static const Color greyLight = Color(0xFFF3F4F6);
  static const Color grey = Color(0xFF9CA3AF);
  static const Color greyDark = Color(0xFF6B7280);
  static const Color greyVeryLight = Color(0xFFF9FAFB);
}

class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;
  static const double huge = 48.0;
  static const double section = 32.0;
}

class AppRadius {
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 14.0;
  static const double xl = 16.0;
  static const double xxl = 20.0;
  static const double card = 14.0;
  static const double button = 14.0;
}

class AppTextStyles {
  static const TextStyle heading1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.5,
    color: AppTheme.textPrimary,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.25,
    color: AppTheme.textPrimary,
  );

  static const TextStyle heading3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w500,
    color: AppTheme.textPrimary,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    height: 1.5,
    color: AppTheme.textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    height: 1.5,
    color: AppTheme.textPrimary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    height: 1.4,
    color: AppTheme.textSecondary,
  );

  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppTheme.textPrimary,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppTheme.textSecondary,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppTheme.textSecondary,
  );
}

class AppElevation {
  static const double none = 0.0;
  static const double sm = 0.5;
  static const double md = 1.0;
  static const double lg = 2.0;
  static const double xl = 4.0;
}

class AppShadows {
  static List<BoxShadow> get soft => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 8.0,
          offset: const Offset(0, 2),
          spreadRadius: 0,
        ),
      ];

  static List<BoxShadow> get medium => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 12.0,
          offset: const Offset(0, 4),
          spreadRadius: 0,
        ),
      ];

  static List<BoxShadow> get light => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.02),
          blurRadius: 4.0,
          offset: const Offset(0, 1),
          spreadRadius: 0,
        ),
      ];
}

class AppTouchTarget {
  static const double minSize = 48.0;
  static const double buttonHeight = 56.0;
  static const double cardMinHeight = 110.0;
  static const double categoryChipHeight = 110.0;
}

class AppTheme {
  static const Color divider = Color(0xFFE5E7EB);
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
}
