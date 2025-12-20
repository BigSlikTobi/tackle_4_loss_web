import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tackle4loss_mobile/core/os_shell/widgets/t4l_scaffold.dart';

void main() {
  testWidgets('T4LScaffold renders content and gradient', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: T4LScaffold(
          body: Center(child: Text('Hello World')),
          showCloseButton: true,
          showNavBar: true,
        ),
      ),
    );

    // Verify Body Content
    expect(find.text('Hello World'), findsOneWidget);

    // Verify Close Button exists
    expect(find.byIcon(Icons.close), findsOneWidget);

    // Verify NavBar exists (by finding the 'H')
    expect(find.text('H'), findsOneWidget);
  });

  testWidgets('T4LScaffold hides navbar when showNavBar is false', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: T4LScaffold(
          body: Center(child: Text('Empty')),
          showNavBar: false,
        ),
      ),
    );

    expect(find.text('H'), findsNothing);
  });
}
