import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../design_tokens.dart';
import '../../micro_app.dart';

/// A reusable container for micro-app icons with theme-aware backgrounds.
/// Uses inverted theme: light background in dark mode, dark background in light mode.
class MicroAppIconContainer extends StatelessWidget {
  final MicroApp app;
  final double size;
  final double borderRadius;
  final bool showShadow;

  const MicroAppIconContainer({
    super.key,
    required this.app,
    this.size = 48,
    this.borderRadius = 12,
    this.showShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Use constraints if size is infinite, otherwise use specified size
        final actualSize = size.isFinite ? size : constraints.maxWidth;

        // Determine which asset to use
        // User preference: Always use dark icons if available as they "look so much better"
        final assetPath = app.iconDarkAssetPath ??
            app.iconLightAssetPath ??
            app.iconAssetPath;
        final isSvg = assetPath.toLowerCase().endsWith('.svg');
        final isThemeSpecific =
            app.iconDarkAssetPath != null || app.iconLightAssetPath != null;

        // For theme-specific icons (designed SVGs), we remove the outer background/padding
        // and let the icon fill the space with rounded corners.
        // For legacy icons, we keep the stylized container.

        return Container(
          width: size.isFinite ? size : null,
          height: size.isFinite ? size : null,
          decoration: isThemeSpecific
              ? null
              : BoxDecoration(
                  color: isDarkMode
                      ? AppColors.neutralBase
                      : AppColors.backgroundDark,
                  borderRadius: BorderRadius.circular(borderRadius),
                  boxShadow: showShadow ? AppShadows.sm : null,
                ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius),
            child: Padding(
              padding: isThemeSpecific
                  ? EdgeInsets.zero
                  : EdgeInsets.all(actualSize * 0.15),
              child: isSvg
                  ? SvgPicture.asset(
                      assetPath,
                      fit: BoxFit.cover, // Use cover for full-bleed icons
                      placeholderBuilder: (context) => Icon(
                        app.icon,
                        color: isDarkMode
                            ? AppColors.backgroundDark
                            : AppColors.neutralBase,
                        size: actualSize * 0.5,
                      ),
                    )
                  : Image.asset(
                      assetPath,
                      fit: isThemeSpecific ? BoxFit.cover : BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          app.icon,
                          color: isDarkMode
                              ? AppColors.backgroundDark
                              : AppColors.neutralBase,
                          size: actualSize * 0.5,
                        );
                      },
                    ),
            ),
          ),
        );
      },
    );
  }
}
