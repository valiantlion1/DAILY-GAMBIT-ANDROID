import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../core/models.dart';

ShadThemeData buildShadTheme(AppThemePack pack) {
  final ShadColorScheme base = ShadColorScheme.fromName('stone');
  return ShadThemeData(
    brightness: Brightness.light,
    colorScheme: base.copyWith(
      background: pack.background,
      foreground: const Color(0xFF201A16),
      card: Color.alphaBlend(
        Colors.white.withValues(alpha: 0.88),
        pack.surface,
      ),
      cardForeground: const Color(0xFF201A16),
      popover: Colors.white,
      popoverForeground: const Color(0xFF201A16),
      primary: pack.accent,
      primaryForeground: Colors.white,
      secondary: Color.alphaBlend(
        Colors.white.withValues(alpha: 0.72),
        pack.surface,
      ),
      secondaryForeground: const Color(0xFF2A211A),
      muted: Color.alphaBlend(
        Colors.white.withValues(alpha: 0.72),
        pack.surface,
      ),
      mutedForeground: const Color(0xFF6A635C),
      accent: pack.darkSquare,
      accentForeground: Colors.white,
      destructive: const Color(0xFF8C3B35),
      destructiveForeground: Colors.white,
      border: pack.darkSquare.withValues(alpha: 0.14),
      input: pack.darkSquare.withValues(alpha: 0.10),
      ring: pack.accent,
      selection: pack.accent.withValues(alpha: 0.22),
      custom: <String, Color>{
        'boardLight': pack.lightSquare,
        'boardDark': pack.darkSquare,
      },
    ),
    radius: BorderRadius.circular(24),
    textTheme: ShadTextTheme.fromGoogleFont(GoogleFonts.sora),
  );
}

ThemeData buildAppTheme(AppThemePack pack, {ThemeData? baseTheme}) {
  final ThemeData base = baseTheme ?? ThemeData(useMaterial3: true);
  final ColorScheme colorScheme = ColorScheme.fromSeed(
    seedColor: pack.accent,
    brightness: Brightness.light,
    primary: pack.accent,
    surface: pack.surface,
  );
  final Color elevatedSurface = Color.alphaBlend(
    Colors.white.withValues(alpha: 0.82),
    pack.surface,
  );
  final Color ink = const Color(0xFF201A16);
  final RoundedRectangleBorder rounded = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(22),
  );

  return base.copyWith(
    colorScheme: colorScheme.copyWith(
      surface: pack.surface,
      surfaceContainerHighest: elevatedSurface,
      primary: pack.accent,
      secondary: pack.darkSquare,
      outline: pack.darkSquare.withValues(alpha: 0.12),
      onPrimary: Colors.white,
      onSurface: ink,
    ),
    scaffoldBackgroundColor: pack.background,
    canvasColor: Colors.transparent,
    textTheme: TextTheme(
      displaySmall: GoogleFonts.cormorantGaramond(
        fontSize: 38,
        fontWeight: FontWeight.w700,
        height: 1.0,
        color: ink,
      ),
      headlineSmall: GoogleFonts.cormorantGaramond(
        fontSize: 30,
        fontWeight: FontWeight.w700,
        height: 1.04,
        color: ink,
      ),
      titleLarge: GoogleFonts.sora(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.1,
        color: const Color(0xFF2A211A),
      ),
      titleMedium: GoogleFonts.sora(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
        color: const Color(0xFF2A211A),
      ),
      bodyLarge: GoogleFonts.sora(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        height: 1.45,
        color: const Color(0xFF4D433B),
      ),
      bodyMedium: GoogleFonts.sora(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        height: 1.42,
        color: const Color(0xFF71675F),
      ),
      bodySmall: GoogleFonts.sora(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: const Color(0xFF8A8077),
      ),
      labelLarge: GoogleFonts.sora(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.6,
      ),
    ),
    dividerColor: pack.darkSquare.withValues(alpha: 0.10),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      color: elevatedSurface,
      margin: EdgeInsets.zero,
      surfaceTintColor: Colors.transparent,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: rounded,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        elevation: 0,
        backgroundColor: pack.accent,
        foregroundColor: Colors.white,
        textStyle: GoogleFonts.sora(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: rounded,
        side: BorderSide(color: pack.darkSquare.withValues(alpha: 0.20)),
        foregroundColor: const Color(0xFF2A211A),
        textStyle: GoogleFonts.sora(fontSize: 14, fontWeight: FontWeight.w600),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
      ),
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      selectedColor: pack.accent.withValues(alpha: 0.14),
      side: BorderSide(color: pack.accent.withValues(alpha: 0.14)),
      labelStyle: GoogleFonts.sora(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF2A211A),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.transparent,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      height: 68,
      indicatorColor: pack.accent.withValues(alpha: 0.14),
      labelTextStyle: WidgetStatePropertyAll<TextStyle>(
        GoogleFonts.sora(fontSize: 11, fontWeight: FontWeight.w700),
      ),
      iconTheme: WidgetStateProperty.resolveWith<IconThemeData?>((
        Set<WidgetState> states,
      ) {
        if (states.contains(WidgetState.selected)) {
          return IconThemeData(color: pack.accent);
        }
        return IconThemeData(
          color: const Color(0xFF8A8178).withValues(alpha: 0.92),
        );
      }),
    ),
    switchTheme: SwitchThemeData(
      trackColor: WidgetStateProperty.resolveWith<Color?>((
        Set<WidgetState> states,
      ) {
        if (states.contains(WidgetState.selected)) {
          return pack.accent.withValues(alpha: 0.38);
        }
        return pack.darkSquare.withValues(alpha: 0.18);
      }),
      thumbColor: WidgetStateProperty.resolveWith<Color?>((
        Set<WidgetState> states,
      ) {
        if (states.contains(WidgetState.selected)) {
          return pack.accent;
        }
        return const Color(0xFFB8BFC7);
      }),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: pack.accent,
      linearTrackColor: pack.accent.withValues(alpha: 0.10),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      titleTextStyle: GoogleFonts.sora(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: ink,
      ),
    ),
  );
}
