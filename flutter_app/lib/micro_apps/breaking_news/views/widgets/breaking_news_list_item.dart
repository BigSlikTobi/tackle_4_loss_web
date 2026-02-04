import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/t4l_theme.dart';
import '../../../../core/services/team_logo_service.dart';
import '../../models/breaking_news_article.dart';

class BreakingNewsListItem extends StatelessWidget {
  final BreakingNewsArticle article;
  final VoidCallback onTap;

  const BreakingNewsListItem({
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

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 90,
                height: 90,
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: article.imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: article.imageUrl!,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => Icon(
                          Icons.broken_image,
                          color: colors.textSecondary.withValues(alpha: 0.3),
                          size: 32,
                        ),
                      )
                    : Icon(
                        Icons.newspaper,
                        color: colors.textSecondary.withValues(alpha: 0.3),
                        size: 32,
                      ),
              ),
            ),
            const SizedBox(width: 16),

            // Content Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Headline
                  Text(
                    article.headline,
                    style: TextStyle(
                      fontFamily: 'RussoOne',
                      color: colors.textPrimary,
                      fontSize: 16,
                      height: 1.3,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Metadata Row
                  Row(
                    children: [
                       // Team Logo Badge (if available)
                       // Team Logo Badge (if available)
                      if (teamId != null) ...[
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.white, // White background for contrast
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: colors.border.withValues(alpha: 0.5), 
                              width: 1
                            ),
                          ),
                          padding: const EdgeInsets.all(2), // Padding inside white circle
                          child: ClipOval(
                            child: Image.asset(
                              TeamLogoService.getLogoPath(teamId),
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => const SizedBox(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],

                      // Player Headshot (if available)
                      if (article.players?.isNotEmpty == true && article.players!.first.headshotUrl != null) ...[
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.white, // White background for contrast
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: colors.border.withValues(alpha: 0.5), 
                              width: 1
                            ),
                          ),
                           // NetworkImage handles scaling differently, CircleAvatar is safer here
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            backgroundImage: NetworkImage(article.players!.first.headshotUrl!),
                            onBackgroundImageError: (_, __) {},
                            radius: 10,
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],

                      // Source Badge
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            article.sourceName.toUpperCase(),
                            style: TextStyle(
                              color: colors.brand,
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),

                      // Separator
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Text(
                          '•',
                          style: TextStyle(
                            color: colors.textSecondary,
                            fontSize: 10,
                          ),
                        ),
                      ),

                      // Time
                      Text(
                        _formatTime(article.createdAt),
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
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
