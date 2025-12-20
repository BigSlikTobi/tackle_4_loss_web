import 'micro_app.dart';

class AppRegistry {
  // Singleton Pattern
  static final AppRegistry _instance = AppRegistry._internal();
  factory AppRegistry() => _instance;
  AppRegistry._internal();

  /// Metadata for App Store display and categorization.
  /// Defined centrally, not by the individual apps.
  final Map<String, AppMetadata> _appMetadata = {
    'deep_dive': AppMetadata(category: 'Reading', isFeatured: true),
    'breaking_news': AppMetadata(category: 'Utility', isFeatured: false),
    'app_store': AppMetadata(category: 'System', isFeatured: false),
  };

  final List<MicroApp> _registeredApps = [];

  /// Returns an unmodifiable list of all registered metrics.
  List<MicroApp> get apps => List.unmodifiable(_registeredApps);

  /// Registers a new MicroApp.
  void register(MicroApp app) {
    if (_registeredApps.any((element) => element.id == app.id)) {
      // Avoid duplicate registration
      return;
    }
    _registeredApps.add(app);
  }

  /// Finds an app by its ID.
  MicroApp? getApp(String id) {
    try {
      return _registeredApps.firstWhere((element) => element.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Gets metadata for an app. Returns default if not configured.
  AppMetadata getMetadata(String id) {
    return _appMetadata[id] ?? AppMetadata(category: 'Productivity', isFeatured: false);
  }

  /// Returns the ID of the currently featured app (App of the Month).
  String? get featuredAppId {
    for (var entry in _appMetadata.entries) {
      if (entry.value.isFeatured) {
        return entry.key;
      }
    }
    return null;
  }
}

class AppMetadata {
  final String category;
  final bool isFeatured;

  AppMetadata({
    required this.category,
    required this.isFeatured,
  });
}
