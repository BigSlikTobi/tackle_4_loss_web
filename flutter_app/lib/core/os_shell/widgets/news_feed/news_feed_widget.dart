import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../controllers/news_feed_controller.dart';
import '../../../models/news_feed_item.dart';
import '../../../services/articles_service.dart';
import '../../../services/settings_service.dart';
import 'news_feed_item_card.dart';
import 'video_feed_item_card.dart';
import 'personalized_feed_item_card.dart';
import 'deep_dive_feed_item_card.dart';
import 'breaking_featured_card.dart';
import 'breaking_list_item_card.dart';
import '../../../widgets/shimmer_skeleton.dart';

/// News feed widget with infinite scroll for the home screen
class NewsFeedWidget extends StatefulWidget {
  /// Optional override (used by tests) for the articles backend.
  final ArticlesService? articlesService;

  const NewsFeedWidget({super.key, this.articlesService});

  @override
  State<NewsFeedWidget> createState() => _NewsFeedWidgetState();
}

class _NewsFeedWidgetState extends State<NewsFeedWidget> {
  late NewsFeedController _controller;
  bool _initialized = false;
  String? _currentLanguageCode;
  ScrollController? _scrollController;
  DateTime? _lastLoadMoreAt;
  final Set<String> _precachedUrls = {};

  static const double _loadMoreThreshold = 320.0;
  static const Duration _loadMoreThrottle = Duration(milliseconds: 600);

  void _initializeController(SettingsService settings) {
    _controller = NewsFeedController(
      languageCode: settings.locale.languageCode,
      articlesService: widget.articlesService,
    );
    _precachedUrls.clear();
    _controller.loadInitial();
  }

  void _attachScrollController(ScrollController? controller) {
    if (_scrollController == controller) return;
    _scrollController?.removeListener(_onScroll);
    _scrollController = controller;
    _scrollController?.addListener(_onScroll);
  }

  void _onScroll() {
    final controller = _scrollController;
    if (controller == null || !controller.hasClients) return;
    final position = controller.position;
    if (!position.isScrollingNotifier.value) return;
    if (position.maxScrollExtent - position.pixels <= _loadMoreThreshold) {
      _maybeLoadMore();
    }
  }

  void _maybeLoadMore() {
    if (_controller.isLoading || !_controller.hasMore) return;
    final now = DateTime.now();
    if (_lastLoadMoreAt != null &&
        now.difference(_lastLoadMoreAt!) < _loadMoreThrottle) {
      return;
    }
    _lastLoadMoreAt = now;
    _controller.loadMore();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final settings = Provider.of<SettingsService>(context);
    final newLanguageCode = settings.locale.languageCode;
    final resolvedScrollController =
        Scrollable.maybeOf(context)?.widget.controller ??
            PrimaryScrollController.maybeOf(context);
    _attachScrollController(resolvedScrollController);

    if (!_initialized) {
      // First initialization
      _currentLanguageCode = newLanguageCode;
      _initializeController(settings);
      _initialized = true;
    } else if (_currentLanguageCode != newLanguageCode) {
      // Language changed - reinitialize controller
      _currentLanguageCode = newLanguageCode;
      _lastLoadMoreAt = null;
      _controller.dispose();
      _initializeController(settings);
    }
  }

  @override
  void dispose() {
    _scrollController?.removeListener(_onScroll);
    _controller.dispose();
    super.dispose();
  }

  /// Pre-cache images for upcoming feed items to improve perceived loading speed.
  /// Uses a URL-based set to avoid redundant precache calls across rebuilds,
  /// and remains correct even when list indices shift (e.g. realtime inserts).
  void _precacheUpcomingImages(BuildContext context, int currentIndex) {
    const lookAhead = 3;
    for (int i = 1; i <= lookAhead; i++) {
      final nextIndex = currentIndex + i;
      if (nextIndex < _controller.items.length) {
        final item = _controller.items[nextIndex];
        if (item is NewsFeedItem && item.imageUrl != null) {
          final url = item.imageUrl!;
          if (_precachedUrls.contains(url)) continue;
          _precachedUrls.add(url);
          precacheImage(
            CachedNetworkImageProvider(
              url,
              maxWidth: 800,
              maxHeight: 400,
            ),
            context,
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsService>(context);
    final userTeamId = settings.selectedTeam?.id;

    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        if (_controller.error != null && _controller.items.isEmpty) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load news feed',
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        _precachedUrls.clear();
                        _controller.refresh();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (_controller.items.isEmpty && _controller.isLoading) {
          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => const NewsFeedItemSkeleton(),
              childCount: 3,
            ),
          );
        }

        // Index of the first NewsFeedItem (used as the featured hero card).
        final featuredIndex =
            _controller.items.indexWhere((it) => it is NewsFeedItem);
        final lastIndex = _controller.items.length - 1;

        return SliverMainAxisGroup(
          slivers: [
            const SliverToBoxAdapter(child: SizedBox(height: 8)),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index >= _controller.items.length) {
                    if (_controller.hasMore) {
                      return const NewsFeedItemSkeleton();
                    }
                    return const SizedBox.shrink();
                  }

                  final item = _controller.items[index];
                  _precacheUpcomingImages(context, index);

                  if (item is NewsFeedItem) {
                    if (index == featuredIndex) {
                      return BreakingFeaturedCard(item: item);
                    }
                    return BreakingListItemCard(
                      item: item,
                      isLast: index == lastIndex && !_controller.hasMore,
                    );
                  }

                  // Fallback rendering for other content types (kept for
                  // forward-compat; gated micro-apps don't surface in MVP).
                  return switch (item) {
                    NewsFeedItem newsItem => NewsFeedItemCard(
                        item: newsItem,
                        userTeamId: userTeamId,
                      ),
                    VideoFeedItem videoItem =>
                      VideoFeedItemCard(item: videoItem),
                    PersonalizedFeedItem personalizedItem =>
                      PersonalizedFeedItemCard(item: personalizedItem),
                    DeepDiveFeedItem deepDiveItem =>
                      DeepDiveFeedItemCard(item: deepDiveItem),
                  };
                },
                childCount:
                    _controller.items.length + (_controller.hasMore ? 1 : 0),
              ),
            ),
          ],
        );
      },
    );
  }
}
