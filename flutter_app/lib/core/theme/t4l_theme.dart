import 'package:flutter/material.dart';
import '../../design_tokens.dart';
import '../models/team_model.dart';

class T4LThemeColors extends ThemeExtension<T4LThemeColors> {
  final Color brand;
  final Color brandLight;
  final Color surface;
  final Color background;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color border;
  final Color breakingNewsRed;
  final Color breakingNewsRedBright;

  /// Semi-transparent overlay for cards (uses opposite theme's base color)
  /// Light mode: dark overlay, Dark mode: light overlay
  final Color cardOverlay;

  /// Border color for overlay cards
  final Color cardOverlayBorder;

  /// Text color that contrasts with the brand color
  /// Used for text on top of brand-colored backgrounds
  final Color contrastText;

  const T4LThemeColors({
    required this.brand,
    required this.brandLight,
    required this.surface,
    required this.background,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.border,
    required this.breakingNewsRed,
    required this.breakingNewsRedBright,
    required this.cardOverlay,
    required this.cardOverlayBorder,
    required this.contrastText,
  });

  @override
  ThemeExtension<T4LThemeColors> copyWith({
    Color? brand,
    Color? brandLight,
    Color? surface,
    Color? background,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? border,
    Color? breakingNewsRed,
    Color? breakingNewsRedBright,
    Color? cardOverlay,
    Color? cardOverlayBorder,
    Color? contrastText,
  }) {
    return T4LThemeColors(
      brand: brand ?? this.brand,
      brandLight: brandLight ?? this.brandLight,
      surface: surface ?? this.surface,
      background: background ?? this.background,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      border: border ?? this.border,
      breakingNewsRed: breakingNewsRed ?? this.breakingNewsRed,
      breakingNewsRedBright:
          breakingNewsRedBright ?? this.breakingNewsRedBright,
      cardOverlay: cardOverlay ?? this.cardOverlay,
      cardOverlayBorder: cardOverlayBorder ?? this.cardOverlayBorder,
      contrastText: contrastText ?? this.contrastText,
    );
  }

  @override
  ThemeExtension<T4LThemeColors> lerp(
    ThemeExtension<T4LThemeColors>? other,
    double t,
  ) {
    if (other is! T4LThemeColors) {
      return this;
    }
    return T4LThemeColors(
      brand: Color.lerp(brand, other.brand, t)!,
      brandLight: Color.lerp(brandLight, other.brandLight, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      background: Color.lerp(background, other.background, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      border: Color.lerp(border, other.border, t)!,
      breakingNewsRed: Color.lerp(breakingNewsRed, other.breakingNewsRed, t)!,
      breakingNewsRedBright: Color.lerp(
        breakingNewsRedBright,
        other.breakingNewsRedBright,
        t,
      )!,
      cardOverlay: Color.lerp(cardOverlay, other.cardOverlay, t)!,
      cardOverlayBorder: Color.lerp(
        cardOverlayBorder,
        other.cardOverlayBorder,
        t,
      )!,
      contrastText: Color.lerp(contrastText, other.contrastText, t)!,
    );
  }
}

class T4LTheme {
  /// Calculates the appropriate text color for contrast against a background color.
  /// Returns white for dark backgrounds, black for light backgrounds.
  static Color _getContrastText(Color backgroundColor) {
    // Use the relative luminance formula to determine brightness
    // Luminance > 0.5 means the color is "light" and needs dark text
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  static ThemeData light({Team? team}) {
    // Dynamic Brand Logic:
    // If team selected -> Use secondary color (Light Mode convention per user req)
    // Else -> Use default brand color
    final brandColor = team != null ? team.secondaryColor : AppColors.brandBase;
    // brandLight is what will be used for card backgrounds in widgets
    final brandLightColor = team != null
        ? team.primaryColor
        : AppColors.brandLight;
    // Calculate contrast text based on the actual brandLight color
    final contrastTextColor = _getContrastText(brandLightColor);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      colorScheme: ColorScheme.fromSeed(
        seedColor: brandColor,
        brightness: Brightness.light,
        surface: AppColors.cardLight,
      ),
      extensions: [
        T4LThemeColors(
          brand: brandColor,
          brandLight: brandLightColor,
          surface: AppColors.cardLight,
          background: AppColors.backgroundLight,
          textPrimary: AppColors.textMainLight,
          textSecondary: AppColors.textSubLight,
          textMuted: AppColors.neutralTextMuted,
          border: AppColors.neutralBorder,
          breakingNewsRed: AppColors.breakingNewsRed,
          breakingNewsRedBright: AppColors.breakingNewsRedBright,
          // Emotional design: Light mode cards use team's primary (brandLight) color
          cardOverlay: brandLightColor.withValues(alpha: 0.85),
          cardOverlayBorder: brandLightColor.withValues(alpha: 0.2),
          // Dynamic contrast: white text on dark cards, black text on light cards
          contrastText: contrastTextColor,
        ),
      ],
    );
  }

  static ThemeData dark({Team? team}) {
    // Dynamic Brand Logic:
    // If team selected -> Use primary color (Dark Mode convention per user req)
    // Else -> Use default brand color
    final brandColor = team != null ? team.primaryColor : AppColors.brandBase;
    // brandLight is what will be used for card backgrounds in widgets
    final brandLightColor = team != null
        ? team.secondaryColor
        : AppColors.brandLight;
    // Calculate contrast text based on the actual brandLight color
    final contrastTextColor = _getContrastText(brandLightColor);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: brandColor,
        brightness: Brightness.dark,
        surface: AppColors.cardDark,
      ),
      extensions: [
        T4LThemeColors(
          brand: brandColor,
          brandLight: brandLightColor,
          surface: AppColors.cardDark,
          background: AppColors.backgroundDark,
          textPrimary: AppColors.textMainDark,
          textSecondary: AppColors.textSubDark,
          textMuted: AppColors.neutralTextLight,
          border: const Color(0xFF2C2C2E),
          breakingNewsRed: AppColors.breakingNewsRed,
          breakingNewsRedBright: AppColors.breakingNewsRedBright,
          // Emotional design: Dark mode cards use team's secondary (brandLight) color
          cardOverlay: brandLightColor.withValues(alpha: 0.85),
          cardOverlayBorder: brandLightColor.withValues(alpha: 0.2),
          // Dynamic contrast: white text on dark cards, black text on light cards
          contrastText: contrastTextColor,
        ),
      ],
    );
  }
}
