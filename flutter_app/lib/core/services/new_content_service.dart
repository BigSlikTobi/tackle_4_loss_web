import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app_registry.dart';

/// Service to track "new" content indicators for badges.
/// Persists last-seen IDs via SharedPreferences.
class NewContentService with ChangeNotifier {
  static final NewContentService _instance = NewContentService._internal();
  factory NewContentService() => _instance;
  NewContentService._internal();

  @visibleForTesting
  NewContentService.testing();

  static const String _lastSeenDeepDiveKey = 'last_seen_deep_dive_id';
  static const String _lastSeenAppCountKey = 'last_seen_app_count';

  String? _lastSeenDeepDiveId;
  int _lastSeenAppCount = 0;

  String? _latestDeepDiveId;
  int _currentAppCount = 0;

  bool _isInitialized = false;

  /// Initialize service by loading persisted values.
  Future<void> init() async {
    if (_isInitialized) return;

    final prefs = await SharedPreferences.getInstance();
    _lastSeenDeepDiveId = prefs.getString(_lastSeenDeepDiveKey);
    _lastSeenAppCount = prefs.getInt(_lastSeenAppCountKey) ?? 0;

    // Get current app count from registry
    _updateCurrentAppCount();

    _isInitialized = true;
    notifyListeners();
  }

  void _updateCurrentAppCount() {
    final registry = AppRegistry();
    // Count apps that are in the App Hub (not on home page, excluding app_hub itself)
    _currentAppCount = registry.apps
        .where((app) => app.id != 'app_hub' && !app.showOnHomePage)
        .length;
  }

  /// Set the latest deep dive ID (called when deep dive data is loaded).
  void setLatestDeepDiveId(String? id) {
    if (id != null && id != _latestDeepDiveId) {
      _latestDeepDiveId = id;
      notifyListeners();
    }
  }

  /// Returns true if there's a new deep dive the user hasn't seen.
  bool get hasNewDeepDive {
    if (_latestDeepDiveId == null) return false;
    return _latestDeepDiveId != _lastSeenDeepDiveId;
  }

  /// Returns true if there are new apps in the hub the user hasn't seen.
  bool get hasNewAppsInHub {
    _updateCurrentAppCount();
    return _currentAppCount > _lastSeenAppCount;
  }

  /// Mark the current deep dive as seen.
  Future<void> markDeepDiveSeen(String id) async {
    if (_lastSeenDeepDiveId == id) return;

    _lastSeenDeepDiveId = id;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastSeenDeepDiveKey, id);
    notifyListeners();
  }

  /// Mark App Hub as visited (clears badge).
  Future<void> markAppHubSeen() async {
    _updateCurrentAppCount();
    _lastSeenAppCount = _currentAppCount;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastSeenAppCountKey, _currentAppCount);
    notifyListeners();
  }

  /// For testing: reset all state
  @visibleForTesting
  Future<void> reset() async {
    _lastSeenDeepDiveId = null;
    _lastSeenAppCount = 0;
    _latestDeepDiveId = null;
    _currentAppCount = 0;
    _isInitialized = false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastSeenDeepDiveKey);
    await prefs.remove(_lastSeenAppCountKey);
    notifyListeners();
  }
}
