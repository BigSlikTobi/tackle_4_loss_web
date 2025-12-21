import 'package:flutter/material.dart';
import '../../design_tokens.dart';

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
      breakingNewsRedBright: breakingNewsRedBright ?? this.breakingNewsRedBright,
    );
  }

  @override
  ThemeExtension<T4LThemeColors> lerp(ThemeExtension<T4LThemeColors>? other, double t) {
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
      breakingNewsRedBright: Color.lerp(breakingNewsRedBright, other.breakingNewsRedBright, t)!,
    );
  }
}

class T4LTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.brandBase,
        brightness: Brightness.light,
        surface: AppColors.cardLight,
      ),
      extensions: const [
        T4LThemeColors(
          brand: AppColors.brandBase,
          brandLight: AppColors.brandLight,
          surface: AppColors.cardLight,
          background: AppColors.backgroundLight,
          textPrimary: AppColors.textMainLight,
          textSecondary: AppColors.textSubLight,
          textMuted: AppColors.neutralTextMuted,
          border: AppColors.neutralBorder,
          breakingNewsRed: AppColors.breakingNewsRed,
          breakingNewsRedBright: AppColors.breakingNewsRedBright,
        ),
      ],
    );
  }

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.brandBase,
        brightness: Brightness.dark,
        surface: AppColors.cardDark,
      ),
      extensions: const [
        T4LThemeColors(
          brand: AppColors.brandBase,
          brandLight: AppColors.brandLight, // Might want a lighter variant for dark mode eventually
          surface: AppColors.cardDark,
          background: AppColors.backgroundDark,
          textPrimary: AppColors.textMainDark,
          textSecondary: AppColors.textSubDark,
          textMuted: AppColors.neutralTextLight, // Muted text in dark mode is often lighter
          border: Color(0xFF2C2C2E), // Darker border
          breakingNewsRed: AppColors.breakingNewsRed,
          breakingNewsRedBright: AppColors.breakingNewsRedBright,
        ),
      ],
    );
  }
}
