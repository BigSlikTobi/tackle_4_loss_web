import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tackle4loss_mobile/core/services/installed_apps_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  // Re-adding previous passing tests to ensure comprehensive run
  test('Grid initializes with 20 empty slots (or defaults)', () async {
    final service = InstalledAppsService();
    service.resetDefaults();
    expect(service.getItemAt(0), 'breaking_news|widget');
    expect(service.isOccupySlot(1), true);
  });

  test('Install 1x1 App finds first empty slot', () async {
    final service = InstalledAppsService();
    service.resetDefaults(); 
    // Default Empty slots: 3, 7, 8, ...
    
    service.install('new_app_1');
    expect(service.getItemAt(3), 'new_app_1');
  });

  test('Uninstall 1x1 App clears slot', () async {
    final service = InstalledAppsService();
    service.resetDefaults();
    
    // Settings is at 2
    expect(service.getItemAt(2), 'settings');
    
    service.uninstall('settings');
    expect(service.isEmpty(2), true);
  });

  test('Uninstall 2x2 Widget clears all 4 slots', () async {
    final service = InstalledAppsService();
    service.resetDefaults();
    
    // Breaking News Widget at 0 (occupies 1, 4, 5)
    expect(service.getItemAt(0), 'breaking_news|widget');
    service.uninstall('breaking_news');
    
    expect(service.isEmpty(0), true);
    expect(service.isEmpty(1), true);
    expect(service.isEmpty(4), true);
    expect(service.isEmpty(5), true);
  });

  test('Move 1x1 App to Empty Slot (Swap)', () async {
    final service = InstalledAppsService();
    service.resetDefaults();
    
    // Move Settings (2) to Empty (3)
    service.moveApp(2, 3);
    
    expect(service.getItemAt(3), 'settings');
    expect(service.isEmpty(2), true);
  });

  test('Move 1x1 App to Occupied 1x1 (Swap)', () async {
    final service = InstalledAppsService();
    service.resetDefaults();
    
    // Install 'A' at 3
    service.install('A'); 
    
    // Move Settings (2) to 'A' (3)
    service.moveApp(2, 3);
    
    expect(service.getItemAt(3), 'settings');
    expect(service.getItemAt(2), 'A');
  });

  test('Move 2x2 Widget to valid space', () async {
    final service = InstalledAppsService();
    service.resetDefaults();
    
    // We need 2x2 at index 8 (8,9, 12,13)
    // By default these are empty.
    
    service.moveApp(0, 8);
    
    // Old slots cleared
    expect(service.isEmpty(0), true);
    expect(service.isEmpty(1), true);
    
    // New slots occupied
    expect(service.getItemAt(8), 'breaking_news|widget');
    expect(service.isOccupySlot(9), true);
    expect(service.isOccupySlot(12), true);
    expect(service.isOccupySlot(13), true);
  });

  test('Move 2x2 Widget displaces items if space blocked', () {
      final service = InstalledAppsService();
      service.resetDefaults();
      
      // Install 'A', 'B', 'C'.
      // A -> 3
      // B -> 7
      // C -> 8
      
      service.install('A'); // 2
      service.install('B'); // 3
      service.install('C'); // 6
      service.install('D'); // 7 
      // Wait, let's just FORCE D to be at 8 to be sure.
      service.moveApp(_findAppIndex(service, 'D'), 8);

      // Expect D at 8.
      expect(service.getItemAt(8), 'D');
      
      // Try move widget from 0 to 8. 
      // BEFORE: Should fail.
      // AFTER: Should succeed and SWAP D to 0.
      service.moveApp(0, 8);
      
      // Widget should be at 8
      expect(service.getItemAt(8), 'breaking_news|widget');
      
      // D should be displaced to Source (0)
      expect(service.getItemAt(0), 'D');
  });
}

int _findAppIndex(InstalledAppsService service, String appId) {
  for (int i=0; i<20; i++) {
    if (service.getItemAt(i) == appId) return i;
  }
  return -1;
}
