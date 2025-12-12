import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models.dart';
import '../services/breaking_news_service.dart';
import '../design_tokens.dart';
import '../screens/breaking_news_detail_screen.dart';

class BreakingNewsListWidget extends StatefulWidget {
  final String languageCode;

  const BreakingNewsListWidget({super.key, required this.languageCode});

  @override
  State<BreakingNewsListWidget> createState() => _BreakingNewsListWidgetState();
}

class _BreakingNewsListWidgetState extends State<BreakingNewsListWidget>
    with SingleTickerProviderStateMixin {
  final BreakingNewsService _service = BreakingNewsService();
  List<BreakingNews> _news = [];
  bool _isLoading = true;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  late final RealtimeChannel _channel;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 0.5).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _channel = Supabase.instance.client.channel(
      'breaking-news-changes-flutter',
    );
    _channel
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'content',
          table: 'breaking_news',
          callback: (payload) {
            _fetchNews();
          },
        )
        .subscribe();

    _fetchNews();
  }

  @override
  void didUpdateWidget(BreakingNewsListWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.languageCode != widget.languageCode) {
      _fetchNews();
    }
  }

  @override
  void dispose() {
    _channel.unsubscribe();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _fetchNews() async {
    setState(() => _isLoading = true);
    try {
      final news = await _service.fetchBreakingNews(widget.languageCode);
      if (mounted) {
        setState(() {
          _news = news;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoading && _news.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.space2,
        right: AppSpacing.space2,
        top: 2.0,
        bottom: AppSpacing.space3,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors
                      .brandBase, // Using brand green for background like web
                  borderRadius: BorderRadius.circular(100),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.brandBase.withOpacity(0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    FadeTransition(
                      opacity: _pulseAnimation,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.breakingNewsRedBright,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.breakingNewsRedBright,
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'BREAKING',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  height: 1,
                  margin: const EdgeInsets.only(left: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.brandBase.withOpacity(0.2),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 4.0),

          // List
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              ),
            )
          else
            ListView.separated(
              physics:
                  const NeverScrollableScrollPhysics(), // Nested in scroll view
              shrinkWrap: true,
              itemCount: _news.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: AppColors.neutralBorder.withOpacity(0.5),
              ),
              itemBuilder: (context, index) {
                final item = _news[index];
                return InkWell(
                  onTap: () {
                    // Navigate to Full Screen Modal
                    showGeneralDialog(
                      context: context,
                      barrierDismissible: true,
                      barrierLabel: 'Close',
                      pageBuilder: (context, anim1, anim2) =>
                          BreakingNewsDetailScreen(
                            initialNewsId: item.id,
                            allNews: _news,
                          ),
                      transitionBuilder: (ctx, anim1, anim2, child) {
                        return SlideTransition(
                          position:
                              Tween(
                                begin: const Offset(0, 1),
                                end: Offset.zero,
                              ).animate(
                                CurvedAnimation(
                                  parent: anim1,
                                  curve: Curves.easeOutCubic,
                                ),
                              ),
                          child: child,
                        );
                      },
                      transitionDuration: const Duration(milliseconds: 300),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 8,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            item.headline,
                            style: const TextStyle(
                              fontSize: AppTypography.fontSizeMd,
                              fontWeight: AppTypography
                                  .fontWeightBold, // font-medium in web, bold here for read
                              color: AppColors.neutralText,
                              height: 1.4,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          // Simple time formatting
                          "${item.createdAt.hour.toString().padLeft(2, '0')}:${item.createdAt.minute.toString().padLeft(2, '0')}",
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.neutralTextMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
