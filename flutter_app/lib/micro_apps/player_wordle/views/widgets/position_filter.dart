/// Position filter chips for player selection.
library;

import 'package:flutter/material.dart';
import '../../../../design_tokens.dart';
import '../../../../core/theme/t4l_theme.dart';
import '../../models/game_state.dart';

/// Get available positions based on difficulty.
List<String> getPositionsForDifficulty(Difficulty difficulty) {
  // Fan & Rookie: Only popular positions (QB, WR, TE, RB, DE, CB)
  // Pro & All Madden: All positions
  
  const restrictedPositions = ['QB', 'RB', 'WR', 'TE', 'DE', 'CB'];
  const allPositions = ['QB', 'RB', 'FB', 'WR', 'TE', 'K', 'P', 'DE', 'DT', 'NT', 'OLB', 'ILB', 'MLB', 'CB', 'S', 'FS', 'SS', 'OT', 'G', 'C', 'LS'];
  // Also define a comprehensive "Pro" list if All Madden has extras, but user said "Pro and All Madden show all".
  // Let's assume standard comprehensive list for Pro, and maybe the full-full list for All Madden if there's a distinction in data.
  // Actually, user said "Pro and All Madden we show all positions". I'll use the fullest list for both to be safe, or just the standard full set.
  // Let's use the full detailed list for both to ensure nothing is missed.
  
  switch (difficulty) {
    case Difficulty.fan:
    case Difficulty.rookie:
      return restrictedPositions;
    case Difficulty.pro:
    case Difficulty.allMadden:
      return allPositions;
  }
}

/// Horizontal scrolling position filter chips.
class PositionFilter extends StatelessWidget {
  /// Currently selected position (null = none selected).
  final String? selectedPosition;

  /// Callback when a position is selected.
  final ValueChanged<String?> onPositionSelected;

  /// Current difficulty level (affects available positions).
  final Difficulty difficulty;

  const PositionFilter({
    super.key,
    required this.selectedPosition,
    required this.onPositionSelected,
    required this.difficulty,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<T4LThemeColors>()!;
    final positions = getPositionsForDifficulty(difficulty);

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space2),
        itemCount: positions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (context, index) {
          final position = positions[index];
          final isSelected = position == selectedPosition;

          return GestureDetector(
            onTap: () => onPositionSelected(isSelected ? null : position),
            child: AnimatedContainer(
              duration: AppAnimation.durationFast,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? colors.brand : colors.surface,
                borderRadius: BorderRadius.circular(AppBorders.radiusFull),
                border: Border.all(
                  color: isSelected ? colors.brand : colors.border,
                  width: 1,
                ),
              ),
              child: Text(
                position,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? colors.contrastText : colors.textPrimary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
