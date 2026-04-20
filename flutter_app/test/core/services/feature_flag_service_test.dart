import 'package:flutter_test/flutter_test.dart';
import 'package:tackle4loss_mobile/core/services/feature_flag_service.dart';

void main() {
  group('FeatureFlagService', () {
    late FeatureFlagService service;

    setUp(() {
      service = FeatureFlagService();
    });

    group('isEnabled', () {
      test('returns true for MVP-enabled apps', () {
        expect(service.isEnabled('breaking_news'), isTrue);
        expect(service.isEnabled('standings'), isTrue);
      });

      test('returns false for apps deferred from MVP', () {
        expect(service.isEnabled('app_hub'), isFalse);
        expect(service.isEnabled('deep_dive'), isFalse);
        expect(service.isEnabled('radio'), isFalse);
        expect(service.isEnabled('game_reports'), isFalse);
        expect(service.isEnabled('player_wordle'), isFalse);
      });

      test('returns false for unknown feature keys', () {
        expect(service.isEnabled('unknown_app'), isFalse);
        expect(service.isEnabled(''), isFalse);
        expect(service.isEnabled('some_random_key'), isFalse);
      });
    });

    group('singleton behavior', () {
      test('returns same instance', () {
        final instance1 = FeatureFlagService();
        final instance2 = FeatureFlagService();
        expect(identical(instance1, instance2), isTrue);
      });
    });
  });
}
