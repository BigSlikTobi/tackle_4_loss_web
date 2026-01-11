import 'package:flutter/material.dart';
import '../../core/micro_app.dart';
import '../../core/app_category.dart';
import '../../design_tokens.dart';
import 'views/radio_screen.dart';
import 'views/widgets/radio_home_widget.dart'; // Will be created next

class RadioApp extends MicroApp {
  @override
  String get id => 'radio';

  @override
  String get name => 'Radio';

  @override
  String get description => 'Audio content, podcasts, and briefings';

  @override
  AppCategory get category => AppCategory.content;

  @override
  bool get showOnHomePage => true;

  @override
  IconData get icon => Icons.radio;

  @override
  String get iconAssetPath => 'lib/micro_apps/radio/store_assets/radio_icon.png';

  @override
  Color get themeColor => AppColors.brandBase;

  @override
  String get storeImageAsset => 'lib/micro_apps/radio/store_assets/image.png';

  @override
  String get descriptionAsset => 'lib/micro_apps/radio/store_assets/description.md';

  @override
  WidgetBuilder get page => (context) => const RadioScreen();

  @override
  bool get hasWidget => true;

  @override
  Size get widgetSize => const Size(2, 1); 
  
  @override
  WidgetBuilder get widgetBuilder => (context) => const RadioHomeWidget();
}

