import 'package:shared_preferences/shared_preferences.dart';

/// Rate limiter for cloud-enhanced reports.
/// Limits users to [maxDailyReports] cloud Gemini API calls per day.
class CloudReportLimiter {
  /// Maximum number of cloud-enhanced reports per day per user.
  static const int maxDailyReports = 5;
  
  /// Key prefix for storing daily usage count.
  static const String _keyPrefix = 'cloud_reports_';
  
  SharedPreferences? _prefs;
  
  /// Initialize the limiter with shared preferences.
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }
  
  /// Get the storage key for today's date.
  String _getTodayKey() {
    final today = DateTime.now().toIso8601String().split('T').first;
    return '$_keyPrefix$today';
  }
  
  /// Check if the user can use cloud enhancement today.
  /// Returns true if under the daily limit.
  Future<bool> canUseCloudEnhancement() async {
    await init();
    final count = _prefs?.getInt(_getTodayKey()) ?? 0;
    return count < maxDailyReports;
  }
  
  /// Get the number of cloud reports used today.
  Future<int> getUsedToday() async {
    await init();
    return _prefs?.getInt(_getTodayKey()) ?? 0;
  }
  
  /// Get the number of cloud reports remaining today.
  Future<int> getRemainingToday() async {
    final used = await getUsedToday();
    return (maxDailyReports - used).clamp(0, maxDailyReports);
  }
  
  /// Record that a cloud-enhanced report was generated.
  /// Returns false if the limit was already reached.
  Future<bool> recordCloudUsage() async {
    await init();
    final key = _getTodayKey();
    final count = _prefs?.getInt(key) ?? 0;
    
    if (count >= maxDailyReports) {
      return false; // Limit reached
    }
    
    await _prefs?.setInt(key, count + 1);
    return true;
  }
  
  /// Clean up old entries (older than 7 days) to prevent storage bloat.
  Future<void> cleanupOldEntries() async {
    await init();
    final keys = _prefs?.getKeys() ?? <String>{};
    final today = DateTime.now();
    
    for (final key in keys) {
      if (key.startsWith(_keyPrefix)) {
        final dateStr = key.substring(_keyPrefix.length);
        try {
          final date = DateTime.parse(dateStr);
          if (today.difference(date).inDays > 7) {
            await _prefs?.remove(key);
          }
        } catch (_) {
          // Invalid date format, remove the key
          await _prefs?.remove(key);
        }
      }
    }
  }
}
