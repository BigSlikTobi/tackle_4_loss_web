import 'package:flutter/foundation.dart';

class GridMoveCalculator {
  static const int gridCols = 4;
  static const int gridRows = 5;
  static const int gridSize = gridCols * gridRows;
  
  static const String emptySlot = '__EMPTY__';
  static const String occupiedSlot = '__OCCUPIED__';

  /// Calculates the new grid state after moving an app from [fromIndex] to [toIndex].
  /// Returns a new list with the updated state.
  static List<String> calculateMove({
    required List<String> currentGrid,
    required int fromIndex,
    required int toIndex,
  }) {
    // Create a copy to work on
    final List<String> newGrid = List<String>.from(currentGrid);
    
    if (fromIndex < 0 || fromIndex >= gridSize) return newGrid;
    if (toIndex < 0 || toIndex >= gridSize) return newGrid;
    if (fromIndex == toIndex) return newGrid;

    final item = newGrid[fromIndex];
    final isWidget = item.contains('|widget');

    if (isWidget) {
      _moveWidget(newGrid, item, fromIndex, toIndex);
    } else {
      _moveApp(newGrid, item, fromIndex, toIndex);
    }
    
    return newGrid;
  }

  static void _moveWidget(List<String> grid, String item, int fromIndex, int toIndex) {
    // Check bounds for the target 2x2 area
    int targetRow = toIndex ~/ gridCols;
    int targetCol = toIndex % gridCols;

    if (targetCol + 1 >= gridCols || targetRow + 1 >= gridRows) {
      debugPrint('DEBUG: Cannot place widget at $toIndex, out of bounds for 2x2');
      return; // Target 2x2 area would be out of bounds
    }

    // Step A: Identify obstacles (other apps/widgets) in the target 2x2 area
    List<int> targetIndices = [
      toIndex,
      toIndex + 1,
      toIndex + gridCols,
      toIndex + gridCols + 1,
    ];

    List<int> obstacleMasters = []; // Stores the master index of any app/widget that needs to be displaced

    for (int i = 0; i < gridSize; i++) {
      final val = grid[i];
      if (val == emptySlot || val == occupiedSlot) continue;

      // Check intersection
      bool intersects = false;
      List<int> footprint;
      if (val.contains('|widget')) {
        footprint = [i, i + 1, i + gridCols, i + gridCols + 1];
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
    _safeClear(grid, fromIndex);
    _safeClear(grid, fromIndex + 1);
    _safeClear(grid, fromIndex + gridCols);
    _safeClear(grid, fromIndex + gridCols + 1);

    // Step C: Remove Obstacles from grid (temporarily)
    Map<int, String> displacedItems = {}; // MasterIndex -> Value
    for (final master in obstacleMasters) {
      displacedItems[master] = grid[master];
      // Clear them
      final isWid = grid[master].contains('|widget');
      _safeClear(grid, master);
      if (isWid) {
        _safeClear(grid, master + 1);
        _safeClear(grid, master + gridCols);
        _safeClear(grid, master + gridCols + 1);
      }
    }

    // Step D: Place Self at Target
    _safeSet(grid, toIndex, item);
    _safeSet(grid, toIndex + 1, occupiedSlot);
    _safeSet(grid, toIndex + gridCols, occupiedSlot);
    _safeSet(grid, toIndex + gridCols + 1, occupiedSlot);

    // Step E: Re-seat Obstacles
    List<int> freeSlots = [
      fromIndex,
      fromIndex + 1,
      fromIndex + gridCols,
      fromIndex + gridCols + 1
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
          if (grid[fs] == emptySlot) {
            _safeSet(grid, fs, val);
            placed = true;
            break;
          }
        }
        if (!placed) {
          // If no free slot from the widget's old position, try to find any empty slot
          int newSlot = grid.indexOf(emptySlot);
          if (newSlot != -1) {
            _safeSet(grid, newSlot, val);
          } else {
            debugPrint('DEBUG: Displaced app $val could not be re-seated, grid full.');
          }
        }
      }
    }
  }

  static void _moveApp(List<String> grid, String item, int fromIndex, int toIndex) {
    if (grid[toIndex] == emptySlot) {
      // Simple move
      grid[toIndex] = item;
      grid[fromIndex] = emptySlot;
    } else if (!grid[toIndex].contains('|widget') && grid[toIndex] != occupiedSlot) {
      // Swap with another 1x1
      grid[fromIndex] = grid[toIndex];
      grid[toIndex] = item;
    }
  }

  static void _safeClear(List<String> grid, int index) {
    if (index >= 0 && index < gridSize) {
      grid[index] = emptySlot;
    }
  }

  static void _safeSet(List<String> grid, int index, String value) {
    if (index >= 0 && index < gridSize) {
      grid[index] = value;
    }
  }
}
