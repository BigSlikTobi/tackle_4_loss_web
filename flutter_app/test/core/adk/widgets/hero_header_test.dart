import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:tackle4loss_mobile/core/adk/widgets/t4l_hero_header.dart';

void main() {
  testWidgets('T4LHeroHeader renders title and image',
      (WidgetTester tester) async {
    const testTitle = 'Test Header';
    const testImage = 'https://example.com/image.png';

    await mockNetworkImagesFor(() async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  T4LHeroHeader(
                    title: testTitle,
                    imageUrl: testImage,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Verify Title (Upper Case)
      expect(find.text(testTitle.toUpperCase()), findsOneWidget);
    });
  });

  testWidgets('T4LHeroHeader respects height', (WidgetTester tester) async {
    const double customHeight = 250.0;

    await mockNetworkImagesFor(() async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                T4LHeroHeader(
                  title: 'Short',
                  imageUrl: 'https://example.com/img.png',
                  height: customHeight,
                ),
              ],
            ),
          ),
        ),
      );

      final SizedBox box = tester.widget(find.byType(SizedBox).first);
      expect(box.height, customHeight);
    });
  });
}
