import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../controllers/news_feed_controller.dart';
import '../../../models/news_feed_item.dart';
import '../../../services/settings_service.dart';
import 'news_feed_item_card.dart';
import 'video_feed_item_card.dart';
import 'personalized_feed_item_card.dart';
import 'deep_dive_feed_item_card.dart';
import '../../../widgets/shimmer_skeleton.dart';

/// News feed widget with infinite scroll for the home screen
class NewsFeedWidget extends StatefulWidget {
  final SupabaseClient? supabaseClient;

  const NewsFeedWidget({super.key, this.supabaseClient});

  @override
  State<NewsFeedWidget> createState() => _NewsFeedWidgetState();
}

class _NewsFeedWidgetState extends State<NewsFeedWidget> {
  late NewsFeedController _controller;
  bool _initialized = false;
  String? _currentLanguageCode;
  ScrollController? _scrollController;
  DateTime? _lastLoadMoreAt;

  static const double _loadMoreThreshold = 320.0;
  static const Duration _loadMoreThrottle = Duration(milliseconds: 600);

  void _initializeController(SettingsService settings) {
    _controller = NewsFeedController(
      languageCode: settings.locale.languageCode,
      client: widget.supabaseClient,
    );
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

  /// Pre-cache images for upcoming feed items to improve perceived loading speed
  void _precacheUpcomingImages(BuildContext context, int currentIndex) {
    const lookAhead = 3;
    for (int i = 1; i <= lookAhead; i++) {
      final nextIndex = currentIndex + i;
      if (nextIndex < _controller.items.length) {
        final item = _controller.items[nextIndex];
        if (item is NewsFeedItem && item.imageUrl != null) {
          precacheImage(
            CachedNetworkImageProvider(
              item.imageUrl!,
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
                      onPressed: () => _controller.refresh(),
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

        return SliverMainAxisGroup(
          slivers: [
            // Team Logo Watermark Section - No Text
            SliverToBoxAdapter(
              child: SizedBox(
                height: 100,
                child: settings.selectedTeam != null
                    ? Center(
                        child: Opacity(
                          opacity: 0.15,
                          child: Image.asset(
                            settings.selectedTeam!.logoUrl,
                            width: 180,
                            height: 180,
                            fit: BoxFit.contain,
                            errorBuilder: (c, e, s) => const SizedBox(),
                          ),
                        ),
                      )
                    : const SizedBox(),
              ),
            ),

            // Feed Items
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index >= _controller.items.length) {
                    // Loading indicator at the end
                    if (_controller.hasMore) {
                      return const NewsFeedItemSkeleton();
                    }
                    return const SizedBox.shrink();
                  }

                  final item = _controller.items[index];

                  // Pre-cache images for upcoming items (look-ahead of 3)
                  _precacheUpcomingImages(context, index);

                  // Handle different feed item types
                  return switch (item) {
                    NewsFeedItem newsItem => NewsFeedItemCard(
                        item: newsItem,
                        userTeamId: userTeamId,
                      ),
                    VideoFeedItem videoItem => VideoFeedItemCard(
                        item: videoItem,
                      ),
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
