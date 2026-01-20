import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../design_tokens.dart';
import '../../services/installed_apps_service.dart';
import '../../services/navigation_service.dart';
import '../../theme/t4l_theme.dart';
import 'app_grid_item.dart';

class AppStrip extends StatelessWidget {
  const AppStrip({super.key});

  @override
  Widget build(BuildContext context) {
    final installedAppsService = Provider.of<InstalledAppsService>(context);
    final apps = installedAppsService.installedApps.where((app) => app.id != 'standings').toList();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Theme-aware glassmorphism
    final glassColor = isDark
        ? Colors.white.withValues(alpha: 0.05)
        : Colors.black.withValues(alpha: 0.03);
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.black.withValues(alpha: 0.08);

    return Container(
      height: 90, // Reduced since text is removed
      width: double.infinity,
      decoration: BoxDecoration(
        color: glassColor,
        border: Border(
          top: BorderSide(
            color: borderColor,
            width: 1,
          ),
        ),
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: apps.length,
            itemBuilder: (context, index) {
              final app = apps[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: SizedBox(
                  width: 72,
                  child: OSShellAppItem(
                    app: app,
                    onTap: () => NavigationService().openApp(context, app),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
