import 'package:flutter/material.dart';
import '../../micro_app.dart';

class OSShellController {
  final BuildContext context;

  OSShellController(this.context);

  void openApp(MicroApp app) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => app.page(context),
      ),
    );
  }

  void openAppStore() {
    // Navigate to App Store or show modal
    // For now, let's just push the AppStoreScreen if we can find it
    // Actually, AppRegistry has it.
    print("Navigating to App Store...");
  }

  void openHistory() {
    print("Opening History...");
  }

  void openSettings() {
    print("Opening Settings...");
  }

  void openTeamSelector() {
    print("Opening Team Selector...");
  }
}
