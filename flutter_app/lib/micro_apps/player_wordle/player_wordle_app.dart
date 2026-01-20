import 'package:flutter/material.dart';
import '../../core/micro_app.dart';
import '../../core/app_category.dart';
import 'views/game_mode_picker_screen.dart';

/// The Player Wordle (NFL Guessing Game) micro app.
/// Players guess an NFL player within 8 tries using attribute feedback.
class PlayerWordleApp extends MicroApp {
  @override
  String get id => 'player_wordle';

  @override
  String get name => 'Guess the Player';

  @override
  String get description => 'Guess the mystery NFL player in 8 tries';

  @override
  AppCategory get category => AppCategory.games;

  @override
  bool get showOnHomePage => true;

  @override
  IconData get icon => Icons.sports_football_rounded;

  @override
  String get iconAssetPath =>
      'lib/micro_apps/player_wordle/store_assets/player_wordle_icon.png';

  @override
  String? get iconLightAssetPath =>
      'lib/micro_apps/player_wordle/store_assets/wordle_light.svg';

  @override
  String? get iconDarkAssetPath =>
      'lib/micro_apps/player_wordle/store_assets/wordle_dark.svg';

  @override
  Color get themeColor => const Color(0xFF8B5CF6); // Purple for games

  @override
  String get storeImageAsset =>
      'lib/micro_apps/player_wordle/store_assets/player_wordle_store.png';

  @override
  String get descriptionAsset =>
      'lib/micro_apps/player_wordle/store_assets/description.md';

  @override
  WidgetBuilder get page => (context) => const GameModePickerScreen();

  @override
  bool get hasWidget => false;

  @override
  Size get widgetSize => const Size(1, 1);
}

