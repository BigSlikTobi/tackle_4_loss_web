import 'package:flutter/material.dart';
import '../../core/micro_app.dart';
import 'views/player_wordle_screen.dart';

/// The Player Wordle (NFL Guessing Game) micro app.
/// Players guess an NFL player within 8 tries using attribute feedback.
class PlayerWordleApp extends MicroApp {
  @override
  String get id => 'player_wordle';

  @override
  String get name => 'Player Wordle';

  @override
  IconData get icon => Icons.sports_football_rounded;

  @override
  String get iconAssetPath =>
      'lib/micro_apps/player_wordle/store_assets/player_wordle_icon.png';

  @override
  Color get themeColor => const Color(0xFF8B5CF6); // Purple for games

  @override
  String get storeImageAsset =>
      'lib/micro_apps/player_wordle/store_assets/player_wordle_store.png';

  @override
  String get descriptionAsset =>
      'lib/micro_apps/player_wordle/store_assets/description.md';

  @override
  WidgetBuilder get page => (context) => const PlayerWordleScreen();

  @override
  bool get hasWidget => false;

  @override
  Size get widgetSize => const Size(1, 1);
}
