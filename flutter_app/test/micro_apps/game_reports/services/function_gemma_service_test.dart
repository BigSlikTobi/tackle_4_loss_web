import 'package:flutter_test/flutter_test.dart';
import 'package:tackle4loss_mobile/micro_apps/game_reports/services/function_gemma_service.dart';

void main() {
  group('FunctionGemmaService', () {
    group('session cleanup', () {
      test('closeChatSession is idempotent and safe to call multiple times',
          () async {
        final service = FunctionGemmaService();

        // Should not throw when called with no active session
        await expectLater(
          service.closeChatSession(),
          completes,
        );

        // Should be safe to call multiple times
        await expectLater(
          service.closeChatSession(),
          completes,
        );
      });

      test('dispose cleans up sessions and resets state', () async {
        final service = FunctionGemmaService();

        // dispose should complete without error even if no model loaded
        await expectLater(
          service.dispose(),
          completes,
        );

        // After dispose, model should not be ready
        expect(service.isModelReady, isFalse);
      });
    });

    group('model state', () {
      test('isModelReady is false initially', () {
        final service = FunctionGemmaService();
        expect(service.isModelReady, isFalse);
      });

      test('generateResponse returns null when model not ready', () async {
        final service = FunctionGemmaService();

        final result = await service.generateResponse('test prompt');

        expect(result, isNull);
      });
    });
  });
}
