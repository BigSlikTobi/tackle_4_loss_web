import '../../../core/app_registry.dart';
import '../../../core/micro_app.dart';
import '../../../core/app_category.dart';

class AppHubController {
  final AppRegistry _appRegistry = AppRegistry();

  /// Returns all available apps in the ecosystem (excluding App Hub itself and apps on home page).
  List<MicroApp> getAllApps() {
    return _appRegistry.apps.where((app) => app.id != 'app_hub' && !app.showOnHomePage).toList();
  }

  /// Gets apps filtered by category.
  List<MicroApp> getAppsByCategory(AppCategory? category) {
    final apps = getAllApps();
    if (category == null) return apps;
    return apps.where((app) => app.category == category).toList();
  }

  /// Returns the currently featured app (App of the Month).
  MicroApp getFeaturedApp() {
    // Use full registry to allow featuring home page apps if needed
    final allApps = _appRegistry.apps;
    return allApps.firstWhere(
      (app) => _appRegistry.getMetadata(app.id).isFeatured,
      orElse: () => allApps.first,
    );
  }

  /// Returns list of apps for the grid view (including featured app if it matches category).
  List<MicroApp> getOtherApps({AppCategory? category}) {
    return getAppsByCategory(category);
  }

  /// Get all available categories (excluding system).
  List<AppCategory> getCategories() {
    return AppCategory.values.where((c) => c != AppCategory.system).toList();
  }
}
