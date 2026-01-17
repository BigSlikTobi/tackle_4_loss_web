import 'package:flutter/material.dart';
import '../../../../design_tokens.dart';
import '../../micro_app.dart';
import '../../theme/t4l_theme.dart';
import '../../services/settings_service.dart';
import 'package:provider/provider.dart';

class OSShellAppItem extends StatelessWidget {
  final MicroApp app;
  final VoidCallback onTap;

  const OSShellAppItem({super.key, required this.app, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // final settings = Provider.of<SettingsService>(context); // No longer needed for colors
    final colors = Theme.of(context).extension<T4LThemeColors>()!;

    return GestureDetector(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: 1.0,
        child: Container(
          decoration: BoxDecoration(
            color: app.themeColor, // Use app's theme color (often Team Color)
            borderRadius: BorderRadius.circular(18), // Smooth rounded corners
            boxShadow: [
              BoxShadow(
                color: app.themeColor.withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Image.asset(
              app.iconAssetPath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // Fallback to Icon if asset fails
                return Center(
                  child: Icon(app.icon, color: Colors.white, size: 32),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
