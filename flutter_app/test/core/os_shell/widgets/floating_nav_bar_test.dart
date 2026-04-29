import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tackle4loss_mobile/core/os_shell/widgets/t4l_floating_nav_bar.dart';
import 'package:tackle4loss_mobile/core/widgets/notification_badge.dart';

void main() {
  testWidgets('T4LFloatingNavBar renders the 4 MVP buttons',
      (WidgetTester tester) async {
    bool homePressed = false;
    bool gameCenterPressed = false;
    bool settingsPressed = false;
    bool teamPressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: T4LFloatingNavBar(
            onHome: () => homePressed = true,
            onGameCenter: () => gameCenterPressed = true,
            onSettings: () => settingsPressed = true,
            onTeamLogo: () => teamPressed = true,
            homeTooltip: 'Home',
            gameCenterTooltip: 'Game Center',
            settingsTooltip: 'Settings',
          ),
        ),
      ),
    );

    expect(find.byTooltip('Home'), findsOneWidget);
    expect(find.byTooltip('Game Center'), findsOneWidget);
    expect(find.byTooltip('Settings'), findsOneWidget);
    expect(find.byTooltip('History'), findsNothing,
        reason: 'MVP Dock drops the History button.');

    // Center button uses Image, not Icon
    expect(find.byType(Image), findsOneWidget);

    await tester.tap(find.byTooltip('Home'));
    expect(homePressed, isTrue);

    await tester.tap(find.byTooltip('Game Center'));
    expect(gameCenterPressed, isTrue);

    await tester.tap(find.byTooltip('Settings'));
    expect(settingsPressed, isTrue);

    await tester.tap(find.byType(Image));
    expect(teamPressed, isTrue);
  });

  testWidgets('T4LFloatingNavBar shows badge when showGameCenterBadge is true',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: T4LFloatingNavBar(
            onHome: () {},
            onGameCenter: () {},
            onSettings: () {},
            onTeamLogo: () {},
            showGameCenterBadge: true,
          ),
        ),
      ),
    );

    expect(find.byType(NotificationBadge), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('T4LFloatingNavBar hides badge when showGameCenterBadge is false',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: T4LFloatingNavBar(
            onHome: () {},
            onGameCenter: () {},
            onSettings: () {},
            onTeamLogo: () {},
            showGameCenterBadge: false,
          ),
        ),
      ),
    );

    expect(find.text('1'), findsNothing);
  });
}
