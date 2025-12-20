import 'package:flutter/material.dart';
import '../../../../design_tokens.dart';

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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: AppColors.neutralBorder.withOpacity(0.1),
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
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    category,
                    style: TextStyle(
                      color: AppColors.textSecondary,
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
                  ? Icon(Icons.cloud_download, color: AppColors.primary) // Re-download icon style if installed (or Open)
                  : Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.surface.withOpacity(0.3), // Glassy button
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Text(
                        'GET',
                        style: TextStyle(
                          color: AppColors.primary,
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
