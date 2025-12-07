# Design Token Export Guide

## Overview

This project maintains a single source of truth for design tokens in `design-tokens.ts`, which can be exported to Flutter/Dart for cross-platform consistency.

## Exporting to Flutter/Dart

### Quick Start

From the repo root:

```bash
cd web
npm run export-tokens
# or
node export-tokens-to-dart.js
```

This generates `../flutter_app/lib/design_tokens.dart` with all colors, typography, spacing, and animation values.

### What Gets Exported

✅ **Colors** - All color scales with proper Dart Color format (0xFFRRGGBB)
- Primary (Field Green)
- Secondary (Stadium Lights Gold)  
- Accent Colors (Red, Blue, Orange, Purple)
- Neutral (Paper, Ink, Charcoal)
- Football-specific (Field, Leather, Chalk)

✅ **Typography** - Font sizes, weights, line heights, letter spacing
✅ **Spacing** - Consistent 4px-based spacing scale
✅ **Borders** - Border radius and width values
✅ **Animation** - Duration and curve constants
✅ **Haptic Feedback** - Feedback type constants

### Using in Flutter

```dart
import 'design_tokens.dart';

// Colors
Container(
  color: AppColors.primary600,
  child: Text(
    'TACKLE4LOSS',
    style: TextStyle(
      fontSize: AppTypography.fontSize4XL,
      fontWeight: AppTypography.fontWeightBlack,
      color: AppColors.white,
    ),
  ),
)

// Spacing
Padding(
  padding: EdgeInsets.all(AppSpacing.space4),
  child: ...
)

// Animation
AnimatedContainer(
  duration: AppAnimation.durationNormal,
  curve: AppAnimation.curveEaseOut,
  ...
)

// Borders
Container(
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(AppBorders.radiusLG),
    border: Border.all(
      color: AppColors.primary600,
      width: AppBorders.widthMedium,
    ),
  ),
)

// Haptic Feedback (using Flutter's HapticFeedback)
import 'package:flutter/services.dart';

HapticFeedback.mediumImpact(); // for AppHaptics.medium
HapticFeedback.heavyImpact();  // for AppHaptics.heavy
HapticFeedback.lightImpact();  // for AppHaptics.light
```

### Updating Tokens

1. Edit `design-tokens.ts` (the source of truth)
2. Update the inline copy in `export-tokens-to-dart.js` (near the top of the file)
3. Run `npm run export-tokens` (from `web/`)
4. `flutter_app/lib/design_tokens.dart` is updated automatically

### Why Two Copies?

The export script contains an inline copy of the tokens because:
- TypeScript files can't be directly imported into Node.js scripts easily
- Keeps the export process simple and dependency-free
- You only need to update both when changing design tokens (infrequent)

### Automation (Future)

For larger projects, consider:
- Using a build tool like Theo or Style Dictionary
- Setting up a GitHub Action to auto-export on changes
- Creating a shared NPM/pub.dev package for the tokens

## File Structure

```
tackle_4_loss_web/
├── web/design-tokens.ts              # Source of truth (Web)
├── web/export-tokens-to-dart.js      # Export script
├── flutter_app/lib/design_tokens.dart # Auto-generated (Flutter)
└── web/DESIGN_TOKENS_EXPORT.md       # This file
```

## Notes

- `design_tokens.dart` is auto-generated and gitignored
- Always regenerate after updating design tokens
- The Dart file uses Flutter's material Color and other standard types
- Haptic feedback types are exported as string constants for use with Flutter's HapticFeedback API
