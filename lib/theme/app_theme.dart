import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF0F766E);
  static const accent = Color(0xFFF59E0B);
  static const danger = Color(0xFFDC2626);
  static const success = Color(0xFF16A34A);
  static const background = Color(0xFFF6F8FA);
}

class AppTheme {
  static ThemeData light() {
    return ThemeData(
      // Enable Material 3
      useMaterial3: true,
      // Generate a palette from teal, then force the main color to be exactly our teal
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary)
          .copyWith(primary: AppColors.primary),
      // Background color every screen
      scaffoldBackgroundColor: AppColors.background,
    );
  }

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      // Same teal seed, but generate the dark version of the palette
      colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary, brightness: Brightness.dark),
    );
  }
}
