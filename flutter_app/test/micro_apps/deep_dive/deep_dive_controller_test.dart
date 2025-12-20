import 'package:flutter_test/flutter_test.dart';
import 'package:tackle4loss_mobile/micro_apps/deep_dive/controllers/deep_dive_controller.dart';

void main() {
  group('DeepDiveController', () {
    late DeepDiveController controller;

    setUp(() {
      controller = DeepDiveController();
    });

    test('Initial state is correct', () {
      expect(controller.article, isNull);
      expect(controller.isLoading, isFalse);
      expect(controller.isPlayingAudio, isFalse);
    });

    test('loadLatestArticle fetches data and updates state', () async {
      // Act
      final future = controller.loadLatestArticle();
      
      // Assert Loading (sync)
      expect(controller.isLoading, isTrue);

      // Await completion
      await future;

      // Assert Loaded
      expect(controller.isLoading, isFalse);
      expect(controller.article, isNotNull);
      expect(controller.article!.title, isNotEmpty);
    });

    test('toggleAudio switches playback state', () {
      expect(controller.isPlayingAudio, isFalse);
      
      controller.toggleAudio();
      expect(controller.isPlayingAudio, isTrue);
      
      controller.toggleAudio();
      expect(controller.isPlayingAudio, isFalse);
    });
  });
}
