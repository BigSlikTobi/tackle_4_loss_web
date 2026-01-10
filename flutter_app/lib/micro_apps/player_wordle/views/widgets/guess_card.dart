import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../../../design_tokens.dart';
import '../../../../l10n/app_localizations.dart';
import '../../models/guess_result.dart';

/// Colors for match status feedback.
class FeedbackColors {
  static const Color match = Color(0xFF22C55E); // Green-500
  static const Color partial = Color(0xFFF59E0B); // Amber-500
  static const Color miss = Color(0xFF6B7280); // Gray-500
}

/// A single guess displayed as a card with clear feedback.
class GuessCard extends StatefulWidget {
  final GuessResult guess;
  final int guessNumber;
  final bool isLatest;

  const GuessCard({
    super.key,
    required this.guess,
    required this.guessNumber,
    this.isLatest = false,
  });

  @override
  State<GuessCard> createState() => _GuessCardState();
}

class _GuessCardState extends State<GuessCard> {
  int _revealedCount = 0;
  final int _totalAttributes = 7;
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.isLatest;
    if (widget.isLatest) {
      _animateReveal();
    } else {
      _revealedCount = _totalAttributes;
    }
  }

  Future<void> _animateReveal() async {
    // Initial delay before starting
    await Future.delayed(const Duration(milliseconds: 300));
    
    for (int i = 1; i <= _totalAttributes; i++) {
      if (!mounted) return;
      
      // Delay between reveals (Adjusted to 600ms for slower reveal)
      await Future.delayed(const Duration(milliseconds: 600));
      
      if (mounted) {
        setState(() {
          _revealedCount = i;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final player = widget.guess.guessedPlayer;
    final isCorrect = widget.guess.isCorrect;
    
    return GestureDetector(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      child: AnimatedContainer(
        duration: AppAnimation.durationNormal,
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space2,
          vertical: AppSpacing.space1,
        ),
        decoration: BoxDecoration(
          color: isCorrect 
              ? FeedbackColors.match.withValues(alpha: 0.1)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(AppBorders.radiusXl),
          border: Border.all(
            color: isCorrect 
                ? FeedbackColors.match 
                : (widget.isLatest ? AppColors.brandBase : AppColors.neutralBorder),
            width: isCorrect || widget.isLatest ? 2 : 1,
          ),
          boxShadow: widget.isLatest ? AppShadows.md : AppShadows.sm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Player header
            _buildPlayerHeader(player),
            
            AnimatedCrossFade(
              firstChild: Padding(
                padding: const EdgeInsets.only(
                  left: 72, // Align with text
                  right: AppSpacing.space2,
                  bottom: AppSpacing.space2,
                ), 
                child: _buildCompactDots(),
              ),
              secondChild: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(height: 1, color: AppColors.neutralBorder),
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.space2),
                    child: _buildAttributeGrid(),
                  ),
                ],
              ),
              crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: AppAnimation.durationNormal,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactDots() {
    return Row(
      children: [
        _buildDot(widget.guess.conferenceMatch == MatchStatus.match ? FeedbackColors.match : FeedbackColors.miss),
        const SizedBox(width: 8),
        _buildDot(switch (widget.guess.divisionMatch) {
          MatchStatus.match => FeedbackColors.match,
          MatchStatus.partial => FeedbackColors.partial,
          MatchStatus.miss => FeedbackColors.miss,
        }),
        const SizedBox(width: 8),
        _buildDot(switch (widget.guess.teamMatch) {
          MatchStatus.match => FeedbackColors.match,
          MatchStatus.partial => FeedbackColors.partial,
          MatchStatus.miss => FeedbackColors.miss,
        }),
        const SizedBox(width: 8),
        _buildDot(widget.guess.positionMatch == MatchStatus.match ? FeedbackColors.match : FeedbackColors.miss),
        const SizedBox(width: 8),
        _buildDot(_getNumericColor(widget.guess.jerseyComparison)),
        const SizedBox(width: 8),
        _buildDot(_getNumericColor(widget.guess.ageComparison)),
        const SizedBox(width: 8),
        _buildDot(_getNumericColor(widget.guess.heightComparison)),
      ],
    );
  }

  Color _getNumericColor(NumericComparison comparison) {
    if (comparison.match) return FeedbackColors.match;
    if (comparison.isClose) return FeedbackColors.partial;
    return FeedbackColors.miss;
  }

  Widget _buildDot(Color color) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildPlayerHeader(player) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.space2),
      child: Row(
        children: [
          // Guess number badge
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.brandBase, // Keep brand color for badge
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${widget.guessNumber}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.space2),
          // Player photo
          CircleAvatar(
            radius: 22,
            foregroundImage: player.headshot != null
                ? NetworkImage(player.headshot!)
                : null,
            onForegroundImageError: (_, __) {},
            backgroundColor: AppColors.neutralBorder,
            child: const Icon(Icons.person, size: 22, color: AppColors.textSecondary),
          ),
          const SizedBox(width: AppSpacing.space2),
          // Player name and team
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.displayName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${player.team ?? AppLocalizations.of(context)!.playerWordleNotAvailable} • ${player.position ?? AppLocalizations.of(context)!.playerWordleNotAvailable}',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Result icon (revealed last) - ONLY show on Latest (Full) card or if it is the Correct one?
          // Actually, for compact view, the green dots tell the story. But a checkmark is nice if correct.
          if (_revealedCount >= _totalAttributes && widget.guess.isCorrect)
            const Icon(Icons.check_circle, color: FeedbackColors.match, size: 28),
        ],
      ),
    );
  }

  Widget _buildAttributeGrid() {
    final l10n = AppLocalizations.of(context)!;
    return Wrap(
      spacing: AppSpacing.space1,
      runSpacing: AppSpacing.space1,
      children: [
        _buildRevealingChip(
          0, l10n.playerWordleHeaderConf, widget.guess.guessedPlayer.conference ?? '?', 
          widget.guess.conferenceMatch == MatchStatus.match,
          widget.guess.conferenceMatch == MatchStatus.miss,
          widget.guess.conferenceMatch == MatchStatus.match ? FeedbackColors.match : FeedbackColors.miss
        ),
        _buildRevealingChip(
          1, l10n.playerWordleHeaderDiv, _shortDivision(widget.guess.guessedPlayer.division),
          widget.guess.divisionMatch == MatchStatus.match,
          widget.guess.divisionMatch == MatchStatus.miss,
          switch (widget.guess.divisionMatch) {
            MatchStatus.match => FeedbackColors.match,
            MatchStatus.partial => FeedbackColors.partial,
            MatchStatus.miss => FeedbackColors.miss,
          }
        ),
        _buildRevealingChip(
          2, l10n.playerWordleHeaderTeam, widget.guess.guessedPlayer.team ?? '?',
          widget.guess.teamMatch == MatchStatus.match,
          widget.guess.teamMatch == MatchStatus.miss,
          switch (widget.guess.teamMatch) {
            MatchStatus.match => FeedbackColors.match,
            MatchStatus.partial => FeedbackColors.partial,
            MatchStatus.miss => FeedbackColors.miss,
          }
        ),
        _buildRevealingChip(
          3, l10n.playerWordleHeaderPos, widget.guess.guessedPlayer.position ?? '?',
          widget.guess.positionMatch == MatchStatus.match,
          widget.guess.positionMatch == MatchStatus.miss,
          switch (widget.guess.positionMatch) {
            MatchStatus.match => FeedbackColors.match,
            MatchStatus.partial => FeedbackColors.partial,
            MatchStatus.miss => FeedbackColors.miss,
          }
        ),
        _buildRevealingNumericChip(
          4, l10n.playerWordleHeaderNum, widget.guess.guessedPlayer.jerseyNumber?.toString() ?? '?',
          widget.guess.jerseyComparison
        ),
        _buildRevealingNumericChip(
          5, l10n.playerWordleHeaderAge, widget.guess.guessedPlayer.age?.toString() ?? '?',
          widget.guess.ageComparison
        ),
        _buildRevealingNumericChip(
          6, l10n.playerWordleHeaderHt, widget.guess.guessedPlayer.displayHeight,
          widget.guess.heightComparison
        ),
      ],
    );
  }

  Widget _buildRevealingChip(int index, String label, String value, bool isMatch, bool isMiss, Color color) {
    return _RevealingChip(
      isRevealed: index < _revealedCount,
      isMatch: isMatch,
      isMiss: isMiss,
      color: color,
      child: _buildChipContent(label, value),
    );
  }

  Widget _buildRevealingNumericChip(int index, String label, String value, NumericComparison comparison) {
    final color = comparison.match 
        ? FeedbackColors.match 
        : (comparison.isClose ? FeedbackColors.partial : FeedbackColors.miss);

    String displayValue = value;
    if (!comparison.match && comparison.direction != NumericDirection.exact) {
      displayValue = '$value ${comparison.direction == NumericDirection.up ? "↑" : "↓"}';
    }

    return _RevealingChip(
      isRevealed: index < _revealedCount,
      isMatch: comparison.match,
      isMiss: !comparison.match && !comparison.isClose,
      color: color,
      child: _buildChipContent(label, displayValue),
    );
  }

  Widget _buildChipContent(String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  String _shortDivision(String? division) {
    if (division == null) return '?';
    final parts = division.split(' ');
    if (parts.length > 1) {
      return parts[1].substring(0, 1).toUpperCase(); // N, S, E, W
    }
    return division.length > 2 ? division.substring(0, 1) : division;
  }
}

class _RevealingChip extends StatefulWidget {
  final bool isRevealed;
  final bool isMatch;
  final bool isMiss;
  final Color color;
  final Widget child;

  const _RevealingChip({
    required this.isRevealed,
    required this.isMatch,
    required this.isMiss,
    required this.color,
    required this.child,
  });

  @override
  State<_RevealingChip> createState() => _RevealingChipState();
}

class _RevealingChipState extends State<_RevealingChip> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shakeAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700), // Slower pulse/shake
    );

    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -3), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -3, end: 3), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 3, end: -3), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -3, end: 0), weight: 1),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _pulseAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.1), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.1, end: 1.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(_RevealingChip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRevealed && !oldWidget.isRevealed) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isRevealed) return const SizedBox();

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Base reveal: Blur to Clear + Fade In
        final transform = Matrix4.identity();
        if (widget.isMiss) {
          transform.translate(_shakeAnimation.value);
        } else if (widget.isMatch) {
          transform.scale(_pulseAnimation.value);
        }

        return Transform(
          transform: transform,
          alignment: Alignment.center,
          child: child,
        );
      },
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 600), // Slower blur
        tween: Tween(begin: 10.0, end: 0.0), // Blur amount
        builder: (context, blur, child) {
          return TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 500), // Slower fade in
            tween: Tween(begin: 0.0, end: 1.0), // Opacity
            builder: (context, opacity, _) {
              // Combining effects
              return Opacity(
                opacity: opacity,
                child: ImageFiltered(
                  imageFilter: ui.ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: widget.color,
                      borderRadius: BorderRadius.circular(AppBorders.radiusMd),
                    ),
                    child: widget.child,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
