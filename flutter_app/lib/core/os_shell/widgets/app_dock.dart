import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../services/navigation_service.dart';
import '../../services/new_content_service.dart';
import '../../services/settings_service.dart';
import '../../team_center/views/team_center_overlay.dart';
import 't4l_floating_nav_bar.dart';
import 'team_selector_dialog.dart';
import 'user_settings_dialog.dart';

/// Standard app-wide floating dock with the canonical NavigationService
/// wiring (Home / Schedule / Settings + team badge). Reused by the OS shell
/// and any deep screen (e.g. the breaking-news detail) that should keep the
/// global navigation visible.
class AppDock extends StatelessWidget {
  final T4LNavTab activeTab;

  const AppDock({super.key, this.activeTab = T4LNavTab.home});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsService>(context);
    final l10n = AppLocalizations.of(context);

    return ListenableBuilder(
      listenable: NewContentService(),
      builder: (context, _) {
        return T4LFloatingNavBar(
          activeTab: activeTab,
          homeTooltip: l10n?.navHome,
          gameCenterTooltip: l10n?.navGameCenter,
          settingsTooltip: l10n?.navSettings,
          favoriteTeamLogoUrl: settings.selectedTeam?.logoUrl,
          showGameCenterBadge: false,
          onHome: () => NavigationService().goHome(context),
          onGameCenter: () => NavigationService().openGameCenter(context),
          onSettings: () => NavigationService().openSettings(
            context,
            (context) => const UserSettingsDialog(),
          ),
          onTeamLogo: () {
            if (settings.selectedTeam == null) {
              NavigationService().openTeamSelector(
                context,
                (context) => const TeamSelectorDialog(),
              );
            } else {
              NavigationService().openTeamCenter(
                context,
                () => TeamCenterOverlay.show(context, settings.selectedTeam!),
              );
            }
          },
        );
      },
    );
  }
}
