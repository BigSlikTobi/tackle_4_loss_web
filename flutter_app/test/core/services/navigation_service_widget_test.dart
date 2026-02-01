import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tackle4loss_mobile/core/app_category.dart';
import 'package:tackle4loss_mobile/core/app_registry.dart';
import 'package:tackle4loss_mobile/core/micro_app.dart';
import 'package:tackle4loss_mobile/core/services/navigation_service.dart';

// Mock MicroApp for standings (Game Center)
class MockStandingsApp extends MicroApp {
  @override
  String get id => 'standings';
  @override
  String get name => 'Game Center';
  @override
  AppCategory get category => AppCategory.gameData;
  @override
  WidgetBuilder get page => (context) => Scaffold(
        appBar: AppBar(title: const Text('Game Center')),
        body: const Text('Game Center Screen'),
      );

  // Implement other required overrides with dummies
  @override
  String get description => '';
  @override
  bool get showOnHomePage => true;
  @override
  IconData get icon => Icons.sports;
  @override
  String get iconAssetPath => '';
  @override
  Color get themeColor => Colors.blue;
  @override
  String get storeImageAsset => '';
  @override
  String get descriptionAsset => '';
  @override
  bool get hasWidget => false;
  @override
  Size get widgetSize => Size.zero;
  @override
  WidgetBuilder get widgetBuilder => (context) => Container();
}

void main() {
  setUp(() {
    AppRegistry().clear();
    NavigationService().reset();
  });

  tearDown(() {
    AppRegistry().clear();
    NavigationService().reset();
  });

  testWidgets('NavigationService openGameCenter prevents multiple opens',
      (WidgetTester tester) async {
    // Setup
    AppRegistry().register(MockStandingsApp());
    final navService = NavigationService(); // Singleton

    // Build a simple app with a button that calls openGameCenter
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: ElevatedButton(
                onPressed: () => navService.openGameCenter(context),
                child: const Text('Open Game Center'),
              ),
            );
          },
        ),
      ),
    );

    // Initial state
    expect(find.text('Game Center Screen'), findsNothing);

    // Tap once
    await tester.tap(find.text('Open Game Center'));
    await tester.pump(); // Start animation
    await tester.pump(const Duration(milliseconds: 100)); // Processing

    // Verify it opened (partially or fully)
    expect(find.text('Game Center Screen'), findsOneWidget);

    // Tap again IMMEDIATELY (simulate rapid click or double click logic if possible)
    await tester.tap(find.text('Open Game Center'), warnIfMissed: false);
    await tester.pump();

    // Close the Game Center
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    expect(find.text('Game Center Screen'), findsNothing);

    // Open again
    await tester.tap(find.text('Open Game Center'));
    await tester.pumpAndSettle();
    expect(find.text('Game Center Screen'), findsOneWidget);
  });

  testWidgets('NavigationService openSettings prevents multiple dialogs',
      (WidgetTester tester) async {
    final navService = NavigationService();

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: ElevatedButton(
                onPressed: () => navService.openSettings(
                  context,
                  (context) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Settings Dialog'),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close Settings'),
                      )
                    ],
                  ),
                ),
                child: const Text('Open Settings'),
              ),
            );
          },
        ),
      ),
    );

    // Tap once
    await tester.tap(find.text('Open Settings'));
    await tester.pump();
    expect(find.text('Settings Dialog'), findsOneWidget);

    // Tap again
    await tester.tap(find.text('Open Settings'), warnIfMissed: false);
    await tester.pump();

    // Should still be one dialog
    expect(find.text('Settings Dialog'), findsOneWidget);

    // Close dialog using button
    await tester.tap(find.text('Close Settings'));
    await tester.pumpAndSettle();

    expect(find.text('Settings Dialog'), findsNothing);
  });
}
