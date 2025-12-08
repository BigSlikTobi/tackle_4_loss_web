import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models.dart';
import '../design_tokens.dart';

class ArticleFeed extends StatelessWidget {
  final List<Article> articles;
  final ValueChanged<Article> onSelect;

  const ArticleFeed({
    super.key,
    required this.articles,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    if (articles.isEmpty) {
      return const SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.space6),
            child: Column(
              children: [
                Text('🔍', style: TextStyle(fontSize: 48)),
                SizedBox(height: AppSpacing.space2),
                Text('No articles', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.all(AppSpacing.space2),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          // Featured Article
          if (articles.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.space3),
              child: FeaturedArticleCard(
                article: articles.first,
                onTap: () => onSelect(articles.first),
              ),
            ),
          
          // List of other articles
          ...articles.skip(1).map((article) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.space2),
            child: ArticleCard(article: article, onTap: () => onSelect(article)),
          )),
          
          const SizedBox(height: AppSpacing.space6),
        ]),
      ),
    );
  }
}

class FeaturedArticleCard extends StatelessWidget {
  final Article article;
  final VoidCallback onTap;

  const FeaturedArticleCard({super.key, required this.article, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.neutralBase,
          borderRadius: BorderRadius.circular(AppBorders.radiusXl),
          boxShadow: AppShadows.md,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: CachedNetworkImage(
                    imageUrl: article.heroImage,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(color: AppColors.neutralSoft),
                    errorWidget: (context, url, error) => Container(color: AppColors.neutralSoft),
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.brandBase,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'DD',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.space3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(LucideIcons.calendar, size: 14, color: AppColors.neutralTextMuted),
                      const SizedBox(width: 4),
                      Text(article.date, style: const TextStyle(color: AppColors.neutralTextMuted, fontSize: AppTypography.fontSizeSm)),
                      const SizedBox(width: 8),
                      const Text('•', style: TextStyle(color: AppColors.neutralBorder)),
                      const SizedBox(width: 8),
                      Text(article.author, style: const TextStyle(color: AppColors.neutralTextMuted, fontSize: AppTypography.fontSizeSm)),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.space2),
                  Text(
                    article.title,
                    style: const TextStyle(
                      fontFamily: AppTypography.fontFamilyPrimary,
                      fontSize: AppTypography.fontSizeXl,
                      fontWeight: AppTypography.fontWeightBold,
                      height: 1.1,
                      color: AppColors.neutralText,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space1),
                  Text(
                    article.subtitle,
                    style: const TextStyle(
                      color: AppColors.neutralTextMuted,
                      fontSize: AppTypography.fontSizeMd,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space3),
                  const Row(
                    children: [
                      Text('Read', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.neutralText)),
                      SizedBox(width: 4),
                      Icon(LucideIcons.chevronRight, size: 16, color: AppColors.neutralText),
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
}

class ArticleCard extends StatelessWidget {
  final Article article;
  final VoidCallback onTap;

  const ArticleCard({super.key, required this.article, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.neutralBase,
          borderRadius: BorderRadius.circular(AppBorders.radiusLg),
          boxShadow: AppShadows.sm,
          border: Border.all(color: AppColors.neutralBorder.withOpacity(0.5)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            SizedBox(
              width: 120,
              height: 120,
              child: CachedNetworkImage(
                imageUrl: article.heroImage,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(color: AppColors.neutralSoft),
                errorWidget: (context, url, error) => Container(color: AppColors.neutralSoft),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.space2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        const Icon(LucideIcons.calendar, size: 12, color: AppColors.neutralTextMuted),
                        const SizedBox(width: 4),
                        Text(
                          article.date.split(',')[0], // Shorten date
                          style: const TextStyle(color: AppColors.neutralTextMuted, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      article.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: AppTypography.fontFamilyPrimary,
                        fontSize: AppTypography.fontSizeMd,
                        fontWeight: AppTypography.fontWeightBold,
                        height: 1.2,
                        color: AppColors.neutralText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      article.author.toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.neutralTextMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: AppSpacing.space2),
              child: Icon(LucideIcons.chevronRight, size: 16, color: AppColors.neutralBorder),
            ),
          ],
        ),
      ),
    );
  }
}
