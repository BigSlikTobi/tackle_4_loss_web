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

  /// Returns a list of apps for the "Quick View" highlights section.
  /// Prioritizes featured apps, then falls back to other apps.
  List<MicroApp> getQuickViewApps() {
    final allApps = _appRegistry.apps;
    
    // 1. Get explicitly featured apps
    final featured = allApps.where(
      (app) => _appRegistry.getMetadata(app.id).isFeatured
    ).toList();
    
    // 2. If we have fewer than 3, fill with others (excluding system apps like app_hub)
    if (featured.length < 3) {
      final others = allApps.where(
        (app) => !featured.contains(app) && 
                 app.id != 'app_hub' &&
                 app.category != AppCategory.system
      ).toList();
      
      featured.addAll(others.take(3 - featured.length));
    }
    
    return featured.take(3).toList();
  }

  /// Returns list of apps for the grid view (including featured app if it matches category).
  List<MicroApp> getOtherApps({AppCategory? category}) {
    return getAppsByCategory(category);
  }

  /// Returns apps grouped by category for the new category-based layout.
  Map<AppCategory, List<MicroApp>> getAppsByCategories() {
    final apps = getAllApps();
    final Map<AppCategory, List<MicroApp>> grouped = {};
    
    for (final category in AppCategory.values) {
      if (category == AppCategory.system) continue; // Skip system apps
      final categoryApps = apps.where((app) => app.category == category).toList();
      if (categoryApps.isNotEmpty) {
        grouped[category] = categoryApps;
      }
    }
    
    return grouped;
  }

  /// Get all available categories (excluding system).
  List<AppCategory> getCategories() {
    return AppCategory.values.where((c) => c != AppCategory.system).toList();
  }
}
