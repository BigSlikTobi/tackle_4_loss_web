import 'package:flutter/material.dart';
import '../app_registry.dart';
import '../micro_app.dart';
import '../../l10n/app_localizations.dart';

class NavigationService {
  static final NavigationService _instance = NavigationService._internal();
  factory NavigationService() => _instance;
  NavigationService._internal();

  String? _lastAppId;

  /// Tracks the last micro-app opened.
  void trackAppLaunch(String appId) {
    if (appId != 'app_store' && appId != 'settings') {
      _lastAppId = appId;
    }
  }

  /// Returns the ID of the last used micro-app.
  String? get lastAppId => _lastAppId;

  /// Navigates to the App Store.
  void openAppStore(BuildContext context) {
    final store = AppRegistry().getApp('app_store');
    if (store != null) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => store.page(context)),
      );
    }
  }

  /// Reopens the last used app if available.
  void reopenLastApp(BuildContext context) {
    if (_lastAppId != null) {
      final app = AppRegistry().getApp(_lastAppId!);
      if (app != null) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => app.page(context)),
        );
      }
    } else {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.historyEmpty)),
      );
    }
  }

  /// Pushes a new app onto the stack and tracks it.
  void openApp(BuildContext context, MicroApp app) {
    trackAppLaunch(app.id);
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => app.page(context)),
    );
  }

  /// Navigates back to the home screen.
  void goHome(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}
