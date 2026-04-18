import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/models.dart';

ThemeData buildAppTheme(AppThemePack pack) {
  final ColorScheme colorScheme = ColorScheme.fromSeed(
    seedColor: pack.accent,
    brightness: Brightness.light,
    primary: pack.accent,
    surface: pack.surface,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme.copyWith(
      surface: pack.surface,
      primary: pack.accent,
      secondary: pack.darkSquare,
    ),
    scaffoldBackgroundColor: pack.background,
    textTheme: TextTheme(
      displaySmall: GoogleFonts.cormorantGaramond(
        fontSize: 34,
        fontWeight: FontWeight.w700,
        height: 1.0,
        color: const Color(0xFF1A1B1D),
      ),
      headlineSmall: GoogleFonts.cormorantGaramond(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF1A1B1D),
      ),
      titleLarge: GoogleFonts.sora(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF1F2529),
      ),
      titleMedium: GoogleFonts.sora(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF1F2529),
      ),
      bodyLarge: GoogleFonts.sora(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF2F3A40),
      ),
      bodyMedium: GoogleFonts.sora(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: const Color(0xFF526068),
      ),
      labelLarge: GoogleFonts.sora(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      color: pack.surface,
      margin: EdgeInsets.zero,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: pack.surface.withValues(alpha: 0.92),
      indicatorColor: pack.accent.withValues(alpha: 0.16),
      labelTextStyle: WidgetStatePropertyAll<TextStyle>(
        GoogleFonts.sora(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      selectedColor: pack.accent.withValues(alpha: 0.16),
      side: BorderSide(color: pack.accent.withValues(alpha: 0.16)),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      titleTextStyle: GoogleFonts.sora(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF1A1B1D),
      ),
    ),
  );
}
