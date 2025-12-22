import 'package:flutter/material.dart';
import '../../core/micro_app.dart';
import 'views/deep_dive_list_screen.dart';

class DeepDiveApp implements MicroApp {
  @override
  String get id => 'deep_dive';

  @override
  String get name => 'Deep Dive';

  @override
  IconData get icon => Icons.article_rounded;

  @override
  String get iconAssetPath => 'lib/micro_apps/deep_dive/store_assets/deep_dive_icon.png';

  @override
  Color get themeColor => const Color(0xFF0f3d2e); // Brand Green

  @override
  String get storeImageAsset => 'lib/micro_apps/deep_dive/store_assets/deep_dives.png';

  @override
  String get descriptionAsset => 'lib/micro_apps/deep_dive/store_assets/description.md';

  @override
  WidgetBuilder get page => (context) => const DeepDiveListScreen();

  @override
  bool get hasWidget => false;

  @override
  Size get widgetSize => const Size(1, 1);

  @override
  WidgetBuilder get widgetBuilder => (context) => const SizedBox();
}
