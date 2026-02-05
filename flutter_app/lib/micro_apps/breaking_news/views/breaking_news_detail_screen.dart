import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/t4l_theme.dart';
import '../../../core/services/team_logo_service.dart';
import '../../../core/services/settings_service.dart';
import 'package:tackle4loss_mobile/design_tokens.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../l10n/app_localizations.dart';
import '../models/breaking_news_article.dart';
import '../services/breaking_news_service.dart';

class BreakingNewsDetailScreen extends StatefulWidget {
  final BreakingNewsArticle summary;

  const BreakingNewsDetailScreen({
    super.key,
    required this.summary,
  });

  @override
  State<BreakingNewsDetailScreen> createState() =>
      _BreakingNewsDetailScreenState();
}

class _BreakingNewsDetailScreenState extends State<BreakingNewsDetailScreen> {
  final _service = BreakingNewsService();
  late Future<BreakingNewsArticle> _detailFuture;

  @override
  void initState() {
    super.initState();
    _detailFuture = _service.fetchBreakingNewsDetail(widget.summary.id);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<T4LThemeColors>()!;
    // Use summary data initially, then upgrade to detail if loaded
    final article = widget.summary;

    // Access settings for background gradient
    final settings = Provider.of<SettingsService>(context);

    return Scaffold(
      backgroundColor: Colors.transparent, // Allow gradient to show
      body: Container(
        decoration: BoxDecoration(
          gradient: settings.backgroundGradient,
        ),
        child: CustomScrollView(
          slivers: [
            // 1. Sliver App Bar with Hero Image
            SliverAppBar(
              expandedHeight: 300,
              pinned: true,
              backgroundColor: colors.surface.withValues(
                  alpha: 0.9), // Match surface but slightly translucent
              leading: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back,
                      color: Colors.white, size: 20),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (article.imageUrl != null)
                      Hero(
                        tag: 'breaking_news_hero_${article.id}',
                        child: CachedNetworkImage(
                          imageUrl: article.imageUrl!,
                          fit: BoxFit.cover,
                        ),
                      ),

                    // Gradient Overlay for text readability
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.3),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.3],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 2. Content Body
            SliverToBoxAdapter(
              child: FutureBuilder<BreakingNewsArticle>(
                future: _detailFuture,
                builder: (context, snapshot) {
                  // If we have full detail, use it. Otherwise use summary + loading indicator
                  final fullArticle = snapshot.data;
                  final displayArticle = fullArticle ?? article;
                  final isLoading =
                      snapshot.connectionState == ConnectionState.waiting;
                  final hasError = snapshot.hasError;
                  final sourceUri = displayArticle.sourceUrl != null
                      ? Uri.tryParse(displayArticle.sourceUrl!)
                      : null;
                  final hasValidSourceUrl = sourceUri != null &&
                      (sourceUri.isScheme('http') ||
                          sourceUri.isScheme('https'));

                  return Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Team & Source Meta
                        Row(
                          children: [
                            if (displayArticle.sourceName != 'Source') ...[
                              // Make source clickable if URL exists
                              InkWell(
                                onTap: hasValidSourceUrl
                                    ? () async {
                                        if (await canLaunchUrl(sourceUri)) {
                                          await launchUrl(
                                            sourceUri,
                                            mode:
                                                LaunchMode.externalApplication,
                                          );
                                        }
                                      }
                                    : null,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    displayArticle.sourceName.toUpperCase(),
                                    style: TextStyle(
                                      color: colors.brand, // Use brand color
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.0,
                                      decoration: hasValidSourceUrl
                                          ? TextDecoration.underline
                                          : null,
                                      decorationColor: colors.brand,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '•',
                                style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.7)),
                              ),
                              const SizedBox(width: 8),
                            ],
                            Text(
                              DateFormat('MMM d, y • h:mm a')
                                  .format(displayArticle.createdAt),
                              style: TextStyle(
                                color: colors.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Headline
                        Text(
                          displayArticle.headline,
                          style: AppTextStyles.h2.copyWith(
                            color: colors.textPrimary,
                            fontSize: 24,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Error Layer
                        if (hasError)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .error
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error_outline,
                                    color: Theme.of(context).colorScheme.error),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    AppLocalizations.of(context)!
                                        .breakingNewsDetailLoadError,
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .error),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // Loading Layer
                        if (isLoading)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(32),
                              child: CircularProgressIndicator(),
                            ),
                          ),

                        // Full Content Layer
                        if (fullArticle != null) ...[
                          // Team Logos (if any)
                          if (fullArticle.teams?.isNotEmpty == true) ...[
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: fullArticle.teams!.map((team) {
                                final teamId = team.teamId.toLowerCase();
                                return Chip(
                                  avatar: Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    padding: const EdgeInsets.all(2),
                                    child: CircleAvatar(
                                      backgroundColor: Colors.white,
                                      backgroundImage: AssetImage(
                                        TeamLogoService.getLogoPath(teamId),
                                      ),
                                    ),
                                  ),
                                  label: Text(teamId.toUpperCase()),
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHighest,
                                  side: BorderSide.none,
                                  labelStyle: TextStyle(
                                    color: colors.textPrimary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 24),
                          ],

                          // Introduction
                          if (fullArticle.introductionParagraph != null) ...[
                            Text(
                              fullArticle.introductionParagraph!,
                              style: AppTextStyles.body.copyWith(
                                color: colors.textPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],

                          // Player Headshots
                          if (fullArticle.players?.isNotEmpty == true) ...[
                            SizedBox(
                              height: 70,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: fullArticle.players!.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(width: 16),
                                itemBuilder: (context, index) {
                                  final player = fullArticle.players![index];
                                  final headshot = player.headshotUrl;
                                  if (headshot == null)
                                    return const SizedBox.shrink();
                                  return Column(
                                    children: [
                                      Container(
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                        padding: const EdgeInsets.all(
                                            2), // White border effect
                                        child: CircleAvatar(
                                          radius: 24,
                                          backgroundImage:
                                              NetworkImage(headshot),
                                          backgroundColor: Colors.white,
                                        ),
                                      ),
                                      if (player.name != null) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          player.name!,
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: colors.textSecondary,
                                          ),
                                        )
                                      ]
                                    ],
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],

                          // Body Content
                          if (fullArticle.content != null)
                            Text(
                              fullArticle.content!,
                              style: AppTextStyles.body.copyWith(
                                color: colors
                                    .textSecondary, // Softer for reading long text
                                fontSize: 16,
                                height: 1.6,
                              ),
                            ),

                          const SizedBox(height: 40),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
