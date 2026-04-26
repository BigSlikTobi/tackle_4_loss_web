import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../models/news_feed_item.dart';
import '../../services/articles_service.dart';

/// Controller for the home-screen news feed, backed by the dedicated
/// "articles" Supabase project (`get-articles` edge function with cursor
/// pagination).
class NewsFeedController extends ChangeNotifier {
  final String languageCode;
  final int _pageSize = 20;
  final ArticlesService _articlesService;

  List<FeedItem> _items = [];
  bool _isLoading = false;
  bool _hasMore = true;
  String? _error;
  ArticlesCursor? _cursor;

  /// Set of item IDs for efficient de-duplication
  final Set<String> _itemIds = {};

  NewsFeedController({
    required this.languageCode,
    ArticlesService? articlesService,
  }) : _articlesService = articlesService ?? ArticlesService();

  List<FeedItem> get items => _items;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  String? get error => _error;

  /// Load the first page of articles.
  Future<void> loadInitial() async {
    _items = [];
    _itemIds.clear();
    _cursor = null;
    _hasMore = true;
    _error = null;
    await _fetchPage();
  }

  /// Load next page of articles.
  Future<void> loadMore() async {
    if (_isLoading || !_hasMore) return;
    await _fetchPage();
  }

  Future<void> _fetchPage() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final page = await _articlesService.fetchArticles(
        language: languageCode,
        limit: _pageSize,
        cursor: _cursor,
      );

      for (final item in page.items) {
        if (!_itemIds.contains(item.id)) {
          _items.add(item);
          _itemIds.add(item.id);
        }
      }

      _cursor = page.nextCursor;
      _hasMore = page.nextCursor != null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await loadInitial();
  }
}
