import 'package:flutter/material.dart';
import '../../core/micro_app.dart';
import '../../core/app_category.dart';
import 'views/deep_dive_list_screen.dart';

import 'views/widgets/deep_dive_home_widget.dart';

class DeepDiveApp extends MicroApp {
  @override
  String get id => 'deep_dive';

  @override
  String get name => 'Deep Dive';

  @override
  String get description => 'In-depth NFL analysis and long-form articles';

  @override
  AppCategory get category => AppCategory.content;

  // showOnHomePage defaults to false (App Hub only)

  @override
  bool get showOnHomePage => true;

  @override
  IconData get icon => Icons.article_rounded;

  @override
  String get iconAssetPath =>
      'lib/micro_apps/deep_dive/store_assets/deep_dive_icon.png';

  @override
  String? get iconLightAssetPath =>
      'lib/micro_apps/deep_dive/store_assets/deep_dive_lite.svg';

  @override
  String? get iconDarkAssetPath =>
      'lib/micro_apps/deep_dive/store_assets/deep_dive_dark.svg';

  @override
  Color get themeColor => const Color(0xFF0f3d2e); // Brand Green

  @override
  String get storeImageAsset =>
      'lib/micro_apps/deep_dive/store_assets/deep_dives.png';

  @override
  String get descriptionAsset =>
      'lib/micro_apps/deep_dive/store_assets/description.md';

  @override
  WidgetBuilder get page => (context) => const DeepDiveListScreen();

  @override
  bool get hasWidget => true;

  @override
  Size get widgetSize => const Size(2, 2);

  @override
  WidgetBuilder get widgetBuilder => (context) => const DeepDiveHomeWidget();
}
