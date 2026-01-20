import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tackle4loss_mobile/core/services/installed_apps_service.dart';
import 'package:tackle4loss_mobile/core/app_registry.dart';
import 'package:tackle4loss_mobile/micro_apps/breaking_news/breaking_news_app.dart';
import 'package:tackle4loss_mobile/micro_apps/deep_dive/deep_dive_app.dart';
import 'package:tackle4loss_mobile/micro_apps/radio/radio_app.dart';
import 'package:tackle4loss_mobile/micro_apps/standings/standings_app.dart';
import 'package:tackle4loss_mobile/micro_apps/app_store/app_store_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    
    // Clear and set up registry with apps for testing
    final registry = AppRegistry();
    registry.clear();
    registry.register(BreakingNewsApp());
    registry.register(DeepDiveApp());
    registry.register(RadioApp());
    registry.register(StandingsApp());
    registry.register(AppHubApp());
  });

  test('Service initializes with default apps', () async {
    final service = InstalledAppsService();
    service.resetDefaults();
    
    // Breaking News, Deep Dive, Radio, and Standings have showOnHomePage = true
    expect(service.isInstalled('breaking_news'), true);
    expect(service.isInstalled('deep_dive'), true);
    expect(service.isInstalled('radio'), true);
    expect(service.isInstalled('standings'), true);
    
    // AppHub has showOnHomePage = false  
    expect(service.isInstalled('app_hub'), false);
  });

  test('Install app adds to the end of the list', () async {
    final service = InstalledAppsService();
    service.resetDefaults();
    
    // Ensure 'app_hub' is not installed initially
    expect(service.isInstalled('app_hub'), false);
    
    service.install('app_hub');
    
    expect(service.isInstalled('app_hub'), true);
    // Should be at the end
    expect(service.getItemAt(service.rawItems.length - 1), 'app_hub');
  });

  test('Uninstall app removes it from the list', () async {
    final service = InstalledAppsService();
    service.resetDefaults();
    
    expect(service.isInstalled('breaking_news'), true);
    
    service.uninstall('breaking_news');
    
    expect(service.isInstalled('breaking_news'), false);
  });

  test('Move app reorders the list correctly', () async {
    final service = InstalledAppsService();
    service.resetDefaults();
    
    // Default order includes: breaking_news, radio, deep_dive, standings...
    // Let's verify initial positions relative to each other
    final initialList = service.rawItems;
    final breakingNewsIndex = initialList.indexOf('breaking_news');
    final radioIndex = initialList.indexOf('radio');
    
    expect(breakingNewsIndex, isNotNull);
    expect(radioIndex, isNotNull);
    
    // Move 'breaking_news' to after 'radio'
    service.moveApp(breakingNewsIndex, radioIndex);
    
    final newList = service.rawItems;
    expect(newList[radioIndex], 'breaking_news'); // It should now be at the old radio position
    // Note: List reordering shifting might make precise index verification tricky without helper
    // but effectively we moved item at index 0 to index 1.
  });
  
  test('Move app to start', () async {
    final service = InstalledAppsService();
    service.resetDefaults();
    
    // Assume 'radio' is not at 0
    final radioIndex = service.rawItems.indexOf('radio');
    expect(radioIndex, greaterThan(0));
    
    service.moveApp(radioIndex, 0);
    
    expect(service.getItemAt(0), 'radio');
  });
}