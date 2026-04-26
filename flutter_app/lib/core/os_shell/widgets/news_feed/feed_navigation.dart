import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/news_feed_item.dart';
import '../../../services/articles_service.dart';
import '../../../services/settings_service.dart';
import '../../../../micro_apps/breaking_news/models/breaking_news_article.dart';
import '../../../../micro_apps/breaking_news/views/breaking_news_detail_screen.dart';

/// Push the breaking-news detail screen for a feed item. The detail screen
/// fetches the full article from the articles project by ID; the summary
/// supplies the placeholder content (headline, image, team) for the hero
/// while the network request resolves.
///
/// The current app locale is baked into the detail fetcher so the request
/// includes a `language` hint — sibling articles in the new API share a
/// story across language-specific ids (e.g. id 229 = en, 230 = de), and we
/// also forward the locale for any future server-side language fallback.
Future<void> openNewsItemDetail(BuildContext context, NewsFeedItem item) {
  final articles = ArticlesService();
  final languageCode =
      Provider.of<SettingsService>(context, listen: false).locale.languageCode;
  return Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => BreakingNewsDetailScreen(
        summary: _toArticleSummary(item),
        detailFetcher: (id) =>
            articles.fetchArticleDetail(id, language: languageCode),
        relatedFetcher: articles.fetchRelatedStories,
      ),
    ),
  );
}

BreakingNewsArticle _toArticleSummary(NewsFeedItem item) {
  return BreakingNewsArticle(
    id: item.id,
    headline: item.headline ?? item.xPost,
    status: item.status,
    imageUrl: item.imageUrl,
    createdAt: item.createdAt,
    teams: item.teams
        ?.whereType<Map>()
        .map((t) => TeamReference.fromJson(Map<String, dynamic>.from(t)))
        .toList(),
    players: item.players
        ?.whereType<Map>()
        .map((p) => PlayerReference.fromJson(Map<String, dynamic>.from(p)))
        .toList(),
    sourceName: item.source,
  );
}
