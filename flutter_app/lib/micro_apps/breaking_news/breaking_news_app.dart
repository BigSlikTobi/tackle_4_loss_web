import 'package:flutter/material.dart';
import '../../core/micro_app.dart';
import '../../core/app_category.dart';
import 'views/breaking_news_list_screen.dart';
import 'views/widgets/breaking_news_widget.dart';

class BreakingNewsApp implements MicroApp {
  @override
  String get id => 'breaking_news';

  @override
  String get name => 'Breaking News';

  @override
  String get description => 'Real-time NFL news and updates';

  @override
  AppCategory get category => AppCategory.news;

  @override
  bool get showOnHomePage => true;

  @override
  IconData get icon => Icons.flash_on_rounded;

  @override
  String get iconAssetPath => 'lib/micro_apps/breaking_news/store_assets/breaking_news_icon.png';

  @override
  String? get iconDarkAssetPath => 'lib/micro_apps/breaking_news/store_assets/news_breaking_dark.svg';

  @override
  String? get iconLightAssetPath => 'lib/micro_apps/breaking_news/store_assets/breaking_news_lite.svg';

  @override
  Color get themeColor => const Color(0xFFD32F2F); // Red
  
  @override
  String get storeImageAsset => 'https://images.unsplash.com/photo-1504711434969-e33886168f5c?q=80&w=3540&auto=format&fit=crop';

  @override
  String get descriptionAsset => ''; // To be implemented

  @override
  WidgetBuilder get page => (context) => const BreakingNewsListScreen();
  
  @override
  Widget buildPage(BuildContext context, {Object? arguments}) {
    String? initialArticleId;
    bool autoFlip = false;

    if (arguments is Map<String, dynamic>) {
      initialArticleId = arguments['articleId'] as String?;
      autoFlip = arguments['autoFlip'] as bool? ?? false;
    }

    return BreakingNewsListScreen(
      initialArticleId: initialArticleId,
      autoFlip: autoFlip,
    );
  }

  @override
  bool get hasWidget => false;

  @override
  Size get widgetSize => const Size(2, 2);

  @override
  WidgetBuilder get widgetBuilder => (context) => const BreakingNewsWidget();
}

