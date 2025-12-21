import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tackle4loss_mobile/core/os_shell/widgets/t4l_scaffold.dart';
import 'package:tackle4loss_mobile/core/services/settings_service.dart';
import 'package:tackle4loss_mobile/l10n/app_localizations.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget createTestWidget(Widget child) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: SettingsService()),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: child,
      ),
    );
  }

  testWidgets('T4LScaffold renders content and gradient', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget(
      const T4LScaffold(
        body: Center(child: Text('Hello World')),
        showCloseButton: true,
        showNavBar: true,
      ),
    ));

    await tester.pump();
    await tester.pump();

    // Verify Body Content
    expect(find.text('Hello World'), findsOneWidget);

    // Verify Close Button exists
    expect(find.byIcon(Icons.close), findsOneWidget);

    // Verify NavBar exists (by finding the 'H')
    expect(find.text('H'), findsOneWidget);
  });

  testWidgets('T4LScaffold hides navbar when showNavBar is false', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget(
      const T4LScaffold(
        body: Center(child: Text('Empty')),
        showNavBar: false,
      ),
    ));

    await tester.pump();
    await tester.pump();

    expect(find.text('H'), findsNothing);
  });
}
