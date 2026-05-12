// ─────────────────────────────────────────────
//  APP CONSTANTS - Standardized Design System
// ─────────────────────────────────────────────

import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
// COLORS
// ─────────────────────────────────────────────
class AppColors {
  static const Color scaffold    = Color(0xFFE8E0CE);
  static const Color accent      = Color(0xFFE07B39);
  static const Color cardBg      = Color(0xFFF5F0E3);
  static const Color offerCardBg = Color(0xFFC8B99A);
  static const Color textDark    = Color(0xFF2C2814);
  static const Color textMuted   = Color(0xFF8A8070);
  static const Color navBg       = Color(0xFFB5C49E);
  static const Color white       = Color(0xFFFFFFFF);
  static const Color divider     = Color(0xFFD9D0BF);
  static const Color chipDark    = Color(0xFF6B7C4E);
  static const Color accentGreen = Color(0xFF5A9E8B);
  static const Color headerBg    = Color(0xFFCCD5AE);
  static const Color danger      = Color(0xFFD64545);
  static const Color dangerBg    = Color(0xFFFCEBEB);
  static const Color inputBg     = Color(0xFFFAEDCD);
  static const Color iconBg      = Color(0xFFFAEDCD);
  // Additional colors needed for compatibility
  static const Color accentBg    = Color(0xFFFAEEDA);
  static const Color input       = Color(0xFFFAEDCD);
  static const Color textMut     = Color(0xFF8A8070); // Alias for textMuted
}

// ─────────────────────────────────────────────
// TEXT SIZES - Standardized and reduced
// ─────────────────────────────────────────────
class AppTextSizes {
  static const double titleXLarge  = 22.0;  // Extra large for page headers
  static const double titleLarge   = 18.0;  // Was 20-22
  static const double titleMedium  = 16.0;  // Was 18-20
  static const double titleSmall   = 14.0;  // Was 15-16
  static const double bodyLarge    = 13.0;  // Was 14-15
  static const double bodyMedium   = 12.0;  // Was 13-14
  static const double bodySmall    = 11.0;  // Was 12-13
  static const double caption      = 10.0;  // Was 11-12
  static const double tiny         = 9.0;   // Was 10-11
}

// ─────────────────────────────────────────────
// SPACING
// ─────────────────────────────────────────────
class AppSpacing {
  static const double xs  = 4.0;
  static const double sm  = 8.0;
  static const double md  = 12.0;
  static const double lg  = 16.0;
  static const double xl  = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;
}

// ─────────────────────────────────────────────
// DIMENSIONS
// ─────────────────────────────────────────────
class AppDimensions {
  static const double headerHeight = 120.0;
  static const double logoSize = 40.0;
  static const double buttonHeight = 48.0;
  static const double cardRadius = 16.0;
  static const double buttonRadius = 24.0;
  static const double iconSize = 20.0;
  static const double navHeight = 60.0;
}

// ─────────────────────────────────────────────
// BORDER RADIUS
// ─────────────────────────────────────────────
class AppBorderRadius {
  static const double small = 8.0;
  static const double medium = 12.0;
  static const double large = 16.0;
  static const double xlarge = 20.0;
  static const double round = 24.0;
  static const double full = 30.0;
}

// ─────────────────────────────────────────────
// SHADOWS
// ─────────────────────────────────────────────
class AppShadows {
  static const BoxShadow card = BoxShadow(
    color: Colors.black12,
    blurRadius: 8,
    offset: Offset(0, 2),
  );
  
  static const BoxShadow button = BoxShadow(
    color: Colors.black12,
    blurRadius: 12,
    offset: Offset(0, 4),
  );
}

// ─────────────────────────────────────────────
// FONT WEIGHTS
// ─────────────────────────────────────────────
class AppFontWeights {
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight extraBold = FontWeight.w800;
  static const FontWeight black = FontWeight.w900;
}
