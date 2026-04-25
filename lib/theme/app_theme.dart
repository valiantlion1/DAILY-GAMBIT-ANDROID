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
      foreground: const Color(0xFF241E18),
      card: const Color(0xFFF8F1E6),
      cardForeground: const Color(0xFF241E18),
      popover: Colors.white,
      popoverForeground: const Color(0xFF241E18),
      primary: pack.accent,
      primaryForeground: Colors.white,
      secondary: const Color(0xFFEAE0D1),
      secondaryForeground: const Color(0xFF241E18),
      muted: const Color(0xFFECE3D7),
      mutedForeground: const Color(0xFF786D63),
      accent: const Color(0xFF17281D),
      accentForeground: Colors.white,
      destructive: const Color(0xFF8C3B35),
      destructiveForeground: Colors.white,
      border: const Color(0x33241E18),
      input: const Color(0x26241E18),
      ring: pack.accent,
      selection: pack.accent.withValues(alpha: 0.20),
    ),
    radius: BorderRadius.circular(8),
    textTheme: ShadTextTheme.fromGoogleFont(GoogleFonts.sora),
  );
}

ThemeData buildAppTheme(AppThemePack pack, {ThemeData? baseTheme}) {
  final ThemeData base = baseTheme ?? ThemeData(useMaterial3: true);
  const Color ink = Color(0xFF241E18);
  const Color muted = Color(0xFF786D63);
  final RoundedRectangleBorder rounded = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(8),
  );
  final ColorScheme scheme = ColorScheme.fromSeed(
    seedColor: pack.accent,
    brightness: Brightness.light,
    primary: pack.accent,
    surface: pack.surface,
  );

  return base.copyWith(
    colorScheme: scheme.copyWith(
      primary: pack.accent,
      secondary: const Color(0xFF17281D),
      surface: pack.surface,
      outline: const Color(0x33241E18),
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
        letterSpacing: 0,
        color: ink,
      ),
      headlineSmall: GoogleFonts.cormorantGaramond(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 1.04,
        letterSpacing: 0,
        color: ink,
      ),
      titleLarge: GoogleFonts.cormorantGaramond(
        fontSize: 21,
        fontWeight: FontWeight.w700,
        height: 1.08,
        letterSpacing: 0,
        color: ink,
      ),
      titleMedium: GoogleFonts.sora(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
        color: ink,
      ),
      bodyLarge: GoogleFonts.sora(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        height: 1.42,
        letterSpacing: 0,
        color: ink,
      ),
      bodyMedium: GoogleFonts.sora(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        height: 1.38,
        letterSpacing: 0,
        color: muted,
      ),
      bodySmall: GoogleFonts.sora(
        fontSize: 10.5,
        fontWeight: FontWeight.w600,
        height: 1.25,
        letterSpacing: 0,
        color: muted,
      ),
      labelLarge: GoogleFonts.sora(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
        color: ink,
      ),
    ),
    dividerColor: const Color(0x1F241E18),
    cardTheme: CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: const Color(0xFFF7F0E5),
      surfaceTintColor: Colors.transparent,
      shape: rounded,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: rounded,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        elevation: 0,
        backgroundColor: pack.accent,
        foregroundColor: Colors.white,
        textStyle: GoogleFonts.sora(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: rounded,
        side: const BorderSide(color: Color(0x33241E18)),
        foregroundColor: ink,
        textStyle: GoogleFonts.sora(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    ),
    switchTheme: SwitchThemeData(
      trackColor: WidgetStateProperty.resolveWith<Color?>((
        Set<WidgetState> states,
      ) {
        if (states.contains(WidgetState.selected)) {
          return const Color(0xFF5E7E4D);
        }
        return const Color(0x33241E18);
      }),
      thumbColor: WidgetStateProperty.resolveWith<Color?>((
        Set<WidgetState> states,
      ) {
        if (states.contains(WidgetState.selected)) {
          return Colors.white;
        }
        return const Color(0xFFF6EFE5);
      }),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(color: pack.accent),
  );
}
