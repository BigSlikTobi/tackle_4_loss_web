
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:audio_service/audio_service.dart'; // New import
import '../../../../design_tokens.dart';
import '../../../core/os_shell/widgets/t4l_scaffold.dart';
import '../../../core/os_shell/widgets/t4l_header.dart';
import '../../../core/services/settings_service.dart'; // New import
import '../../../core/services/audio_player_service.dart';
import '../../../core/adk/widgets/t4l_hero_header.dart';
import '../controllers/deep_dive_detail_controller.dart';
import '../models/deep_dive_article.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/theme/t4l_theme.dart';

class DeepDiveScreen extends StatefulWidget {
  final DeepDiveArticle article;
  final DeepDiveDetailController? controller;

  const DeepDiveScreen({
    super.key, 
    required this.article,
    this.controller,
  });

  @override
  State<DeepDiveScreen> createState() => _DeepDiveScreenState();
}

class _DeepDiveScreenState extends State<DeepDiveScreen> {
  late final DeepDiveDetailController _controller;
  late final PageController _pageController;
  int _currentPage = 0;

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
                NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) {
                    return [
                      T4LHeroHeader(
                        title: article.title,
                        subtitle: article.summary,
                        imageUrl: article.imageUrl,
                        videoUrl: article.videoUrl,
                        isDarkMode: isDarkMode,
                        heroTag: 'hero-${article.id}',
                        floatingAction: article.audioUrl == null
                            ? null
                            : StreamBuilder<PlaybackState>(
                                stream: AudioPlayerService().playbackStateStream,
                                builder: (context, snapshot) {
                                  final playing = snapshot.data?.playing ?? false;
                                  final currentMediaStr = AudioPlayerService()
                                      .currentMediaItem
                                      ?.id;
                                  final isIsActiveArticle =
                                      currentMediaStr == article.audioUrl;
                                  final showPause = playing && isIsActiveArticle;

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
                                              article.imageUrl);
                                        }
                                      }
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: colors.surface,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.1),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                        border: Border.all(
                                          color: colors.textPrimary.withOpacity(0.1),
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
                                }),
                      ),
                    ];
                  },
                  body: controller.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : (sections.isNotEmpty)
                          ? PageView.builder(
                              controller: _pageController,
                              onPageChanged: (index) {
                                setState(() {
                                  _currentPage = index;
                                });
                              },
                              itemCount: sections.length,
                              itemBuilder: (context, index) {
                                final section = sections[index];
                                return MediaQuery.removePadding(
                                  context: context,
                                  removeTop: true,
                                  child: SingleChildScrollView(
                                    physics: const BouncingScrollPhysics(),
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          24, 32, 24, 120),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            l10n.deepDiveChapter(index + 1).toUpperCase(),
                                            style: AppTextStyles.caption.copyWith(
                                              color: colors.brand,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 2.0,
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          MarkdownBody(
                                            data: section.content,
                                            styleSheet: MarkdownStyleSheet(
                                              p: TextStyle(
                                                  color: colors.textSecondary,
                                                  fontSize: 16,
                                                  height: 1.6),
                                              h2: TextStyle(
                                                  color: colors.textPrimary,
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.bold),
                                              h3: TextStyle(
                                                  color: colors.textPrimary,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w600),
                                              blockquote: TextStyle(
                                                  color: colors.border,
                                                  fontStyle: FontStyle.italic),
                                              code: TextStyle(
                                                  backgroundColor: colors.surface,
                                                  color: colors.textPrimary),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            )
                          : SingleChildScrollView(
                              padding: const EdgeInsets.all(24.0),
                              child: content != null
                                  ? MarkdownBody(
                                      data: content,
                                      styleSheet: MarkdownStyleSheet(
                                        p: TextStyle(
                                            color: colors.textSecondary,
                                            fontSize: 16,
                                            height: 1.6),
                                        h2: TextStyle(
                                            color: colors.textPrimary,
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold),
                                        h3: TextStyle(
                                            color: colors.textPrimary,
                                            fontSize: 20,
                                            fontWeight: FontWeight.w600),
                                        blockquote: TextStyle(
                                            color: colors.border,
                                            fontStyle: FontStyle.italic),
                                        code: TextStyle(
                                            backgroundColor: colors.surface,
                                            color: colors.textPrimary),
                                      ),
                                    )
                                  : Center(
                                      child: Text(l10n.deepDiveNoContent,
                                          style: TextStyle(
                                              color: colors.textSecondary))),
                            ),
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
                            (isDarkMode
                                    ? colors.background 
                                    : colors.background)
                                .withOpacity(0),
                          ],
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: LinearProgressIndicator(
                                value: (sections.length > 1)
                                    ? _currentPage / (sections.length - 1)
                                    : 1.0,
                                color: colors.textPrimary.withOpacity(0.1),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    colors.brand),
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
}
