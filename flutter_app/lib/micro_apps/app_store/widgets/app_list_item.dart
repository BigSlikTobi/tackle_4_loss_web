import 'package:flutter/material.dart';
import '../../../../design_tokens.dart';
import '../../../../core/theme/t4l_theme.dart';

class AppStoreListItem extends StatelessWidget {
  final String title;
  final String category;
  final IconData icon;
  final String iconAssetPath; 
  final Color iconColor;
  final bool isInstalled;
  final VoidCallback onTap;
  final VoidCallback onAction;

  const AppStoreListItem({
    super.key,
    required this.title,
    required this.category,
    required this.icon,
    required this.iconAssetPath,
    required this.iconColor,
    required this.isInstalled,
    required this.onTap,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<T4LThemeColors>()!;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: colors.border.withOpacity(0.1),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            // App Icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: iconColor,
                borderRadius: BorderRadius.circular(14), // Apple-ish Squircle radius
                boxShadow: AppShadows.sm,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.asset(
                  iconAssetPath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(icon, color: Colors.white, size: 30);
                  },
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Text Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    category,
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            
            // Action Button
            GestureDetector(
              onTap: onAction,
              child: isInstalled
                  ? Icon(Icons.check_circle, color: colors.textSecondary) // Use check for installed
                  : Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                      decoration: BoxDecoration(
                        color: colors.surface, 
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Text(
                        'GET',
                        style: TextStyle(
                          color: colors.brand,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
