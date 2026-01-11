import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tackle4loss_mobile/core/services/installed_apps_service.dart';
import 'package:tackle4loss_mobile/core/app_registry.dart';
import 'package:tackle4loss_mobile/micro_apps/app_store/app_store_app.dart';
import 'package:tackle4loss_mobile/micro_apps/breaking_news/breaking_news_app.dart';
import 'package:tackle4loss_mobile/micro_apps/standings/standings_app.dart';
import 'package:tackle4loss_mobile/micro_apps/radio/radio_app.dart';
import 'package:tackle4loss_mobile/micro_apps/deep_dive/deep_dive_app.dart';

void main() {
  group('InstalledAppsService', () {
    late InstalledAppsService service;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      
      // Clear registry before each test to ensure deterministic behavior
      final registry = AppRegistry();
      registry.clear(); // Assuming this method exists or we can just register again
      
      // Register apps with current configuration
      registry.register(BreakingNewsApp()); // true, false
      registry.register(DeepDiveApp());     // true, false
      registry.register(RadioApp());        // true, true
      registry.register(StandingsApp());    // false
      registry.register(AppHubApp());       // false
      
      service = InstalledAppsService();
      await service.init();
    });

    group('initialization', () {
      test('init sets up default grid layout based on showOnHomePage', () async {
        service.resetDefaults();
        
        expect(service.isInstalled('breaking_news'), isTrue);
        expect(service.isInstalled('deep_dive'), isTrue);
        expect(service.isInstalled('radio'), isTrue);
        
        // These should NOT be installed on home page
        expect(service.isInstalled('standings'), isFalse);
        expect(service.isInstalled('app_hub'), isFalse);
      });
    });

    group('grid queries', () {
      test('isEmpty returns true for empty slots', () {
        service.resetDefaults();
        bool hasEmptySlot = false;
        for (int i = 0; i < 20; i++) {
          if (service.isEmpty(i)) {
            hasEmptySlot = true;
            break;
          }
        }
        expect(hasEmptySlot, isTrue);
      });

      test('isWidget returns true for widget slots', () {
        service.resetDefaults();
        // Radio is a widget (3x1)
        // Check if any slot is a widget
        bool hasWidget = false;
        for (int i = 0; i < 20; i++) {
          if (service.isWidget(i)) {
            hasWidget = true;
            break;
          }
        }
        expect(hasWidget, isTrue);
      });

      test('isInstalled checks if app is in grid', () {
        service.resetDefaults();
        expect(service.isInstalled('breaking_news'), isTrue);
        expect(service.isInstalled('unknown_app'), isFalse);
      });

      test('isInstalledAsWidget checks widget status', () {
        service.resetDefaults();
        expect(service.isInstalledAsWidget('radio'), isTrue);
        expect(service.isInstalledAsWidget('breaking_news'), isFalse);
      });
    });

    group('install', () {
      test('install places 1x1 app in first empty slot', () {
        service.resetDefaults();
        service.install('player_wordle');
        expect(service.isInstalled('player_wordle'), isTrue);
      });

      test('install with asWidget places widget correctly', () {
        service.resetDefaults();
        // Uninstall radio first since it's already installed as widget
        service.uninstall('radio');
        // Re-install as widget
        service.install('radio', asWidget: true);
        expect(service.isInstalledAsWidget('radio'), isTrue);
      });
    });

    group('uninstall', () {
      test('uninstall removes app from grid', () {
        service.resetDefaults();
        expect(service.isInstalled('breaking_news'), isTrue);
        service.uninstall('breaking_news');
        expect(service.isInstalled('breaking_news'), isFalse);
      });

      test('uninstall does not remove app_hub', () {
        // Even if not on home page by default, if installed manually it should be protected
        service.install('app_hub');
        service.uninstall('app_hub');
        expect(service.isInstalled('app_hub'), isTrue);
      });
    });

    group('resetDefaults', () {
      test('resetDefaults restores grid based on manifest', () {
        service.install('player_wordle');
        service.resetDefaults();
        expect(service.isInstalled('player_wordle'), isFalse);
        expect(service.isInstalled('breaking_news'), isTrue);
      });
    });
  });
}
