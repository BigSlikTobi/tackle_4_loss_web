import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tackle4loss_mobile/core/onboarding/views/first_launch_flow.dart';
import 'package:tackle4loss_mobile/core/services/settings_service.dart';
import 'package:tackle4loss_mobile/core/theme/t4l_theme.dart';

Widget _wrap(Widget child, SettingsService settings) {
  return ChangeNotifierProvider<SettingsService>.value(
    value: settings,
    child: MaterialApp(
      theme: T4LTheme.light(team: null),
      home: child,
    ),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('FirstLaunchFlow Continue is disabled until a team is picked',
      (tester) async {
    final settings = SettingsService.testing();
    await mockNetworkImagesFor(() async {
      await tester.pumpWidget(_wrap(const FirstLaunchFlow(), settings));
      await tester.pumpAndSettle();
    });

    final continueBtn = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'CONTINUE'),
    );
    expect(continueBtn.onPressed, isNull,
        reason: 'CONTINUE must be disabled before a team is selected');
  });

  testWidgets('FirstLaunchFlow advances to language step after team pick',
      (tester) async {
    final settings = SettingsService.testing();
    await mockNetworkImagesFor(() async {
      await tester.pumpWidget(_wrap(const FirstLaunchFlow(), settings));
      await tester.pumpAndSettle();

      // Tap the first team tile.
      await tester.tap(find.byType(GestureDetector).first);
      await tester.pump();

      await tester.tap(find.widgetWithText(FilledButton, 'CONTINUE'));
      await tester.pumpAndSettle();
    });

    expect(find.text('Confirm your language'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    expect(find.text('Deutsch'), findsOneWidget);
  });

  testWidgets(
      'FirstLaunchFlow GET STARTED persists team, language and onboarding flag',
      (tester) async {
    final settings = SettingsService.testing();
    await mockNetworkImagesFor(() async {
      await tester.pumpWidget(_wrap(const FirstLaunchFlow(), settings));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(GestureDetector).first);
      await tester.pump();
      await tester.tap(find.widgetWithText(FilledButton, 'CONTINUE'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Deutsch'));
      await tester.pump();
      await tester.tap(find.widgetWithText(FilledButton, 'GET STARTED'));
      await tester.pumpAndSettle();
    });

    expect(settings.onboardingComplete, isTrue);
    expect(settings.locale.languageCode, 'de');
    expect(settings.selectedTeam, isNotNull);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('onboarding_complete_v1'), isTrue);
  });

  testWidgets('FirstLaunchFlow blocks system back via PopScope',
      (tester) async {
    final settings = SettingsService.testing();
    await mockNetworkImagesFor(() async {
      await tester.pumpWidget(_wrap(const FirstLaunchFlow(), settings));
      await tester.pumpAndSettle();
    });

    final popScope = tester.widget<PopScope>(find.byType(PopScope));
    expect(popScope.canPop, isFalse,
        reason: 'Onboarding must not be dismissible by system back gesture');
  });
}
