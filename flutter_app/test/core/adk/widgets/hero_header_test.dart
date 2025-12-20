import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:tackle4loss_mobile/core/adk/widgets/t4l_hero_header.dart';
import 'package:tackle4loss_mobile/design_tokens.dart';

void main() {
  testWidgets('T4LHeroHeader renders title and image', (WidgetTester tester) async {
    const testTitle = 'Test Header';
    const testImage = 'https://example.com/image.png';

    await mockNetworkImagesFor(() async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                T4LHeroHeader(
                  title: testTitle,
                  imageUrl: testImage,
                ),
              ],
            ),
          ),
        ),
      );

      // Verify Title (Upper Case)
      expect(find.text(testTitle.toUpperCase()), findsOneWidget);

      // Verify FlexibleSpaceBar exists
      expect(find.byType(FlexibleSpaceBar), findsOneWidget);
    });
  });

  testWidgets('T4LHeroHeader respects expandedHeight', (WidgetTester tester) async {
    const double customHeight = 250.0;

    await mockNetworkImagesFor(() async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                T4LHeroHeader(
                  title: 'Short',
                  imageUrl: 'https://example.com/img.png',
                  expandedHeight: customHeight,
                ),
              ],
            ),
          ),
        ),
      );

      final SliverAppBar appBar = tester.widget(find.byType(SliverAppBar));
      expect(appBar.expandedHeight, customHeight);
    });
  });
}
