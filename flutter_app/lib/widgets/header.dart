import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../design_tokens.dart';

class AppHeader extends StatelessWidget {
  final String selectedLanguage;
  final ValueChanged<String> onLanguageChanged;

  const AppHeader({
    super.key,
    required this.selectedLanguage,
    required this.onLanguageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: AppColors.neutralBase.withOpacity(0.9),
      surfaceTintColor: Colors.transparent, // Disable Material 3 tint
      elevation: 0,
      pinned: true,
      floating: true,
      toolbarHeight: 70, // Slightly taller to match web feel
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(
          color: AppColors.neutralBorder,
          height: 1.0,
        ),
      ),
      title: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.brandBase,
              borderRadius: BorderRadius.circular(AppBorders.radiusXl),
              boxShadow: AppShadows.sm,
            ),
            padding: const EdgeInsets.all(0),
            clipBehavior: Clip.antiAlias,
            child: Image.asset('assets/T4L_app_logo.png', fit: BoxFit.cover),
          ),
          const SizedBox(width: AppSpacing.space2),
          const Text(
            'Deep Dives',
            style: TextStyle(
              color: AppColors.neutralText,
              fontFamily: AppTypography.fontFamilyPrimary,
              fontWeight: AppTypography.fontWeightBold,
              fontSize: AppTypography.fontSizeLg,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: AppSpacing.space2),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.neutralBase,
              borderRadius: BorderRadius.circular(AppBorders.radiusXl),
              border: Border.all(color: AppColors.neutralBorder),
            ),
            padding: const EdgeInsets.all(4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: ['de', 'en'].map((lang) {
                final isSelected = selectedLanguage == lang;
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onLanguageChanged(lang);
                  },
                  child: AnimatedContainer(
                    duration: AppAnimation.durationFast,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.brandBase : Colors.transparent,
                      borderRadius: BorderRadius.circular(AppBorders.radiusLg),
                    ),
                    child: Text(
                      lang.toUpperCase(),
                      style: TextStyle(
                        color: isSelected ? AppColors.neutralBase : AppColors.neutralText.withOpacity(0.6),
                        fontWeight: AppTypography.fontWeightBold,
                        fontSize: AppTypography.fontSizeSm,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
