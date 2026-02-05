import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/deep_dive_article.dart';

class DeepDiveController extends ChangeNotifier {
  List<DeepDiveArticle> _articles = [];
  DeepDiveArticle? _latestArticle;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _error;
  int _offset = 0;

  static const int _pageSize = 25;

  List<DeepDiveArticle> get articles => _articles;
  DeepDiveArticle? get latestArticle => _latestArticle;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  String? get error => _error;

  Future<void> loadLatestArticle(String languageCode) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await Supabase.instance.client.functions.invoke(
        'get-latest-deepdive',
        body: {'language_code': languageCode},
      );

      final data = response.data as Map<String, dynamic>;
      _latestArticle = DeepDiveArticle.fromJson(data);
    } catch (e) {
      debugPrint('Error fetching latest deep dive: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load the first page of articles, resetting pagination state.
  Future<void> loadAllArticles(String languageCode,
      {bool forceRefresh = false}) async {
    if (_articles.isNotEmpty && !forceRefresh) return;

    _offset = 0;
    _hasMore = true;
    _error = null;
    _isLoading = true;
    notifyListeners();

    try {
      final result =
          await fetchDeepDives(languageCode, limit: _pageSize, offset: 0);
      _articles = result.items;
      _hasMore = result.hasMore;
      _offset = result.items.length;
    } catch (e) {
      debugPrint('Error fetching deep dives: $e');
      _error = e.toString();
      _articles = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load the next page of articles (called from scroll detection).
  Future<void> loadMore(String languageCode) async {
    if (_isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final result =
          await fetchDeepDives(languageCode, limit: _pageSize, offset: _offset);
      _articles.addAll(result.items);
      _hasMore = result.hasMore;
      _offset += result.items.length;
    } catch (e) {
      debugPrint('Error loading more deep dives: $e');
      _error = e.toString();
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  @visibleForTesting
  Future<DeepDivePageResult> fetchDeepDives(String languageCode,
      {int limit = 25, int offset = 0}) async {
    final response = await Supabase.instance.client.functions.invoke(
      'get-all-deepdives',
      body: {
        'language_code': languageCode,
        'limit': limit,
        'offset': offset,
      },
    );

    final payload = response.data;
    final List<dynamic> items;
    int? totalCount;

    if (payload is Map<String, dynamic> && payload['data'] is List<dynamic>) {
      // New paginated response shape: { data, count, limit, offset }
      items = payload['data'] as List<dynamic>;
      totalCount = payload['count'] as int?;
    } else if (payload is List<dynamic>) {
      // Legacy plain-list response (backward compat)
      items = payload;
    } else {
      debugPrint(
          'Unexpected deep dive payload type: ${payload.runtimeType}, value: $payload');
      throw FormatException(
          'Unexpected deep dive response: ${payload.runtimeType}');
    }

    final articles =
        items.map((json) => DeepDiveArticle.fromJson(json)).toList();
    final bool hasMore;
    if (totalCount != null) {
      hasMore = (offset + articles.length) < totalCount;
    } else {
      // Legacy: if we got a full page, assume there might be more
      hasMore = articles.length >= limit;
    }

    return DeepDivePageResult(items: articles, hasMore: hasMore);
  }
}

/// Result of a paginated deep dive fetch.
class DeepDivePageResult {
  final List<DeepDiveArticle> items;
  final bool hasMore;

  const DeepDivePageResult({required this.items, required this.hasMore});
}
