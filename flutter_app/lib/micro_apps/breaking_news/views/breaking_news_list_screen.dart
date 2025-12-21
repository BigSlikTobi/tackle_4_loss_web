import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../design_tokens.dart';
import '../../../core/os_shell/widgets/t4l_scaffold.dart';
import '../../../core/services/settings_service.dart';
import '../models/breaking_news_article.dart'; // Added Import
import '../controllers/breaking_news_controller.dart';
import 'widgets/breaking_news_card.dart';
import 'widgets/swipeable_card_stack.dart';
import 'package:intl/intl.dart';
import 'widgets/side_stack_widget.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/theme/t4l_theme.dart';

class BreakingNewsListScreen extends StatefulWidget {
  const BreakingNewsListScreen({super.key});

  @override
  State<BreakingNewsListScreen> createState() => _BreakingNewsListScreenState();
}

class _BreakingNewsListScreenState extends State<BreakingNewsListScreen> {
  final BreakingNewsController _controller = BreakingNewsController();
  final GlobalKey<SwipeableCardStackState> _stackKey = GlobalKey<SwipeableCardStackState>();

  bool _showSaved = false;
  bool _isLoaded = false;
  
  // History List Overlay State
  List<BreakingNewsArticle>? _historyArticles;
  String? _historyTitle;
  Color? _historyColor;
  bool _showHistory = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isLoaded) {
      final locale = Localizations.localeOf(context).languageCode;
      _controller.loadNews(languageCode: locale);
      _isLoaded = true;
    }
  }

  void _showHistoryList({
    required List<BreakingNewsArticle> articles,
    required String title,
    required Color color,
  }) {
    setState(() {
      // Create a modifiable copy so we can remove items locally for instant UI feedback
      _historyArticles = List.from(articles);
      _historyTitle = title;
      _historyColor = color;
      _showHistory = true;
    });
  }

  void _restoreFromHistory(BreakingNewsArticle article) {
    _controller.restoreArticle(article);
    setState(() {
      _showHistory = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).extension<T4LThemeColors>()!;

    return ChangeNotifierProvider.value(
      value: _controller,
      child: T4LScaffold(
        title: l10n.breakingNewsTitle,
        body: Stack(
          children: [
            Column(
              children: [
                const SizedBox(height: 140), 

                Expanded(
                  child: Consumer<BreakingNewsController>(
                    builder: (context, controller, child) {
                      if (controller.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      
                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // 1. Active Cards (Bottom Layer of this Stack)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                            child: SwipeableCardStack(
                              key: _stackKey,
                              articles: controller.articles,
                              onCardFlip: null, // No longer marking as read simply on flip
                              onReadFinished: (article) {
                                controller.markAsRead(article.id);
                                // Trigger programmatic swipe left to "put it down"
                                _stackKey.currentState?.swipeLeft();
                              },
                              onSwipeLeft: (article) => controller.swipeLeft(article),
                              onSwipeRight: (article) => controller.swipeRight(article),
                            ),
                          ),

                          // 2. Side Stacks (Badges - Top Layer)
                          // Refused (Red) - Upper Left
                          Positioned(
                            left: -4,
                            top: screenHeight * 0.15,
                            child: SideStackWidget(
                              articles: controller.refusedArticles, 
                              color: colors.breakingNewsRed,
                              alignment: Alignment.centerLeft,
                              onStackTap: () => _showHistoryList(
                                articles: controller.refusedArticles,
                                title: l10n.breakingNewsRefused,
                                color: colors.breakingNewsRed,
                              ),
                            ),
                          ),
                          
                          // Read History (Dynamic) - Lower Left
                          Positioned(
                            left: -4,
                            bottom: screenHeight * 0.15,
                            child: SideStackWidget(
                              articles: controller.readHistoryArticles,
                              color: colors.textPrimary,
                              alignment: Alignment.centerLeft,
                              onStackTap: () => _showHistoryList(
                                articles: controller.readHistoryArticles,
                                title: l10n.breakingNewsReadHistory,
                                color: colors.textPrimary,
                              ),
                            ),
                          ),
                          
                          // Saved (Brand) - Center Right
                          Positioned(
                            right: -4,
                            top: screenHeight * 0.3,
                            child: SideStackWidget(
                              articles: controller.savedArticles,
                              color: colors.brand, 
                              alignment: Alignment.centerRight,
                              onStackTap: () => _showHistoryList(
                                articles: controller.savedArticles,
                                title: l10n.breakingNewsSaved,
                                color: colors.brand,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),

            // 3. History Overlay (Foreground)
            if (_showHistory && _historyArticles != null)
              _buildHistoryOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryOverlay() {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).extension<T4LThemeColors>()!;

    return Positioned.fill(
      child: GestureDetector(
        onTap: () => setState(() => _showHistory = false),
        child: Container(
          color: Colors.black54,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 160),
          child: GestureDetector(
            onTap: () {}, // Prevent tap-through
            child: Material(
              color: colors.surface,
              elevation: 20,
              borderRadius: BorderRadius.circular(24),
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _historyTitle ?? l10n.breakingNewsHistory,
                          style: TextStyle(
                            fontFamily: AppTextStyles.fontHeading,
                            fontSize: 18,
                            color: (_historyColor ?? colors.textPrimary).computeLuminance() > 0.5 && Theme.of(context).brightness == Brightness.light ? Colors.black : (_historyColor ?? colors.textPrimary),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: colors.textSecondary),
                          onPressed: () => setState(() => _showHistory = false),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, color: colors.border.withOpacity(0.5)),
                  // List
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.all(12),
                      itemCount: _historyArticles!.length,
                      separatorBuilder: (context, index) => Divider(color: colors.border.withOpacity(0.2)),
                      itemBuilder: (context, index) {
                        final article = _historyArticles![index];
                        return ListTile(
                          title: Text(
                            article.headline,
                            style: TextStyle(
                              fontSize: 14, 
                              fontWeight: FontWeight.w500,
                              color: colors.textPrimary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.settings_backup_restore, color: colors.brand),
                            onPressed: () => _restoreFromHistory(article),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
