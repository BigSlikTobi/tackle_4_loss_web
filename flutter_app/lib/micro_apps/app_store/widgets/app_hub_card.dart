import 'package:flutter/material.dart';
import '../../../../design_tokens.dart';
import '../../../../core/theme/t4l_theme.dart';
import '../../../core/micro_app.dart';

/// A grid card for displaying an app in the App Hub.
class AppHubCard extends StatelessWidget {
  final MicroApp app;
  final VoidCallback onOpen;

  const AppHubCard({
    super.key,
    required this.app,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<T4LThemeColors>()!;

    return GestureDetector(
      onTap: onOpen,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colors.border.withValues(alpha: 0.1),
            width: 1,
          ),
          boxShadow: AppShadows.sm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon Row
            Row(
              children: [
                // App Icon
                Builder(
                  builder: (context) {
                    final isDarkMode =
                        Theme.of(context).brightness == Brightness.dark;
                    final backgroundColor = isDarkMode
                        ? AppColors.neutralBase
                        : AppColors.backgroundDark;
                    return Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: AppShadows.sm,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Image.asset(
                            app.iconAssetPath,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(app.icon,
                                  color: isDarkMode
                                      ? AppColors.backgroundDark
                                      : AppColors.neutralBase,
                                  size: 24);
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const Spacer(),
                // Open Button
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: colors.brand.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Open',
                    style: TextStyle(
                      color: colors.brand,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // App Name
            Text(
              app.name,
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),

            // Description
            Text(
              app.description,
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 12,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
