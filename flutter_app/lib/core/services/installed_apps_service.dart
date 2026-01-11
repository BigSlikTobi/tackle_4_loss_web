import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app_registry.dart';
import '../micro_app.dart';
import 'grid_move_calculator.dart';

class InstalledAppsService with ChangeNotifier {
  // Singleton
  static final InstalledAppsService _instance = InstalledAppsService._internal();
  factory InstalledAppsService() => _instance;
  InstalledAppsService._internal();

  static const String _storageKey = 'installed_app_ids_grid_v11'; 
  static const String _manifestKey = 'home_page_manifest_hash';
  static const int _gridCols = 4;
  static const int _gridRows = 5;
  static const int _gridSize = _gridCols * _gridRows;
  
  static const String _emptySlot = '__EMPTY__';
  static const String _occupiedSlot = '__OCCUPIED__';
  
  // Fixed list of 20 items 
  final List<String> _installedItems = List.filled(_gridSize, _emptySlot, growable: false);

  /// Generates a hash representing the current "source of truth" home page configuration.
  /// If any app's showOnHomePage or hasWidget status changes, this hash will change.
  String _getManifestHash() {
    final registry = AppRegistry();
    final apps = registry.apps.where((app) => app.showOnHomePage).toList();
    // Sort to ensure deterministic hash regardless of registration order
    apps.sort((a, b) => a.id.compareTo(b.id));
    
    return apps.map((app) => '${app.id}:${app.hasWidget}:${app.widgetSize.width}x${app.widgetSize.height}').join('|');
  }

  // Initialize persistence & migrate old data
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final storedItems = prefs.getStringList(_storageKey);
    final storedManifest = prefs.getString(_manifestKey);
    final currentManifest = _getManifestHash();

    // Reset to empty
    _installedItems.fillRange(0, _gridSize, _emptySlot);

    // If manifest changed, we MUST reset to apply new code-level defaults
    if (storedManifest != currentManifest) {
      resetDefaults();
      return;
    }

    if (storedItems != null && storedItems.length == _gridSize) {
      for (int i = 0; i < _gridSize; i++) {
        _installedItems[i] = storedItems[i];
      }
    } else {
       resetDefaults();
    }
    
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_storageKey, _installedItems);
    await prefs.setString(_manifestKey, _getManifestHash());
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

  /// Checks if a widget of specific size can be placed at [index].
  bool canPlaceWidgetAt(int index, int width, int height, {int ignoreIndex = -1, bool checkEasyPlacement = false}) {
     int row = index ~/ _gridCols;
     int col = index % _gridCols;
     
     if (col + width > _gridCols) return false; // Crosses right edge
     if (row + height > _gridRows) return false; // Crosses bottom edge
     
     if (!checkEasyPlacement) return true;

     // Check all required slots
     for (int y = 0; y < height; y++) {
       for (int x = 0; x < width; x++) {
         int slot = index + x + (y * _gridCols);
         
         // If ignoring specific index (e.g. self during move)
         // Note: We only strictly ignore the exact origin index of the dragged item
         // A more robust check might ignore all slots currently occupied by the dragged item,
         // but for 'checkEasyPlacement' (auto-install), ignoreIndex is usually -1.
         if (slot == ignoreIndex) continue;

         if (_installedItems[slot] != _emptySlot) return false;
       }
     }
     return true;
  }

  int _findSpaceForWidget(int width, int height, {int startIndex = 0}) {
    for (int i = startIndex; i < _gridSize; i++) {
       if (canPlaceWidgetAt(i, width, height, checkEasyPlacement: true)) return i;
    }
    return -1;
  }

  void install(String appId, {bool asWidget = false}) {
    // Determine size first if widget
    int width = 1;
    int height = 1;
    
    if (asWidget) {
       final app = AppRegistry().getApp(appId);
       if (app != null) {
         width = app.widgetSize.width.toInt();
         height = app.widgetSize.height.toInt();
       } else {
         debugPrint('App $appId not found for install');
         return;
       }
    }

    uninstall(appId); 
    
    if (asWidget) {
       int slot = _findSpaceForWidget(width, height);
       if (slot != -1) {
         _installedItems[slot] = '$appId|widget';
         // Mark occupied slots
         for (int y = 0; y < height; y++) {
           for (int x = 0; x < width; x++) {
             if (x == 0 && y == 0) continue; // Skip master slot
             int occupySlot = slot + x + (y * _gridCols);
             if (occupySlot < _gridSize) {
                _installedItems[occupySlot] = _occupiedSlot;
             }
           }
         }
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

  // Helper to safely clear a slot
  void _safeClear(int index) {
    if (index >= 0 && index < _gridSize) {
      _installedItems[index] = _emptySlot;
    }
  }

  void uninstall(String appId) {
    if (appId == 'app_hub') return;
    
    // We need to look for the master entry
    int index = -1;
    for (int i = 0; i < _gridSize; i++) {
      if (_installedItems[i].split('|').first == appId && _installedItems[i] != _occupiedSlot) {
        index = i;
        break;
      }
    }
    
    if (index != -1) {
      final item = _installedItems[index];
      // Check if it was a widget to clear footprint
      if (item.contains('|widget')) {
          final app = AppRegistry().getApp(appId);
          int width = 2; // Default fallback
          int height = 2;
          if (app != null) {
            width = app.widgetSize.width.toInt();
            height = app.widgetSize.height.toInt();
          }
          
          for (int y = 0; y < height; y++) {
            for (int x = 0; x < width; x++) {
              int slot = index + x + (y * _gridCols);
              _safeClear(slot);
            }
          }
      } else {
        _safeClear(index);
      }
      _persist();
      notifyListeners();
    }
  }
  
  /// Swap items (Fixed Grid Logic)
  void moveApp(int fromIndex, int toIndex) {
    if (fromIndex < 0 || fromIndex >= _gridSize) return;
    if (toIndex < 0 || toIndex >= _gridSize) return;
    if (fromIndex == toIndex) return;

    final newGrid = GridMoveCalculator.calculateMove(
      currentGrid: _installedItems,
      fromIndex: fromIndex,
      toIndex: toIndex,
    );

    // Apply changes
    for (int i = 0; i < _gridSize; i++) {
      _installedItems[i] = newGrid[i];
    }
    
    _persist();
    notifyListeners();
  }

  /// Restoration for debugging - populates grid based on showOnHomePage property
  void resetDefaults() {
    _installedItems.fillRange(0, _gridSize, _emptySlot);
    
    // Get all apps that should be on home page
    final registry = AppRegistry();
    final homePageApps = registry.apps.where((app) => app.showOnHomePage).toList();
    
    int nextSlot = 0;
    for (final app in homePageApps) {
      // Find first empty slot for checking
      while (nextSlot < _gridSize && _installedItems[nextSlot] != _emptySlot) {
        nextSlot++;
      }
      if (nextSlot >= _gridSize) break;
      
      if (app.hasWidget) {
        int width = app.widgetSize.width.toInt();
        int height = app.widgetSize.height.toInt();
        
        // Search for space for widget starting from nextSlot
        int widgetSlot = _findSpaceForWidget(width, height, startIndex: nextSlot);
        
        if (widgetSlot != -1) {
          _installedItems[widgetSlot] = '${app.id}|widget';
          
          // Mark occupied using safe bounds check
          for (int y = 0; y < height; y++) {
             for (int x = 0; x < width; x++) {
               if (x == 0 && y == 0) continue;
               int slot = widgetSlot + x + (y * _gridCols);
               if (slot < _gridSize) _installedItems[slot] = _occupiedSlot;
             }
          }
        } else {
          // Fall back to 1x1 if no space for widget found
          _installedItems[nextSlot] = app.id;
        }
      } else {
        // Place 1x1 app
        _installedItems[nextSlot] = app.id;
      }
    }

    _persist();
    notifyListeners();
  }
}

