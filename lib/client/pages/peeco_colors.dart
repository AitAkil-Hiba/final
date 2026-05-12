// ─────────────────────────────────────────────
//  COULEURS — extraites fidèlement du Figma
// ─────────────────────────────────────────────
// ignore_for_file: unnecessary_import, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PeecoColors {
  // Fonds
  static const Color backgroundPrimary   = Color(0xFFFEFAE0); // crème chaud
  static const Color backgroundSecondary = Color(0xFFE9EDC9); // vert sauge clair
  static const Color backgroundCard      = Color(0xFFFFFFFF);
 
  // Accents
  static const Color accentGreen  = Color(0xFFCCD5AE); // vert sauge moyen
  static const Color accentGold   = Color(0xFFFAEDCD); // doré clair
  static const Color accentOrange = Color(0xFFF9AE63); // orange doux
 
  // Textes
  static const Color textPrimary   = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B6B6B);
  static const Color textHint      = Color(0xFFAAAAAA);
 
  // États
  static const Color success = Color(0xFF4CAF50);
  static const Color error   = Color(0xFFE53935);
  static const Color warning = Color(0xFFFF9800);
 
  // Bordures
  static const Color border        = Color(0xFFE9EDC9);
  static const Color borderFocused = Color(0xFFCCD5AE);
 
  // Gradients
  static const LinearGradient gradientSplash = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFFFFF), Color(0xFFCCD5AE)],
  );
 
  static const LinearGradient gradientBackground = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.226, 0.452, 0.755],
    colors: [Color(0xFFFFFFFF), Color(0xFFFAEDCD), Color(0xFFCCD5AE)],
  );
 
  static const LinearGradient gradientNotifs = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.226, 0.832],
    colors: [Color(0xFFFFFFFF), Color(0xFFFAEDCD)],
  );
}
 
// ─────────────────────────────────────────────
//  THÈME GLOBAL
// ─────────────────────────────────────────────


ThemeData peecoTheme() {
  return ThemeData(
    useMaterial3: true,
    fontFamily: 'SF Pro Rounded',
    scaffoldBackgroundColor: PeecoColors.backgroundPrimary,
    colorScheme: ColorScheme.light(
      primary:    PeecoColors.accentGreen,
      secondary:  PeecoColors.accentGold,
      surface:    PeecoColors.backgroundPrimary,
      background: PeecoColors.backgroundPrimary,
      onPrimary:  PeecoColors.textPrimary,
      onSurface:  PeecoColors.textPrimary,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: PeecoColors.backgroundPrimary,
      foregroundColor: PeecoColors.textPrimary,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: PeecoColors.textPrimary,
        fontSize: 17,
        fontWeight: FontWeight.w600,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: PeecoColors.accentGreen,
        foregroundColor: PeecoColors.textPrimary,
        elevation: 0,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: PeecoColors.textPrimary,
        side: const BorderSide(color: PeecoColors.accentGreen, width: 1.5),
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: PeecoColors.backgroundCard,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: PeecoColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: PeecoColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: PeecoColors.borderFocused, width: 2),
      ),
      hintStyle: const TextStyle(color: PeecoColors.textHint, fontSize: 15),
      labelStyle: const TextStyle(color: PeecoColors.textSecondary),
    ),
    cardTheme: CardThemeData(
      color: PeecoColors.backgroundCard,
      elevation: 2,
      shadowColor: PeecoColors.accentGreen.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: PeecoColors.border, width: 1),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: PeecoColors.backgroundCard,
      selectedItemColor: PeecoColors.accentGreen,
      unselectedItemColor: PeecoColors.textHint,
      elevation: 8,
      type: BottomNavigationBarType.fixed,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: PeecoColors.backgroundSecondary,
      selectedColor: PeecoColors.accentGreen,
      labelStyle: const TextStyle(color: PeecoColors.textPrimary, fontSize: 13),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    dividerTheme: const DividerThemeData(
      color: PeecoColors.border,
      thickness: 1,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: PeecoColors.textPrimary),
      headlineMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: PeecoColors.textPrimary),
      headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: PeecoColors.textPrimary),
      titleLarge: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: PeecoColors.textPrimary),
      titleMedium: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: PeecoColors.textPrimary),
      titleSmall: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: PeecoColors.textSecondary),
      bodyLarge: TextStyle(fontSize: 16, color: PeecoColors.textPrimary),
      bodyMedium: TextStyle(fontSize: 14, color: PeecoColors.textSecondary),
      bodySmall: TextStyle(fontSize: 12, color: PeecoColors.textHint),
      labelLarge: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: PeecoColors.textPrimary),
    ),
  );
}
 