import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../../models/news_feed_item.dart';
import '../../../services/settings_service.dart';
import '../../../theme/t4l_theme.dart';
import '../../../services/navigation_service.dart';
import '../../../app_registry.dart';

/// Individual news feed item with subtle ambient animations
class NewsFeedItemCard extends StatefulWidget {
  final NewsFeedItem item;
  final String? userTeamId;

  const NewsFeedItemCard({super.key, required this.item, this.userTeamId});

  @override
  State<NewsFeedItemCard> createState() => _NewsFeedItemCardState();
}

class _NewsFeedItemCardState extends State<NewsFeedItemCard>
    with TickerProviderStateMixin {
  late AnimationController _animController;
  late AnimationController _breathingController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // Subtle breathing animation
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat(reverse: true);

    _fadeAnim = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));

    _scaleAnim = Tween<double>(begin: 1.0, end: 1.015).animate(
      CurvedAnimation(
        parent: _breathingController,
        curve: Curves.easeInOutSine,
      ),
    );

    // Start animation on build
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _breathingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t4lColors = theme.extension<T4LThemeColors>();
    final settings = Provider.of<SettingsService>(context);
    final teamColor =
        settings.selectedTeam?.primaryColor ?? t4lColors?.brand ?? Colors.blue;
    final isDarkMode = theme.brightness == Brightness.dark;

    // Check if this item matches the user's team
    final bool isUserTeamMatch =
        widget.userTeamId != null &&
        widget.item.teams != null &&
        widget.item.teams!.any(
          (team) =>
              team['team_id']?.toString().toLowerCase() ==
              widget.userTeamId?.toLowerCase(),
        );

    // Inverted colors for matching team items
    final Color bgColor = isUserTeamMatch
        ? (isDarkMode
              ? Colors.white.withValues(alpha: 0.95)
              : const Color(0xFF1A1A1A))
        : Colors.transparent;
    final Color textPrimary = isUserTeamMatch
        ? (isDarkMode ? Colors.black87 : Colors.white)
        : (t4lColors?.textPrimary ?? Colors.white);
    final Color textMuted = isUserTeamMatch
        ? (isDarkMode ? Colors.black54 : Colors.white70)
        : (t4lColors?.textMuted ?? Colors.grey);
    final Color headlineColor = isUserTeamMatch
        ? (isDarkMode ? teamColor : Colors.white)
        : teamColor.withValues(alpha: 0.95);
    final Color accentColor = isUserTeamMatch
        ? teamColor
        : teamColor.withValues(alpha: 0.7);

    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: ScaleTransition(
          scale: _scaleAnim,
          child: GestureDetector(
            onTap: () {
              final app = AppRegistry().getApp('breaking_news');
              if (app != null) {
                NavigationService().openApp(
                  context,
                  app,
                  arguments: {'articleId': widget.item.id, 'autoFlip': true},
                );
              }
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // The card content
                Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: isUserTeamMatch ? 8 : 0,
                  ),
                  padding: isUserTeamMatch
                      ? const EdgeInsets.all(12)
                      : EdgeInsets.zero,
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: isUserTeamMatch
                        ? BorderRadius.circular(16)
                        : null,
                    border: isUserTeamMatch
                        ? Border.all(
                            color: teamColor.withValues(alpha: 0.5),
                            width: 2,
                          )
                        : null,
                    boxShadow: isUserTeamMatch
                        ? [
                            BoxShadow(
                              color: teamColor.withValues(alpha: 0.3),
                              blurRadius: 12,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Team badge for matching items
                      if (isUserTeamMatch)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: teamColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.star,
                                  size: 12,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'YOUR TEAM',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      // 1. Header Row (Headline + Source + Time)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Team accent bar
                              Container(
                                width: 3,
                                // Allow bar to stretch with text height, min 14
                                constraints: const BoxConstraints(
                                  minHeight: 14,
                                ),
                                decoration: BoxDecoration(
                                  color: accentColor,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 10),

                              // Headline + Source + Time (Multiline)
                              Expanded(
                                child: Text.rich(
                                  TextSpan(
                                    children: [
                                      // Headline
                                      TextSpan(
                                        text: (widget.item.headline ?? 'NEWS')
                                            .toUpperCase(),
                                        style: TextStyle(
                                          color: headlineColor,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.5,
                                          height: 1.3,
                                        ),
                                      ),

                                      // Separator
                                      TextSpan(
                                        text: ' • ',
                                        style: TextStyle(
                                          color: textMuted.withValues(
                                            alpha: 0.4,
                                          ),
                                          fontSize: 13,
                                        ),
                                      ),

                                      // Source (Small)
                                      if (widget.item.source != null) ...[
                                        TextSpan(
                                          text: widget.item.source!
                                              .toUpperCase(),
                                          style: TextStyle(
                                            color: textMuted.withValues(
                                              alpha: 0.8,
                                            ),
                                            fontSize: 11, // Smaller letters
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                        TextSpan(
                                          text: ' • ',
                                          style: TextStyle(
                                            color: textMuted.withValues(
                                              alpha: 0.4,
                                            ),
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],

                                      // Time
                                      TextSpan(
                                        text: _formatTimeAgo(
                                          widget.item.createdAt,
                                        ),
                                        style: TextStyle(
                                          color: textMuted.withValues(
                                            alpha: 0.6,
                                          ),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // 2. Players and Teams Row (Context)
                      if ((widget.item.players != null &&
                              widget.item.players!.isNotEmpty) ||
                          (widget.item.teams != null &&
                              widget.item.teams!.isNotEmpty))
                        Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: Row(
                            children: [
                              // Team Logos (left side)
                              if (widget.item.teams != null &&
                                  widget.item.teams!.isNotEmpty)
                                Row(
                                  children: [
                                    ...widget.item.teams!.take(3).map((team) {
                                      final teamId =
                                          team['team_id']
                                              ?.toString()
                                              .toLowerCase() ??
                                          '';
                                      if (teamId.isEmpty) {
                                        return const SizedBox.shrink();
                                      }

                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          right: 6,
                                        ),
                                        child: Container(
                                          width: 28,
                                          height: 28,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.white,
                                            border: Border.all(
                                              color: teamColor.withValues(
                                                alpha: 0.3,
                                              ),
                                              width: 1,
                                            ),
                                          ),
                                          child: ClipOval(
                                            child: Image.asset(
                                              'assets/logos/teams/$teamId.png',
                                              width: 26,
                                              height: 26,
                                              errorBuilder: (_, __, ___) =>
                                                  Icon(
                                                    Icons.sports_football,
                                                    size: 14,
                                                    color: teamColor.withValues(
                                                      alpha: 0.5,
                                                    ),
                                                  ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                                    const SizedBox(width: 8),
                                  ],
                                ),

                              // Player Headshots (right side, expanding)
                              if (widget.item.players != null &&
                                  widget.item.players!.isNotEmpty)
                                Expanded(
                                  child: SizedBox(
                                    height: 32,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: widget.item.players!.length,
                                      itemBuilder: (context, index) {
                                        final player =
                                            widget.item.players![index];
                                        final headshotUrl =
                                            player['headshot_url'];
                                        if (headshotUrl == null) {
                                          return const SizedBox.shrink();
                                        }

                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            right: 6,
                                          ),
                                          child: Container(
                                            width: 32,
                                            height: 32,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: teamColor.withValues(
                                                  alpha: 0.4,
                                                ),
                                                width: 1.5,
                                              ),
                                            ),
                                            child: ClipOval(
                                              child: CachedNetworkImage(
                                                imageUrl: headshotUrl,
                                                fit: BoxFit.cover,
                                                // Optimization: Small images, aggressive caching
                                                memCacheWidth: 64,
                                                memCacheHeight: 64,
                                                maxWidthDiskCache: 64,
                                                maxHeightDiskCache: 64,
                                                fadeInDuration: const Duration(
                                                  milliseconds: 100,
                                                ),
                                                fadeOutDuration: const Duration(
                                                  milliseconds: 50,
                                                ),
                                                placeholder: (context, url) =>
                                                    Container(
                                                      color: teamColor
                                                          .withValues(
                                                            alpha: 0.1,
                                                          ),
                                                    ),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Icon(
                                                          Icons.person,
                                                          size: 16,
                                                          color:
                                                              t4lColors
                                                                  ?.textMuted ??
                                                              Colors.grey,
                                                        ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),

                      // 3. Image (Between Teams and Body)
                      if (widget.item.imageUrl != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: CachedNetworkImage(
                                imageUrl: widget.item.imageUrl!,
                                width: double.infinity,
                                height: 200,
                                fit: BoxFit.cover,
                                memCacheWidth: 800,
                                memCacheHeight: 400,
                                maxWidthDiskCache: 800,
                                maxHeightDiskCache: 400,
                                fadeInDuration: const Duration(
                                  milliseconds: 150,
                                ),
                                fadeOutDuration: const Duration(
                                  milliseconds: 100,
                                ),
                                placeholder: (context, url) => Container(
                                  height: 200,
                                  color: teamColor.withValues(alpha: 0.08),
                                  child: Center(
                                    child: Icon(
                                      Icons.image_outlined,
                                      size: 32,
                                      color: teamColor.withValues(alpha: 0.2),
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  height: 200,
                                  color: teamColor.withValues(alpha: 0.08),
                                  child: Icon(
                                    Icons.image_not_supported,
                                    color: teamColor.withValues(alpha: 0.3),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                      // 3. Body Text (X Post) - Now after Image
                      Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Text(
                          widget.item.xPost,
                          style: TextStyle(
                            color: textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            height: 1.5,
                            letterSpacing: -0.1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Elegant gradient separator (OUTSIDE the card)
                Container(
                  height: 1,
                  margin: EdgeInsets.only(
                    left: 24,
                    right: 24,
                    top: isUserTeamMatch ? 8 : 0,
                    bottom: 24,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        teamColor.withValues(alpha: 0.2),
                        teamColor.withValues(alpha: 0.2),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.3, 0.7, 1.0],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

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
