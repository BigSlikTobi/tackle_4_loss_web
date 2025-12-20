import 'package:flutter/material.dart';
import '../../core/micro_app.dart';
import 'views/breaking_news_list_screen.dart';

class BreakingNewsApp implements MicroApp {
  @override
  String get id => 'breaking_news';

  @override
  String get name => 'Breaking News';

  @override
  IconData get icon => Icons.flash_on_rounded;

  @override
  String get iconAssetPath => 'lib/micro_apps/breaking_news/store_assets/breaking_news_icon.png';

  @override
  Color get themeColor => const Color(0xFFD32F2F); // Red
  
  @override
  String get storeImageAsset => 'https://images.unsplash.com/photo-1504711434969-e33886168f5c?q=80&w=3540&auto=format&fit=crop';

  @override
  String get descriptionAsset => ''; // To be implemented

  @override
  WidgetBuilder get page => (context) => const BreakingNewsListScreen();
}
