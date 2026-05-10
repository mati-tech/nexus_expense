import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Deep-sea blue palette
  static const Color deepSea = Color(0xFF0B2545);
  static const Color midSea = Color(0xFF13315C);
  static const Color steel = Color(0xFF8DA9C4);
  static const Color mist = Color(0xFFEEF4ED);
  static const Color foam = Color(0xFFF7FAFC);
  static const Color surface = Colors.white;

  // Status colors
  static const Color income = Color(0xFF2E7D5B);
  static const Color incomeSoft = Color(0xFFE0F2EC);
  static const Color expense = Color(0xFFD96B5A);
  static const Color expenseSoft = Color(0xFFFCE9E5);

  static const Color textPrimary = Color(0xFF0B2545);
  static const Color textSecondary = Color(0xFF5A6B7B);
  static const Color divider = Color(0xFFE3E8EE);
}

class AppTheme {
  static ThemeData light() {
    final base = ThemeData.light(useMaterial3: true);
    final textTheme = GoogleFonts.interTextTheme(base.textTheme).apply(
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    );

    return base.copyWith(
      colorScheme: const ColorScheme.light(
        primary: AppColors.deepSea,
        onPrimary: Colors.white,
        secondary: AppColors.midSea,
        onSecondary: Colors.white,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        error: AppColors.expense,
      ),
      scaffoldBackgroundColor: AppColors.foam,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.foam,
        foregroundColor: AppColors.deepSea,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppColors.deepSea,
        ),
      ),
      // <comment-tag text="Changed from CardTheme to CardThemeData to match newer Flutter SDK requirements.">
      cardTheme: CardThemeData(
// </comment-tag>
        color: AppColors.surface,
        elevation: 0,
        // <comment-tag text="Changed from zero to provide a small gap between transactions in your list.">
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        // </comment-tag>
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(
            // <comment-tag text="Consider making this border slightly more prominent if the background color is very close to the surface color.">
            color: AppColors.divider,
            width: 1,
            // </comment-tag>
          ),
        ),
        // <comment-tag text="Ensures that any ripple effects (InkWell) are clipped to the rounded corners.">
        clipBehavior: Clip.antiAlias,
        // </comment-tag>
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.deepSea, width: 1.5),
        ),
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        hintStyle: const TextStyle(color: AppColors.textSecondary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.deepSea,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.deepSea,
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.deepSea,
        contentTextStyle: GoogleFonts.inter(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
