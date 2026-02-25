import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.black,
      colorScheme: const ColorScheme.dark(
        primary:   AppColors.primary,
        surface:   AppColors.surface,
        onPrimary: AppColors.white,
        onSurface: AppColors.white,
        outline:   AppColors.border,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge:  GoogleFonts.syne(fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.white),
        displayMedium: GoogleFonts.syne(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.white),
        titleLarge:    GoogleFonts.syne(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.white),
        titleMedium:   GoogleFonts.syne(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.white),
        bodyLarge:  const TextStyle(fontSize: 15, color: AppColors.white, height: 1.6),
        bodyMedium: const TextStyle(fontSize: 13, color: AppColors.greyMuted, height: 1.5),
        labelSmall: GoogleFonts.syne(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: .08, color: AppColors.greyMuted),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.black,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.syne(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.white),
        iconTheme: const IconThemeData(color: AppColors.white),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.border),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface2,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
        labelStyle: const TextStyle(color: AppColors.greyMuted),
        hintStyle:  const TextStyle(color: AppColors.greyLight),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.syne(fontSize: 15, fontWeight: FontWeight.w700),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          side: const BorderSide(color: AppColors.border),
          textStyle: GoogleFonts.syne(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.border, thickness: 1, space: 1),
    );
  }
}