import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/news_feed_item.dart';

/// Controller for managing news feed state and pagination
/// Supports multiple content types via FeedItem base class
/// Subscribes to real-time updates from content.news_updates table
class NewsFeedController extends ChangeNotifier {
  final String languageCode;
  final int _pageSize = 20;
  
  List<FeedItem> _items = [];
  bool _isLoading = false;
  bool _hasMore = true;
  String? _error;
  int _offset = 0;
  
  /// Supabase Realtime channel for listening to new news updates
  RealtimeChannel? _realtimeChannel;

  NewsFeedController({required this.languageCode});

  List<FeedItem> get items => _items;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  String? get error => _error;

  /// Load initial set of news feed items and subscribe to realtime updates
  Future<void> loadInitial() async {
    _offset = 0;
    _items = [];
    _hasMore = true;
    _error = null;
    
    // Subscribe to realtime updates
    _subscribeToRealtimeUpdates();
    
    await _fetchPage();
  }

  /// Subscribe to INSERT events on content.news_updates table
  void _subscribeToRealtimeUpdates() {
    // Remove existing subscription if any
    _unsubscribeFromRealtime();
    
    _realtimeChannel = Supabase.instance.client
        .channel('news-feed-updates')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'content',
          table: 'news_updates',
          callback: (payload) {
            _handleRealtimeInsert(payload.newRecord);
          },
        )
        .subscribe();
  }

  /// Handle a new item inserted via realtime
  void _handleRealtimeInsert(Map<String, dynamic> newRecord) {
    // Check if the new item matches our language filter
    final recordLanguageCode = newRecord['language_code'] as String?;
    if (recordLanguageCode != null && recordLanguageCode != languageCode) {
      return; // Ignore items for other languages
    }

    // Check if we already have this item (avoid duplicates)
    final newId = newRecord['id']?.toString();
    if (newId != null && _items.any((item) => item.id == newId)) {
      return;
    }

    // Fetch the full item details via edge function to get enriched data
    // (source name, player headshots, etc.)
    _fetchAndPrependNewItem(newId);
  }

  /// Fetch a single item and prepend it to the list
  Future<void> _fetchAndPrependNewItem(String? itemId) async {
    if (itemId == null) return;

    try {
      // Fetch just the first item (offset 0, limit 1) to get the newest item
      // This ensures we get the fully enriched data from the edge function
      final response = await Supabase.instance.client.functions.invoke(
        'get-news-feed',
        body: {
          'language_code': languageCode,
          'limit': 1,
          'offset': 0,
        },
      );

      if (response.status != 200) {
        return;
      }

      final data = response.data as Map<String, dynamic>;
      final List<dynamic> itemsJson = data['items'] as List<dynamic>;
      
      if (itemsJson.isNotEmpty) {
        final newItem = FeedItem.fromJson(itemsJson.first as Map<String, dynamic>);
        
        // Check again for duplicates (in case of race conditions)
        if (!_items.any((item) => item.id == newItem.id)) {
          // Prepend the new item to the beginning of the list
          _items.insert(0, newItem);
          _offset += 1; // Adjust offset to account for new item
          notifyListeners();
        }
      }
    } catch (e) {
      // Silently fail - the item will appear on next refresh
      debugPrint('Failed to fetch new realtime item: $e');
    }
  }

  /// Unsubscribe from realtime channel
  void _unsubscribeFromRealtime() {
    if (_realtimeChannel != null) {
      Supabase.instance.client.removeChannel(_realtimeChannel!);
      _realtimeChannel = null;
    }
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

  @override
  void dispose() {
    _unsubscribeFromRealtime();
    super.dispose();
  }
}
