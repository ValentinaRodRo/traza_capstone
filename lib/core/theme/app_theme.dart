import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TrazaColors {
  // Brand Primary
  static const Color navyDeep = Color(0xFF0C1F3F);
  static const Color navyMid = Color(0xFF1B3A5C);
  static const Color navyLight = Color(0xFF2A5080);
  static const Color authorityBlue = Color(0xFF0C447C);

  // Semantic
  static const Color danger = Color(0xFFE24B4A);
  static const Color dangerLight = Color(0xFFFCEBEB);
  static const Color dangerText = Color(0xFFA32D2D);

  static const Color warning = Color(0xFFEF9F27);
  static const Color warningLight = Color(0xFFFAEEDA);
  static const Color warningText = Color(0xFF854F0B);

  static const Color success = Color(0xFF1D9E75);
  static const Color successLight = Color(0xFFEAF3DE);
  static const Color successText = Color(0xFF3B6D11);

  static const Color info = Color(0xFF185FA5);
  static const Color infoLight = Color(0xFFE6F1FB);
  static const Color infoText = Color(0xFF185FA5);

  static const Color purple = Color(0xFF3C3489);
  static const Color purpleLight = Color(0xFFEEEDFE);

  // Neutrals
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceAlt = Color(0xFFF5F6F8);
  static const Color surfaceDim = Color(0xFFEEF0F4);
  static const Color border = Color(0xFFDDE1E9);
  static const Color borderLight = Color(0xFFEEF0F4);

  static const Color textPrimary = Color(0xFF0E1825);
  static const Color textSecondary = Color(0xFF5C6B7A);
  static const Color textTertiary = Color(0xFF8E9EAD);

  // Map gradient
  static const Color mapLow = Color(0xFF4CAF50);
  static const Color mapMid = Color(0xFFFF9800);
  static const Color mapHigh = Color(0xFFE24B4A);
}

class TrazaTheme {
  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: TrazaColors.navyMid,
        brightness: Brightness.light,
        primary: TrazaColors.navyMid,
        secondary: TrazaColors.success,
        error: TrazaColors.danger,
        surface: TrazaColors.surface,
        surfaceContainerHighest: TrazaColors.surfaceAlt,
      ),
    );

    return base.copyWith(
      scaffoldBackgroundColor: TrazaColors.surfaceAlt,
      textTheme: GoogleFonts.interTextTheme(base.textTheme).copyWith(
        displayLarge: GoogleFonts.inter(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: TrazaColors.textPrimary,
          letterSpacing: -0.5,
        ),
        headlineLarge: GoogleFonts.inter(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: TrazaColors.textPrimary,
          letterSpacing: -0.3,
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: TrazaColors.textPrimary,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: TrazaColors.textPrimary,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: TrazaColors.textPrimary,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: TrazaColors.textPrimary,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: TrazaColors.textSecondary,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w400,
          color: TrazaColors.textTertiary,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: TrazaColors.surface,
          letterSpacing: 0.2,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: TrazaColors.navyMid,
        foregroundColor: TrazaColors.surface,
        elevation: 0,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: TrazaColors.surface,
        ),
        iconTheme: const IconThemeData(color: TrazaColors.surface),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: TrazaColors.surface,
        selectedItemColor: TrazaColors.navyMid,
        unselectedItemColor: TrazaColors.textTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: TrazaColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: TrazaColors.borderLight),
        ),
        margin: const EdgeInsets.only(bottom: 10),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: TrazaColors.surfaceAlt,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: TrazaColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: TrazaColors.border, width: 0.8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: TrazaColors.navyMid, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        hintStyle: GoogleFonts.inter(fontSize: 13, color: TrazaColors.textTertiary),
        labelStyle: GoogleFonts.inter(fontSize: 12, color: TrazaColors.textSecondary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: TrazaColors.navyMid,
          foregroundColor: TrazaColors.surface,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: TrazaColors.navyMid,
          side: const BorderSide(color: TrazaColors.navyMid),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: TrazaColors.borderLight,
        thickness: 0.8,
      ),
    );
  }
}

// Spacing constants
class TrazaSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;

  static const EdgeInsets pagePadding = EdgeInsets.symmetric(horizontal: 16, vertical: 12);
  static const EdgeInsets cardPadding = EdgeInsets.all(16);
}

// Border radius constants
class TrazaRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 28;
  static BorderRadius circular(double r) => BorderRadius.circular(r);
  static BorderRadius get card => BorderRadius.circular(16);
  static BorderRadius get button => BorderRadius.circular(14);
  static BorderRadius get chip => BorderRadius.circular(100);
  static BorderRadius get sheet => const BorderRadius.vertical(top: Radius.circular(28));
}