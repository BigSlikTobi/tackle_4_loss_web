import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tackle4loss_mobile/core/services/new_content_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    // Set up mock SharedPreferences
    SharedPreferences.setMockInitialValues({});
  });

  group('NewContentService', () {
    test('hasNewDeepDive returns false when no latest article is set',
        () async {
      final service = NewContentService.testing();
      expect(service.hasNewDeepDive, isFalse);
    });

    test(
        'hasNewDeepDive returns true when new article ID differs from last seen',
        () async {
      SharedPreferences.setMockInitialValues({
        'last_seen_deep_dive_id': 'old-article-id',
      });

      final service = NewContentService.testing();
      await service.init();

      service.setLatestDeepDiveId('new-article-id');
      expect(service.hasNewDeepDive, isTrue);
    });

    test('hasNewDeepDive returns false after marking as seen', () async {
      SharedPreferences.setMockInitialValues({});

      final service = NewContentService.testing();
      await service.init();

      service.setLatestDeepDiveId('article-123');
      expect(service.hasNewDeepDive, isTrue);

      await service.markDeepDiveSeen('article-123');
      expect(service.hasNewDeepDive, isFalse);
    });

    test('markDeepDiveSeen persists to SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({});

      final service = NewContentService.testing();
      await service.init();

      await service.markDeepDiveSeen('persist-test-id');

      final prefs = await SharedPreferences.getInstance();
      expect(
          prefs.getString('last_seen_deep_dive_id'), equals('persist-test-id'));
    });

    test('markAppHubSeen persists app count', () async {
      SharedPreferences.setMockInitialValues({});

      final service = NewContentService.testing();
      await service.init();

      await service.markAppHubSeen();

      final prefs = await SharedPreferences.getInstance();
      // Without registered apps, count should be 0
      expect(prefs.getInt('last_seen_app_count'), equals(0));
    });

    test('reset clears all state', () async {
      SharedPreferences.setMockInitialValues({
        'last_seen_deep_dive_id': 'some-id',
        'last_seen_app_count': 5,
      });

      final service = NewContentService.testing();
      await service.init();
      service.setLatestDeepDiveId('some-id');
      expect(service.hasNewDeepDive, isFalse);

      await service.reset();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('last_seen_deep_dive_id'), isNull);
      expect(prefs.getInt('last_seen_app_count'), isNull);
    });
  });
}
