import 'package:flutter/material.dart';
import '../../core/micro_app.dart';
import 'views/app_store_screen.dart';

class AppStoreApp implements MicroApp {
  @override
  String get id => 'app_store';

  @override
  String get name => 'App Store';

  @override
  IconData get icon => Icons.storefront;

  @override
  String get iconAssetPath => 'lib/micro_apps/app_store/store_assets/app_store_icon.png';

  @override
  Color get themeColor => Colors.blueAccent;

  @override
  String get storeImageAsset => 'https://images.unsplash.com/photo-1556742049-0cfed4f7a07d?q=80&w=3540&auto=format&fit=crop';

  @override
  String get descriptionAsset => '';

  @override
  WidgetBuilder get page => (context) => const AppStoreScreen();

  @override
  bool get hasWidget => false;

  @override
  Size get widgetSize => const Size(1, 1);

  @override
  WidgetBuilder get widgetBuilder => (context) => const SizedBox();
}
