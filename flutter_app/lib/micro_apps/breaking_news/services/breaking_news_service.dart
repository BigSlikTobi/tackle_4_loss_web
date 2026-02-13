import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/breaking_news_article.dart';

class BreakingNewsService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<BreakingNewsArticle>> fetchBreakingNews({
    String languageCode = 'en',
  }) async {
    try {
      final response = await _supabase.functions.invoke(
        'get-breaking-news',
        body: {'language_code': languageCode},
      );

      final List<dynamic> data = response.data;
      return data.map((json) => BreakingNewsArticle.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load breaking news: $e');
    }
  }

  Future<BreakingNewsArticle> fetchBreakingNewsDetail(String id) async {
    try {
      final response = await _supabase.functions.invoke(
        'get-breaking-news-detail',
        body: {'id': id},
      );

      return BreakingNewsArticle.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to load breaking news detail: $e');
    }
  }

  /// Fetches stories related to [newsUpdateId] via story groups.
  ///
  /// Returns an empty list when the story has no group membership or
  /// if the request fails.
  Future<List<RelatedStory>> fetchRelatedStories(
    String newsUpdateId, {
    String? languageCode,
  }) async {
    try {
      final body = <String, dynamic>{'news_update_id': newsUpdateId};
      if (languageCode != null) body['language_code'] = languageCode;

      final response = await _supabase.functions.invoke(
        'get-related-stories',
        body: body,
      );

      final List<dynamic> data = response.data ?? [];
      return data
          .map((json) => RelatedStory.fromJson(Map<String, dynamic>.from(json)))
          .toList();
    } catch (_) {
      return [];
    }
  }
}
