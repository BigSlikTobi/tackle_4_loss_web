/// Design Tokens for Tackle4Loss DeepDives
/// Ported from web/design-tokens.ts
///
/// Compact set aligned to 60/30/10 palette, 8pt grid, 4 font sizes, 2 weights.
library;

import 'package:flutter/material.dart';

// ============================================
// COLORS
// ============================================

class AppColors {
  AppColors._();

  // Brand
  static const Color brandBase = Color(0xFF0f3d2e); // Dark green metallic (10%)
  static const Color brandLight = Color(0xFF13543e);

  // Neutral
  static const Color neutralBase = Color(0xFFffffff); // 60% surface
  static const Color neutralSoft = Color(0xFFf4f4f4);
  static const Color neutralBorder = Color(0xFFe0e0e0);
  static const Color neutralText = Color(0xFF111111); // 30% complementary
  static const Color neutralTextMuted = Color(0xFF3a3a3a);
  static const Color neutralTextLight =
      Color(0xFF71717a); // Light text (zinc-500 equivalent)

  // Accent
  static const Color accentLine =
      Color(0xFFcfd4d1); // subtle dividers on neutral

  // Breaking News
  static const Color breakingNewsRed = Color(0xFF991b1b); // Red-800
  static const Color breakingNewsRedBright = Color(0xFFef4444); // Red-500

  // Legacy/Mapped Colors (Restored for compatibility)
  static const Color primary = brandBase;
  static const Color secondary = brandLight;
  static const Color accent = accentLine;

  static const Color backgroundLight = neutralSoft;
  static const Color backgroundDark = Color(0xFF0F1010); // Deep dark background

  static const Color cardLight = neutralBase;
  static const Color cardDark =
      Color(0xFF1A1C1C); // Slightly lighter than background

  static const Color textMainLight = neutralText;
  static const Color textMainDark =
      Color(0xFFE0E0E0); // Light grey for dark mode

  static const Color textSubLight = neutralTextLight;
  static const Color textSubDark = Color(0xFFA1A1AA); // Zinc-400 for dark mode

  // Aliases for Light Mode (Default)
  static const Color background = backgroundLight;
  static const Color surface = cardLight;
  static const Color textPrimary = textMainLight;
  static const Color textSecondary = textSubLight;
}

// ============================================
// TYPOGRAPHY
// ============================================

class AppTypography {
  AppTypography._();

  // Font Families
  static const String fontFamilyPrimary =
      'Inter'; // Fallback to system if not available

  // Font Sizes
  static const double fontSizeSm = 14.0; // 0.875rem
  static const double fontSizeMd = 16.0; // 1rem
  static const double fontSizeLg = 20.0; // 1.25rem
  static const double fontSizeXl = 28.0; // 1.75rem

  // Font Weights
  static const FontWeight fontWeightRegular = FontWeight.w400;
  static const FontWeight fontWeightBold = FontWeight.w700;
}

// ============================================
// SPACING - 8pt grid
// ============================================

class AppSpacing {
  AppSpacing._();

  static const double space0 = 0;
  static const double space1 = 8.0; // 0.5rem
  static const double space2 = 16.0; // 1rem
  static const double space3 = 24.0; // 1.5rem
  static const double space4 = 32.0; // 2rem
  static const double space5 = 40.0; // 2.5rem
  static const double space6 = 48.0; // 3rem
}

// ============================================
// BORDERS & RADIUS
// ============================================

class AppBorders {
  AppBorders._();

  // Widths
  static const double width0 = 0;
  static const double width1 = 1.0;
  static const double width2 = 2.0;
  static const double width4 = 4.0;
  static const double width8 = 8.0;

  // Radius
  static const double radiusNone = 0;
  static const double radiusSm = 2.0; // 0.125rem
  static const double radiusBase = 4.0; // 0.25rem
  static const double radiusMd = 6.0; // 0.375rem
  static const double radiusLg = 8.0; // 0.5rem
  static const double radiusXl = 12.0; // 0.75rem
  static const double radius2Xl = 16.0; // 1rem
  static const double radiusFull = 9999.0;
}

// ============================================
// SHADOWS
// ============================================

class AppShadows {
  AppShadows._();

  static const List<BoxShadow> sm = [
    BoxShadow(
        color: Color.fromRGBO(0, 0, 0, 0.05),
        offset: Offset(0, 1),
        blurRadius: 2,
        spreadRadius: 0),
  ];

  static const List<BoxShadow> base = [
    BoxShadow(
        color: Color.fromRGBO(0, 0, 0, 0.1),
        offset: Offset(0, 1),
        blurRadius: 3,
        spreadRadius: 0),
    BoxShadow(
        color: Color.fromRGBO(0, 0, 0, 0.1),
        offset: Offset(0, 1),
        blurRadius: 2,
        spreadRadius: -1),
  ];

  static const List<BoxShadow> md = [
    BoxShadow(
        color: Color.fromRGBO(0, 0, 0, 0.1),
        offset: Offset(0, 4),
        blurRadius: 6,
        spreadRadius: -1),
    BoxShadow(
        color: Color.fromRGBO(0, 0, 0, 0.1),
        offset: Offset(0, 2),
        blurRadius: 4,
        spreadRadius: -2),
  ];

  static const List<BoxShadow> lg = [
    BoxShadow(
        color: Color.fromRGBO(0, 0, 0, 0.1),
        offset: Offset(0, 10),
        blurRadius: 15,
        spreadRadius: -3),
    BoxShadow(
        color: Color.fromRGBO(0, 0, 0, 0.1),
        offset: Offset(0, 4),
        blurRadius: 6,
        spreadRadius: -4),
  ];

  static const List<BoxShadow> xl = [
    BoxShadow(
        color: Color.fromRGBO(0, 0, 0, 0.1),
        offset: Offset(0, 20),
        blurRadius: 25,
        spreadRadius: -5),
    BoxShadow(
        color: Color.fromRGBO(0, 0, 0, 0.1),
        offset: Offset(0, 8),
        blurRadius: 10,
        spreadRadius: -6),
  ];

  static const List<BoxShadow> newspaper = [
    BoxShadow(
        color: Color.fromRGBO(0, 0, 0, 0.15),
        offset: Offset(2, 2),
        blurRadius: 8,
        spreadRadius: 0),
  ];
}

// ============================================
// ANIMATION
// ============================================

class AppAnimation {
  AppAnimation._();

  static const Duration durationInstant = Duration(milliseconds: 75);
  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationNormal = Duration(milliseconds: 300);
  static const Duration durationSlow = Duration(milliseconds: 500);
  static const Duration durationSlower = Duration(milliseconds: 750);

  static const Curve curveLinear = Curves.linear;
  static const Curve curveEaseIn = Curves.easeIn;
  static const Curve curveEaseOut = Curves.easeOut;
  static const Curve curveEaseInOut = Curves.easeInOut;
  static const Curve curveBounce = Curves.elasticOut;
}

// ============================================
// TEXT STYLES (COMPOSITE)
// ============================================

class AppTextStyles {
  AppTextStyles._();

  static const String fontHeading = 'RussoOne';
  static const String fontBody = 'Inter';

  // Headings
  static const TextStyle display = TextStyle(
    fontFamily: fontHeading,
    fontSize: 34.0,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle h1 = TextStyle(
    fontFamily: fontHeading,
    fontSize: 28.0,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: fontHeading,
    fontSize: 22.0,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle h3 = TextStyle(
    fontFamily: fontBody,
    fontSize: 20.0,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  // Body
  static const TextStyle body = TextStyle(
    fontFamily: fontBody,
    fontSize: 16.0,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontBody,
    fontSize: 14.0,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );

  // Utility
  static const TextStyle caption = TextStyle(
    fontFamily: fontBody,
    fontSize: 14.0,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );
}

// ============================================
// LAYOUT - Golden Ratio & Proportions
// ============================================

class AppLayout {
  AppLayout._();

  /// Golden Ratio (φ = 1.618...)
  /// The golden ratio defines harmonious proportions used in design.
  static const double goldenRatio = 1.618033988749895;

  /// Upper section ratio (1 / (1 + φ)) ≈ 0.382 = 38.2%
  /// Use for the smaller section (e.g., app icons grid).
  static const double goldenUpper = 0.381966011250105;

  /// Lower section ratio (φ / (1 + φ)) ≈ 0.618 = 61.8%
  /// Use for the larger section (e.g., news feed).
  static const double goldenLower = 0.618033988749895;
}
