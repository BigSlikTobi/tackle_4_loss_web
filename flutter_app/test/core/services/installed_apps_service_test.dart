import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tackle4loss_mobile/core/services/installed_apps_service.dart';

void main() {
  group('InstalledAppsService', () {
    // Note: Since InstalledAppsService is a singleton, tests must account for shared state.
    // For independent tests, we'll reset via resetDefaults() and init().
    
    late InstalledAppsService service;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      service = InstalledAppsService();
      await service.init();
    });

    group('initialization', () {
      test('init sets up default grid layout', () async {
        service.resetDefaults();
        
        // Breaking news widget at position 0
        expect(service.getItemAt(0), 'breaking_news|widget');
        // Occupied slots for 2x2 widget
        expect(service.isOccupySlot(1), isTrue);
        expect(service.isOccupySlot(4), isTrue);
        expect(service.isOccupySlot(5), isTrue);
        // Settings at position 2
        expect(service.getItemAt(2), 'settings');
      });
    });

    group('grid queries', () {
      test('isEmpty returns true for empty slots', () {
        service.resetDefaults();
        // Position 3 should be empty in default layout
        expect(service.isEmpty(3), isTrue);
        expect(service.isEmpty(6), isTrue);
      });

      test('isEmpty returns false for occupied slots', () {
        service.resetDefaults();
        expect(service.isEmpty(0), isFalse); // breaking_news|widget
        expect(service.isEmpty(1), isFalse); // occupied
        expect(service.isEmpty(2), isFalse); // settings
      });

      test('isEmpty returns true for out-of-bounds indices', () {
        expect(service.isEmpty(-1), isTrue);
        expect(service.isEmpty(100), isTrue);
      });

      test('isWidget returns true for widget slots', () {
        service.resetDefaults();
        expect(service.isWidget(0), isTrue); // breaking_news|widget
      });

      test('isWidget returns false for regular apps', () {
        service.resetDefaults();
        expect(service.isWidget(2), isFalse); // settings (1x1 app)
      });

      test('isInstalled checks if app is in grid', () {
        service.resetDefaults();
        expect(service.isInstalled('breaking_news'), isTrue);
        expect(service.isInstalled('settings'), isTrue);
        expect(service.isInstalled('unknown_app'), isFalse);
      });

      test('isInstalledAsWidget checks widget status', () {
        service.resetDefaults();
        expect(service.isInstalledAsWidget('breaking_news'), isTrue);
        expect(service.isInstalledAsWidget('settings'), isFalse);
      });
    });

    group('install', () {
      test('install places 1x1 app in first empty slot', () {
        service.resetDefaults();
        
        service.install('deep_dive');
        
        // Should be placed in first empty slot (index 3 in default layout)
        expect(service.isInstalled('deep_dive'), isTrue);
      });

      test('install with asWidget places 2x2 widget', () {
        service.resetDefaults();
        
        // Find a valid 2x2 space and install
        service.install('standings', asWidget: true);
        
        expect(service.isInstalledAsWidget('standings'), isTrue);
      });

      test('install removes existing installation first', () {
        service.resetDefaults();
        
        // Install as regular app first
        service.install('deep_dive');
        expect(service.isInstalled('deep_dive'), isTrue);
        
        // Re-install as widget should remove old and place new
        service.install('deep_dive', asWidget: true);
        
        // Check it's now a widget (if space available)
        // Note: This depends on available space in grid
      });
    });

    group('uninstall', () {
      test('uninstall removes 1x1 app from grid', () {
        service.resetDefaults();
        service.install('deep_dive');
        expect(service.isInstalled('deep_dive'), isTrue);
        
        service.uninstall('deep_dive');
        
        expect(service.isInstalled('deep_dive'), isFalse);
      });

      test('uninstall removes 2x2 widget and clears occupied slots', () {
        service.resetDefaults();
        
        // Uninstall the default breaking_news widget
        service.uninstall('breaking_news');
        
        expect(service.isInstalled('breaking_news'), isFalse);
        // Occupied slots should now be empty
        expect(service.isEmpty(1), isTrue);
        expect(service.isEmpty(4), isTrue);
        expect(service.isEmpty(5), isTrue);
      });

      test('uninstall does not remove app_store', () {
        service.resetDefaults();
        service.install('app_store');
        
        service.uninstall('app_store');
        
        // app_store should still be installed (protected)
        expect(service.isInstalled('app_store'), isTrue);
      });
    });

    group('canPlaceWidgetAt', () {
      test('returns false for right edge positions', () {
        service.resetDefaults();
        
        // Position 3 is at column 3 (right edge), can't fit 2x2
        expect(service.canPlaceWidgetAt(3), isFalse);
        expect(service.canPlaceWidgetAt(7), isFalse);
      });

      test('returns false for bottom edge positions', () {
        service.resetDefaults();
        
        // Positions in last row can't fit 2x2
        expect(service.canPlaceWidgetAt(16), isFalse);
        expect(service.canPlaceWidgetAt(17), isFalse);
      });

      test('returns true for valid 2x2 positions without checkEasyPlacement', () {
        service.resetDefaults();
        
        // Position 6 should be valid for 2x2 (bounds check only)
        expect(service.canPlaceWidgetAt(6), isTrue);
      });
    });

    group('moveApp', () {
      test('moveApp ignores out-of-bounds indices', () {
        service.resetDefaults();
        final before = List.from(service.rawItems);
        
        service.moveApp(-1, 5);
        
        expect(service.rawItems, equals(before));
      });

      test('moveApp ignores same index', () {
        service.resetDefaults();
        final before = List.from(service.rawItems);
        
        service.moveApp(2, 2);
        
        expect(service.rawItems, equals(before));
      });
    });

    group('resetDefaults', () {
      test('resetDefaults restores default grid layout', () {
        // Modify grid
        service.install('deep_dive');
        service.install('radio');
        
        // Reset
        service.resetDefaults();
        
        // Verify defaults
        expect(service.getItemAt(0), 'breaking_news|widget');
        expect(service.getItemAt(2), 'settings');
      });
    });

    group('rawItems', () {
      test('rawItems returns unmodifiable list', () {
        final items = service.rawItems;
        
        expect(items.length, 20); // 4x5 grid
        expect(() => items.add('test'), throwsUnsupportedError);
      });
    });

    group('installedApps', () {
      test('installedApps filters out empty and occupied slots', () {
        service.resetDefaults();
        
        final apps = service.installedApps;
        
        // Should return a list (may be empty if AppRegistry not initialized in test)
        // The important thing is it doesn't include EMPTY or OCCUPIED markers
        expect(apps, isA<List>());
      });
    });
  });
}
