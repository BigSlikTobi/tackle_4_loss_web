import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/os_shell/widgets/t4l_scaffold.dart';
import '../models/breaking_news_article.dart';
import '../controllers/breaking_news_controller.dart';
import '../../../core/services/settings_service.dart';
import 'widgets/breaking_news_hero.dart';
import 'widgets/breaking_news_list_item.dart';
import 'breaking_news_detail_screen.dart';
import '../../../l10n/app_localizations.dart';

class BreakingNewsListScreen extends StatefulWidget {
  final String? initialArticleId;
  final bool autoFlip;

  const BreakingNewsListScreen({
    super.key,
    this.initialArticleId,
    this.autoFlip = false,
  });

  @override
  State<BreakingNewsListScreen> createState() => _BreakingNewsListScreenState();
}

class _BreakingNewsListScreenState extends State<BreakingNewsListScreen> {
  final BreakingNewsController _controller = BreakingNewsController();
  bool _isInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      final locale = Localizations.localeOf(context).languageCode;
      final settings = Provider.of<SettingsService>(context, listen: false);
      
      _controller.loadNews(
        languageCode: locale,
        userTeamId: settings.selectedTeam?.id,
      );
      _isInit = true;
    }
  }

  void _openDetail(BuildContext context, BreakingNewsArticle article) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BreakingNewsDetailScreen(summary: article),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ChangeNotifierProvider.value(
      value: _controller,
      child: T4LScaffold(
        title: l10n.breakingNewsTitle,
        // Listen to settings changes to update user's team preference dynamically
        body: Consumer<SettingsService>(
          builder: (context, settings, _) {
            // Update controller if team changes while screen is open
            WidgetsBinding.instance.addPostFrameCallback((_) {
               _controller.updateUserTeam(settings.selectedTeam?.id);
            });

            return Consumer<BreakingNewsController>(
              builder: (context, controller, child) {
                if (controller.isLoading && controller.articles.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                // If loading failed or empty
                if (controller.articles.isEmpty) {
                  return Center(
                    child: Text(
                      'No breaking news available.',
                      style: TextStyle(color: Theme.of(context).colorScheme.outline),
                    ),
                  );
                }

                final hero = controller.heroArticle;
                final listItems = controller.listArticles;

                return RefreshIndicator(
                  onRefresh: () => controller.loadNews(
                    languageCode: Localizations.localeOf(context).languageCode,
                    userTeamId: settings.selectedTeam?.id,
                  ),
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      // SliverOverlapInjector? T4LScaffold handles header, 
                      // but we usually need padding or safe area if not transparent
                      const SliverToBoxAdapter(
                         child: SizedBox(height: 16), // Top padding
                      ),

                      // 1. Hero Article
                      if (hero != null)
                        SliverToBoxAdapter(
                          child: BreakingNewsHero(
                            article: hero,
                            onTap: () => _openDetail(context, hero),
                          ),
                        ),

                      const SliverToBoxAdapter(child: SizedBox(height: 16)),

                      // 2. Section Header (if needed, e.g. "Latest News")
                      // Optional: just start list

                      // 3. List Articles
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final article = listItems[index];
                            return Column(
                              children: [
                                BreakingNewsListItem(
                                  article: article,
                                  onTap: () => _openDetail(context, article),
                                ),
                                // Divider (except for last item)
                                if (index < listItems.length - 1)
                                  Divider(
                                    height: 1, 
                                    indent: 122, // Align with text start roughly
                                    endIndent: 16,
                                    color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
                                  ),
                              ],
                            );
                          },
                          childCount: listItems.length,
                        ),
                      ),
                      
                      // Bottom Padding
                      const SliverToBoxAdapter(child: SizedBox(height: 100)),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
