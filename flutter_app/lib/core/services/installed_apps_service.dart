import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app_registry.dart';
import '../micro_app.dart';

class InstalledAppsService with ChangeNotifier {
  // Singleton
  static final InstalledAppsService _instance = InstalledAppsService._internal();
  factory InstalledAppsService() => _instance;
  InstalledAppsService._internal();

  static const String _storageKey = 'installed_app_ids_strip_v1'; 
  static const String _manifestKey = 'home_page_manifest_hash_v1';
  
  // Ordered list of installed app IDs
  final List<String> _installedItems = [];

  /// Generates a hash representing the current "source of truth" home page configuration.
  String _getManifestHash() {
    final registry = AppRegistry();
    final apps = registry.apps.where((app) => app.showOnHomePage).toList();
    // Sort to ensure deterministic hash regardless of registration order
    apps.sort((a, b) => a.id.compareTo(b.id));
    
    return apps.map((app) => app.id).join('|');
  }

  // Initialize persistence
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final storedItems = prefs.getStringList(_storageKey);
    final storedManifest = prefs.getString(_manifestKey);
    final currentManifest = _getManifestHash();

    // Reset to empty
    _installedItems.clear();

    // If manifest changed or no data, reset to defaults
    if (storedManifest != currentManifest || storedItems == null) {
      resetDefaults();
      return;
    }

    _installedItems.addAll(storedItems);
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_storageKey, _installedItems);
    await prefs.setString(_manifestKey, _getManifestHash());
  }

  /// Returns the app ID at index
  String getItemAt(int index) {
    if (index < 0 || index >= _installedItems.length) return '';
    return _installedItems[index];
  }
  
  /// Returns the full list of app IDs
  List<String> get rawItems => List.unmodifiable(_installedItems);

  /// Returns ONLY installed apps
  List<MicroApp> get installedApps {
    final registry = AppRegistry();
    return _installedItems
      .map((id) => registry.getApp(id))
      .whereType<MicroApp>()
      .toList();
  }
  
  bool isInstalled(String appId) {
    return _installedItems.contains(appId);
  }

  // Deprecated grid-specific helpers kept as stubs for cross-compatibility during migration
  bool isOccupySlot(int index) => false;
  bool isEmpty(int index) => index >= _installedItems.length;
  bool isWidget(int index) => false;
  bool isInstalledAsWidget(String appId) => false;
  bool canPlaceWidgetAt(int index, int width, int height, {int ignoreIndex = -1, bool checkEasyPlacement = false}) => false;

  void install(String appId, {bool asWidget = false}) {
    if (isInstalled(appId)) return;
    
    _installedItems.add(appId);
    _persist();
    notifyListeners();
  }

  void uninstall(String appId) {
    if (appId == 'app_hub') return;
    
    if (_installedItems.remove(appId)) {
      _persist();
      notifyListeners();
    }
  }
  
  /// Reorder apps in the strip
  void moveApp(int fromIndex, int toIndex) {
    if (fromIndex < 0 || fromIndex >= _installedItems.length) return;
    if (toIndex < 0 || toIndex >= _installedItems.length) return;
    if (fromIndex == toIndex) return;

    final item = _installedItems.removeAt(fromIndex);
    _installedItems.insert(toIndex, item);
    
    _persist();
    notifyListeners();
  }

  /// Resets to apps that have showOnHomePage = true
  void resetDefaults() {
    _installedItems.clear();
    
    final registry = AppRegistry();
    final homePageApps = registry.apps.where((app) => app.showOnHomePage).toList();
    
    // Default logical order
    final preferredOrder = [
      'breaking_news',
      'radio',
      'deep_dive',
      'player_wordle',
      'standings',
      'game_reports',
    ];

    // Add apps in preferred order if they exist and should be on home page
    for (final id in preferredOrder) {
      if (homePageApps.any((app) => app.id == id)) {
        _installedItems.add(id);
      }
    }

    // Add any remaining home page apps
    for (final app in homePageApps) {
      if (!_installedItems.contains(app.id)) {
        _installedItems.add(app.id);
      }
    }

    _persist();
    notifyListeners();
  }
}
