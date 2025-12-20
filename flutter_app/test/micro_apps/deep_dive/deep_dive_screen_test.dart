import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tackle4loss_mobile/micro_apps/deep_dive/views/deep_dive_screen.dart';
import 'package:tackle4loss_mobile/core/adk/widgets/t4l_scaffold.dart';
import 'package:tackle4loss_mobile/core/adk/widgets/t4l_hero_header.dart';
import 'package:network_image_mock/network_image_mock.dart';

void main() {
  testWidgets('DeepDiveScreen renders ADK components and content', (WidgetTester tester) async {
    // Wrap in mock network image because screen uses Image.network
    await mockNetworkImagesFor(() async {
      await tester.pumpWidget(const MaterialApp(home: DeepDiveScreen()));

      // 1. Initial Loading State
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // 2. Wait for Mock Load (800ms in controller)
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // 3. Verify ADK Components
      expect(find.byType(T4LScaffold), findsOneWidget);
      expect(find.byType(T4LHeroHeader), findsOneWidget);

      // 4. Verify Content
      expect(find.text('DEEP DIVE'), findsOneWidget);
      expect(find.text('TACTICAL ANALYSIS'), findsOneWidget);
      expect(find.text('Listen to this article'), findsOneWidget);
    });
  });
}
