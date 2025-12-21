import '../../../core/app_registry.dart';
import '../../../core/services/installed_apps_service.dart';
import '../../../core/micro_app.dart';

class AppStoreController {
  final InstalledAppsService _installedAppsService = InstalledAppsService();
  final AppRegistry _appRegistry = AppRegistry();

  /// Returns all available apps in the ecosystem.
  List<MicroApp> getAllApps() {
    return _appRegistry.apps;
  }

  /// Gets the display metadata (Category, Featured) for an app.
  AppMetadata getAppMetadata(String appId) {
    return _appRegistry.getMetadata(appId);
  }

  /// Checks if an app is currently installed.
  bool isInstalled(String appId) {
    return _installedAppsService.isInstalled(appId);
  }

  /// Toggles the install state of an app.
  void toggleInstall(String appId, {bool asWidget = false}) {
    if (isInstalled(appId)) {
      _installedAppsService.uninstall(appId);
    } else {
      _installedAppsService.install(appId, asWidget: asWidget);
    }
  }

  /// Returns the currently featured app (App of the Month).
  MicroApp getFeaturedApp() {
    final apps = getAllApps();
    return apps.firstWhere(
      (app) => getAppMetadata(app.id).isFeatured,
      orElse: () => apps.first, // Fallback
    );
  }

  /// Returns list of non-featured, non-store apps for the list view.
  List<MicroApp> getOtherApps() {
    final featured = getFeaturedApp();
    return getAllApps()
        .where((app) => app.id != featured.id && app.id != 'app_store')
        .toList();
  }
}
