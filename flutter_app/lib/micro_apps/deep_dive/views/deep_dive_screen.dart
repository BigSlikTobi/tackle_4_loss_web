import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:audio_service/audio_service.dart'; // New import
import 'package:url_launcher/url_launcher.dart';
import '../../../../design_tokens.dart';
import '../../../core/os_shell/widgets/t4l_scaffold.dart';
import '../../../core/services/audio_player_service.dart';
import '../../../core/adk/widgets/t4l_hero_header.dart';
import '../controllers/deep_dive_detail_controller.dart';
import '../models/deep_dive_article.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/theme/t4l_theme.dart';
import '../../../core/widgets/shimmer_skeleton.dart';

class DeepDiveScreen extends StatefulWidget {
  final DeepDiveArticle article;
  final DeepDiveDetailController? controller;

  const DeepDiveScreen({super.key, required this.article, this.controller});

  @override
  State<DeepDiveScreen> createState() => _DeepDiveScreenState();
}

class _DeepDiveScreenState extends State<DeepDiveScreen> {
  late final DeepDiveDetailController _controller;
  late final PageController _pageController;
  final ScrollController _scrollController = ScrollController();
  final int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _controller = widget.controller ?? DeepDiveDetailController();
    _controller.loadArticleDetails(widget.article.id);
  }

  @override
  void dispose() {
    _controller.dispose();
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<T4LThemeColors>()!;
    final l10n = AppLocalizations.of(context)!;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return ChangeNotifierProvider.value(
      value: _controller,
      child: T4LScaffold(
        body: Consumer<DeepDiveDetailController>(
          builder: (context, controller, child) {
            final article = controller.article ?? widget.article;
            final sections = article.sections ?? [];
            final content = article.content;

            return Stack(
              children: [
                controller.isLoading
                    ? const Center(
                        child: ShimmerBox(
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      )
                    : CustomScrollView(
                        controller: _scrollController,
                        slivers: [
                          // 1. Hero Header (Standard Content)
                          SliverToBoxAdapter(
                            child: T4LHeroHeader(
                              title: article.title,
                              subtitle: article.summary,
                              imageUrl: article.imageUrl,
                              videoUrl: article.videoUrl,
                              height: 440.0,
                              isDarkMode: isDarkMode,
                              heroTag: 'hero-${article.id}',
                              floatingAction: article.audioUrl == null
                                  ? null
                                  : StreamBuilder<PlaybackState>(
                                      stream: AudioPlayerService()
                                          .playbackStateStream,
                                      builder: (context, snapshot) {
                                        final playing =
                                            snapshot.data?.playing ?? false;
                                        final currentMediaStr =
                                            AudioPlayerService()
                                                .currentMediaItem
                                                ?.id;
                                        final isIsActiveArticle =
                                            currentMediaStr == article.audioUrl;
                                        final showPause =
                                            playing && isIsActiveArticle;

                                        return GestureDetector(
                                          onTap: () {
                                            if (showPause) {
                                              AudioPlayerService().pause();
                                            } else {
                                              if (article.audioUrl != null) {
                                                AudioPlayerService().play(
                                                  article.audioUrl!,
                                                  article.title,
                                                  article.author,
                                                  article.imageUrl,
                                                );
                                              }
                                            }
                                          },
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                                milliseconds: 200),
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: colors.surface,
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withValues(alpha: 0.1),
                                                  blurRadius: 10,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ],
                                              border: Border.all(
                                                color: colors.textPrimary
                                                    .withValues(alpha: 0.1),
                                                width: 1,
                                              ),
                                            ),
                                            child: Icon(
                                              showPause
                                                  ? Icons.pause_rounded
                                                  : Icons.play_arrow_rounded,
                                              color: colors.brand,
                                              size: 32,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                            ),
                          ),

                          // 2. Notebook Disclaimer
                          if (article.notebookUrl != null)
                            SliverToBoxAdapter(
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(24, 24, 24, 0),
                                child: InkWell(
                                  onTap: () async {
                                    final uri = Uri.parse(article.notebookUrl!);
                                    if (await canLaunchUrl(uri)) {
                                      await launchUrl(uri);
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color:
                                          colors.brand.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color:
                                            colors.brand.withValues(alpha: 0.2),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.info_outline,
                                          size: 20,
                                          color: colors.brand,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            l10n.deepDiveNotebookDisclaimer,
                                            style: TextStyle(
                                              color: colors.textPrimary,
                                              fontSize: 12,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Icon(
                                          Icons.arrow_forward_ios_rounded,
                                          size: 12,
                                          color: colors.brand,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),

                          // 3. Content Body
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (sections.isNotEmpty)
                                    Column(
                                      children:
                                          sections.asMap().entries.map((entry) {
                                        final index = entry.key;
                                        final section = entry.value;
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 32.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                l10n
                                                    .deepDiveChapter(index + 1)
                                                    .toUpperCase(),
                                                style: AppTextStyles.caption
                                                    .copyWith(
                                                  color: colors.brand,
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: 2.0,
                                                ),
                                              ),
                                              const SizedBox(height: 16),
                                              MarkdownBody(
                                                data: _formatContent(
                                                    section.content),
                                                styleSheet: MarkdownStyleSheet(
                                                  p: TextStyle(
                                                    color: colors.textSecondary,
                                                    fontSize: 16,
                                                    height: 1.6,
                                                  ),
                                                  h2: TextStyle(
                                                    color: colors.textPrimary,
                                                    fontSize: 24,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  h3: TextStyle(
                                                    color: colors.textPrimary,
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                  blockquote: TextStyle(
                                                    color: colors.border,
                                                    fontStyle: FontStyle.italic,
                                                  ),
                                                  code: TextStyle(
                                                    backgroundColor:
                                                        colors.surface,
                                                    color: colors.textPrimary,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    )
                                  else if (content != null)
                                    MarkdownBody(
                                      data: _formatContent(content),
                                      styleSheet: MarkdownStyleSheet(
                                        p: TextStyle(
                                          color: colors.textSecondary,
                                          fontSize: 16,
                                          height: 1.6,
                                        ),
                                        h2: TextStyle(
                                          color: colors.textPrimary,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        h3: TextStyle(
                                          color: colors.textPrimary,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        blockquote: TextStyle(
                                          color: colors.border,
                                          fontStyle: FontStyle.italic,
                                        ),
                                        code: TextStyle(
                                          backgroundColor: colors.surface,
                                          color: colors.textPrimary,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                // Progress Overlay
                if (sections.isNotEmpty && !controller.isLoading)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            (isDarkMode
                                ? colors.background
                                : colors.background),
                            (isDarkMode ? colors.background : colors.background)
                                .withValues(alpha: 0),
                          ],
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 20,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: LinearProgressIndicator(
                                value: (sections.length > 1)
                                    ? _currentPage / (sections.length - 1)
                                    : 1.0,
                                color: colors.textPrimary.withValues(
                                  alpha: 0.1,
                                ),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  colors.brand,
                                ),
                                minHeight: 2,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            "${_currentPage + 1} / ${sections.length}",
                            style: AppTextStyles.caption.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _formatContent(String content) {
    // 1. Structure Bullet Points:
    //    Replace " • " or "• " with a proper Markdown list item.
    //    We add double newlines \n\n before the asterisk to ensure Markdown
    //    treats it as a new block/list item.
    String formatted = content.replaceAll(RegExp(r'\s*•\s*'), '\n\n* ');

    // 2. Headings for "Scenario X:"
    //    Bold "Scenario X:" and ensure it starts on a new line.
    formatted = formatted.replaceAllMapped(
      RegExp(r'(Scenario \d+:)', caseSensitive: false),
      (match) => '\n\n**${match.group(1)}**',
    );

    // 3. Bold "Result:"
    //    Make "Result:" bold.
    formatted = formatted.replaceAll(
      RegExp(r'(Result:)', caseSensitive: false),
      '**Result:**',
    );

    // 4. Clean up excessive newlines (optional, but good for tidiness)
    formatted = formatted.replaceAll(RegExp(r'\n{3,}'), '\n\n');

    return formatted.trim();
  }
}
