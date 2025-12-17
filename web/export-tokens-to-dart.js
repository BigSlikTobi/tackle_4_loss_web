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
    primary: "#113528", // Dark Green
    secondary: "#D4B363", // Gold
    accent: "#C92A2A", // Red for live/breaking
    background: {
      light: "#F3F5F7",
      dark: "#000000",
    },
    card: {
      light: "#FFFFFF",
      dark: "#111111",
    },
    text: {
      main: {
        light: "#113528",
        dark: "#F9FAFB",
      },
      sub: {
        light: "#5D7369",
        dark: "#9CA3AF",
      },
    },
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
library design_tokens;

import 'package:flutter/material.dart';

// ============================================
// COLORS
// ============================================

class AppColors {
  AppColors._();
  
  static const Color primary = Color(${toDartColor(designTokens.colors.primary)});
  static const Color secondary = Color(${toDartColor(designTokens.colors.secondary)});
  static const Color accent = Color(${toDartColor(designTokens.colors.accent)});
  
  static const Color backgroundLight = Color(${toDartColor(designTokens.colors.background.light)});
  static const Color backgroundDark = Color(${toDartColor(designTokens.colors.background.dark)});
  
  static const Color cardLight = Color(${toDartColor(designTokens.colors.card.light)});
  static const Color cardDark = Color(${toDartColor(designTokens.colors.card.dark)});
  
  static const Color textMainLight = Color(${toDartColor(designTokens.colors.text.main.light)});
  static const Color textMainDark = Color(${toDartColor(designTokens.colors.text.main.dark)});
  
  static const Color textSubLight = Color(${toDartColor(designTokens.colors.text.sub.light)});
  static const Color textSubDark = Color(${toDartColor(designTokens.colors.text.sub.dark)});
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
