
import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../design_tokens.dart';
import '../../models/breaking_news_article.dart';
import 'package:intl/intl.dart';

import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/services/settings_service.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/theme/t4l_theme.dart';

class BreakingNewsCard extends StatefulWidget {
  final BreakingNewsArticle article;
  final VoidCallback? onFlip;
  final ValueChanged<bool>? onFlipChanged;
  final VoidCallback? onReadFinished;

  const BreakingNewsCard({
    super.key,
    required this.article,
    this.onFlip,
    this.onFlipChanged,
    this.onReadFinished,
  });

  @override
  State<BreakingNewsCard> createState() => _BreakingNewsCardState();
}

class _BreakingNewsCardState extends State<BreakingNewsCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _frontRotation;
  late Animation<double> _backRotation;
  bool _isFront = true;

  late ScrollController _scrollController;
  bool _isFullyRead = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    _controller = AnimationController(
        duration: const Duration(milliseconds: 600), vsync: this);

    _frontRotation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -pi / 2), weight: 50),
      TweenSequenceItem(tween: ConstantTween(-pi / 2), weight: 50),
    ]).animate(_controller);

    _backRotation = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(pi / 2), weight: 50),
      TweenSequenceItem(tween: Tween(begin: pi / 2, end: 0.0), weight: 50),
    ]).animate(_controller);
  }

  void _flipCard() {
    if (_isFront) {
      _controller.forward();
      // Call onFlip when flipping to back (reading)
      widget.onFlip?.call();
    } else {
      _controller.reverse();
      // If fully read, notify parent when closing the story
      if (_isFullyRead) {
        widget.onReadFinished?.call();
      }
    }
    
    setState(() => _isFront = !_isFront);
    
    // Notify change: true = back visible (reading), false = front visible
    widget.onFlipChanged?.call(!_isFront);
  }

  void _scrollListener() {
    if (!_isFullyRead && _scrollController.hasClients) {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 20) {
        setState(() {
          _isFullyRead = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _flipCard,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Front Side
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform(
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(_frontRotation.value),
                alignment: Alignment.center,
                child: _frontRotation.value >= -pi / 2
                    ? _buildFront()
                    : const SizedBox.shrink(),
              );
            },
          ),
          // Back Side
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform(
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(_backRotation.value),
                alignment: Alignment.center,
                child: _backRotation.value <= pi / 2
                    ? _buildBack()
                    : const SizedBox.shrink(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFront() {
    final colors = Theme.of(context).extension<T4LThemeColors>()!;
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final imageUrl = widget.article.imageUrl ?? 
        'https://images.unsplash.com/photo-1504711434969-e33886168f5c?q=80&w=3540&auto=format&fit=crop';

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppShadows.xl,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: colors.textPrimary.withOpacity(0.1),
              child: const Center(child: CircularProgressIndicator()),
            ),
            errorWidget: (context, url, error) => Container(
              color: colors.textPrimary.withOpacity(0.05),
              child: const Icon(Icons.broken_image, color: Colors.white24, size: 48),
            ),
          ),
          
          // Gradient Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.2),
                  Colors.black.withOpacity(0.9),
                ],
                stops: const [0.4, 0.6, 1.0],
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tag & Time
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: colors.breakingNewsRed,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        l10n.breakingNewsTag,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12, // AppTypography.fontSizeSm - small adj
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      DateFormat('h:mm a').format(widget.article.createdAt.toLocal()),
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Headline
                Text(
                  widget.article.headline,
                  style: TextStyle(
                    fontFamily: 'RussoOne',
                    color: Colors.white,
                    fontSize: 28,
                    height: 1.1,
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
                
                if (widget.article.subHeader != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    widget.article.subHeader!,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 24), // Bottom padding visual
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBack() {
    final colors = Theme.of(context).extension<T4LThemeColors>()!;
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final bgColor = colors.surface;
    final textColor = colors.textPrimary;
    final subTextColor = colors.textSecondary;
    final borderColor = colors.border.withOpacity(0.5);

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppShadows.md,
      ),
      child: Column(
        children: [
          // Header Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: borderColor)),
            ),
            child: Row(
              children: [
                Icon(Icons.article_outlined, color: textColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.breakingNewsBackTitle,
                    style: AppTextStyles.h3.copyWith(color: textColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (_isFullyRead)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(Icons.check_circle, color: Colors.green, size: 20),
                  ),
                const SizedBox(width: 8),
                
                // Team Logos - Use Wrap to prevent overflow if many teams
                if (widget.article.teams != null && widget.article.teams!.isNotEmpty)
                   ConstrainedBox(
                     constraints: const BoxConstraints(maxWidth: 120),
                     child: Wrap(
                       alignment: WrapAlignment.end,
                       spacing: -8, // Slight overlap for style
                       children: widget.article.teams!.take(3).map((team) {
                         final teamId = team['team_id']?.toString().toLowerCase() ?? '';
                         if (teamId.isEmpty) return const SizedBox.shrink();
                         
                         return Container(
                           decoration: BoxDecoration(
                             shape: BoxShape.circle,
                             border: Border.all(color: bgColor, width: 2),
                             color: Colors.white,
                           ),
                           child: Image.asset(
                             'assets/logos/teams/$teamId.png',
                             width: 28,
                             height: 28,
                             errorBuilder: (_,__,___) => const SizedBox.shrink(),
                           ),
                         );
                       }).toList(),
                     ),
                   ),
              ],
            ),
          ),
          
          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Players Section (Headshots)
                  if (widget.article.players != null && widget.article.players!.isNotEmpty) ...[
                    SizedBox(
                      height: 60,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: widget.article.players!.length,
                        itemBuilder: (context, index) {
                          final player = widget.article.players![index];
                          final headshotUrl = player['headshot_url'];
                          if (headshotUrl == null) return const SizedBox.shrink();
                          
                          return Padding(
                            padding: const EdgeInsets.only(right: 12.0),
                            child: CircleAvatar(
                              radius: 24,
                              backgroundColor: isDark ? Colors.white10 : AppColors.neutralSoft,
                              backgroundImage: NetworkImage(headshotUrl),
                              onBackgroundImageError: (_, __) {},
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Divider(color: borderColor, height: 32),
                  ],

                  Text(
                    widget.article.headline,
                    style: AppTextStyles.h2.copyWith(fontSize: 22, color: textColor),
                  ),
                  const SizedBox(height: 16),
                  
                  if (widget.article.introductionParagraph != null)
                    Text(
                      widget.article.introductionParagraph!,
                      style: AppTextStyles.body.copyWith(
                        height: 1.6,
                        color: textColor, // Strong emphasis
                        fontWeight: FontWeight.w600,
                        fontSize: 16
                      ),
                    ),
                  
                  if (widget.article.content != null) ...[
                     const SizedBox(height: 20),
                     Text(
                        widget.article.content!,
                        style: AppTextStyles.body.copyWith(
                          height: 1.6,
                          color: subTextColor,
                          fontSize: 16
                        ),
                     ),
                  ]
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
