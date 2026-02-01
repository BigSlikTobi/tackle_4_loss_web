import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:tackle4loss_mobile/core/services/settings_service.dart';
import 'package:tackle4loss_mobile/core/services/new_content_service.dart';
import 'package:tackle4loss_mobile/core/theme/t4l_theme.dart';
import 'package:tackle4loss_mobile/core/widgets/notification_badge.dart';
import 'package:tackle4loss_mobile/micro_apps/deep_dive/controllers/deep_dive_controller.dart';
import 'package:tackle4loss_mobile/micro_apps/deep_dive/views/deep_dive_screen.dart';

class DeepDiveHomeWidget extends StatefulWidget {
  const DeepDiveHomeWidget({super.key});

  @override
  State<DeepDiveHomeWidget> createState() => _DeepDiveHomeWidgetState();
}

class _DeepDiveHomeWidgetState extends State<DeepDiveHomeWidget> {
  final DeepDiveController _controller = DeepDiveController();
  VideoPlayerController? _videoController;
  bool _isInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      final settings = Provider.of<SettingsService>(context);
      _controller.loadLatestArticle(settings.locale.languageCode).then((_) {
        // Track latest deep dive for badge
        if (_controller.latestArticle != null) {
          NewContentService()
              .setLatestDeepDiveId(_controller.latestArticle!.id);
        }
        _initializeVideo();
      });
      _isInit = true;
    }
  }

  void _initializeVideo() async {
    final article = _controller.latestArticle;
    if (article?.videoUrl != null) {
      _videoController =
          VideoPlayerController.networkUrl(Uri.parse(article!.videoUrl!))
            ..setLooping(true)
            ..setVolume(0.0) // Mute by default for widget
            ..initialize().then((_) {
              if (mounted) {
                setState(() {});
                _videoController!.play();
              }
            });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Consumer<DeepDiveController>(
        builder: (context, controller, child) {
          final article = controller.latestArticle;
          final colors = Theme.of(context).extension<T4LThemeColors>()!;

          if (controller.isLoading) {
            return Container(
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Center(child: CircularProgressIndicator()),
            );
          }

          if (article == null) {
            return Container(
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Center(
                child:
                    Icon(Icons.article_outlined, color: colors.textSecondary),
              ),
            );
          }

          return GestureDetector(
            onTap: () {
              // Mark deep dive as seen when tapped
              NewContentService().markDeepDiveSeen(article.id);
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => DeepDiveScreen(article: article),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                color: colors.surface,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // 1. Media Layer (Video or Image)
                    if (_videoController != null &&
                        _videoController!.value.isInitialized)
                      FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          width: _videoController!.value.size.width,
                          height: _videoController!.value.size.height,
                          child: VideoPlayer(_videoController!),
                        ),
                      )
                    else
                      CachedNetworkImage(
                        imageUrl: article.imageUrl,
                        fit: BoxFit.cover,
                      ),

                    // 2. Gradient Overlay for Text Readability
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.7),
                          ],
                          stops: const [0.6, 1.0],
                        ),
                      ),
                    ),

                    // 3. Text Content
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: colors.brand,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'DEEP DIVE',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            article.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    // 4. New Content Badge
                    ListenableBuilder(
                      listenable: NewContentService(),
                      builder: (context, child) {
                        return Positioned(
                          top: 12,
                          right: 12,
                          child: NotificationBadge(
                            show: NewContentService().hasNewDeepDive,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
