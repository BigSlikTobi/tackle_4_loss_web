import 'package:flutter_test/flutter_test.dart';
import 'package:tackle4loss_mobile/core/services/navigation_service.dart';

void main() {
  group('NavigationService Tests', () {
    test('trackAppLaunch updates lastAppId for normal apps', () {
      final service = NavigationService();
      service.trackAppLaunch('deep_dive');
      expect(service.lastAppId, 'deep_dive');
      
      service.trackAppLaunch('breaking_news');
      expect(service.lastAppId, 'breaking_news');
    });

    test('trackAppLaunch does not update lastAppId for system apps', () {
      final service = NavigationService();
      service.trackAppLaunch('deep_dive'); // Set initial
      
      service.trackAppLaunch('app_store');
      expect(service.lastAppId, 'deep_dive'); // Should still be deep_dive
      
      service.trackAppLaunch('settings');
      expect(service.lastAppId, 'deep_dive'); // Should still be deep_dive
    });
  });
}
