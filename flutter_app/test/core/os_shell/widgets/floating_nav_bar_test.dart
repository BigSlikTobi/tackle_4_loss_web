import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tackle4loss_mobile/core/os_shell/widgets/t4l_floating_nav_bar.dart';
import 'package:lucide_icons/lucide_icons.dart';

void main() {
  testWidgets('T4LFloatingNavBar renders all buttons', (WidgetTester tester) async {
    bool homePressed = false;
    bool storePressed = false;
    bool historyPressed = false;
    bool settingsPressed = false;
    bool teamPressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: T4LFloatingNavBar(
            onHome: () => homePressed = true,
            onAppStore: () => storePressed = true,
            onHistory: () => historyPressed = true,
            onSettings: () => settingsPressed = true,
            onTeamLogo: () => teamPressed = true,
          ),
        ),
      ),
    );

    // Verify 'H' text for home
    expect(find.text('H'), findsOneWidget);
    
    // Verify icons
    expect(find.byIcon(LucideIcons.layoutGrid), findsOneWidget);
    expect(find.byIcon(LucideIcons.history), findsOneWidget);
    expect(find.byIcon(LucideIcons.user), findsOneWidget);
    expect(find.byIcon(LucideIcons.trophy), findsOneWidget);

    // Test Taps
    await tester.tap(find.text('H'));
    expect(homePressed, isTrue);

    await tester.tap(find.byIcon(LucideIcons.layoutGrid));
    expect(storePressed, isTrue);

    await tester.tap(find.byIcon(LucideIcons.history));
    expect(historyPressed, isTrue);

    await tester.tap(find.byIcon(LucideIcons.user));
    expect(settingsPressed, isTrue);

    await tester.tap(find.byIcon(LucideIcons.trophy));
    expect(teamPressed, isTrue);
  });
}
