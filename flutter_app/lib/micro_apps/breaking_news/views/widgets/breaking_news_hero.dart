import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/t4l_theme.dart';
import '../../../../core/services/team_logo_service.dart';
import '../../models/breaking_news_article.dart';

class BreakingNewsHero extends StatelessWidget {
  final BreakingNewsArticle article;
  final VoidCallback onTap;

  const BreakingNewsHero({
    super.key,
    required this.article,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<T4LThemeColors>()!;
    final teamId = article.teams?.isNotEmpty == true
        ? article.teams!.first.teamId.toLowerCase()
        : null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        height: 240, // 16:9 ish aspect ratio container
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: colors.surface,
          boxShadow: [
             BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background Image
            if (article.imageUrl != null)
              CachedNetworkImage(
                imageUrl: article.imageUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: colors.textPrimary.withValues(alpha: 0.1),
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  color: colors.textPrimary.withValues(alpha: 0.05),
                  child: const Center(
                    child: Icon(Icons.broken_image, color: Colors.white24),
                  ),
                ),
              ),

            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.3),
                    Colors.black.withValues(alpha: 0.9),
                  ],
                  stops: const [0.4, 0.7, 1.0],
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Meta Row (Breaking Tag + Time)
                  Row(
                    children: [
                      _buildBreakingTag(colors),
                      const SizedBox(width: 8),
                      Text(
                        _formatTime(article.createdAt),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Headline
                  Text(
                    article.headline,
                    style: const TextStyle(
                      fontFamily: 'RussoOne', 
                      color: Colors.white,
                      fontSize: 22,
                      height: 1.2,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 8),

                  // Bottom Meta Row (Source + Team)
                  Row(
                    children: [
                      // Source
                      // Source Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          article.sourceName.toUpperCase(),
                          style: TextStyle(
                            color: colors.brand,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      
                      if (teamId != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          '•',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                        ),
                        const SizedBox(width: 8),
                        // Team Logo
                        Container(
                          width: 22,
                          height: 22,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          padding: const EdgeInsets.all(2),
                          child: ClipOval(
                            child: Image.asset(
                              TeamLogoService.getLogoPath(teamId),
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => const SizedBox(),
                            ),
                          ),
                        ),
                      ],

                      // Player Headshot (if available)
                      if (article.players?.isNotEmpty == true && article.players!.first.headshotUrl != null) ...[
                         const SizedBox(width: 8),
                        Container(
                          width: 22,
                          height: 22,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            backgroundImage: NetworkImage(article.players!.first.headshotUrl!),
                            onBackgroundImageError: (_, __) {},
                            radius: 11,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBreakingTag(T4LThemeColors colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colors.breakingNewsRed,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: colors.breakingNewsRed.withValues(alpha: 0.4),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.flash_on, color: Colors.white, size: 10),
          SizedBox(width: 4),
          Text(
            'BREAKING',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return DateFormat('MMM d').format(date);
    }
  }
}
