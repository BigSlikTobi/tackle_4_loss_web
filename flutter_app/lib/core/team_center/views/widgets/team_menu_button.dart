import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TeamMenuButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final String? iconAssetPath;
  final VoidCallback onTap;
  final Color? color;

  const TeamMenuButton({
    super.key,
    required this.label,
    required this.icon,
    this.iconAssetPath,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: (color ?? const Color(0xFF252836)).withValues(alpha: 0.9), // Team color or Dark Blue-Grey
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Icon Container
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    // color: const Color(0xFF38404B), // Removed per user request ("no background")
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: iconAssetPath != null
                        ? (iconAssetPath!.toLowerCase().endsWith('.svg')
                            ? SvgPicture.asset(
                                iconAssetPath!,
                                width: 28,
                                height: 28,
                                fit: BoxFit.contain,
                                colorFilter: isDark
                                    ? ColorFilter.mode(
                                        Colors.white.withValues(alpha: 0.9),
                                        BlendMode.srcIn,
                                      )
                                    : null,
                              )
                            : Image.asset(
                                iconAssetPath!,
                                width: 28,
                                height: 28,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    icon,
                                    color: const Color(0xFF4ADE80),
                                    size: 24,
                                  );
                                },
                              ))
                        : Icon(
                            icon,
                            color: const Color(0xFF4ADE80), // Green accent from mockup
                            size: 24,
                          ),
                  ),
                ),
                const SizedBox(width: 16),
                
                // Label
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                
                // Chevron
                const Icon(
                  Icons.chevron_right,
                  color: Colors.white54,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
