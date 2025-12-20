import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app_registry.dart';
import '../micro_app.dart';

class InstalledAppsService with ChangeNotifier {
  // Singleton
  static final InstalledAppsService _instance = InstalledAppsService._internal();
  factory InstalledAppsService() => _instance;
  InstalledAppsService._internal();

  static const String _storageKey = 'installed_app_ids_grid';
  // Fixed 16-slot grid. Null means empty slot.
  final List<String?> _grid = List<String?>.filled(16, null);

  // Initialize persistence & migrate old data
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final storedIds = prefs.getStringList(_storageKey);

    if (storedIds != null && storedIds.length == 16) {
      // Load existing grid
      for (int i = 0; i < 16; i++) {
        final val = storedIds[i];
        _grid[i] = (val.isEmpty || val == '__EMPTY__') ? null : val;
      }
    } else {
      // Migration / First Run: Load dense list or default
      final oldIds = prefs.getStringList('installed_app_ids') ?? []; // Default to empty (App Store is in Dock)
      
      // Clear grid first
      _grid.fillRange(0, 16, null);
      
      // Fill sequentially
      int gridIndex = 0;
      for (final id in oldIds) {
        if (gridIndex >= 16) break;
        if (id == 'app_store') continue; // Skip App Store
        
        _grid[gridIndex++] = id;
      }
    }
    
    // CLEANUP: Ensure App Store and Featured Article are NOT in the grid
    // (They are shown in Dock and Hero respectively)
    final featuredAppId = AppRegistry().featuredAppId;
    
    // Remove 'app_store' if present
    final storeIndex = _grid.indexOf('app_store');
    if (storeIndex != -1) {
      _grid[storeIndex] = null;
    }

    // Remove Featured App if present
    if (featuredAppId != null) {
      final featIndex = _grid.indexOf(featuredAppId);
      if (featIndex != -1) {
        _grid[featIndex] = null;
      }
    }
    
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    // Serialize: null -> "__EMPTY__"
    final storageList = _grid.map((id) => id ?? '__EMPTY__').toList();
    await prefs.setStringList(_storageKey, storageList);
  }

  /// Returns the sparse list of apps (16 slots). Null means empty.
  List<MicroApp?> get gridApps {
    final registry = AppRegistry();
    return _grid.map((id) {
      if (id == null) return null;
      return registry.getApp(id);
    }).toList();
  }
  
  // Backwards compatibility getter (Dense list)
  List<MicroApp> get installedApps {
     return gridApps.whereType<MicroApp>().toList();
  }

  bool isInstalled(String appId) => _grid.contains(appId);

  void install(String appId) {
    if (!isInstalled(appId)) {
      final emptyIndex = _grid.indexOf(null);
      if (emptyIndex != -1) {
        _grid[emptyIndex] = appId;
        _persist();
        notifyListeners();
      }
    }
  }

  void uninstall(String appId) {
    if (appId == 'app_store') return; 
    final index = _grid.indexOf(appId);
    if (index != -1) {
      _grid[index] = null;
      _persist();
      notifyListeners();
    }
  }
  
  /// Swaps app at [fromIndex] to [toIndex].
  void moveApp(int fromIndex, int toIndex) {
    if (fromIndex < 0 || fromIndex >= 16 || toIndex < 0 || toIndex >= 16) return;
    
    final temp = _grid[fromIndex];
    _grid[fromIndex] = _grid[toIndex];
    _grid[toIndex] = temp;
    
    _persist();
    notifyListeners();
  }
}
