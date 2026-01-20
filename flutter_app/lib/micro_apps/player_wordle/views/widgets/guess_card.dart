import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../../../design_tokens.dart';
import '../../../../design_tokens.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/theme/t4l_theme.dart';
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
    await Future.delayed(const Duration(milliseconds: 150));
    
    for (int i = 1; i <= _totalAttributes; i++) {
      if (!mounted) return;
      
      // Delay between reveals (250ms for snappy but readable pace)
      await Future.delayed(const Duration(milliseconds: 250));
      
      if (mounted) {
        setState(() {
          _revealedCount = i;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<T4LThemeColors>()!;
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
              : colors.surface,
          borderRadius: BorderRadius.circular(AppBorders.radiusXl),
          border: Border.all(
            color: isCorrect 
                ? FeedbackColors.match 
                : (widget.isLatest ? colors.brand : colors.border),
            width: isCorrect || widget.isLatest ? 2 : 1,
          ),
          boxShadow: widget.isLatest ? AppShadows.md : AppShadows.sm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Player header
            _buildPlayerHeader(player, colors),
            
            AnimatedCrossFade(
              firstChild: Padding(
                padding: const EdgeInsets.only(
                  left: 40, // Align with text (Badge 24 + Gap 8 + Padding 8)
                  right: AppSpacing.space2,
                  bottom: AppSpacing.space2,
                ), 
                child: _buildCompactDots(),
              ),
              secondChild: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(height: 1, color: colors.border),
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

  Widget _buildPlayerHeader(player, T4LThemeColors colors) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.space2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Guess number badge
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: colors.brand, // Keep brand color for badge
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${widget.guessNumber}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.space2),
          
          // Player name and team (Left aligned)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.displayName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${player.team ?? AppLocalizations.of(context)!.playerWordleNotAvailable} • ${player.position ?? AppLocalizations.of(context)!.playerWordleNotAvailable}',
                  style: TextStyle(
                    fontSize: 13,
                    color: colors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(width: AppSpacing.space2),
          
          // Player photo (Right aligned, larger)
          Hero(
            tag: 'player_headshot_${player.playerId}_${widget.guessNumber}',
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.surface,
                border: Border.all(color: colors.border, width: 1),
                boxShadow: AppShadows.sm,
              ),
              child: ClipOval(
                child: player.headshot != null
                    ? Image.network(
                        player.headshot!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(Icons.person, size: 32, color: colors.textSecondary),
                      )
                    : Icon(Icons.person, size: 32, color: colors.textSecondary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttributeGrid() {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildVerticalAttribute(
          0, 'CONF', widget.guess.guessedPlayer.conference ?? '?', 
          widget.guess.conferenceMatch == MatchStatus.match,
          widget.guess.conferenceMatch == MatchStatus.miss,
          widget.guess.conferenceMatch == MatchStatus.match ? FeedbackColors.match : FeedbackColors.miss
        ),
        _buildVerticalAttribute(
          1, 'DIV', _shortDivision(widget.guess.guessedPlayer.division),
          widget.guess.divisionMatch == MatchStatus.match,
          widget.guess.divisionMatch == MatchStatus.miss,
          switch (widget.guess.divisionMatch) {
            MatchStatus.match => FeedbackColors.match,
            MatchStatus.partial => FeedbackColors.partial,
            MatchStatus.miss => FeedbackColors.miss,
          }
        ),
        _buildVerticalAttribute(
          2, 'TEAM', widget.guess.guessedPlayer.team ?? '?',
          widget.guess.teamMatch == MatchStatus.match,
          widget.guess.teamMatch == MatchStatus.miss,
          switch (widget.guess.teamMatch) {
            MatchStatus.match => FeedbackColors.match,
            MatchStatus.partial => FeedbackColors.partial,
            MatchStatus.miss => FeedbackColors.miss,
          }
        ),
        _buildVerticalAttribute(
          3, 'POS', widget.guess.guessedPlayer.position ?? '?',
          widget.guess.positionMatch == MatchStatus.match,
          widget.guess.positionMatch == MatchStatus.miss,
          switch (widget.guess.positionMatch) {
            MatchStatus.match => FeedbackColors.match,
            MatchStatus.partial => FeedbackColors.partial,
            MatchStatus.miss => FeedbackColors.miss,
          }
        ),
        _buildVerticalNumericAttribute(
          4, '#', widget.guess.guessedPlayer.jerseyNumber?.toString() ?? '?',
          widget.guess.jerseyComparison
        ),
        _buildVerticalNumericAttribute(
          5, 'AGE', widget.guess.guessedPlayer.age?.toString() ?? '?',
          widget.guess.ageComparison
        ),
        _buildVerticalNumericAttribute(
          6, 'HT', widget.guess.guessedPlayer.displayHeight,
          widget.guess.heightComparison
        ),
      ],
    );
  }

  Widget _buildVerticalAttribute(int index, String label, String value, bool isMatch, bool isMiss, Color color) {
    return Expanded(
      child: _RevealingChip(
        isRevealed: index < _revealedCount,
        isMatch: isMatch,
        isMiss: isMiss,
        color: color,
        child: _buildVerticalContent(label, value, color),
      ),
    );
  }

  Widget _buildVerticalNumericAttribute(int index, String label, String value, NumericComparison comparison) {
    final color = comparison.match 
        ? FeedbackColors.match 
        : (comparison.isClose ? FeedbackColors.partial : FeedbackColors.miss);

    String displayValue = value;
    if (!comparison.match && comparison.direction != NumericDirection.exact) {
      displayValue = '$value${comparison.direction == NumericDirection.up ? "↑" : "↓"}';
    }

    return Expanded(
      child: _RevealingChip(
        isRevealed: index < _revealedCount,
        isMatch: comparison.match,
        isMiss: !comparison.match && !comparison.isClose,
        color: color,
        child: _buildVerticalContent(label, displayValue, color),
      ),
    );
  }

  Widget _buildVerticalContent(String label, String value, Color color) {
    final colors = Theme.of(context).extension<T4LThemeColors>()!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label outside the box
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: colors.textSecondary,
          ),
          maxLines: 1,
          overflow: TextOverflow.clip,
        ),
        const SizedBox(height: 4),
        // Colored box with value
        Container(
          height: 32, // Fixed height for uniformity
          width: double.infinity,
          alignment: Alignment.center,
          margin: const EdgeInsets.symmetric(horizontal: 2), // Spacing between boxes
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(AppBorders.radiusMd),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
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
      duration: const Duration(milliseconds: 400), // Quick pulse/shake
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
        duration: const Duration(milliseconds: 300), // Quick blur
        tween: Tween(begin: 8.0, end: 0.0), // Blur amount
        builder: (context, blur, child) {
          return TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 250), // Quick fade in
            tween: Tween(begin: 0.0, end: 1.0), // Opacity
            builder: (context, opacity, _) {
              // Combining effects
              return Opacity(
                opacity: opacity,
                child: ImageFiltered(
                  imageFilter: ui.ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                  child: widget.child,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
