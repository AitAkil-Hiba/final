import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const cream1 = Color(0xFFFDF8F0);
  static const cream2 = Color(0xFFF5EDD8);
  static const cardBg = Color(0xFFFFFBF4);
  static const cardBgAlt = Color(0xFFF9F3E8);

  static const textPrimary = Color(0xFF1A1A1A);
  static const textSecondary = Color(0xFF6B6B6B);
  static const textMuted = Color(0xFFAAAAAA);

  static const accentGreen = Color(0xFF4CAF7D);
  static const accentOrange = Color(0xFFE07B39);
  static const accentBrown = Color(0xFF8B5E3C);

  static const iconBg = Color(0xFFF0E8D8);
  static const divider = Color(0xFFE8DEC8);
  static const navBg = Color(0xFFFDF8F0);
  static const navActive = Color(0xFF5C4A2A);
  static const navInactive = Color(0xFFBBB0A0);
}

const appGradient = BoxDecoration(
  gradient: LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color.fromARGB(210, 246, 240, 226),
      Color.fromARGB(255, 227, 231, 214),
      Color.fromARGB(255, 233, 238, 212),
    ],
  ),
);

class AppFonts {
  AppFonts._();

  static const plusJakarta = 'PlusJakartaSans';
  static const notoThai = 'NotoSansThaiLooped';
}

class AppTextStyles {
  AppTextStyles._();

  static const pageTitle = TextStyle(
    fontFamily: AppFonts.plusJakarta,
    fontSize: 29,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  static const sectionLabel = TextStyle(
    fontFamily: AppFonts.plusJakarta,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.textMuted,
    letterSpacing: 1.2,
  );

  static const statValue = TextStyle(
    fontFamily: AppFonts.plusJakarta,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -1,
  );

  static const statLabel = TextStyle(
    fontFamily: AppFonts.plusJakarta,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textMuted,
    letterSpacing: 0.3,
  );

  static const statDelta = TextStyle(
    fontFamily: AppFonts.plusJakarta,
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
  );

  static const listItemTitle = TextStyle(
    fontFamily: AppFonts.plusJakarta,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static const navLabel = TextStyle(
    fontFamily: AppFonts.plusJakarta,
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.3,
  );

  static const bodyMedium = TextStyle(
    fontFamily: AppFonts.plusJakarta,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static const bodySmall = TextStyle(
    fontFamily: AppFonts.plusJakarta,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static const buttonLabel = TextStyle(
    fontFamily: AppFonts.plusJakarta,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    letterSpacing: 0.2,
  );

  static const inputLabel = TextStyle(
    fontFamily: AppFonts.plusJakarta,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static const inputText = TextStyle(
    fontFamily: AppFonts.plusJakarta,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static const chartLabel = TextStyle(
    fontFamily: AppFonts.notoThai,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static const chartValue = TextStyle(
    fontFamily: AppFonts.notoThai,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
}

class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
        fontFamily: AppFonts.plusJakarta,
        scaffoldBackgroundColor: AppColors.cream1,
        colorScheme: const ColorScheme.light(
          primary: AppColors.accentBrown,
          secondary: AppColors.accentGreen,
          surface: AppColors.cardBg,
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          titleTextStyle: AppTextStyles.pageTitle,
          iconTheme: IconThemeData(color: AppColors.textPrimary),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.cardBg,
          labelStyle: AppTextStyles.inputLabel,
          hintStyle: AppTextStyles.inputText
              .copyWith(color: AppColors.textMuted),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.divider),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.divider),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:
                const BorderSide(color: AppColors.accentBrown, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:
                const BorderSide(color: AppColors.accentOrange, width: 1.2),
          ),
        ),
        useMaterial3: true,
      );
}
