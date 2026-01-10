/// Game Stats Card displaying player statistics.
library;

import 'package:flutter/material.dart';
import '../../../../design_tokens.dart';
import '../../../../l10n/app_localizations.dart';

/// Displays game statistics (streak, win rate).
class GameStatsCard extends StatelessWidget {
  /// Current win streak
  final int currentStreak;
  
  /// Maximum win streak achieved
  final int maxStreak;
  
  /// Total games played
  final int gamesPlayed;
  
  /// Total games won
  final int gamesWon;

  const GameStatsCard({
    super.key,
    required this.currentStreak,
    required this.maxStreak,
    required this.gamesPlayed,
    required this.gamesWon,
  });

  @override
  Widget build(BuildContext context) {
    final winPercentage = gamesPlayed > 0 
        ? ((gamesWon / gamesPlayed) * 100).round() 
        : 0;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.space2),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppBorders.radiusLg),
        boxShadow: AppShadows.sm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStat(
            context,
            value: gamesPlayed.toString(),
            label: AppLocalizations.of(context)!.playerWordleStatPlayed,
          ),
          _buildStat(
            context,
            value: '$winPercentage%',
            label: AppLocalizations.of(context)!.playerWordleStatWon,
          ),
          _buildStat(
            context,
            value: currentStreak.toString(),
            label: AppLocalizations.of(context)!.playerWordleStatStreak,
            highlight: currentStreak >= 3,
          ),
          _buildStat(
            context,
            value: maxStreak.toString(),
            label: AppLocalizations.of(context)!.playerWordleStatMax,
          ),
        ],
      ),
    );
  }

  Widget _buildStat(
    BuildContext context, {
    required String value,
    required String label,
    bool highlight = false,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (highlight) ...[
              const Text('🔥', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 4),
            ],
            Text(
              value,
              style: TextStyle(
                fontSize: AppTypography.fontSizeLg,
                fontWeight: AppTypography.fontWeightBold,
                color: highlight ? const Color(0xFFEF4444) : AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: AppTypography.fontSizeSm,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
