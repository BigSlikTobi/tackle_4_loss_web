import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tackle4loss_mobile/core/services/installed_apps_service.dart';
import 'package:tackle4loss_mobile/core/app_registry.dart';
import 'package:tackle4loss_mobile/micro_apps/app_store/app_store_app.dart';
import 'package:tackle4loss_mobile/micro_apps/breaking_news/breaking_news_app.dart';
import 'package:tackle4loss_mobile/micro_apps/standings/standings_app.dart';
import 'package:tackle4loss_mobile/micro_apps/radio/radio_app.dart';
import 'package:tackle4loss_mobile/micro_apps/deep_dive/deep_dive_app.dart';
import 'package:tackle4loss_mobile/micro_apps/player_wordle/player_wordle_app.dart';
import 'package:tackle4loss_mobile/micro_apps/game_reports/game_reports_app.dart';

void main() {
  group('InstalledAppsService', () {
    late InstalledAppsService service;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      
      // Clear registry before each test to ensure deterministic behavior
      final registry = AppRegistry();
      registry.clear();
      
      // Register apps with current configuration
      // Note: All these apps now have showOnHomePage = true
      registry.register(BreakingNewsApp()); // on home
      registry.register(DeepDiveApp());     // on home
      registry.register(RadioApp());        // on home
      registry.register(PlayerWordleApp()); // on home
      registry.register(GameReportsApp());  // on home (feature flagged off)
      registry.register(StandingsApp());    // on home
      registry.register(AppHubApp());       // NOT on home (system app)
      
      service = InstalledAppsService();
      await service.init();
    });

    group('initialization', () {
      test('init sets up default ordered list based on showOnHomePage', () async {
        service.resetDefaults();
        
        final apps = service.rawItems;
        expect(apps, contains('breaking_news'));
        expect(apps, contains('deep_dive'));
        expect(apps, contains('radio'));
        expect(apps, contains('standings'));
        expect(apps, contains('player_wordle'));
        
        // App Hub should NOT be installed (system app, showOnHomePage = false)
        expect(service.isInstalled('app_hub'), isFalse);
      });
    });

    group('queries', () {
      test('isInstalled checks if app is in list', () {
        service.resetDefaults();
        expect(service.isInstalled('breaking_news'), isTrue);
        expect(service.isInstalled('standings'), isTrue); // Now on home
      });
      
      test('rawItems returns correct list', () {
         service.resetDefaults();
         expect(service.rawItems.length, greaterThan(0));
         expect(service.rawItems, isA<List<String>>());
      });
    });

    group('install/uninstall', () {
      test('install adds app to the end of the list', () {
        service.resetDefaults();
        // First uninstall to test install behavior
        service.uninstall('standings');
        expect(service.isInstalled('standings'), isFalse);
        
        service.install('standings');
        
        expect(service.isInstalled('standings'), isTrue);
        expect(service.rawItems.last, equals('standings'));
      });

      test('install does not duplicate existing app', () {
        service.resetDefaults();
        int initialCount = service.rawItems.length;
        
        service.install('breaking_news');
        
        expect(service.rawItems.length, equals(initialCount));
      });

      test('uninstall removes app from list', () {
        service.resetDefaults();
        expect(service.isInstalled('breaking_news'), isTrue);
        
        service.uninstall('breaking_news');
        
        expect(service.isInstalled('breaking_news'), isFalse);
      });

      test('uninstall does not remove app_hub', () {
        service.install('app_hub');
        service.uninstall('app_hub');
        expect(service.isInstalled('app_hub'), isTrue);
      });
    });

    group('moveApp', () {
      test('moveApp reorders items correctly', () {
        // Setup a simple known state
        service.resetDefaults();
        
        // Let's force a clean slate for precise move testing
        for (var app in service.rawItems) {
          service.uninstall(app);
        }
        service.install('app1');
        service.install('app2');
        service.install('app3');
        
        // Initial state: [app1, app2, app3]
        expect(service.rawItems, equals(['app1', 'app2', 'app3']));
        
        // Move app1 to end
        service.moveApp(0, 2);
        expect(service.rawItems, equals(['app2', 'app3', 'app1']));
        
        // Move app1 back to start
        service.moveApp(2, 0);
        expect(service.rawItems, equals(['app1', 'app2', 'app3']));
      });
    });
    
    group('resetDefaults', () {
      test('resetDefaults restores original list', () {
        service.uninstall('breaking_news');
        expect(service.isInstalled('breaking_news'), isFalse);
        
        service.resetDefaults();
        expect(service.isInstalled('breaking_news'), isTrue);
      });
    });
  });
}
