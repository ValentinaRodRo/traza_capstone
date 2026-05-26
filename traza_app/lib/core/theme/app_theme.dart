import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

// ═══════════════════════════════════════════════════════════════════════════════
//  TRAZA DESIGN SYSTEM — app_theme.dart
// ═══════════════════════════════════════════════════════════════════════════════

// ─────────────────────────────────────────────
//  DARK COLOR TOKENS  (sin cambios)
// ─────────────────────────────────────────────

class TrazaColors {
  TrazaColors._();

  static const Color bg         = Color(0xFF0E1117);
  static const Color bgSurface  = Color(0xFF161923);
  static const Color bgCard     = Color(0xFF1A1E2A);
  static const Color bgOverlay  = Color(0xFF1E2230);

  static const Color brand      = Color(0xFF3D6FE8);
  static const Color brandDeep  = Color(0xFF2451C4);
  static const Color brandSub   = Color(0xFF1A2340);

  static const Color danger     = Color(0xFFE24B4A);
  static const Color dangerSub  = Color(0xFF2A1620);
  static const Color dangerText = Color(0xFFF09595);

  static const Color warning    = Color(0xFFEF9F27);
  static const Color warningSub = Color(0xFF221C0E);
  static const Color warningText= Color(0xFFFAC775);

  static const Color success    = Color(0xFF1D9E75);
  static const Color successSub = Color(0xFF0E2618);
  static const Color successText= Color(0xFF5DCAA5);

  static const Color info       = Color(0xFF378ADD);
  static const Color infoSub    = Color(0xFF0C1E30);
  static const Color infoText   = Color(0xFF85B7EB);

  static const Color purple     = Color(0xFF7F77DD);
  static const Color purpleSub  = Color(0xFF1A1830);
  static const Color purpleText = Color(0xFFAFA9EC);

  static const Color textPrimary   = Color(0xFFF0F2F7);
  static const Color textSecondary = Color(0xFF9AA0B2);
  static const Color textTertiary  = Color(0xFF4B5263);
  static const Color textDisabled  = Color(0xFF2E3444);

  static const Color border      = Color(0xFF232733);
  static const Color borderFaint = Color(0xFF1E2230);
  static const Color borderFocus = Color(0xFF3D6FE8);

  static const Color mapLow  = Color(0xFF1D9E75);
  static const Color mapMid  = Color(0xFFEF9F27);
  static const Color mapHigh = Color(0xFFE24B4A);
}

// ─────────────────────────────────────────────
//  LIGHT COLOR TOKENS
// ─────────────────────────────────────────────

class TrazaColorsLight {
  TrazaColorsLight._();

  static const Color bg         = Color(0xFFF5F7FC);
  static const Color bgSurface  = Color(0xFFFFFFFF);
  static const Color bgCard     = Color(0xFFF0F3FA);
  static const Color bgOverlay  = Color(0xFFFFFFFF);

  static const Color brand      = Color(0xFF3D6FE8);
  static const Color brandDeep  = Color(0xFF2451C4);
  static const Color brandSub   = Color(0xFFDDE6FA);

  static const Color danger     = Color(0xFFD63B3A);
  static const Color dangerSub  = Color(0xFFFFEDED);
  static const Color dangerText = Color(0xFFB02020);

  static const Color warning    = Color(0xFFD4860A);
  static const Color warningSub = Color(0xFFFFF4E0);
  static const Color warningText= Color(0xFF8A5500);

  static const Color success    = Color(0xFF1A8A65);
  static const Color successSub = Color(0xFFE0F7EF);
  static const Color successText= Color(0xFF0E6347);

  static const Color info       = Color(0xFF2878CC);
  static const Color infoSub    = Color(0xFFE0EEF9);
  static const Color infoText   = Color(0xFF1A5A99);

  static const Color purple     = Color(0xFF6058C8);
  static const Color purpleSub  = Color(0xFFEEEDFA);
  static const Color purpleText = Color(0xFF3D3799);

  static const Color textPrimary   = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF4B5563);
  static const Color textTertiary  = Color(0xFF9CA3AF);
  static const Color textDisabled  = Color(0xFFD1D5DB);

  static const Color border      = Color(0xFFE5E7EB);
  static const Color borderFaint = Color(0xFFF3F4F6);
  static const Color borderFocus = Color(0xFF3D6FE8);

  static const Color mapLow  = Color(0xFF1A8A65);
  static const Color mapMid  = Color(0xFFD4860A);
  static const Color mapHigh = Color(0xFFD63B3A);
}

// ─────────────────────────────────────────────
//  ADAPTIVE TOKENS  (usa el contexto del tema)
// ─────────────────────────────────────────────

class TrazaThemeTokens {
  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color bg(BuildContext context) =>
      isDark(context) ? TrazaColors.bg : TrazaColorsLight.bg;

  static Color bgSurface(BuildContext context) =>
      isDark(context) ? TrazaColors.bgSurface : TrazaColorsLight.bgSurface;

  static Color bgCard(BuildContext context) =>
      isDark(context) ? TrazaColors.bgCard : TrazaColorsLight.bgCard;

  static Color bgOverlay(BuildContext context) =>
      isDark(context) ? TrazaColors.bgOverlay : TrazaColorsLight.bgOverlay;

  static Color brand(BuildContext context) =>
      isDark(context) ? TrazaColors.brand : TrazaColorsLight.brand;

  static Color brandSub(BuildContext context) =>
      isDark(context) ? TrazaColors.brandSub : TrazaColorsLight.brandSub;

  static Color danger(BuildContext context) =>
      isDark(context) ? TrazaColors.danger : TrazaColorsLight.danger;

  static Color dangerSub(BuildContext context) =>
      isDark(context) ? TrazaColors.dangerSub : TrazaColorsLight.dangerSub;

  static Color warning(BuildContext context) =>
      isDark(context) ? TrazaColors.warning : TrazaColorsLight.warning;

  static Color success(BuildContext context) =>
      isDark(context) ? TrazaColors.success : TrazaColorsLight.success;

  static Color successSub(BuildContext context) =>
      isDark(context) ? TrazaColors.successSub : TrazaColorsLight.successSub;

  static Color successText(BuildContext context) =>
      isDark(context) ? TrazaColors.successText : TrazaColorsLight.successText;

  static Color info(BuildContext context) =>
      isDark(context) ? TrazaColors.info : TrazaColorsLight.info;

  static Color infoSub(BuildContext context) =>
      isDark(context) ? TrazaColors.infoSub : TrazaColorsLight.infoSub;

  static Color infoText(BuildContext context) =>
      isDark(context) ? TrazaColors.infoText : TrazaColorsLight.infoText;

  static Color purple(BuildContext context) =>
      isDark(context) ? TrazaColors.purple : TrazaColorsLight.purple;

  static Color purpleSub(BuildContext context) =>
      isDark(context) ? TrazaColors.purpleSub : TrazaColorsLight.purpleSub;

  static Color textPrimary(BuildContext context) =>
      isDark(context) ? TrazaColors.textPrimary : TrazaColorsLight.textPrimary;

  static Color textSecondary(BuildContext context) =>
      isDark(context) ? TrazaColors.textSecondary : TrazaColorsLight.textSecondary;

  static Color textTertiary(BuildContext context) =>
      isDark(context) ? TrazaColors.textTertiary : TrazaColorsLight.textTertiary;

  static Color border(BuildContext context) =>
      isDark(context) ? TrazaColors.border : TrazaColorsLight.border;

  static Color borderFaint(BuildContext context) =>
      isDark(context) ? TrazaColors.borderFaint : TrazaColorsLight.borderFaint;

  static Color warningSub(BuildContext context) =>
      isDark(context) ? TrazaColors.warningSub : TrazaColorsLight.warningSub;
}

// ─────────────────────────────────────────────
//  SPACING TOKENS  (sin cambios)
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
//  RADIUS TOKENS  (sin cambios)
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
//  TEXT STYLES  (sin cambios)
// ─────────────────────────────────────────────

class TrazaTextStyles {
  TrazaTextStyles._();

  static TextStyle get displayLarge => const TextStyle(
        fontSize: 32, fontWeight: FontWeight.w700,
        color: TrazaColors.textPrimary, letterSpacing: -0.8, height: 1.1);

  static TextStyle get headlineLarge => const TextStyle(
        fontSize: 24, fontWeight: FontWeight.w700,
        color: TrazaColors.textPrimary, letterSpacing: -0.5, height: 1.2);

  static TextStyle get headlineMedium => const TextStyle(
        fontSize: 20, fontWeight: FontWeight.w600,
        color: TrazaColors.textPrimary, letterSpacing: -0.3);

  static TextStyle get titleLarge => const TextStyle(
        fontSize: 17, fontWeight: FontWeight.w700,
        color: TrazaColors.textPrimary, letterSpacing: -0.3);

  static TextStyle get titleMedium => const TextStyle(
        fontSize: 15, fontWeight: FontWeight.w600,
        color: TrazaColors.textPrimary, letterSpacing: -0.1);

  static TextStyle get titleSmall => const TextStyle(
        fontSize: 13, fontWeight: FontWeight.w600,
        color: TrazaColors.textPrimary, letterSpacing: -0.1);

  static TextStyle get bodyLarge => const TextStyle(
        fontSize: 15, fontWeight: FontWeight.w400,
        color: TrazaColors.textPrimary, height: 1.5);

  static TextStyle get bodyMedium => const TextStyle(
        fontSize: 13, fontWeight: FontWeight.w400,
        color: TrazaColors.textSecondary, height: 1.5);

  static TextStyle get bodySmall => const TextStyle(
        fontSize: 11, fontWeight: FontWeight.w400,
        color: TrazaColors.textTertiary, height: 1.4);

  static TextStyle get labelLarge => const TextStyle(
        fontSize: 14, fontWeight: FontWeight.w600,
        color: TrazaColors.textPrimary, letterSpacing: 0.1);

  static TextStyle get labelMedium => const TextStyle(
        fontSize: 12, fontWeight: FontWeight.w500,
        color: TrazaColors.textSecondary);

  static TextStyle get labelSmall => const TextStyle(
        fontSize: 10, fontWeight: FontWeight.w500,
        color: TrazaColors.textTertiary, letterSpacing: 0.3);

  static TextStyle get sectionHeader => const TextStyle(
        fontSize: 11, fontWeight: FontWeight.w700,
        color: TrazaColors.textPrimary, letterSpacing: 1.0);

  static TextStyle get statValue => const TextStyle(
        fontSize: 22, fontWeight: FontWeight.w700,
        color: TrazaColors.textPrimary, letterSpacing: -0.8, height: 1.0);

  static TextStyle get badge => const TextStyle(
        fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 0.5);
}

// ─────────────────────────────────────────────
//  THEME DATA
// ─────────────────────────────────────────────

class TrazaTheme {
  TrazaTheme._();

  static ThemeData get dark => _build(
        brightness: Brightness.dark,
        bg: TrazaColors.bg,
        surface: TrazaColors.bgSurface,
        card: TrazaColors.bgCard,
        overlay: TrazaColors.bgOverlay,
        textPrimary: TrazaColors.textPrimary,
        textSecondary: TrazaColors.textSecondary,
        textTertiary: TrazaColors.textTertiary,
        border: TrazaColors.border,
        borderFocus: TrazaColors.borderFocus,
        fillColor: TrazaColors.bgSurface,
        overlayStyle: SystemUiOverlayStyle.light,
      );

  static ThemeData get light => _build(
        brightness: Brightness.light,
        bg: TrazaColorsLight.bg,
        surface: TrazaColorsLight.bgSurface,
        card: TrazaColorsLight.bgCard,
        overlay: TrazaColorsLight.bgOverlay,
        textPrimary: TrazaColorsLight.textPrimary,
        textSecondary: TrazaColorsLight.textSecondary,
        textTertiary: TrazaColorsLight.textTertiary,
        border: TrazaColorsLight.border,
        borderFocus: TrazaColorsLight.borderFocus,
        fillColor: TrazaColorsLight.bgSurface,
        overlayStyle: SystemUiOverlayStyle.dark,
      );

  static ThemeData _build({
    required Brightness brightness,
    required Color bg,
    required Color surface,
    required Color card,
    required Color overlay,
    required Color textPrimary,
    required Color textSecondary,
    required Color textTertiary,
    required Color border,
    required Color borderFocus,
    required Color fillColor,
    required SystemUiOverlayStyle overlayStyle,
  }) {
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: bg,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: TrazaColors.brand,
        onPrimary: Colors.white,
        secondary: TrazaColors.success,
        onSecondary: Colors.white,
        error: TrazaColors.danger,
        onError: Colors.white,
        surface: surface,
        onSurface: textPrimary,
      ),
      textTheme: _buildTextTheme(textPrimary, textSecondary, textTertiary),
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: overlayStyle,
        titleTextStyle: TrazaTextStyles.titleLarge.copyWith(color: textPrimary),
        iconTheme: IconThemeData(color: textSecondary, size: 20),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: bg,
        selectedItemColor: TrazaColors.brand,
        unselectedItemColor: textTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: TrazaRadius.card,
          side: BorderSide(color: border, width: 0.5),
        ),
        margin: const EdgeInsets.only(bottom: 8),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: fillColor,
        border: OutlineInputBorder(
          borderRadius: TrazaRadius.input,
          borderSide: BorderSide(color: border, width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: TrazaRadius.input,
          borderSide: BorderSide(color: border, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: TrazaRadius.input,
          borderSide: BorderSide(color: borderFocus, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: TrazaRadius.input,
          borderSide: const BorderSide(color: TrazaColors.danger, width: 1.0),
        ),
        contentPadding: TrazaSpacing.inputPadding,
        hintStyle: TrazaTextStyles.bodyMedium.copyWith(color: textTertiary),
        labelStyle: TrazaTextStyles.labelMedium.copyWith(color: textSecondary),
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
          side: BorderSide(color: border, width: 0.5),
          shape: RoundedRectangleBorder(borderRadius: TrazaRadius.button),
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 24),
          textStyle: TrazaTextStyles.labelLarge,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: border,
        thickness: 0.5,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: overlay,
        modalBackgroundColor: overlay,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
    );
  }

  static TextTheme _buildTextTheme(
    Color primary,
    Color secondary,
    Color tertiary,
  ) {
    return GoogleFonts.dmSansTextTheme().copyWith(
      displayLarge:   GoogleFonts.dmSans(textStyle: TrazaTextStyles.displayLarge.copyWith(color: primary)),
      headlineLarge:  GoogleFonts.dmSans(textStyle: TrazaTextStyles.headlineLarge.copyWith(color: primary)),
      headlineMedium: GoogleFonts.dmSans(textStyle: TrazaTextStyles.headlineMedium.copyWith(color: primary)),
      titleLarge:     GoogleFonts.dmSans(textStyle: TrazaTextStyles.titleLarge.copyWith(color: primary)),
      titleMedium:    GoogleFonts.dmSans(textStyle: TrazaTextStyles.titleMedium.copyWith(color: primary)),
      titleSmall:     GoogleFonts.dmSans(textStyle: TrazaTextStyles.titleSmall.copyWith(color: primary)),
      bodyLarge:      GoogleFonts.dmSans(textStyle: TrazaTextStyles.bodyLarge.copyWith(color: primary)),
      bodyMedium:     GoogleFonts.dmSans(textStyle: TrazaTextStyles.bodyMedium.copyWith(color: secondary)),
      bodySmall:      GoogleFonts.dmSans(textStyle: TrazaTextStyles.bodySmall.copyWith(color: tertiary)),
      labelLarge:     GoogleFonts.dmSans(textStyle: TrazaTextStyles.labelLarge.copyWith(color: primary)),
      labelMedium:    GoogleFonts.dmSans(textStyle: TrazaTextStyles.labelMedium.copyWith(color: secondary)),
      labelSmall:     GoogleFonts.dmSans(textStyle: TrazaTextStyles.labelSmall.copyWith(color: tertiary)),
    );
  }
}