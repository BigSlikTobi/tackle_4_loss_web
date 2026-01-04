import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/news_feed_item.dart';

/// Controller for managing news feed state and pagination
/// Supports multiple content types via FeedItem base class
class NewsFeedController extends ChangeNotifier {
  final String languageCode;
  final int _pageSize = 20;
  
  List<FeedItem> _items = [];
  bool _isLoading = false;
  bool _hasMore = true;
  String? _error;
  int _offset = 0;

  NewsFeedController({required this.languageCode});

  List<FeedItem> get items => _items;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  String? get error => _error;

  /// Load initial set of news feed items
  Future<void> loadInitial() async {
    _offset = 0;
    _items = [];
    _hasMore = true;
    _error = null;
    await _fetchPage();
  }

  /// Load next page of news feed items
  Future<void> loadMore() async {
    if (_isLoading || !_hasMore) return;
    await _fetchPage();
  }

  Future<void> _fetchPage() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await Supabase.instance.client.functions.invoke(
        'get-news-feed',
        body: {
          'language_code': languageCode,
          'limit': _pageSize,
          'offset': _offset,
        },
      );

      if (response.status != 200) {
        throw Exception('Failed to load news feed');
      }

      final data = response.data as Map<String, dynamic>;
      final List<dynamic> itemsJson = data['items'] as List<dynamic>;
      final newItems = itemsJson
          .map((json) => FeedItem.fromJson(json as Map<String, dynamic>))
          .toList();

      _items.addAll(newItems);
      _hasMore = data['hasMore'] as bool? ?? false;
      _offset += newItems.length;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh the feed from the beginning
  Future<void> refresh() async {
    await loadInitial();
  }
}
