import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app_registry.dart';
import '../micro_app.dart';

class InstalledAppsService with ChangeNotifier {
  // Singleton
  static final InstalledAppsService _instance = InstalledAppsService._internal();
  factory InstalledAppsService() => _instance;
  InstalledAppsService._internal();

  static const String _storageKey = 'installed_app_ids_grid_v4'; // Bump version
  static const int _gridCols = 4;
  static const int _gridRows = 5;
  static const int _gridSize = _gridCols * _gridRows;
  
  static const String _emptySlot = '__EMPTY__';
  static const String _occupiedSlot = '__OCCUPIED__';
  
  // Fixed list of 20 items 
  final List<String> _installedItems = List.filled(_gridSize, _emptySlot, growable: false);

  // Initialize persistence & migrate old data
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final storedItems = prefs.getStringList(_storageKey);

    // Reset to empty
    _installedItems.fillRange(0, _gridSize, _emptySlot);

    if (storedItems != null && storedItems.length == _gridSize) {
      for (int i = 0; i < _gridSize; i++) {
        _installedItems[i] = storedItems[i];
      }
    } else {
       // Reset defaults if migration is hard
       // Or try to place sequentially
       resetDefaults();
    }
    
    // Safety check for featured/store removal - This logic is now handled by resetDefaults or install/uninstall
    // The old migration logic is removed, so this safety check is no longer needed in init().
    // It's assumed that `resetDefaults` or `install` will correctly place items.
    
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_storageKey, _installedItems);
  }

  /// Returns the raw item at index (or empty marker)
  String getItemAt(int index) {
    if (index < 0 || index >= _gridSize) return _emptySlot;
    return _installedItems[index];
  }
  
  /// Returns the full list of items including empty slots (as null microapps? or filtered?)
  /// For the UI we need the full grid representation. 
  /// Let's expose the raw list or a helper.
  List<String> get rawItems => List.unmodifiable(_installedItems);

  /// Returns ONLY installed apps for logic that iterates real apps
  List<MicroApp> get installedApps {
    final registry = AppRegistry();
    return _installedItems
      .where((item) => item != _emptySlot && item != _occupiedSlot)
      .map((item) {
        final id = item.split('|').first;
        return registry.getApp(id);
      })
      .whereType<MicroApp>()
      .toList();
  }
  
  bool isOccupySlot(int index) {
     if (index < 0 || index >= _gridSize) return false;
     return _installedItems[index] == _occupiedSlot;
  }
  
  bool isEmpty(int index) {
    if (index < 0 || index >= _gridSize) return true;
    return _installedItems[index] == _emptySlot;
  }
  
  bool isWidget(int index) {
    if (index < 0 || index >= _gridSize) return false;
    return _installedItems[index].endsWith('|widget');
  }

  bool isInstalled(String appId) {
    return _installedItems.any((item) => item.split('|').first == appId);
  }

  bool isInstalledAsWidget(String appId) {
    return _installedItems.contains('$appId|widget');
  }

  // Find 2x2 clean space
  int _findSpaceForWidget() {
    for (int i = 0; i < _gridSize; i++) {
       if (_canPlaceWidgetAt(i)) return i;
    }
    return -1;
  }

  bool _canPlaceWidgetAt(int index, {int ignoreIndex = -1}) {
     // Check bounds (2x2)
     int row = index ~/ _gridCols;
     int col = index % _gridCols;
     
     if (col + 1 >= _gridCols) return false; // Crosses right edge
     if (row + 1 >= _gridRows) return false; // Crosses bottom edge
     
     // Indices to check: i, i+1, i+cols, i+cols+1
     List<int> slots = [
       index, 
       index + 1, 
       index + _gridCols, 
       index + _gridCols + 1
     ];
     
     for (final s in slots) {
       // If ignoring "self" (during move)
       if (s == ignoreIndex || (ignoreIndex != -1 && _installedItems[s] == _occupiedSlot)) { // Simple hack: treat occupied as free if we are moving? 
         // Actually if we look at _moveApp, we clear first.
       }
       
       if (_installedItems[s] != _emptySlot) return false;
     }
     return true;
  }

  void install(String appId, {bool asWidget = false}) {
    uninstall(appId); 
    
    if (asWidget) {
       // Logic for 2x2 widget
       int slot = _findSpaceForWidget();
       if (slot != -1) {
         _installedItems[slot] = '$appId|widget';
         _installedItems[slot+1] = _occupiedSlot;
         _installedItems[slot+_gridCols] = _occupiedSlot;
         _installedItems[slot+_gridCols+1] = _occupiedSlot;
       } else {
         debugPrint('No space for widget $appId');
       }
    } else {
       // Logic for 1x1 app
       int slot = _installedItems.indexOf(_emptySlot);
       if (slot != -1) {
         _installedItems[slot] = appId;
       } else {
         debugPrint('Grid full, cannot install $appId');
       }
    }
    _persist();
    notifyListeners();
  }

  void uninstall(String appId) {
    if (appId == 'app_store') return;
    
    // Clear ALL occurrences (master + occupied)
    // Actually we need to find the master to know which occupieds are his?
    // Simplified: Just clear master and ALL occupieds? No, occupieds are generic.
    
    // Better: Search for master.
    for (int i = 0; i < _gridSize; i++) {
      if (_installedItems[i].split('|').first == appId) {
        if (_installedItems[i].contains('|widget')) {
           // Clear 2x2
           _installedItems[i] = _emptySlot;
           if (i+1 < _gridSize) _installedItems[i+1] = _emptySlot;
           if (i+_gridCols < _gridSize) _installedItems[i+_gridCols] = _emptySlot;
           if (i+_gridCols+1 < _gridSize) _installedItems[i+_gridCols+1] = _emptySlot;
        } else {
           _installedItems[i] = _emptySlot;
        }
      }
    }
    _persist();
    notifyListeners();
  }
  
  /// Swap items (Fixed Grid Logic)
  void moveApp(int fromIndex, int toIndex) {
    if (fromIndex < 0 || fromIndex >= _gridSize) return;
    if (toIndex < 0 || toIndex >= _gridSize) return;
    if (fromIndex == toIndex) return;

    final item = _installedItems[fromIndex];
    final isWidget = item.contains('|widget');
    
    if (isWidget) {
       // Moving a Widget (2x2)
       // 1. Temporarily clear old space
       _installedItems[fromIndex] = _emptySlot;
       _installedItems[fromIndex+1] = _emptySlot;
       _installedItems[fromIndex+_gridCols] = _emptySlot;
       _installedItems[fromIndex+_gridCols+1] = _emptySlot;
       
       // 2. Check if target is valid
       if (_canPlaceWidgetAt(toIndex)) {
          _installedItems[toIndex] = item;
          _installedItems[toIndex+1] = _occupiedSlot;
          _installedItems[toIndex+_gridCols] = _occupiedSlot;
          _installedItems[toIndex+_gridCols+1] = _occupiedSlot;
       } else {
          // Revert!
          _installedItems[fromIndex] = item;
          _installedItems[fromIndex+1] = _occupiedSlot;
          _installedItems[fromIndex+_gridCols] = _occupiedSlot;
          _installedItems[fromIndex+_gridCols+1] = _occupiedSlot;
       }
    } else {
       // Moving 1x1 App
       // Check target type
       if (_installedItems[toIndex] == _emptySlot) {
          // Simple move
          _installedItems[toIndex] = item;
          _installedItems[fromIndex] = _emptySlot;
       } else if (!_installedItems[toIndex].contains('|widget') && _installedItems[toIndex] != _occupiedSlot) {
          // Swap with another 1x1
          _installedItems[fromIndex] = _installedItems[toIndex];
          _installedItems[toIndex] = item;
       }
    }
    
    _persist();
    notifyListeners();
  }

  /// Restoration for debugging
  void resetDefaults() {
    _installedItems.fillRange(0, _gridSize, _emptySlot);
    
    // Place defaults
    // 0: Breaking News Widget (2x2) - Occupies 0, 1, 4, 5
    // 2: Settings
    // 3: Empty
    // 6: Deep Dive
    
    _installedItems[0] = 'breaking_news|widget';
    _installedItems[1] = _occupiedSlot;
    _installedItems[4] = _occupiedSlot;
    _installedItems[5] = _occupiedSlot;
    
    _installedItems[2] = 'settings';
    _installedItems[6] = 'deep_dive';

    _persist();
    notifyListeners();
  }
}
