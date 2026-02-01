import 'package:flutter/material.dart';
import '../app_registry.dart';
import '../micro_app.dart';
import '../../l10n/app_localizations.dart';

class NavigationService {
  static final NavigationService _instance = NavigationService._internal();
  factory NavigationService() => _instance;
  NavigationService._internal();

  @visibleForTesting
  void reset() {
    _isAppHubOpen = false;
    _isSettingsOpen = false;
    _isTeamCenterOpen = false;
    _lastAppId = null;
  }

  bool _isAppHubOpen = false;
  bool _isSettingsOpen = false;
  bool _isTeamCenterOpen = false;

  String? _lastAppId;

  /// Tracks the last micro-app opened.
  void trackAppLaunch(String appId) {
    if (appId != 'app_hub' && appId != 'settings') {
      _lastAppId = appId;
    }
  }

  /// Returns the ID of the last used micro-app.
  String? get lastAppId => _lastAppId;

  /// Navigates to the Game Center (Standings/Schedule).
  void openGameCenter(BuildContext context) {
    if (_isAppHubOpen) return;

    final gameCenter = AppRegistry().getApp('standings');
    if (gameCenter != null) {
      _isAppHubOpen = true;
      Navigator.of(context)
          .push(
        MaterialPageRoute(builder: (context) => gameCenter.page(context)),
      )
          .then((_) {
        _isAppHubOpen = false;
      });
    }
  }

  /// Opens the Settings dialog.
  void openSettings(BuildContext context, WidgetBuilder builder) {
    if (_isSettingsOpen) return;

    _isSettingsOpen = true;
    showDialog(
      context: context,
      builder: builder,
    ).then((_) {
      _isSettingsOpen = false;
    });
  }

  /// Opens the Team Center or Team Selector.
  Future<void> openTeamCenter(
      BuildContext context, Future<void> Function() showOverlay) async {
    if (_isTeamCenterOpen) return;

    _isTeamCenterOpen = true;
    try {
      await showOverlay();
    } finally {
      // Small delay to ensure the UI has time to process the close event completely
      // before allowing another open?
      // Usually await is enough.
      _isTeamCenterOpen = false;
    }
  }

  /// Opens the Team Selector dialog.
  Future<void> openTeamSelector(
      BuildContext context, WidgetBuilder builder) async {
    if (_isTeamCenterOpen) return;
    _isTeamCenterOpen = true;
    try {
      await showDialog(context: context, builder: builder);
    } finally {
      _isTeamCenterOpen = false;
    }
  }

  String? _currentOpenAppId;

  /// Reopens the last used app if available.
  void reopenLastApp(BuildContext context) {
    if (_lastAppId != null) {
      final app = AppRegistry().getApp(_lastAppId!);
      if (app != null) {
        openApp(context, app);
      }
    } else {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.historyEmpty)),
      );
    }
  }

  /// Pushes a new app onto the stack and tracks it.
  void openApp(BuildContext context, MicroApp app, {Object? arguments}) {
    if (_currentOpenAppId == app.id) return;

    trackAppLaunch(app.id);
    _currentOpenAppId = app.id;

    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (context) => app.buildPage(context, arguments: arguments),
      ),
    )
        .then((_) {
      if (_currentOpenAppId == app.id) {
        _currentOpenAppId = null;
      }
    });
  }

  /// Navigates back to the home screen.
  void goHome(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}
