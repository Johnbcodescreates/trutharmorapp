import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Spacing + radius tokens so every screen feels consistent.
class Gap {
  Gap._();
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double radius = 20;
  static const double radiusSm = 14;
}

class AppTheme {
  AppTheme._();

  /// [simpleMode] makes tap targets bigger for Senior-Friendly "Simple Mode".
  static ThemeData light({bool simpleMode = false}) {
    final double buttonHeight = simpleMode ? 64 : 56;

    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.blue,
      primary: AppColors.blue,
      onPrimary: AppColors.white,
      secondary: AppColors.navy,
      onSecondary: AppColors.white,
      surface: AppColors.white,
      onSurface: AppColors.text,
      error: AppColors.riskHigh,
    );

    const baseText = TextStyle(color: AppColors.text, height: 1.35);

    final textTheme = TextTheme(
      displaySmall: baseText.copyWith(fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -0.5),
      headlineMedium: baseText.copyWith(fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: -0.3),
      headlineSmall: baseText.copyWith(fontSize: 22, fontWeight: FontWeight.w700),
      titleLarge: baseText.copyWith(fontSize: 19, fontWeight: FontWeight.w700),
      titleMedium: baseText.copyWith(fontSize: 17, fontWeight: FontWeight.w600),
      titleSmall: baseText.copyWith(fontSize: 15, fontWeight: FontWeight.w600),
      bodyLarge: baseText.copyWith(fontSize: 17),
      bodyMedium: baseText.copyWith(fontSize: 16),
      bodySmall: baseText.copyWith(fontSize: 14, color: AppColors.mutedText),
      labelLarge: baseText.copyWith(fontSize: 17, fontWeight: FontWeight.w700),
      labelMedium: baseText.copyWith(fontSize: 14, fontWeight: FontWeight.w600),
      labelSmall: baseText.copyWith(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.6),
    );

    final roundedButton = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(Gap.radiusSm),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.navy,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(color: AppColors.navy),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.blue,
          foregroundColor: AppColors.white,
          minimumSize: Size(64, buttonHeight),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          shape: roundedButton,
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.navy,
          minimumSize: Size(64, buttonHeight),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          side: const BorderSide(color: AppColors.border, width: 1.5),
          shape: roundedButton,
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.blue,
          minimumSize: const Size(48, 48),
          textStyle: textTheme.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: textTheme.bodyMedium?.copyWith(color: AppColors.mutedText),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Gap.radiusSm),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Gap.radiusSm),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Gap.radiusSm),
          borderSide: const BorderSide(color: AppColors.blue, width: 2),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.white,
        selectedColor: AppColors.lightBlue,
        side: const BorderSide(color: AppColors.border),
        labelStyle: textTheme.bodyMedium,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.white,
        indicatorColor: AppColors.lightBlue,
        height: simpleMode ? 84 : 72,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: simpleMode ? 14 : 12.5,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? AppColors.navy : AppColors.mutedText,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: simpleMode ? 30 : 26,
            color: selected ? AppColors.blue : AppColors.mutedText,
          );
        }),
      ),
      dividerColor: AppColors.border,
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.navy,
      ),
    );
  }
}
