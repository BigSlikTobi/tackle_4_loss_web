import '../models/breaking_news_article.dart';

/// Stubbed in MVP slim — the home shell now sources articles from
/// `ArticlesService` (separate Supabase project). The legacy
/// `get-breaking-news`, `get-breaking-news-detail` and `get-related-stories`
/// edge functions no longer exist on the new main project.
///
// TODO(restore-on-revive): wire to ArticlesService or new edge functions.
class BreakingNewsService {
  Future<List<BreakingNewsArticle>> fetchBreakingNews({
    String languageCode = 'en',
  }) async {
    return const [];
  }

  Future<BreakingNewsArticle> fetchBreakingNewsDetail(String id) async {
    throw UnimplementedError(
      'BreakingNewsService.fetchBreakingNewsDetail is disabled in MVP slim.',
    );
  }

  Future<List<RelatedStory>> fetchRelatedStories(
    String newsUpdateId, {
    String? languageCode,
  }) async {
    return const [];
  }
}
