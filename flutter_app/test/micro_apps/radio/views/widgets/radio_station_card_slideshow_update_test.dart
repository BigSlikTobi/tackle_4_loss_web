import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:tackle4loss_mobile/core/theme/t4l_theme.dart';
import 'package:tackle4loss_mobile/l10n/app_localizations.dart';
import 'package:tackle4loss_mobile/micro_apps/radio/models/radio_station.dart';
import 'package:tackle4loss_mobile/micro_apps/radio/views/widgets/radio_station_card.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  testWidgets(
      'RadioStationCard does not crash when slideshow images shrink after init',
      (WidgetTester tester) async {
    const key = ValueKey('radio-card');

    final stationWithManyImages = RadioStation(
      id: 's1',
      title: 'Station',
      description: 'Desc',
      imageUrl: 'https://example.com/fallback.png',
      slideshowImages: const [
        'https://example.com/1.png',
        'https://example.com/2.png',
        'https://example.com/3.png',
      ],
      categoryId: 'all',
    );

    final stationWithSingleImage = RadioStation(
      id: 's1',
      title: 'Station',
      description: 'Desc',
      imageUrl: 'https://example.com/fallback.png',
      slideshowImages: const [
        'https://example.com/only.png',
      ],
      categoryId: 'all',
    );

    await mockNetworkImagesFor(() async {
      await tester.pumpWidget(
        MaterialApp(
          theme: T4LTheme.light(),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en')],
          home: Scaffold(
            body: RadioStationCard(
              key: key,
              station: stationWithManyImages,
              onTap: () {},
            ),
          ),
        ),
      );

      // Let the periodic timer tick at least once (period is 4s).
      await tester.pump(const Duration(seconds: 5));

      // Rebuild with a shorter list; previously this could cause RangeError in build.
      await tester.pumpWidget(
        MaterialApp(
          theme: T4LTheme.light(),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en')],
          home: Scaffold(
            body: RadioStationCard(
              key: key,
              station: stationWithSingleImage,
              onTap: () {},
            ),
          ),
        ),
      );

      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(find.byType(RadioStationCard), findsOneWidget);
    });
  });
}
