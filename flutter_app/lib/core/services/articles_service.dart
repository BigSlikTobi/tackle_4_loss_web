import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/news_feed_item.dart';
import '../../micro_apps/breaking_news/models/breaking_news_article.dart';

/// Cursor returned by `get-articles` for keyset pagination.
class ArticlesCursor {
  final String createdAt;
  final int id;

  const ArticlesCursor({required this.createdAt, required this.id});

  Map<String, dynamic> toJson() => {'created_at': createdAt, 'id': id};
}

class ArticlesPage {
  final List<NewsFeedItem> items;
  final ArticlesCursor? nextCursor;

  const ArticlesPage({required this.items, this.nextCursor});
}

/// Service for the dedicated "articles" Supabase project that owns the
/// `get-articles` (home feed) and `get-article-detail` edge functions.
///
/// This project is separate from the main app project (auth, standings,
/// realtime, etc.), so the service holds its own [SupabaseClient] keyed by
/// the `ARTICLES_SUPABASE_URL` / `ARTICLES_SUPABASE_ANON_KEY` env entries.
class ArticlesService {
  final SupabaseClient _client;

  ArticlesService({SupabaseClient? client})
      : _client = client ?? _defaultClient();

  static SupabaseClient _defaultClient() {
    final url = dotenv.env['ARTICLES_SUPABASE_URL'];
    final key = dotenv.env['ARTICLES_SUPABASE_ANON_KEY'];
    if (url == null || url.isEmpty || key == null || key.isEmpty) {
      throw StateError(
        'Missing ARTICLES_SUPABASE_URL / ARTICLES_SUPABASE_ANON_KEY in .env',
      );
    }
    return SupabaseClient(url, key);
  }

  /// Map app-internal language code (`en`, `de`) to the API's full BCP-47 tag.
  static String mapLanguage(String code) {
    switch (code.toLowerCase()) {
      case 'de':
        return 'de-DE';
      case 'en':
      default:
        return 'en-US';
    }
  }

  Future<ArticlesPage> fetchArticles({
    required String language,
    int limit = 20,
    ArticlesCursor? cursor,
  }) async {
    final body = <String, dynamic>{
      'limit': limit,
      'language': mapLanguage(language),
    };
    if (cursor != null) body['cursor'] = cursor.toJson();

    final response = await _client.functions.invoke(
      'get-articles',
      body: body,
    );
    if (response.status != 200) {
      throw Exception('get-articles failed: HTTP ${response.status}');
    }

    final data = response.data as Map<String, dynamic>;
    final items = (data['items'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map((m) => _itemFromList(Map<String, dynamic>.from(m)))
        .toList();
    final next = data['next_cursor'];
    final nextCursor = (next is Map)
        ? ArticlesCursor(
            createdAt: next['created_at'] as String,
            id: (next['id'] as num).toInt(),
          )
        : null;
    return ArticlesPage(items: items, nextCursor: nextCursor);
  }

  Future<BreakingNewsArticle> fetchArticleDetail(
    String id, {
    String? language,
  }) async {
    final intId = int.tryParse(id);
    if (intId == null) {
      throw ArgumentError('Article id must be numeric: $id');
    }
    final body = <String, dynamic>{'id': intId};
    if (language != null && language.isNotEmpty) {
      body['language'] = mapLanguage(language);
    }
    final response = await _client.functions.invoke(
      'get-article-detail',
      body: body,
    );
    if (response.status != 200) {
      throw Exception('get-article-detail failed: HTTP ${response.status}');
    }
    return _articleFromDetail(response.data as Map<String, dynamic>);
  }

  /// Related stories aren't exposed by the new project; surface an empty list
  /// so the detail screen renders cleanly without that section.
  Future<List<RelatedStory>> fetchRelatedStories(
    String id, {
    String languageCode = 'en',
  }) async {
    return const [];
  }

  // ─── Mapping ──────────────────────────────────────────────────────────

  static NewsFeedItem _itemFromList(Map<String, dynamic> json) {
    final id = json['id'].toString();
    final team = (json['team'] as String?)?.toLowerCase();
    final teams = team != null && team.isNotEmpty
        ? [
            {'team_id': team}
          ]
        : null;
    return NewsFeedItem(
      id: id,
      headline: json['headline'] as String?,
      xPost: (json['introduction'] as String?) ?? '',
      imageUrl: json['image'] as String?,
      source: json['author'] as String?,
      teams: teams,
      players: null,
      status: null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  static BreakingNewsArticle _articleFromDetail(Map<String, dynamic> json) {
    final id = json['id'].toString();
    final team = (json['team'] as String?)?.toLowerCase();
    final teams =
        team != null && team.isNotEmpty ? [TeamReference(teamId: team)] : null;

    final mentioned = (json['mentioned_players'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map((m) => PlayerReference(
              headshotUrl: m['headshot'] as String?,
              name: m['display_name'] as String?,
              id: m['player_id']?.toString(),
            ))
        .toList();

    final sources =
        (json['sources'] as List<dynamic>? ?? const []).whereType<Map>();
    final firstSource = sources.isEmpty ? null : sources.first;

    return BreakingNewsArticle(
      id: id,
      headline: json['headline'] as String? ?? '',
      status: null,
      subHeader: json['sub_headline'] as String?,
      introductionParagraph: json['introduction'] as String?,
      content: json['content'] as String?,
      imageUrl: json['image'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      teams: teams,
      players: mentioned.isEmpty ? null : mentioned,
      sourceUrl: firstSource?['url'] as String?,
      sourceName: firstSource?['name'] as String?,
      author: json['author'] as String?,
    );
  }
}
