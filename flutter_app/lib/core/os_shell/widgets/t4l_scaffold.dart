import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../design_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../services/navigation_service.dart';
import '../../services/settings_service.dart';
import 't4l_floating_nav_bar.dart';
import 'user_settings_dialog.dart';
import 'team_selector_dialog.dart';
import 'package:audio_service/audio_service.dart';
import '../../services/audio_player_service.dart';
import 't4l_header.dart';
import 'mini_player.dart';

class T4LScaffold extends StatelessWidget {
  final Widget body;
  final bool showCloseButton;
  final bool showNavBar;
  final VoidCallback? onClose;
  final Widget? bottomNavBarOverride;
  final String? title; // New title param
  final List<Widget>? actions;

  const T4LScaffold({
    super.key,
    required this.body,
    this.showCloseButton = true,
    this.showNavBar = true,
    this.bottomNavBarOverride,
    this.onClose,
    this.title,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settings = Provider.of<SettingsService>(context);

    // Determine text color based on background luminance or dark mode
    final headerTextColor = settings.isDarkMode ? Colors.white : AppColors.textPrimary;

    return Scaffold(
      backgroundColor: settings.isDarkMode ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: Stack(
        children: [
          // 1. Core Gradient Background
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: settings.backgroundGradient,
              ),
            ),
          ),

          // 2. Main Layout (Header + Body)
          // We use a Stack to allow the Body to go behind the Header (for immersive Hero)
          Positioned.fill(
            child: Stack(
              children: [
                // Body (Full Screen, behind header)
                // We use a StreamBuilder to dynamically adjust padding when MiniPlayer is active
                StreamBuilder<MediaItem?>(
                  stream: AudioPlayerService().mediaItemStream,
                  builder: (context, snapshot) {
                     final isPlaying = snapshot.data != null;
                     final navBarHeight = (showNavBar || bottomNavBarOverride != null) ? 80.0 : 0.0;
                     final playerHeight = isPlaying ? 80.0 : 0.0; // Reduced clearance to match slim MiniPlayer
                     
                     return Padding(
                      padding: EdgeInsets.only(
                        bottom: navBarHeight + playerHeight, 
                      ),
                      child: body,
                    );
                  },
                ),
                
                // Header (Floating on top)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: T4LHeader(
                    title: title,
                    textColor: headerTextColor,
                    actions: actions,
                  ),
                ),
              ],
            ),
          ),

          // 3. Optional Close Button (Top RIGHT now)
          if (showCloseButton)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Align(
                  alignment: Alignment.topRight, // Changed to topRight
                  child: IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: settings.isDarkMode 
                            ? Colors.black.withOpacity(0.3) 
                            : Colors.white.withOpacity(0.5),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: settings.isDarkMode ? Colors.white10 : Colors.black12
                        ),
                      ),
                      child: Icon(
                        Icons.close, 
                        color: settings.isDarkMode ? Colors.white70 : AppColors.textPrimary, 
                        size: 20
                      ),
                    ),
                    onPressed: onClose ?? () => Navigator.of(context).pop(),
                  ),
                ),
              ),
            ),

          // 4. Persistent Dock OR Override
          // We position the Dock at the bottom.
          // The MiniPlayer should float ABOVE the Dock if the Dock is visible,
          // or at the bottom if the Dock is hidden.
          
          Stack(
            children: [
               Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Mini Player
                    const MiniPlayer(),

                    // Dock (if enabled)
                    if (showNavBar || bottomNavBarOverride != null)
                      bottomNavBarOverride ?? T4LFloatingNavBar(
                        homeTooltip: l10n.navHome,
                        appStoreTooltip: l10n.navAppStore,
                        historyTooltip: l10n.navHistory,
                        settingsTooltip: l10n.navSettings,
                        favoriteTeamLogoUrl: settings.selectedTeam?.logoUrl,
                        onHome: () => NavigationService().goHome(context),
                        onAppStore: () => NavigationService().openAppStore(context),
                        onHistory: () => NavigationService().reopenLastApp(context),
                        onSettings: () {
                          showDialog(
                            context: context,
                            builder: (context) => const UserSettingsDialog(),
                          );
                        },
                        onTeamLogo: () {
                          if (settings.selectedTeam == null) {
                            showDialog(
                              context: context,
                              builder: (context) => const TeamSelectorDialog(),
                            );
                          }
                        },
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
