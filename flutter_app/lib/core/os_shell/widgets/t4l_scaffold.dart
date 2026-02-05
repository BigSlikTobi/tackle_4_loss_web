import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tackle4loss_mobile/design_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../services/navigation_service.dart';
import '../../services/settings_service.dart';
import '../../team_center/views/team_center_overlay.dart'; // Corrected
import 't4l_floating_nav_bar.dart';
import 'user_settings_dialog.dart';
import 'team_selector_dialog.dart';
import 'package:audio_service/audio_service.dart';
import '../../services/audio_player_service.dart';
import 't4l_header.dart';
import 'mini_player.dart';

/// A standardized scaffold that provides consistent layout for all screens.
///
/// Features:
/// - Floating header with logo, title, and actions
/// - Optional close button (integrated into header, no overlap)
/// - Optional back button for navigation
/// - Persistent bottom nav bar with mini player
///
/// Use [T4LHeader.kHeightWithSafeArea] for consistent top padding in body content.
class T4LScaffold extends StatelessWidget {
  final Widget body;
  final bool showCloseButton;
  final bool showNavBar;
  final VoidCallback? onClose;
  final Widget? bottomNavBarOverride;
  final String? title;
  final Widget? titleWidget;
  final List<Widget>? actions;

  /// Whether to show a back button in the header.
  final bool showBackButton;

  /// Callback when back button is pressed. Defaults to Navigator.pop.
  final VoidCallback? onBack;

  /// Whether to show the T4L logo in the header.
  final bool showLogo;

  /// Whether the body should extend behind the header.
  ///
  /// If [true], uses a [Stack] layout where the body starts at the top of the screen
  /// and the header floats above it. Use this for immersive backgrounds or sliver layouts.
  ///
  /// If [false] (default), uses a [Column] layout where the header is placed above
  /// the body. This prevents overlap without manual padding.
  final bool extendBodyBehindHeader;

  const T4LScaffold({
    super.key,
    required this.body,
    this.showCloseButton = true,
    this.showNavBar = true,
    this.bottomNavBarOverride,
    this.onClose,
    this.title,
    this.titleWidget,
    this.actions,
    this.showBackButton = false,
    this.onBack,
    this.showLogo = true,
    this.extendBodyBehindHeader = false,
  });

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsService>(context);

    // Common Header Instance
    // For immersive mode, default to white text unless overridden
    final header = T4LHeader(
      title: title,
      titleWidget: titleWidget,
      textColor: extendBodyBehindHeader ? Colors.white : null,
      actions: _buildCombinedActions(context, settings),
      showBackButton: showBackButton,
      onBack: () => Navigator.of(context).pop(),
      showLogo: showLogo,
    );

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      backgroundColor:
          Colors.transparent, // Background handled by container below
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: BoxDecoration(
          gradient: settings.backgroundGradient,
        ),
        child: SafeArea(
          // Only apply safe area top padding in standard layout (Column)
          // In immersive mode, content goes behind status bar
          top: !extendBodyBehindHeader,
          bottom: false,
          child: Stack(
            children: [
              // Main Layout
              if (extendBodyBehindHeader)
                _buildImmersiveLayout(context, header)
              else
                _buildStandardLayout(context, header),

              // Persistent Bottom Dock (Mini Player + Nav Bar)
              if (showNavBar || bottomNavBarOverride != null)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Mini Player (Only shows when audio is playing/paused)
                      const MiniPlayer(),

                      // Navigation Bar
                      if (showNavBar && bottomNavBarOverride == null)
                        T4LFloatingNavBar(
                          homeTooltip: AppLocalizations.of(context)!.navHome,
                          gameCenterTooltip:
                              AppLocalizations.of(context)!.navGameCenter,
                          historyTooltip:
                              AppLocalizations.of(context)!.navHistory,
                          settingsTooltip:
                              AppLocalizations.of(context)!.navSettings,
                          favoriteTeamLogoUrl: settings.selectedTeam?.logoUrl,
                          showGameCenterBadge: false,
                          onHome: () => NavigationService().goHome(context),
                          onGameCenter: () {
                            NavigationService().openGameCenter(context);
                          },
                          onHistory: () =>
                              NavigationService().reopenLastApp(context),
                          onSettings: () {
                            NavigationService().openSettings(
                              context,
                              (context) => const UserSettingsDialog(),
                            );
                          },
                          onTeamLogo: () {
                            if (settings.selectedTeam == null) {
                              NavigationService().openTeamSelector(
                                context,
                                (context) => const TeamSelectorDialog(),
                              );
                            } else {
                              NavigationService().openTeamCenter(
                                context,
                                () => TeamCenterOverlay.show(
                                    context, settings.selectedTeam!),
                              );
                            }
                          },
                        )
                      else if (bottomNavBarOverride != null)
                        bottomNavBarOverride!,
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the standard Column layout (Header + Body).
  Widget _buildStandardLayout(BuildContext context, Widget header) {
    return Column(
      children: [
        // Header (Top of column)
        header,

        // Body (Expanded below header)
        Expanded(
          child: _buildBodyContent(context, topPadding: 0),
        ),
      ],
    );
  }

  /// Builds the immersive Stack layout (Body + Floating Header).
  Widget _buildImmersiveLayout(BuildContext context, Widget header) {
    return Stack(
      children: [
        // Body (Full screen)
        Positioned.fill(
          child: _buildBodyContent(context,
              topPadding: 0), // Body handles its own padding in immersive
        ),

        // Floating Header
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            // Ensure header respects safe area in immersive mode
            bottom: false,
            child: header,
          ),
        ),
      ],
    );
  }

  /// Wraps the body content with necessary padding/audio player awareness.
  Widget _buildBodyContent(BuildContext context, {required double topPadding}) {
    return StreamBuilder<MediaItem?>(
      stream: AudioPlayerService().mediaItemStream,
      builder: (context, snapshot) {
        final isPlaying = snapshot.data != null;
        final navBarHeight =
            (showNavBar || bottomNavBarOverride != null) ? 80.0 : 0.0;
        final playerHeight = isPlaying ? 80.0 : 0.0;

        return Padding(
          padding: EdgeInsets.only(
            top:
                topPadding, // Should be 0 for standard (column handles it) and immersive (body handles it)
            bottom: navBarHeight + playerHeight,
          ),
          child: body,
        );
      },
    );
  }

  /// Builds the combined actions list, appending close button if needed.
  List<Widget>? _buildCombinedActions(
      BuildContext context, SettingsService settings) {
    if (!showCloseButton && (actions == null || actions!.isEmpty)) {
      return null;
    }

    final List<Widget> combined = [];

    // Add user-provided actions
    if (actions != null) {
      combined.addAll(actions!);
    }

    // Add close button at the end (integrated, no overlap)
    if (showCloseButton) {
      if (combined.isNotEmpty) {
        combined.add(const SizedBox(width: 8));
      }
      combined.add(_buildCloseButton(context, settings));
    }

    return combined.isEmpty ? null : combined;
  }

  Widget _buildCloseButton(BuildContext context, SettingsService settings) {
    return IconButton(
      icon: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: settings.isDarkMode
              ? Colors.black.withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.5),
          shape: BoxShape.circle,
          border: Border.all(
            color: settings.isDarkMode ? Colors.white10 : Colors.black12,
          ),
        ),
        child: Icon(
          Icons.close,
          color: settings.isDarkMode ? Colors.white70 : AppColors.textPrimary,
          size: 18,
        ),
      ),
      onPressed: onClose ?? () => Navigator.of(context).pop(),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
    );
  }
}
