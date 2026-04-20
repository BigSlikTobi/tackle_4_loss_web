import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tackle4loss_mobile/core/os_shell/controllers/os_shell_controller.dart';

void main() {
  group('OSShellController', () {
    testWidgets(
        'initLoadAll resolves isPageReady without invoking get-latest-deepdive',
        (tester) async {
      late BuildContext capturedContext;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              capturedContext = context;
              return const SizedBox();
            },
          ),
        ),
      );

      final controller = OSShellController(capturedContext);
      expect(controller.isPageReady, isFalse,
          reason: 'controller starts not ready');

      await controller.initLoadAll('en');

      expect(controller.isPageReady, isTrue,
          reason:
              'MVP: ready-gate must resolve immediately without Deep Dive fetch');
      controller.dispose();
    });
  });
}
