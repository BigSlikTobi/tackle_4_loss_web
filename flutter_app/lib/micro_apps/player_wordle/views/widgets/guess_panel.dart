/// Main guess panel combining team selector, position filter, and player grid.
library;

import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../../../design_tokens.dart';
import '../../../../core/theme/t4l_theme.dart';
import '../../models/player_model.dart';
import '../../models/game_state.dart';
import 'team_selector.dart';
import 'position_filter.dart';
import 'player_grid.dart';

/// Bottom panel for selecting a player guess via Team → Position → Player flow.
class GuessPanel extends StatelessWidget {
  /// Currently selected team.
  final String? selectedTeam;

  /// Currently selected position.
  final String? selectedPosition;

  /// Players matching current filters.
  final List<Player> filteredPlayers;

  /// Whether players are loading.
  final bool isLoading;

  /// Current difficulty level.
  final Difficulty difficulty;

  /// Set of already guessed player IDs.
  final Set<String> guessedPlayerIds;

  /// Whether the game is in daily challenge mode.
  final bool isDailyChallenge;

  /// Daily streak count.
  final int dailyStreak;

  /// Remaining guesses.
  final int remainingGuesses;

  /// Total points.
  final int totalPoints;

  /// Callbacks.
  final ValueChanged<String?> onTeamSelected;
  final ValueChanged<String?> onPositionSelected;
  final ValueChanged<Player> onPlayerSelected;

  const GuessPanel({
    super.key,
    required this.selectedTeam,
    required this.selectedPosition,
    required this.filteredPlayers,
    required this.isLoading,
    required this.difficulty,
    required this.guessedPlayerIds,
    required this.isDailyChallenge,
    required this.dailyStreak,
    required this.remainingGuesses,
    required this.totalPoints,
    required this.onTeamSelected,
    required this.onPositionSelected,
    required this.onPlayerSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<T4LThemeColors>()!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(AppBorders.radiusXl),
        topRight: Radius.circular(AppBorders.radiusXl),
      ),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.only(
            top: 12,
            bottom: MediaQuery.of(context).padding.bottom + 8,
          ),
          decoration: BoxDecoration(
            color: colors.surface.withValues(alpha: 0.9),
            border: Border(
              top: BorderSide(
                color: (isDark ? Colors.white : colors.border).withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 15,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Mode badge
                    if (isDailyChallenge)
                      _buildDailyBadge(colors)
                    else
                      _buildCareerBadge(colors),
                    // Remaining guesses
                    _buildGuessCounter(colors),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Team selector
              TeamSelector(
                selectedTeam: selectedTeam,
                onTeamSelected: onTeamSelected,
              ),
              const SizedBox(height: 10),

              // Position filter
              PositionFilter(
                selectedPosition: selectedPosition,
                onPositionSelected: onPositionSelected,
                difficulty: difficulty,
              ),
              const SizedBox(height: 10),

              // Player grid
              PlayerGrid(
                players: filteredPlayers,
                isLoading: isLoading,
                onPlayerSelected: onPlayerSelected,
                guessedPlayerIds: guessedPlayerIds,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDailyBadge(T4LThemeColors colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colors.brand, colors.brand.withValues(alpha: 0.8)],
        ),
        borderRadius: BorderRadius.circular(AppBorders.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.calendar_today, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          const Text(
            'Daily',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Colors.white,
            ),
          ),
          if (dailyStreak > 0) ...[
            const SizedBox(width: 6),
            const Text('🔥', style: TextStyle(fontSize: 12)),
            Text(
              '$dailyStreak',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCareerBadge(T4LThemeColors colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppBorders.radiusFull),
        border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.emoji_events, size: 14, color: const Color(0xFFF59E0B)),
          const SizedBox(width: 6),
          Text(
            '$totalPoints PTS',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Color(0xFFF59E0B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuessCounter(T4LThemeColors colors) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 36,
          height: 36,
          child: CircularProgressIndicator(
            value: remainingGuesses / 8,
            strokeWidth: 3,
            color: remainingGuesses > 4
                ? Colors.green
                : (remainingGuesses > 2 ? Colors.orange : Colors.red),
            backgroundColor: AppColors.neutralSoft,
            strokeCap: StrokeCap.round,
          ),
        ),
        Text(
          '$remainingGuesses',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: colors.textPrimary,
          ),
        ),
      ],
    );
  }
}
