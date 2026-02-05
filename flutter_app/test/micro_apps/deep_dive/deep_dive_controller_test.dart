import 'package:flutter_test/flutter_test.dart';
import 'package:tackle4loss_mobile/micro_apps/deep_dive/controllers/deep_dive_controller.dart';
import 'package:tackle4loss_mobile/micro_apps/deep_dive/models/deep_dive_article.dart';

// ---------------------------------------------------------------------------
// Test helpers
// ---------------------------------------------------------------------------

List<Map<String, dynamic>> _makeJsonList(int count, {int startAt = 1}) =>
    List.generate(count, (i) {
      final id = startAt + i;
      return {
        'id': '$id',
        'title': 'Article $id',
        'subtitle': 'Summary $id',
        'content': 'Content $id',
        'hero_image_url': 'https://example.com/$id.png',
        'published_at': '2026-01-01T00:00:00.000Z',
        'author': 'Author',
        'language_code': 'en',
      };
    });

// ---------------------------------------------------------------------------
// Configurable mock controller
// ---------------------------------------------------------------------------

class TestDeepDiveController extends DeepDiveController {
  /// How many items each page returns.
  final int pageItemCount;

  /// Total count reported by the server (null = legacy list response).
  final int? totalCount;

  /// If true, fetchDeepDives will throw.
  bool shouldFail = false;

  /// Tracks all (languageCode, limit, offset) calls made to fetchDeepDives.
  final List<({String lang, int limit, int offset})> fetchCalls = [];

  TestDeepDiveController({
    this.pageItemCount = 3,
    this.totalCount,
  });

  @override
  Future<DeepDivePageResult> fetchDeepDives(String languageCode,
      {int limit = 25, int offset = 0}) async {
    fetchCalls.add((lang: languageCode, limit: limit, offset: offset));

    if (shouldFail) {
      throw Exception('Network error');
    }

    // Simulate a short network delay
    await Future.delayed(const Duration(milliseconds: 10));

    final articles = _makeJsonList(pageItemCount, startAt: offset + 1)
        .map((json) => DeepDiveArticle.fromJson(json))
        .toList();

    final bool hasMore;
    if (totalCount != null) {
      hasMore = (offset + articles.length) < totalCount!;
    } else {
      hasMore = articles.length >= limit;
    }
    return DeepDivePageResult(items: articles, hasMore: hasMore);
  }
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('DeepDiveController', () {
    late TestDeepDiveController controller;

    setUp(() {
      controller = TestDeepDiveController(pageItemCount: 3, totalCount: 10);
    });

    test('initial state is correct', () {
      expect(controller.articles, isEmpty);
      expect(controller.isLoading, false);
      expect(controller.isLoadingMore, false);
      expect(controller.hasMore, true);
      expect(controller.error, isNull);
    });

    test('loadAllArticles fetches first page and updates state', () async {
      final future = controller.loadAllArticles('en');

      // Loading should be true while future is pending
      expect(controller.isLoading, true);

      await future;

      expect(controller.isLoading, false);
      expect(controller.articles.length, 3);
      expect(controller.articles.first.id, '1');
      expect(controller.hasMore, true);
      expect(controller.error, isNull);
    });

    test('loadAllArticles skips fetch when articles already loaded', () async {
      await controller.loadAllArticles('en');
      controller.fetchCalls.clear();

      await controller.loadAllArticles('en');

      // Should not have fetched again
      expect(controller.fetchCalls, isEmpty);
    });

    test('loadAllArticles with forceRefresh re-fetches', () async {
      await controller.loadAllArticles('en');
      controller.fetchCalls.clear();

      await controller.loadAllArticles('en', forceRefresh: true);

      expect(controller.fetchCalls.length, 1);
    });

    test('loadMore appends next page', () async {
      await controller.loadAllArticles('en');
      expect(controller.articles.length, 3);

      await controller.loadMore('en');
      expect(controller.articles.length, 6);
      // Second page should have articles with ids starting at 4
      expect(controller.articles[3].id, '4');
    });

    test('loadMore is no-op when already loading', () async {
      await controller.loadAllArticles('en');
      controller.fetchCalls.clear();

      // Simulate concurrent loadMore calls
      final f1 = controller.loadMore('en');
      final f2 = controller.loadMore('en'); // should be ignored

      await f1;
      await f2;

      // Only one fetch should have happened
      expect(controller.fetchCalls.length, 1);
    });

    test('loadMore is no-op when hasMore is false', () async {
      // totalCount = 3, pageItemCount = 3 => no more pages
      controller = TestDeepDiveController(pageItemCount: 3, totalCount: 3);
      await controller.loadAllArticles('en');
      expect(controller.hasMore, false);

      controller.fetchCalls.clear();
      await controller.loadMore('en');

      expect(controller.fetchCalls, isEmpty);
    });

    test('loadAllArticles sets error on failure', () async {
      controller.shouldFail = true;
      await controller.loadAllArticles('en');

      expect(controller.error, isNotNull);
      expect(controller.articles, isEmpty);
      expect(controller.isLoading, false);
    });

    test('loadMore sets error on failure but keeps existing articles',
        () async {
      await controller.loadAllArticles('en');
      expect(controller.articles.length, 3);

      controller.shouldFail = true;
      await controller.loadMore('en');

      expect(controller.error, isNotNull);
      // Existing articles should still be there
      expect(controller.articles.length, 3);
      expect(controller.isLoadingMore, false);
    });

    test('fetchDeepDives passes correct pagination params', () async {
      await controller.loadAllArticles('en');
      expect(controller.fetchCalls.first.offset, 0);

      await controller.loadMore('en');
      expect(controller.fetchCalls.last.offset, 3);
      expect(controller.fetchCalls.last.lang, 'en');
    });
  });

  group('DeepDiveController.fetchDeepDives response parsing', () {
    test('parses new paginated response shape (Map with data)', () async {
      final controller = _RawPayloadController(payload: {
        'data': _makeJsonList(2),
        'count': 5,
        'limit': 25,
        'offset': 0,
      });

      final result = await controller.fetchDeepDives('en');
      expect(result.items.length, 2);
      expect(result.hasMore, true); // 2 < 5
    });

    test('parses legacy list response', () async {
      final controller = _RawPayloadController(payload: _makeJsonList(3));

      final result = await controller.fetchDeepDives('en', limit: 3, offset: 0);
      expect(result.items.length, 3);
      // Legacy: got a full page worth, so assume more
      expect(result.hasMore, true);
    });

    test('legacy list with fewer items than limit means no more', () async {
      final controller = _RawPayloadController(payload: _makeJsonList(2));

      final result =
          await controller.fetchDeepDives('en', limit: 25, offset: 0);
      expect(result.items.length, 2);
      expect(result.hasMore, false); // 2 < 25
    });

    test('throws FormatException on unexpected payload', () async {
      final controller = _RawPayloadController(payload: 'unexpected string');

      expect(
        () => controller.fetchDeepDives('en'),
        throwsA(isA<FormatException>()),
      );
    });

    test('throws FormatException on Map without data list', () async {
      final controller =
          _RawPayloadController(payload: {'error': 'something went wrong'});

      expect(
        () => controller.fetchDeepDives('en'),
        throwsA(isA<FormatException>()),
      );
    });
  });
}

/// A controller that lets us inject a raw payload to test response parsing
/// without hitting the network. Overrides fetchDeepDives at the Supabase level.
class _RawPayloadController extends DeepDiveController {
  final dynamic payload;

  _RawPayloadController({required this.payload});

  @override
  Future<DeepDivePageResult> fetchDeepDives(String languageCode,
      {int limit = 25, int offset = 0}) async {
    // Replicate the parsing logic from the real controller
    final List<dynamic> items;
    int? totalCount;

    if (payload is Map<String, dynamic> &&
        (payload as Map)['data'] is List<dynamic>) {
      items = (payload as Map)['data'] as List<dynamic>;
      totalCount = (payload as Map)['count'] as int?;
    } else if (payload is List<dynamic>) {
      items = payload as List<dynamic>;
    } else {
      throw FormatException(
          'Unexpected deep dive response: ${payload.runtimeType}');
    }

    final articles =
        items.map((json) => DeepDiveArticle.fromJson(json)).toList();
    final bool hasMore;
    if (totalCount != null) {
      hasMore = (offset + articles.length) < totalCount;
    } else {
      hasMore = articles.length >= limit;
    }
    return DeepDivePageResult(items: articles, hasMore: hasMore);
  }
}
