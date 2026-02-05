import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../models/news_feed_item.dart';
import '../../../theme/t4l_theme.dart';
import '../../../services/navigation_service.dart';
import '../../../app_registry.dart';
import 'package:tackle4loss_mobile/design_tokens.dart';

/// Deep dive article card for the news feed with distinctive styling
class DeepDiveFeedItemCard extends StatefulWidget {
  final DeepDiveFeedItem item;

  const DeepDiveFeedItemCard({super.key, required this.item});

  @override
  State<DeepDiveFeedItemCard> createState() => _DeepDiveFeedItemCardState();
}

class _DeepDiveFeedItemCardState extends State<DeepDiveFeedItemCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnim = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t4lColors = theme.extension<T4LThemeColors>();

    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: GestureDetector(
          onTap: () {
            final app = AppRegistry().getApp('deep_dive');
            if (app != null) {
              NavigationService().openApp(
                context,
                app,
                arguments: {'articleId': widget.item.articleId},
              );
            }
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              // Gradient border effect using a wrapper
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.accent,
                  AppColors.accent.withValues(alpha: 0.3),
                  Colors.purple.withValues(alpha: 0.5),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.3),
                  blurRadius: 20,
                  spreadRadius: 0,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Container(
              margin: const EdgeInsets.all(2), // Border width
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: t4lColors?.surface ?? const Color(0xFF1A1A1A),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero Image with overlay
                  Stack(
                    children: [
                      if (widget.item.imageUrl != null)
                        CachedNetworkImage(
                          imageUrl: widget.item.imageUrl!,
                          width: double.infinity,
                          height: 220, // Reduced height to prevent stretching
                          fit: BoxFit.cover,
                          memCacheWidth: 800,
                          memCacheHeight: 440,
                          placeholder: (context, url) => Container(
                            height: 220,
                            color: AppColors.accent.withValues(alpha: 0.1),
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            height: 220,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  const Color(0xFF1A1A1A),
                                  AppColors.accent.withValues(alpha: 0.2),
                                ],
                              ),
                            ),
                            child: const Icon(
                              Icons.image_not_supported,
                              color: Colors.white24,
                              size: 48,
                            ),
                          ),
                        )
                      else
                        Container(
                          height: 220,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                const Color(0xFF2A2A2A),
                                AppColors.accent.withValues(alpha: 0.4),
                              ],
                            ),
                          ),
                          child: Icon(
                            Icons.auto_stories,
                            color: Colors.white.withValues(alpha: 0.1),
                            size: 64,
                          ),
                        ),
                      // Gradient overlay - Adjusted for shorter height
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.3),
                                Colors.black.withValues(alpha: 0.85),
                                Colors.black.withValues(alpha: 0.98),
                              ],
                              stops: const [0.1, 0.4, 0.7, 1.0],
                            ),
                          ),
                        ),
                      ),
                      // Deep Dive Badge
                      Positioned(
                        top: 12,
                        left: 12,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.accent.withValues(alpha: 0.9),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.auto_awesome,
                                    size: 14,
                                    color: Colors.black.withValues(alpha: 0.8),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'DEEP DIVE',
                                    style: TextStyle(
                                      color:
                                          Colors.black.withValues(alpha: 0.9),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Content Overlay
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Title
                              Text(
                                widget.item.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  height: 1.2,
                                  letterSpacing: -0.4,
                                  shadows: [
                                    Shadow(
                                      offset: Offset(0, 2),
                                      blurRadius: 4,
                                      color: Colors.black54,
                                    ),
                                  ],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),

                              // Summary
                              Text(
                                widget.item.summary,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  height: 1.3,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 12),

                              // Author and Time Row
                              Row(
                                children: [
                                  // Author icon
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: AppColors.accent,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: Colors.white, width: 1),
                                    ),
                                    child: const Icon(
                                      Icons.person,
                                      size: 14,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Author name
                                  Text(
                                    widget.item.author.toUpperCase(),
                                    style: const TextStyle(
                                      color: AppColors.accent,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Time
                                  Text(
                                    _formatTimeAgo(widget.item.createdAt),
                                    style: TextStyle(
                                      color:
                                          Colors.white.withValues(alpha: 0.7),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const Spacer(),
                                  // Read icon
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.white.withValues(alpha: 0.2),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: Colors.white
                                              .withValues(alpha: 0.3)),
                                    ),
                                    child: const Icon(
                                      Icons.arrow_forward,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime.toLocal());

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return '${dateTime.month}/${dateTime.day}';
    }
  }
}
