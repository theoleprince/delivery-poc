import 'package:flutter/material.dart';
import 'package:poc_uber/config/theme/app_colors.dart';
import 'package:poc_uber/config/theme/app_typography.dart';
import 'package:poc_uber/config/theme/elevation.dart';
import 'package:poc_uber/config/theme/radius.dart';
import 'package:poc_uber/config/theme/spacing.dart';

/// Assemble les tokens du Design System (`AppColors`, `AppTypography`,
/// `Spacing`, `AppRadius`, `AppElevation`) en `ThemeData` clair/sombre.
///
/// Statique pour ce sprint : la feature `settings` (planifiée) pourra plus
/// tard reconstruire ces `ThemeData` à partir de valeurs Firestore sans
/// changer la forme de cette classe.
abstract final class AppTheme {
  static ThemeData get light => _build(brightness: Brightness.light);

  static ThemeData get dark => _build(brightness: Brightness.dark);

  static ThemeData _build({required Brightness brightness}) {
    final bool isDark = brightness == Brightness.dark;

    final ColorScheme colorScheme = ColorScheme(
      brightness: brightness,
      primary: AppColors.primary,
      onPrimary: AppColors.textOnPrimary,
      secondary: AppColors.secondary,
      onSecondary: AppColors.textPrimary,
      error: AppColors.error,
      onError: AppColors.textOnPrimary,
      surface: isDark ? AppColors.surfaceDark : AppColors.surface,
      onSurface: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.background,
      fontFamily: AppTypography.fontFamily,
      textTheme: TextTheme(
        headlineLarge: AppTypography.headlineLarge.copyWith(
          color: colorScheme.onSurface,
        ),
        headlineMedium: AppTypography.headlineMedium.copyWith(
          color: colorScheme.onSurface,
        ),
        titleMedium: AppTypography.titleMedium.copyWith(
          color: colorScheme.onSurface,
        ),
        bodyLarge: AppTypography.bodyLarge.copyWith(
          color: colorScheme.onSurface,
        ),
        bodyMedium: AppTypography.bodyMedium.copyWith(
          color: isDark
              ? AppColors.textSecondaryDark
              : AppColors.textSecondary,
        ),
        labelLarge: AppTypography.labelLarge.copyWith(
          color: colorScheme.onSurface,
        ),
        bodySmall: AppTypography.caption.copyWith(
          color: isDark
              ? AppColors.textSecondaryDark
              : AppColors.textSecondary,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: AppElevation.none,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          minimumSize: const Size.fromHeight(48),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.mdBorder,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
          minimumSize: const Size.fromHeight(48),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.mdBorder,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? AppColors.surfaceDark : AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: Spacing.md,
          vertical: Spacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadius.mdBorder,
          borderSide: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.mdBorder,
          borderSide: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.mdBorder,
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.mdBorder,
          borderSide: const BorderSide(color: AppColors.error),
        ),
      ),
      cardTheme: CardThemeData(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        elevation: AppElevation.low,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.lgBorder),
      ),
    );
  }
}
