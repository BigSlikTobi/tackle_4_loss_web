/// Service to manage feature flags for the application.
/// Used to toggle micro-apps and features on/off without data migration.
class FeatureFlagService {
  static final FeatureFlagService _instance = FeatureFlagService._internal();
  factory FeatureFlagService() => _instance;
  FeatureFlagService._internal();

  /// Feature flags configuration.
  /// Key: Feature ID (usually matching app ID)
  /// Value: Enabled status
  final Map<String, bool> _flags = {
    // Core apps
    'app_store': true,
    'breaking_news': true,
    'deep_dive': true,
    'radio': true,
    'standings': true,
    'game_reports': false, // in development
    'player_wordle': true, // Ready for testing
  };

  /// Returns true if the feature/app is enabled.
  /// Returns false if disabled or unknown.
  bool isEnabled(String key) {
    return _flags[key] ?? false;
  }
}
