import 'package:flutter/material.dart';
import '../../core/micro_app.dart';
import '../../core/app_category.dart';
import 'views/standings_screen.dart';
import 'views/widgets/standings_widget.dart';

/// The Standings micro app.
/// Displays NFL game schedules and results organized by week.
class StandingsApp extends MicroApp {
  @override
  String get id => 'standings';

  @override
  String get name => 'Game Center';

  @override
  String get description => 'NFL standings and team rankings';

  @override
  AppCategory get category => AppCategory.gameData;

  @override
  bool get showOnHomePage => true;

  @override
  IconData get icon => Icons.sports_football_rounded;

  @override
  String get iconAssetPath =>
      'lib/micro_apps/standings/store_assets/standings_icon.png';

  @override
  Color get themeColor => const Color(0xFF1E88E5); // Blue

  @override
  String get storeImageAsset =>
      'lib/micro_apps/standings/store_assets/standings_store.png';

  @override
  String get descriptionAsset =>
      'lib/micro_apps/standings/store_assets/description.md';

  @override
  WidgetBuilder get page => (context) => const StandingsScreen();

  @override
  bool get hasWidget => true;

  @override
  Size get widgetSize => const Size(2, 2);

  @override
  WidgetBuilder get widgetBuilder => (context) => const StandingsWidget();
}
