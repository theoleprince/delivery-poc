import 'package:flutter/material.dart';

/// Palette de couleurs du Design System. Valeurs statiques pour ce sprint —
/// la personnalisation dynamique (couleur principale pilotée par Firestore)
/// appartient à la future feature `settings` (voir ARCHITECTURE.md §4.5).
abstract final class AppColors {
  static const Color primary = Color(0xFF0A5C36);
  static const Color primaryVariant = Color(0xFF073F26);
  static const Color secondary = Color(0xFFFFB020);

  static const Color background = Color(0xFFF7F8FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFED6C02);

  static const Color textPrimary = Color(0xFF1A1C1E);
  static const Color textSecondary = Color(0xFF5F6368);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE0E2E5);

  static const Color backgroundDark = Color(0xFF121417);
  static const Color surfaceDark = Color(0xFF1E2124);
  static const Color textPrimaryDark = Color(0xFFF2F2F2);
  static const Color textSecondaryDark = Color(0xFFB0B4B9);
  static const Color borderDark = Color(0xFF33373B);
}
