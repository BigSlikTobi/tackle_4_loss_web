import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/t4l_theme.dart';
import 'package:tackle4loss_mobile/design_tokens.dart';
import '../../../../l10n/app_localizations.dart';
import '../../models/breaking_news_article.dart';

/// Displays a timeline of related stories (updates & originals)
/// linked through story groups.
class RelatedStoriesSection extends StatelessWidget {
  final List<RelatedStory> relatedStories;
  final BreakingNewsArticle currentArticle;
  final void Function(RelatedStory story) onStoryTap;

  const RelatedStoriesSection({
    super.key,
    required this.relatedStories,
    required this.currentArticle,
    required this.onStoryTap,
  });

  @override
  Widget build(BuildContext context) {
    if (relatedStories.isEmpty) return const SizedBox.shrink();

    final colors = Theme.of(context).extension<T4LThemeColors>()!;
    final l10n = AppLocalizations.of(context)!;

    // Build timeline from related stories only (exclude current article),
    // sorted newest first (descending).
    final allStories = <_TimelineEntry>[];

    for (final story in relatedStories) {
      // Skip if this is the same article we're viewing
      if (story.id == currentArticle.id) continue;
      allStories.add(_TimelineEntry(
        id: story.id,
        headline: story.headline,
        imageUrl: story.imageUrl,
        createdAt: story.createdAt,
        isUpdate: story.status?.toLowerCase() == 'update',
        relatedStory: story,
      ));
    }

    // Sort newest first
    allStories.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    // Nothing to show if all stories were filtered out
    if (allStories.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          children: [
            Icon(Icons.timeline, color: colors.brand, size: 20),
            const SizedBox(width: 8),
            Text(
              l10n.breakingNewsRelatedStories,
              style: AppTextStyles.h3.copyWith(
                color: colors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Timeline List
        ...List.generate(allStories.length, (index) {
          final entry = allStories[index];
          final isFirst = index == 0;
          final isLast = index == allStories.length - 1;

          return _TimelineItem(
            entry: entry,
            isFirst: isFirst,
            isLast: isLast,
            onTap: () => onStoryTap(entry.relatedStory),
          );
        }),
      ],
    );
  }
}

/// Internal model for a single entry in the related-stories timeline.
class _TimelineEntry {
  final String id;
  final String headline;
  final String? imageUrl;
  final DateTime createdAt;
  final bool isUpdate;
  final RelatedStory relatedStory;

  _TimelineEntry({
    required this.id,
    required this.headline,
    this.imageUrl,
    required this.createdAt,
    required this.isUpdate,
    required this.relatedStory,
  });
}

/// A single item in the timeline with a connecting line.
class _TimelineItem extends StatelessWidget {
  final _TimelineEntry entry;
  final bool isFirst;
  final bool isLast;
  final VoidCallback? onTap;

  const _TimelineItem({
    required this.entry,
    required this.isFirst,
    required this.isLast,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<T4LThemeColors>()!;
    final l10n = AppLocalizations.of(context)!;

    final tagText = entry.isUpdate
        ? l10n.breakingNewsUpdateStory
        : l10n.breakingNewsOriginalStory;
    final tagColor = entry.isUpdate ? AppColors.breakingNewsRed : colors.brand;

    return IntrinsicHeight(
      // IntrinsicHeight needed so the timeline rail stretches to match card
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline rail (dot + line)
          SizedBox(
            width: 32,
            child: Column(
              children: [
                // Top connector line
                if (!isFirst)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: colors.brand.withValues(alpha: 0.3),
                    ),
                  )
                else
                  const Spacer(),

                // Dot
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: colors.brand.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                ),

                // Bottom connector line
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: colors.brand.withValues(alpha: 0.3),
                    ),
                  )
                else
                  const Spacer(),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Card content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Material(
                color: colors.surface.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        // Thumbnail
                        if (entry.imageUrl != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: SizedBox(
                              width: 56,
                              height: 56,
                              child: CachedNetworkImage(
                                imageUrl: entry.imageUrl!,
                                fit: BoxFit.cover,
                                errorWidget: (_, __, ___) => Container(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHighest,
                                  child: Icon(Icons.newspaper,
                                      color: colors.textSecondary
                                          .withValues(alpha: 0.3),
                                      size: 24),
                                ),
                              ),
                            ),
                          ),
                        if (entry.imageUrl != null) const SizedBox(width: 12),

                        // Text content
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Tag + Date row
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: tagColor.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      tagText.toUpperCase(),
                                      style: TextStyle(
                                        color: tagColor,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      DateFormat('MMM d, h:mm a')
                                          .format(entry.createdAt),
                                      style: TextStyle(
                                        color: colors.textSecondary,
                                        fontSize: 10,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),

                              // Headline
                              Text(
                                entry.headline,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: colors.textPrimary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Arrow icon
                        const SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: colors.textSecondary.withValues(alpha: 0.5),
                          size: 14,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
