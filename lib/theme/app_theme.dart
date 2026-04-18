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
  final Color elevatedSurface = Color.alphaBlend(
    Colors.white.withValues(alpha: 0.78),
    pack.surface,
  );
  final RoundedRectangleBorder rounded = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(20),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme.copyWith(
      surface: pack.surface,
      surfaceContainerHighest: elevatedSurface,
      primary: pack.accent,
      secondary: pack.darkSquare,
      outline: pack.darkSquare.withValues(alpha: 0.18),
      onPrimary: Colors.white,
      onSurface: const Color(0xFF171A1D),
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
    dividerColor: pack.darkSquare.withValues(alpha: 0.14),
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
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        textStyle: GoogleFonts.sora(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.1,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: rounded,
        side: BorderSide(color: pack.darkSquare.withValues(alpha: 0.24)),
        foregroundColor: const Color(0xFF1D252C),
        textStyle: GoogleFonts.sora(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      ),
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      selectedColor: pack.accent.withValues(alpha: 0.16),
      side: BorderSide(color: pack.accent.withValues(alpha: 0.16)),
      labelStyle: GoogleFonts.sora(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF1D252C),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: pack.surface.withValues(alpha: 0.92),
      indicatorColor: pack.accent.withValues(alpha: 0.16),
      labelTextStyle: WidgetStatePropertyAll<TextStyle>(
        GoogleFonts.sora(fontSize: 12, fontWeight: FontWeight.w700),
      ),
      iconTheme: WidgetStateProperty.resolveWith<IconThemeData?>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: pack.darkSquare);
          }
          return IconThemeData(
            color: const Color(0xFF55606A).withValues(alpha: 0.9),
          );
        },
      ),
    ),
    switchTheme: SwitchThemeData(
      trackColor: WidgetStateProperty.resolveWith<Color?>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.selected)) {
            return pack.accent.withValues(alpha: 0.44);
          }
          return pack.darkSquare.withValues(alpha: 0.18);
        },
      ),
      thumbColor: WidgetStateProperty.resolveWith<Color?>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.selected)) {
            return pack.accent;
          }
          return const Color(0xFFB8BFC7);
        },
      ),
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
