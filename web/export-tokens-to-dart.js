// Design Token Exporter for Flutter/Dart
// ==========================================
//
// USAGE:
//   npm run export-tokens
//   or
//   node export-tokens-to-dart.js
//
// OUTPUT:
//   ../flutter_app/lib/design_tokens.dart (auto-generated, gitignored)
//
// MAINTENANCE:
//   When updating design-tokens.ts, also update the inline
//   copy below to keep exports in sync.
//
// ==========================================

import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const outputPath = path.resolve(__dirname, '../flutter_app/lib/design_tokens.dart');

// Manually define the design tokens inline (copied from design-tokens.ts)
// NOTE: Keep this in sync with design-tokens.ts when making changes
const designTokens = {
  colors: {
    primary: {
      50: '#f0fdf4',
      100: '#dcfce7',
      200: '#bbf7d0',
      300: '#86efac',
      400: '#4ade80',
      500: '#16a34a',
      600: '#15803d',
      700: '#14532d',
      800: '#0f3a21',
      900: '#052e16',
    },
    secondary: {
      50: '#fffbeb',
      100: '#fef3c7',
      200: '#fde68a',
      300: '#fcd34d',
      400: '#fbbf24',
      500: '#f59e0b',
      600: '#d97706',
      700: '#b45309',
      800: '#92400e',
      900: '#78350f',
    },
    accent: {
      red: '#dc2626',
      blue: '#2563eb',
      orange: '#ea580c',
      purple: '#9333ea',
    },
    neutral: {
      white: '#ffffff',
      paper: '#fafaf9',
      smoke: '#f5f5f4',
      stone: '#e7e5e4',
      ink: '#0a0a0a',
      charcoal: '#1c1917',
    },
    football: {
      field: '#1a5f3d',
      leather: '#8b4513',
      chalk: '#f8fafc',
      astroturf: '#047857',
    }
  }
};

function toDartColor(hex) {
  // Convert #RRGGBB to 0xFFRRGGBB
  return `0xFF${hex.replace('#', '')}`;
}

function generateDartTokens() {
  const dartCode = `/// Design Tokens for Tackle4Loss DeepDives
/// Auto-generated from design-tokens.ts
/// DO NOT EDIT MANUALLY
///
/// American Football Newspaper Theme
library design_tokens;

import 'package:flutter/material.dart';

// ============================================
// COLORS - Football Stadium & Newspaper Theme
// ============================================

class AppColors {
  AppColors._();
  
  // Primary - Field Green
  static const Color primary50 = Color(${toDartColor(designTokens.colors.primary[50])});
  static const Color primary100 = Color(${toDartColor(designTokens.colors.primary[100])});
  static const Color primary200 = Color(${toDartColor(designTokens.colors.primary[200])});
  static const Color primary300 = Color(${toDartColor(designTokens.colors.primary[300])});
  static const Color primary400 = Color(${toDartColor(designTokens.colors.primary[400])});
  static const Color primary500 = Color(${toDartColor(designTokens.colors.primary[500])});
  static const Color primary600 = Color(${toDartColor(designTokens.colors.primary[600])});
  static const Color primary700 = Color(${toDartColor(designTokens.colors.primary[700])});
  static const Color primary800 = Color(${toDartColor(designTokens.colors.primary[800])});
  static const Color primary900 = Color(${toDartColor(designTokens.colors.primary[900])});
  
  // Secondary - Stadium Lights / Gold
  static const Color secondary50 = Color(${toDartColor(designTokens.colors.secondary[50])});
  static const Color secondary100 = Color(${toDartColor(designTokens.colors.secondary[100])});
  static const Color secondary200 = Color(${toDartColor(designTokens.colors.secondary[200])});
  static const Color secondary300 = Color(${toDartColor(designTokens.colors.secondary[300])});
  static const Color secondary400 = Color(${toDartColor(designTokens.colors.secondary[400])});
  static const Color secondary500 = Color(${toDartColor(designTokens.colors.secondary[500])});
  static const Color secondary600 = Color(${toDartColor(designTokens.colors.secondary[600])});
  static const Color secondary700 = Color(${toDartColor(designTokens.colors.secondary[700])});
  static const Color secondary800 = Color(${toDartColor(designTokens.colors.secondary[800])});
  static const Color secondary900 = Color(${toDartColor(designTokens.colors.secondary[900])});
  
  // Accent Colors
  static const Color accentRed = Color(${toDartColor(designTokens.colors.accent.red)});
  static const Color accentBlue = Color(${toDartColor(designTokens.colors.accent.blue)});
  static const Color accentOrange = Color(${toDartColor(designTokens.colors.accent.orange)});
  static const Color accentPurple = Color(${toDartColor(designTokens.colors.accent.purple)});
  
  // Neutral - Newspaper Ink & Paper
  static const Color white = Color(${toDartColor(designTokens.colors.neutral.white)});
  static const Color paper = Color(${toDartColor(designTokens.colors.neutral.paper)});
  static const Color smoke = Color(${toDartColor(designTokens.colors.neutral.smoke)});
  static const Color stone = Color(${toDartColor(designTokens.colors.neutral.stone)});
  static const Color ink = Color(${toDartColor(designTokens.colors.neutral.ink)});
  static const Color charcoal = Color(${toDartColor(designTokens.colors.neutral.charcoal)});
  
  // Football-specific
  static const Color footballField = Color(${toDartColor(designTokens.colors.football.field)});
  static const Color footballLeather = Color(${toDartColor(designTokens.colors.football.leather)});
  static const Color footballChalk = Color(${toDartColor(designTokens.colors.football.chalk)});
  static const Color footballAstroturf = Color(${toDartColor(designTokens.colors.football.astroturf)});
}

// ============================================
// TYPOGRAPHY - Bold Sports Headlines
// ============================================

class AppTypography {
  AppTypography._();
  
  // Font sizes
  static const double fontSizeXS = 12.0;
  static const double fontSizeSM = 14.0;
  static const double fontSizeBase = 16.0;
  static const double fontSizeLG = 18.0;
  static const double fontSizeXL = 20.0;
  static const double fontSize2XL = 24.0;
  static const double fontSize3XL = 30.0;
  static const double fontSize4XL = 36.0;
  static const double fontSize5XL = 48.0;
  static const double fontSize6XL = 60.0;
  static const double fontSize7XL = 72.0;
  static const double fontSize8XL = 96.0;
  
  // Font weights
  static const FontWeight fontWeightThin = FontWeight.w100;
  static const FontWeight fontWeightLight = FontWeight.w300;
  static const FontWeight fontWeightNormal = FontWeight.w400;
  static const FontWeight fontWeightMedium = FontWeight.w500;
  static const FontWeight fontWeightSemibold = FontWeight.w600;
  static const FontWeight fontWeightBold = FontWeight.w700;
  static const FontWeight fontWeightExtrabold = FontWeight.w800;
  static const FontWeight fontWeightBlack = FontWeight.w900;
  
  // Line heights
  static const double lineHeightNone = 1.0;
  static const double lineHeightTight = 1.15;
  static const double lineHeightSnug = 1.25;
  static const double lineHeightNormal = 1.5;
  static const double lineHeightRelaxed = 1.75;
  static const double lineHeightLoose = 2.0;
  
  // Letter spacing
  static const double letterSpacingTighter = -0.8;
  static const double letterSpacingTight = -0.4;
  static const double letterSpacingNormal = 0;
  static const double letterSpacingWide = 0.4;
  static const double letterSpacingWider = 0.8;
  static const double letterSpacingWidest = 1.6;
}

// ============================================
// SPACING - Consistent rhythm
// ============================================

class AppSpacing {
  AppSpacing._();
  
  static const double space0 = 0;
  static const double space1 = 4.0;
  static const double space2 = 8.0;
  static const double space3 = 12.0;
  static const double space4 = 16.0;
  static const double space5 = 20.0;
  static const double space6 = 24.0;
  static const double space8 = 32.0;
  static const double space10 = 40.0;
  static const double space12 = 48.0;
  static const double space16 = 64.0;
  static const double space20 = 80.0;
  static const double space24 = 96.0;
  static const double space32 = 128.0;
}

// ============================================
// BORDERS & RADIUS
// ============================================

class AppBorders {
  AppBorders._();
  
  static const double radiusNone = 0;
  static const double radiusSM = 2.0;
  static const double radiusBase = 4.0;
  static const double radiusMD = 6.0;
  static const double radiusLG = 8.0;
  static const double radiusXL = 12.0;
  static const double radius2XL = 16.0;
  static const double radiusFull = 9999.0;
  
  static const double widthThin = 1.0;
  static const double widthMedium = 2.0;
  static const double widthThick = 4.0;
  static const double widthExtraThick = 8.0;
}

// ============================================
// ANIMATION - Emotional micro-interactions
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
// HAPTIC FEEDBACK TYPES
// ============================================

class AppHaptics {
  AppHaptics._();
  
  static const String light = 'light';
  static const String medium = 'medium';
  static const String heavy = 'heavy';
  static const String success = 'success';
  static const String warning = 'warning';
  static const String error = 'error';
}
`;

  return dartCode;
}

// Generate and save
const dartCode = generateDartTokens();
fs.mkdirSync(path.dirname(outputPath), { recursive: true });
fs.writeFileSync(outputPath, dartCode);
console.log(`✅ Design tokens exported to ${outputPath}`);
console.log('📱 Ready for Flutter implementation!');
