import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tackle4loss_mobile/design_tokens.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/os_shell/widgets/app_dock.dart';
import '../../../core/services/settings_service.dart';
import '../../../core/services/team_logo_service.dart';
import '../../../core/theme/t4l_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../models/breaking_news_article.dart';
import '../services/breaking_news_service.dart';
import 'widgets/related_stories_section.dart';

/// Article detail — implementation of the V3 "Article Detail" design.
///
/// Full-bleed hero image with parallax + dark gradient, floating back/share
/// pills, italic Anton headline, byline bar with source/date/read-time, and
/// a typographically-led body. Falls back gracefully while the full article
/// content is still loading from Supabase.
/// Async fetchers used by the detail screen. Defaults are wired to the legacy
/// `BreakingNewsService`; the home-feed flow injects `ArticlesService`-backed
/// fetchers so taps on home-feed cards resolve against the new articles
/// project.
typedef ArticleDetailFetcher = Future<BreakingNewsArticle> Function(String id);
typedef RelatedStoriesFetcher = Future<List<RelatedStory>> Function(
  String id, {
  required String languageCode,
});

class BreakingNewsDetailScreen extends StatefulWidget {
  final BreakingNewsArticle summary;
  final ArticleDetailFetcher? detailFetcher;
  final RelatedStoriesFetcher? relatedFetcher;

  const BreakingNewsDetailScreen({
    super.key,
    required this.summary,
    this.detailFetcher,
    this.relatedFetcher,
  });

  @override
  State<BreakingNewsDetailScreen> createState() =>
      _BreakingNewsDetailScreenState();
}

class _BreakingNewsDetailScreenState extends State<BreakingNewsDetailScreen> {
  final _legacyService = BreakingNewsService();
  late Future<BreakingNewsArticle> _detailFuture;
  late Future<List<RelatedStory>> _relatedFuture;

  final _scrollController = ScrollController();
  double _scrollY = 0;

  static const double _heroHeight = 310;

  ArticleDetailFetcher get _detailFetcher =>
      widget.detailFetcher ?? _legacyService.fetchBreakingNewsDetail;
  RelatedStoriesFetcher get _relatedFetcher =>
      widget.relatedFetcher ?? _legacyService.fetchRelatedStories;

  @override
  void initState() {
    super.initState();
    _detailFuture = _detailFetcher(widget.summary.id);
    _relatedFuture = Future.value([]);
    _scrollController.addListener(_onScroll);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final languageCode = Provider.of<SettingsService>(context, listen: false)
        .locale
        .languageCode;
    _relatedFuture = _relatedFetcher(
      widget.summary.id,
      languageCode: languageCode,
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    setState(() => _scrollY = _scrollController.offset);
  }

  double get _progress {
    if (!_scrollController.hasClients) return 0;
    final max = _scrollController.position.maxScrollExtent;
    return max > 0 ? (_scrollController.offset / max).clamp(0.0, 1.0) : 0;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<T4LThemeColors>()!;
    final isDark = theme.brightness == Brightness.dark;
    final settings = Provider.of<SettingsService>(context);
    final article = widget.summary;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      bottomNavigationBar: const AppDock(),
      body: Container(
        decoration: BoxDecoration(gradient: settings.backgroundGradient),
        child: Stack(
          children: [
            // Scrollable content
            CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverToBoxAdapter(
                  child: _Hero(
                    article: article,
                    scrollY: _scrollY,
                    height: _heroHeight,
                  ),
                ),
                SliverToBoxAdapter(
                  child: FutureBuilder<BreakingNewsArticle>(
                    future: _detailFuture,
                    builder: (context, snapshot) {
                      final fullArticle = snapshot.data;
                      final displayArticle = fullArticle ?? article;
                      final isLoading =
                          snapshot.connectionState == ConnectionState.waiting;
                      final hasError = snapshot.hasError;

                      return _Body(
                        article: displayArticle,
                        fullArticle: fullArticle,
                        isLoading: isLoading,
                        hasError: hasError,
                        relatedFuture: _relatedFuture,
                        colors: colors,
                        isDark: isDark,
                      );
                    },
                  ),
                ),
              ],
            ),

            // Top reading-progress bar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                bottom: false,
                child: Container(
                  height: 2,
                  color: colors.brand.withValues(alpha: 0.10),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: _progress,
                    child: Container(color: colors.brand),
                  ),
                ),
              ),
            ),

            // Floating back + share buttons
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _GlassPillButton(
                        onTap: () => Navigator.of(context).pop(),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.chevron_left,
                                size: 18, color: colors.brand),
                            const SizedBox(width: 2),
                            Text(
                              MaterialLocalizations.of(context)
                                  .backButtonTooltip,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.1,
                                color: AppColors.neutralText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Hero ────────────────────────────────────────────────────────────

class _Hero extends StatelessWidget {
  final BreakingNewsArticle article;
  final double scrollY;
  final double height;

  const _Hero({
    required this.article,
    required this.scrollY,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final parallax = (scrollY * 0.35).clamp(0.0, 60.0);
    final overlayOpacity = (0.55 + scrollY * 0.001).clamp(0.55, 0.88);

    return SizedBox(
      height: height,
      child: ClipRect(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Image + parallax
            Transform.translate(
              offset: Offset(0, parallax),
              child: article.imageUrl != null
                  ? Hero(
                      tag: 'breaking_news_hero_${article.id}',
                      child: CachedNetworkImage(
                        imageUrl: article.imageUrl!,
                        fit: BoxFit.cover,
                        memCacheWidth: 900,
                      ),
                    )
                  : Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF0D2119),
                            Color(0xFF1A5F3D),
                            Color(0xFF0A2F24),
                          ],
                        ),
                      ),
                    ),
            ),

            // Dark gradient overlay for text readability
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.20),
                    AppColors.brandBase.withValues(alpha: 0.50),
                    const Color(0xFF0A1C12).withValues(alpha: overlayOpacity),
                  ],
                  stops: const [0.0, 0.55, 1.0],
                ),
              ),
            ),

            // Content (eyebrow + headline + subtitle)
            Positioned(
              left: 20,
              right: 20,
              bottom: 22,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    article.headline.toUpperCase(),
                    style: GoogleFonts.anton(
                      fontSize: 32,
                      height: 0.95,
                      letterSpacing: -0.5,
                      color: Colors.white,
                      fontStyle: FontStyle.italic,
                      shadows: const [
                        Shadow(
                          color: Color(0x66000000),
                          blurRadius: 12,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  if ((article.subHeader ?? '').isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      article.subHeader!,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.45,
                        color: Color(0xB8FFFFFF),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Glass header buttons ────────────────────────────────────────────

class _GlassPillButton extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;
  const _GlassPillButton({required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    return _GlassSurface(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 7, 13, 7),
        child: child,
      ),
    );
  }
}

class _GlassSurface extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;
  const _GlassSurface({required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(11),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Material(
          color: Colors.white.withValues(alpha: 0.92),
          child: InkWell(
            onTap: onTap,
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(
                    color: AppColors.brandBase.withValues(alpha: 0.15),
                    width: 1),
                borderRadius: BorderRadius.circular(11),
                boxShadow: const [
                  BoxShadow(
                      color: Color(0x1F000000),
                      blurRadius: 8,
                      offset: Offset(0, 2)),
                ],
              ),
              child: Center(child: child),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Body ────────────────────────────────────────────────────────────

class _Body extends StatelessWidget {
  final BreakingNewsArticle article;
  final BreakingNewsArticle? fullArticle;
  final bool isLoading;
  final bool hasError;
  final Future<List<RelatedStory>> relatedFuture;
  final T4LThemeColors colors;
  final bool isDark;

  const _Body({
    required this.article,
    required this.fullArticle,
    required this.isLoading,
    required this.hasError,
    required this.relatedFuture,
    required this.colors,
    required this.isDark,
  });

  int _readMinutes(BreakingNewsArticle a) {
    final words = (a.introductionParagraph ?? '').split(RegExp(r'\s+')).length +
        (a.content ?? '').split(RegExp(r'\s+')).length;
    final mins = (words / 220).ceil();
    return mins.clamp(1, 60);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final fullForRead = fullArticle ?? article;
    final readMins = _readMinutes(fullForRead);

    return Container(
      color: colors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _BylineBar(
            article: fullForRead,
            readMins: readMins,
            colors: colors,
            isDark: isDark,
          ),
          if (hasError)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Container(
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
                        l10n.breakingNewsDetailLoadError,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            ),
          if (fullArticle != null) ...[
            if (fullArticle!.introductionParagraph != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Text(
                  fullArticle!.introductionParagraph!,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.7,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.1,
                    color: colors.textPrimary,
                  ),
                ),
              ),
            if ((fullArticle!.subHeader ?? '').isNotEmpty &&
                fullArticle!.subHeader != article.subHeader)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: Text(
                  fullArticle!.subHeader!,
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontHeading,
                    fontSize: 18,
                    height: 1.2,
                    letterSpacing: -0.2,
                    color: colors.textPrimary,
                  ),
                ),
              ),
            if (fullArticle!.teams?.isNotEmpty == true)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: fullArticle!.teams!.map((team) {
                    final teamId = team.teamId.toLowerCase();
                    return _TeamChip(
                        teamId: teamId, colors: colors, isDark: isDark);
                  }).toList(),
                ),
              ),
            if (fullArticle!.players?.isNotEmpty == true)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: SizedBox(
                  height: 70,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: fullArticle!.players!.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 14),
                    itemBuilder: (context, index) {
                      final player = fullArticle!.players![index];
                      final headshot = player.headshotUrl;
                      if (headshot == null) return const SizedBox.shrink();
                      return Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: colors.brand.withValues(alpha: 0.30),
                                width: 1.5,
                              ),
                            ),
                            padding: const EdgeInsets.all(2),
                            child: CircleAvatar(
                              radius: 22,
                              backgroundImage: NetworkImage(headshot),
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
                            ),
                          ],
                        ],
                      );
                    },
                  ),
                ),
              ),
            if (fullArticle!.content != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                child: Text(
                  fullArticle!.content!,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.75,
                    color: colors.textSecondary,
                  ),
                ),
              ),
            _SourceFooter(article: fullArticle!, colors: colors),
            const SizedBox(height: 32),
            FutureBuilder<List<RelatedStory>>(
              future: relatedFuture,
              builder: (context, relatedSnapshot) {
                final related = relatedSnapshot.data ?? [];
                if (related.isEmpty) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: RelatedStoriesSection(
                    relatedStories: related,
                    currentArticle: fullArticle!,
                    onStoryTap: (story) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => BreakingNewsDetailScreen(
                            summary: story.toArticle(),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            // Bottom clearance for the floating dock.
            const SizedBox(height: 140),
          ],
        ],
      ),
    );
  }
}

class _BylineBar extends StatelessWidget {
  final BreakingNewsArticle article;
  final int readMins;
  final T4LThemeColors colors;
  final bool isDark;

  const _BylineBar({
    required this.article,
    required this.readMins,
    required this.colors,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final author = (article.author ?? '').trim();
    final hasAuthor = author.isNotEmpty;
    final dividerColor =
        (isDark ? Colors.white : AppColors.brandBase).withValues(alpha: 0.10);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    if (hasAuthor)
                      Text(
                        author.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                          color: colors.brand,
                        ),
                      ),
                    if (hasAuthor)
                      Text('·',
                          style: TextStyle(
                              color: colors.textMuted.withValues(alpha: 0.6))),
                    Text(
                      DateFormat('MMM d, y · h:mm a').format(article.createdAt),
                      style: TextStyle(
                        fontSize: 11,
                        color: colors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: colors.brand.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.access_time_rounded,
                        size: 11, color: colors.brand),
                    const SizedBox(width: 4),
                    Text(
                      '$readMins min',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: colors.brand,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 14),
            child: Container(height: 1, color: dividerColor),
          ),
        ],
      ),
    );
  }
}

class _TeamChip extends StatelessWidget {
  final String teamId;
  final T4LThemeColors colors;
  final bool isDark;
  const _TeamChip({
    required this.teamId,
    required this.colors,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final bg =
        isDark ? Colors.white.withValues(alpha: 0.06) : AppColors.neutralSoft;
    return Container(
      padding: const EdgeInsets.fromLTRB(4, 4, 12, 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colors.brand.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(2),
            child: Image.asset(
              TeamLogoService.getLogoPath(teamId),
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) =>
                  Icon(Icons.sports_football, size: 14, color: colors.brand),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            teamId.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
              color: colors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SourceFooter extends StatelessWidget {
  final BreakingNewsArticle article;
  final T4LThemeColors colors;
  const _SourceFooter({required this.article, required this.colors});

  @override
  Widget build(BuildContext context) {
    final url = article.sourceUrl;
    if (url == null || url.isEmpty) return const SizedBox.shrink();
    final uri = Uri.tryParse(url);
    if (uri == null || !(uri.isScheme('http') || uri.isScheme('https'))) {
      return const SizedBox.shrink();
    }
    final label = article.sourceName == 'Source'
        ? uri.host.replaceFirst('www.', '')
        : article.sourceName;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: GestureDetector(
        onTap: () async {
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        },
        child: Row(
          children: [
            Text(
              'Read more at ',
              style: TextStyle(
                fontSize: 13,
                color: colors.textSecondary,
              ),
            ),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: colors.brand,
                  decoration: TextDecoration.underline,
                  decorationColor: colors.brand,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.open_in_new, size: 13, color: colors.brand),
          ],
        ),
      ),
    );
  }
}
