/// Team selector widget showing horizontal scrollable team logos.
library;

import 'package:flutter/material.dart';
import '../../../../design_tokens.dart';
import '../../../../core/theme/t4l_theme.dart';

import '../../../../core/services/team_logo_service.dart';

/// List of all NFL team abbreviations.
const List<String> nflTeams = [
  'ARI',
  'ATL',
  'BAL',
  'BUF',
  'CAR',
  'CHI',
  'CIN',
  'CLE',
  'DAL',
  'DEN',
  'DET',
  'GB',
  'HOU',
  'IND',
  'JAX',
  'KC',
  'LAC',
  'LAR',
  'LV',
  'MIA',
  'MIN',
  'NE',
  'NO',
  'NYG',
  'NYJ',
  'PHI',
  'PIT',
  'SEA',
  'SF',
  'TB',
  'TEN',
  'WAS',
];

/// Horizontal scrolling team logo selector.
class TeamSelector extends StatelessWidget {
  /// Currently selected team abbreviation (null = none selected).
  final String? selectedTeam;

  /// Callback when a team is selected.
  final ValueChanged<String?> onTeamSelected;

  const TeamSelector({
    super.key,
    required this.selectedTeam,
    required this.onTeamSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<T4LThemeColors>()!;

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 56,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space2),
        itemCount: nflTeams.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final team = nflTeams[index];
          final isSelected = team == selectedTeam;

          return GestureDetector(
            onTap: () => onTeamSelected(isSelected ? null : team),
            child: AnimatedContainer(
              duration: AppAnimation.durationFast,
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDarkMode ? Colors.white : colors.surface,
                border: Border.all(
                  color: isSelected ? colors.brand : colors.border,
                  width: isSelected ? 3 : 1,
                ),
                boxShadow: isSelected ? AppShadows.md : AppShadows.sm,
              ),
              child: ClipOval(
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Image.asset(
                    TeamLogoService.getLogoPath(team),
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Center(
                      child: Text(
                        team,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: colors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
