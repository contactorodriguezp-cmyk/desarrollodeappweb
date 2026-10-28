import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Colores del diseño en Figma (variables de la colección "Colores").
class AppColors {
  static const bg = Color(0xFFF4F6FA);
  static const surface = Colors.white;
  static const primary = Color(0xFF1F4FD8);
  static const primarySoft = Color(0xFFE7EEFF);
  static const ink = Color(0xFF0E1A2B);
  static const muted = Color(0xFF5B6B82);
  static const border = Color(0xFFDCE2EB);
  static const pending = Color(0xFFB45309);
  static const pendingBg = Color(0xFFFEF3C7);
  static const done = Color(0xFF15803D);
  static const doneBg = Color(0xFFDCFCE7);
}

ThemeData buildTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      surface: AppColors.surface,
    ),
    scaffoldBackgroundColor: AppColors.bg,
  );
  final border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: const BorderSide(color: AppColors.border),
  );
  final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(10));
  const label = TextStyle(fontWeight: FontWeight.w600, fontSize: 15);

  return base.copyWith(
    textTheme: GoogleFonts.interTextTheme(base.textTheme)
        .apply(bodyColor: AppColors.ink, displayColor: AppColors.ink),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      border: border,
      enabledBorder: border,
      focusedBorder: border.copyWith(
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      hintStyle: const TextStyle(color: AppColors.muted),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
          minimumSize: const Size(0, 48), shape: shape, textStyle: label),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 48),
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary, width: 1.5),
        shape: shape,
        textStyle: label,
      ),
    ),
    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: AppColors.surface,
      indicatorColor: AppColors.primarySoft,
    ),
    dividerTheme:
        const DividerThemeData(color: AppColors.border, space: 1, thickness: 1),
  );
}
