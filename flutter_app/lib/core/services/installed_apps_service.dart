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

  /// Checks if a 2x2 widget can be placed at [index].
  /// [checkEasyPlacement]: If true, requires the target slots to be strictly empty (for auto-install).
  /// If false (default), allows occupied slots (assuming they will be swapped/displaced).
  bool canPlaceWidgetAt(int index, {int ignoreIndex = -1, bool checkEasyPlacement = false}) {
     // Check bounds (2x2)
     int row = index ~/ _gridCols;
     int col = index % _gridCols;
     
     if (col + 1 >= _gridCols) return false; // Crosses right edge
     if (row + 1 >= _gridRows) return false; // Crosses bottom edge
     
     // If we don't care about what's there (we will swap), we are good just with bounds!
     if (!checkEasyPlacement) return true;

     // Indices to check for target
     List<int> targetSlots = [
       index, 
       index + 1, 
       index + _gridCols, 
       index + _gridCols + 1
     ];

     // Indices to ignore (current position of the widget being moved)
     List<int> ignoredSlots = [];
     if (ignoreIndex != -1) {
       ignoredSlots = [
         ignoreIndex,
         ignoreIndex + 1,
         ignoreIndex + _gridCols,
         ignoreIndex + _gridCols + 1
       ];
     }
     
     for (final s in targetSlots) {
       // If the slot is part of the widget's current position, treat it as effectively empty (safe to overlap/overwrite self)
       if (ignoredSlots.contains(s)) continue;
       
       if (_installedItems[s] != _emptySlot) return false;
     }
     return true;
  }

  int _findSpaceForWidget() {
    for (int i = 0; i < _gridSize; i++) {
       // For auto-install, we want strictly empty space
       if (canPlaceWidgetAt(i, checkEasyPlacement: true)) return i;
    }
    return -1;
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

  // Helper to safely clear a slot
  void _safeClear(int index) {
    if (index >= 0 && index < _gridSize) {
      _installedItems[index] = _emptySlot;
    }
  }

  // Helper to safely set a slot
  void _safeSet(int index, String value) {
    if (index >= 0 && index < _gridSize) {
      _installedItems[index] = value;
    }
  }

  void uninstall(String appId) {
    if (appId == 'app_store') return;
    
    // Clear ALL occurrences (master + occupied)
    for (int i = 0; i < _gridSize; i++) {
      if (_installedItems[i].split('|').first == appId) {
        if (_installedItems[i].contains('|widget')) {
           // Clear 2x2 with safe checks
           _safeClear(i);
           _safeClear(i + 1);
           _safeClear(i + _gridCols);
           _safeClear(i + _gridCols + 1);
        } else {
           _safeClear(i);
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
       // Check bounds for the target 2x2 area
       int targetRow = toIndex ~/ _gridCols;
       int targetCol = toIndex % _gridCols;

       if (targetCol + 1 >= _gridCols || targetRow + 1 >= _gridRows) {
          debugPrint('DEBUG: Cannot place widget at $toIndex, out of bounds for 2x2');
          return; // Target 2x2 area would be out of bounds
       }

       // Step A: Identify obstacles (other apps/widgets) in the target 2x2 area
       List<int> targetIndices = [
          toIndex,
          toIndex + 1,
          toIndex + _gridCols,
          toIndex + _gridCols + 1,
       ];

       // Footprint of the widget being moved (its current location)
       List<int> footprint = [
          fromIndex,
          fromIndex + 1,
          fromIndex + _gridCols,
          fromIndex + _gridCols + 1,
       ];

       List<int> obstacleMasters = []; // Stores the master index of any app/widget that needs to be displaced

       for (int i = 0; i < _gridSize; i++) {
          final val = _installedItems[i];
          if (val == _emptySlot || val == _occupiedSlot) continue; 

          // Check intersection
          bool intersects = false;
          List<int> footprint;
          if (val.contains('|widget')) {
            footprint = [i, i+1, i+_gridCols, i+_gridCols+1];
          } else {
            footprint = [i];
          }

          for (final f in footprint) {
             if (targetIndices.contains(f)) {
                intersects = true;
                break;
             }
          }
          
          // BUT, ignore self (the widget we are moving)
          if (i == fromIndex) continue;

          if (intersects) {
             obstacleMasters.add(i);
          }
       }
       
       // Step B: Clear Self
       _safeClear(fromIndex);
       _safeClear(fromIndex + 1);
       _safeClear(fromIndex + _gridCols);
       _safeClear(fromIndex + _gridCols + 1);

       // Step C: Remove Obstacles from grid (temporarily)
       Map<int, String> displacedItems = {}; // MasterIndex -> Value
       for (final master in obstacleMasters) {
          displacedItems[master] = _installedItems[master];
          // Clear them
          final isWid = _installedItems[master].contains('|widget');
          _safeClear(master);
          if (isWid) {
            _safeClear(master + 1);
            _safeClear(master + _gridCols);
            _safeClear(master + _gridCols + 1);
          }
       }

       // Step D: Place Self at Target
       _safeSet(toIndex, item);
       _safeSet(toIndex + 1, _occupiedSlot);
       _safeSet(toIndex + _gridCols, _occupiedSlot);
       _safeSet(toIndex + _gridCols + 1, _occupiedSlot);
       
       // Step E: Re-seat Obstacles
       List<int> freeSlots = [
          fromIndex, fromIndex + 1, fromIndex + _gridCols, fromIndex + _gridCols + 1
       ];
       
       for (final entry in displacedItems.entries) {
          final val = entry.value;
          final isWid = val.contains('|widget');
          
          if (isWid) {
             // For now, if a widget is displaced, we just remove it.
             // More complex logic would try to find a new 2x2 spot.
             debugPrint('DEBUG: Displaced widget $val was removed as no re-seating logic is implemented yet.');
          } else {
             // 1x1 App
             bool placed = false;
             for (final fs in freeSlots) {
                if (_installedItems[fs] == _emptySlot) {
                   _safeSet(fs, val);
                   placed = true;
                   break;
                }
             }
             if (!placed) {
                // If no free slot from the widget's old position, try to find any empty slot
                int newSlot = _installedItems.indexOf(_emptySlot);
                if (newSlot != -1) {
                   _safeSet(newSlot, val);
                } else {
                   debugPrint('DEBUG: Displaced app $val could not be re-seated, grid full.');
                }
             }
          }
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
    // _installedItems[6] = 'deep_dive'; // Removed to avoid duplication with Featured Hero

    _persist();
    notifyListeners();
  }
}
