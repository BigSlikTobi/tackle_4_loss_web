import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../controllers/news_feed_controller.dart';
import '../../../models/news_feed_item.dart';
import '../../../services/settings_service.dart';
import '../../../theme/t4l_theme.dart';
import 'news_feed_item_card.dart';
import 'video_feed_item_card.dart';
import 'personalized_feed_item_card.dart';
import '../../../widgets/shimmer_skeleton.dart';

/// News feed widget with infinite scroll for the home screen
class NewsFeedWidget extends StatefulWidget {
  const NewsFeedWidget({super.key});

  @override
  State<NewsFeedWidget> createState() => _NewsFeedWidgetState();
}

class _NewsFeedWidgetState extends State<NewsFeedWidget> {
  late NewsFeedController _controller;
  bool _initialized = false;
  String? _currentLanguageCode;


  void _initializeController(SettingsService settings) {
    _controller = NewsFeedController(
      languageCode: settings.locale.languageCode,
    );
    _controller.loadInitial();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final settings = Provider.of<SettingsService>(context);
    final newLanguageCode = settings.locale.languageCode;

    if (!_initialized) {
      // First initialization
      _currentLanguageCode = newLanguageCode;
      _initializeController(settings);
      _initialized = true;
    } else if (_currentLanguageCode != newLanguageCode) {
      // Language changed - reinitialize controller
      _currentLanguageCode = newLanguageCode;
      _controller.dispose();
      _initializeController(settings);
    }
  }

  @override
  void dispose() {
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
    final t4lColors = Theme.of(context).extension<T4LThemeColors>();

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
                      _controller.loadMore();
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
