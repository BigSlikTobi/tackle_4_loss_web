import 'package:flutter/material.dart';
import '../../micro_app.dart';

class OSShellController extends ChangeNotifier {
  final BuildContext context;
  bool _isPageReady = false;

  OSShellController(this.context);

  bool get isPageReady => _isPageReady;

  bool _mounted = true;

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  /// Resolve the page-ready signal. Kept as an async hook so future MVP
  /// data sources (e.g. an explicit news feed warm-up) can be awaited
  /// here without changing the call site in OSShellView.
  Future<void> initLoadAll(String languageCode) async {
    if (_mounted) {
      _isPageReady = true;
      notifyListeners();
    }
  }

  void openApp(MicroApp app) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => app.page(context)));
  }

  void openAppStore() {
    debugPrint("Navigating to App Store...");
  }

  void openHistory() {
    debugPrint("Opening History...");
  }

  void openSettings() {
    debugPrint("Opening Settings...");
  }

  void openTeamSelector() {
    debugPrint("Opening Team Selector...");
  }
}
