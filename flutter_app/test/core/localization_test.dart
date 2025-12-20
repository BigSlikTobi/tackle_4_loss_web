import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:tackle4loss_mobile/core/services/settings_service.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:tackle4loss_mobile/l10n/app_localizations.dart';

void main() {
  testWidgets('Localization switches between EN and DE', (WidgetTester tester) async {
    final settings = SettingsService();
    
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: settings,
        child: Consumer<SettingsService>(
          builder: (context, settings, _) {
            return MaterialApp(
              locale: settings.locale,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [Locale('en'), Locale('de')],
              home: Builder(
                builder: (context) => Text(AppLocalizations.of(context)!.navHome),
              ),
            );
          },
        ),
      ),
    );

    // Initial check (Default to EN if test environment is not DE)
    // Note: Test environment default locale is often en_US
    expect(find.text('Home'), findsOneWidget);

    // Switch to DE
    settings.setLocale(const Locale('de'));
    await tester.pumpAndSettle();
    expect(find.text('Startseite'), findsOneWidget);

    // Switch back to EN
    settings.setLocale(const Locale('en'));
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);
  });
}
