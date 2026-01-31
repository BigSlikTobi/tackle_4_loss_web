import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
  
  /// Set of item IDs for efficient de-duplication
  final Set<String> _itemIds = {};
  
  /// Supabase Client to use (injectable for testing)
  final SupabaseClient supabaseClient;
  
  /// Supabase Realtime channel for listening to new news updates
  RealtimeChannel? _realtimeChannel;

  NewsFeedController({
    required this.languageCode,
    SupabaseClient? client,
  }) : supabaseClient = client ?? Supabase.instance.client;

  List<FeedItem> get items => _items;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  String? get error => _error;

  /// Load initial set of news feed items and subscribe to realtime updates
  Future<void> loadInitial() async {
    _offset = 0;
    _items = [];
    _itemIds.clear();
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
    
    _realtimeChannel = supabaseClient
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
    if (newId == null || _itemIds.contains(newId)) {
      return;
    }

    // Construct the item directly from the realtime payload
    // Note: This won't have enriched data (source name, player headshots)
    // but the item will be fully enriched on next refresh
    try {
      final newItem = _createItemFromPayload(newRecord);
      if (newItem != null) {
        _items.insert(0, newItem);
        _itemIds.add(newItem.id);
        _offset += 1; // Adjust offset to account for new item
        notifyListeners();
      }
    } catch (e) {
      // Silently fail - the item will appear on next refresh
      debugPrint('Failed to create item from realtime payload: $e');
    }
  }

  /// Create a NewsFeedItem from the realtime payload
  /// Returns null if the payload cannot be parsed
  NewsFeedItem? _createItemFromPayload(Map<String, dynamic> record) {
    final id = record['id']?.toString();
    final createdAt = record['created_at'] as String?;
    
    if (id == null || createdAt == null) return null;

    // Build the image URL if image_file is present
    String? imageUrl = record['image_file'] as String?;
    if (imageUrl != null && !imageUrl.startsWith('http')) {
      // Construct full URL using dotenv
      final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
      imageUrl = '$supabaseUrl/storage/v1/object/public/content/$imageUrl';
    }

    return NewsFeedItem(
      id: id,
      xPost: record['x_post'] as String? ?? '',
      imageUrl: imageUrl,
      source: null, // Not available in realtime payload, will be enriched on refresh
      headline: record['headline'] as String?,
      players: record['players'] as List<dynamic>?,
      teams: record['teams'] as List<dynamic>?,
      createdAt: DateTime.parse(createdAt),
    );
  }

  /// Unsubscribe from realtime channel
  void _unsubscribeFromRealtime() {
    if (_realtimeChannel != null) {
      supabaseClient.removeChannel(_realtimeChannel!);
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
      final response = await supabaseClient.functions.invoke(
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

      // De-duplicate: only add items we don't already have
      // This handles the race condition where realtime adds an item
      // that's also in the paginated results
      for (final item in newItems) {
        if (!_itemIds.contains(item.id)) {
          _items.add(item);
          _itemIds.add(item.id);
        }
      }

      _hasMore = data['hasMore'] as bool? ?? false;
      _offset += newItems.length; // Advance offset by fetched count, not added count
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

