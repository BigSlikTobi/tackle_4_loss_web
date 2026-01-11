import 'package:flutter/material.dart';
import '../../core/micro_app.dart';
import '../../core/app_category.dart';
import 'views/game_report_screen.dart';

/// The Game Reports micro app.
/// Generates AI-powered post-game recaps using local FunctionGemma inference.
class GameReportsApp extends MicroApp {
  @override
  String get id => 'game_reports';

  @override
  String get name => 'Game Reports';

  @override
  String get description => 'AI-powered post-game analysis';

  @override
  AppCategory get category => AppCategory.gameData;

  // showOnHomePage defaults to false (App Hub only)

  @override
  IconData get icon => Icons.article_rounded;

  @override
  String get iconAssetPath => 'lib/micro_apps/game_reports/store_assets/game_reports_icon.png';

  @override
  Color get themeColor => const Color(0xFFFF6B35); // Vibrant orange

  @override
  String get storeImageAsset => 'lib/micro_apps/game_reports/store_assets/game_reports_store.png';

  @override
  String get descriptionAsset => 'lib/micro_apps/game_reports/store_assets/description.md';

  @override
  WidgetBuilder get page => (context) => const GameReportScreen();

  @override
  bool get hasWidget => false; // No home screen widget for MVP

  @override
  Size get widgetSize => const Size(1, 1);

  @override
  WidgetBuilder get widgetBuilder => (context) => const SizedBox.shrink();
}

