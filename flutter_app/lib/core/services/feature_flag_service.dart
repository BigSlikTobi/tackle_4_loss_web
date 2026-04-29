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
    // MVP scope: only breaking_news (home feed data) and standings are visible.
    // Other apps remain in the repo but are flag-off for first App Store release.
    'app_hub': false,
    'breaking_news': true,
    'deep_dive': false,
    'radio': false,
    'standings': true,
    'game_reports': false,
    'player_wordle': false,
  };

  /// Returns true if the feature/app is enabled.
  /// Returns false if disabled or unknown.
  bool isEnabled(String key) {
    return _flags[key] ?? false;
  }
}
