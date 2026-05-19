import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

// ═══════════════════════════════════════════════════════════════════════════════
//  TRAZA DESIGN SYSTEM — app_theme.dart
//  Single source of truth for all visual tokens.
//  All pages and widgets import ONLY from this file.
// ═══════════════════════════════════════════════════════════════════════════════

// ─────────────────────────────────────────────
//  COLOR TOKENS
// ─────────────────────────────────────────────

class TrazaColors {
  TrazaColors._();

  // ── Backgrounds ──────────────────────────────
  static const Color bg         = Color(0xFF0E1117); // Page background
  static const Color bgSurface  = Color(0xFF161923); // Cards, list items
  static const Color bgCard     = Color(0xFF1A1E2A); // Elevated cards, nav items
  static const Color bgOverlay  = Color(0xFF1E2230); // Modals, bottom sheets

  // ── Brand ────────────────────────────────────
  static const Color brand      = Color(0xFF3D6FE8);
  static const Color brandDeep  = Color(0xFF2451C4);
  static const Color brandSub   = Color(0xFF1A2340); // Brand tinted background

  // ── Danger / Red ─────────────────────────────
  static const Color danger     = Color(0xFFE24B4A);
  static const Color dangerSub  = Color(0xFF2A1620);
  static const Color dangerText = Color(0xFFF09595);

  // ── Warning / Amber ──────────────────────────
  static const Color warning    = Color(0xFFEF9F27);
  static const Color warningSub = Color(0xFF221C0E);
  static const Color warningText= Color(0xFFFAC775);

  // ── Success / Green ───────────────────────────
  static const Color success    = Color(0xFF1D9E75);
  static const Color successSub = Color(0xFF0E2618);
  static const Color successText= Color(0xFF5DCAA5);

  // ── Info / Blue ───────────────────────────────
  static const Color info       = Color(0xFF378ADD);
  static const Color infoSub    = Color(0xFF0C1E30);
  static const Color infoText   = Color(0xFF85B7EB);

  // ── Purple ────────────────────────────────────
  static const Color purple     = Color(0xFF7F77DD);
  static const Color purpleSub  = Color(0xFF1A1830);
  static const Color purpleText = Color(0xFFAFA9EC);

  // ── Text ─────────────────────────────────────
  static const Color textPrimary   = Color(0xFFF0F2F7);
  static const Color textSecondary = Color(0xFF9AA0B2);
  static const Color textTertiary  = Color(0xFF4B5263);
  static const Color textDisabled  = Color(0xFF2E3444);

  // ── Borders ───────────────────────────────────
  static const Color border      = Color(0xFF232733);
  static const Color borderFaint = Color(0xFF1E2230);
  static const Color borderFocus = Color(0xFF3D6FE8);

  // ── Map specific ──────────────────────────────
  static const Color mapLow  = Color(0xFF1D9E75);
  static const Color mapMid  = Color(0xFFEF9F27);
  static const Color mapHigh = Color(0xFFE24B4A);
}

// ─────────────────────────────────────────────
//  SPACING TOKENS  (8pt grid)
// ─────────────────────────────────────────────

class TrazaSpacing {
  TrazaSpacing._();

  static const double xs   = 4.0;
  static const double sm   = 8.0;
  static const double md   = 12.0;
  static const double lg   = 16.0;
  static const double xl   = 20.0;
  static const double xxl  = 24.0;
  static const double xxxl = 32.0;

  static const EdgeInsets pagePadding  = EdgeInsets.symmetric(horizontal: 16, vertical: 12);
  static const EdgeInsets cardPadding  = EdgeInsets.all(14);
  static const EdgeInsets inputPadding = EdgeInsets.symmetric(horizontal: 14, vertical: 13);
}

// ─────────────────────────────────────────────
//  RADIUS TOKENS
// ─────────────────────────────────────────────

class TrazaRadius {
  TrazaRadius._();

  static const double xs  = 6.0;
  static const double sm  = 8.0;
  static const double md  = 12.0;
  static const double lg  = 14.0;
  static const double xl  = 18.0;
  static const double xxl = 20.0;

  static BorderRadius get chip   => BorderRadius.circular(100);
  static BorderRadius get card   => BorderRadius.circular(lg);
  static BorderRadius get button => BorderRadius.circular(lg);
  static BorderRadius get input  => BorderRadius.circular(md);
  static BorderRadius get sheet  => const BorderRadius.vertical(top: Radius.circular(28));
  static BorderRadius get map    => BorderRadius.circular(xxl);
}

// ─────────────────────────────────────────────
//  SHADOW TOKENS
// ─────────────────────────────────────────────

class TrazaShadows {
  TrazaShadows._();

  static List<BoxShadow> get brand => [
        BoxShadow(
          color: TrazaColors.brand.withOpacity(0.35),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ];

  static List<BoxShadow> get card => [
        BoxShadow(
          color: Colors.black.withOpacity(0.25),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];
}

// ─────────────────────────────────────────────
//  TEXT STYLES
// ─────────────────────────────────────────────

class TrazaTextStyles {
  TrazaTextStyles._();

  // Display
  static TextStyle get displayLarge => const TextStyle(
        fontSize: 32, fontWeight: FontWeight.w700,
        color: TrazaColors.textPrimary, letterSpacing: -0.8, height: 1.1);

  // Headlines
  static TextStyle get headlineLarge => const TextStyle(
        fontSize: 24, fontWeight: FontWeight.w700,
        color: TrazaColors.textPrimary, letterSpacing: -0.5, height: 1.2);

  static TextStyle get headlineMedium => const TextStyle(
        fontSize: 20, fontWeight: FontWeight.w600,
        color: TrazaColors.textPrimary, letterSpacing: -0.3);

  // Titles
  static TextStyle get titleLarge => const TextStyle(
        fontSize: 17, fontWeight: FontWeight.w700,
        color: TrazaColors.textPrimary, letterSpacing: -0.3);

  static TextStyle get titleMedium => const TextStyle(
        fontSize: 15, fontWeight: FontWeight.w600,
        color: TrazaColors.textPrimary, letterSpacing: -0.1);

  static TextStyle get titleSmall => const TextStyle(
        fontSize: 13, fontWeight: FontWeight.w600,
        color: TrazaColors.textPrimary, letterSpacing: -0.1);

  // Body
  static TextStyle get bodyLarge => const TextStyle(
        fontSize: 15, fontWeight: FontWeight.w400,
        color: TrazaColors.textPrimary, height: 1.5);

  static TextStyle get bodyMedium => const TextStyle(
        fontSize: 13, fontWeight: FontWeight.w400,
        color: TrazaColors.textSecondary, height: 1.5);

  static TextStyle get bodySmall => const TextStyle(
        fontSize: 11, fontWeight: FontWeight.w400,
        color: TrazaColors.textTertiary, height: 1.4);

  // Labels
  static TextStyle get labelLarge => const TextStyle(
        fontSize: 14, fontWeight: FontWeight.w600,
        color: TrazaColors.textPrimary, letterSpacing: 0.1);

  static TextStyle get labelMedium => const TextStyle(
        fontSize: 12, fontWeight: FontWeight.w500,
        color: TrazaColors.textSecondary);

  static TextStyle get labelSmall => const TextStyle(
        fontSize: 10, fontWeight: FontWeight.w500,
        color: TrazaColors.textTertiary, letterSpacing: 0.3);

  // Section header (uppercase caps)
  static TextStyle get sectionHeader => const TextStyle(
        fontSize: 11, fontWeight: FontWeight.w700,
        color: TrazaColors.textPrimary, letterSpacing: 1.0);

  // Stat value
  static TextStyle get statValue => const TextStyle(
        fontSize: 22, fontWeight: FontWeight.w700,
        color: TrazaColors.textPrimary, letterSpacing: -0.8, height: 1.0);

  // Badge
  static TextStyle get badge => const TextStyle(
        fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 0.5);
}

// ─────────────────────────────────────────────
//  THEME DATA
// ─────────────────────────────────────────────

class TrazaTheme {
  TrazaTheme._();

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: TrazaColors.bg,
      colorScheme: const ColorScheme.dark(
        primary:   TrazaColors.brand,
        secondary: TrazaColors.success,
        error:     TrazaColors.danger,
        surface:   TrazaColors.bgSurface,
      ),
      textTheme: _buildTextTheme(),
      appBarTheme: AppBarTheme(
        backgroundColor: TrazaColors.bg,
        foregroundColor: TrazaColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: TrazaTextStyles.titleLarge,
        iconTheme: const IconThemeData(color: TrazaColors.textSecondary, size: 20),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: TrazaColors.bg,
        selectedItemColor: TrazaColors.brand,
        unselectedItemColor: TrazaColors.textTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: TrazaColors.bgSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: TrazaRadius.card,
          side: const BorderSide(color: TrazaColors.border, width: 0.5),
        ),
        margin: const EdgeInsets.only(bottom: 8),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: TrazaColors.bgSurface,
        border: OutlineInputBorder(
          borderRadius: TrazaRadius.input,
          borderSide: const BorderSide(color: TrazaColors.border, width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: TrazaRadius.input,
          borderSide: const BorderSide(color: TrazaColors.border, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: TrazaRadius.input,
          borderSide: const BorderSide(color: TrazaColors.borderFocus, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: TrazaRadius.input,
          borderSide: const BorderSide(color: TrazaColors.danger, width: 1.0),
        ),
        contentPadding: TrazaSpacing.inputPadding,
        hintStyle: TrazaTextStyles.bodyMedium,
        labelStyle: TrazaTextStyles.labelMedium,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: TrazaColors.brand,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: TrazaRadius.button),
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 24),
          textStyle: TrazaTextStyles.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: TrazaColors.brand,
          side: const BorderSide(color: TrazaColors.border, width: 0.5),
          shape: RoundedRectangleBorder(borderRadius: TrazaRadius.button),
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 24),
          textStyle: TrazaTextStyles.labelLarge,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: TrazaColors.border,
        thickness: 0.5,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: TrazaColors.bgOverlay,
        modalBackgroundColor: TrazaColors.bgOverlay,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
    );
  }

  static TextTheme _buildTextTheme() {
    return GoogleFonts.dmSansTextTheme().copyWith(
      displayLarge:  GoogleFonts.dmSans(textStyle: TrazaTextStyles.displayLarge),
      headlineLarge: GoogleFonts.dmSans(textStyle: TrazaTextStyles.headlineLarge),
      headlineMedium:GoogleFonts.dmSans(textStyle: TrazaTextStyles.headlineMedium),
      titleLarge:    GoogleFonts.dmSans(textStyle: TrazaTextStyles.titleLarge),
      titleMedium:   GoogleFonts.dmSans(textStyle: TrazaTextStyles.titleMedium),
      titleSmall:    GoogleFonts.dmSans(textStyle: TrazaTextStyles.titleSmall),
      bodyLarge:     GoogleFonts.dmSans(textStyle: TrazaTextStyles.bodyLarge),
      bodyMedium:    GoogleFonts.dmSans(textStyle: TrazaTextStyles.bodyMedium),
      bodySmall:     GoogleFonts.dmSans(textStyle: TrazaTextStyles.bodySmall),
      labelLarge:    GoogleFonts.dmSans(textStyle: TrazaTextStyles.labelLarge),
      labelMedium:   GoogleFonts.dmSans(textStyle: TrazaTextStyles.labelMedium),
      labelSmall:    GoogleFonts.dmSans(textStyle: TrazaTextStyles.labelSmall),
    );
  }
}