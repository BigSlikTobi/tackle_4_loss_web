/// Team Hint Button widget for the daily challenge.
/// Reveals the mystery player's team for 50 points.
library;

import 'package:flutter/material.dart';
import '../../../../design_tokens.dart';
import '../../../../core/theme/t4l_theme.dart';

/// Button to reveal the mystery player's team (costs 50 points).
class TeamHintButton extends StatelessWidget {
  /// Whether the team hint can be used (after 3 guesses without correct team)
  final bool canUse;
  
  /// Whether the user has enough points (>= 50)
  final bool hasEnoughPoints;
  
  /// Current points balance
  final int totalPoints;
  
  /// The revealed team name (if hint used)
  final String? revealedTeam;
  
  /// Callback when hint is requested
  final VoidCallback onUseHint;
  
  /// Cost of the team hint
  static const int cost = 50;

  const TeamHintButton({
    super.key,
    required this.canUse,
    required this.hasEnoughPoints,
    required this.totalPoints,
    this.revealedTeam,
    required this.onUseHint,
  });

  @override
  Widget build(BuildContext context) {
    // Don't show if not available yet (need 3 guesses)
    if (!canUse && revealedTeam == null) {
      return const SizedBox.shrink();
    }
    
    if (revealedTeam != null) {
      return _buildRevealedHint(context);
    }
    
    return _buildHintButton(context);
  }

  Widget _buildRevealedHint(BuildContext context) {
    final colors = Theme.of(context).extension<T4LThemeColors>()!;
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space2,
        vertical: AppSpacing.space1,
      ),
      decoration: BoxDecoration(
        color: colors.brand.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppBorders.radiusXl),
        border: Border.all(
          color: colors.brand,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.shield,
            color: colors.brand,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.space1),
          Text(
            'Team: $revealedTeam',
            style: TextStyle(
              fontSize: AppTypography.fontSizeSm,
              fontWeight: AppTypography.fontWeightBold,
              color: colors.brand,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHintButton(BuildContext context) {
    final colors = Theme.of(context).extension<T4LThemeColors>()!;
    final isEnabled = hasEnoughPoints;
    
    return TextButton.icon(
      onPressed: isEnabled ? onUseHint : null,
      style: TextButton.styleFrom(
        foregroundColor: isEnabled 
            ? colors.brand 
            : colors.textSecondary,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space2,
          vertical: AppSpacing.space1,
        ),
        backgroundColor: isEnabled
            ? colors.brand.withValues(alpha: 0.1)
            : colors.textSecondary.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorders.radiusMd),
        ),
      ),
      icon: Icon(
        Icons.shield_outlined, 
        size: 18,
        color: isEnabled ? colors.brand : colors.textSecondary,
      ),
      label: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Reveal Team',
            style: TextStyle(
              fontSize: AppTypography.fontSizeSm,
              color: isEnabled ? colors.brand : colors.textSecondary,
            ),
          ),
          Text(
            isEnabled 
                ? '$cost PTS' 
                : 'Need $cost pts (have $totalPoints)',
            style: TextStyle(
              fontSize: 9,
              color: isEnabled 
                  ? colors.brand.withValues(alpha: 0.7)
                  : colors.textSecondary.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

