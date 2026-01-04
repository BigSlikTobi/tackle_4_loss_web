import 'package:flutter/material.dart';
import '../../../standings/models/game_model.dart';

/// Widget for selecting a completed game to generate a report for.
class GameSelector extends StatelessWidget {
  final List<Game> games;
  final Game? selectedGame;
  final ValueChanged<Game> onGameSelected;

  const GameSelector({
    super.key,
    required this.games,
    required this.selectedGame,
    required this.onGameSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select a Game',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        if (games.isEmpty)
          const Text('No completed games available')
        else
          Container(
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: games.length,
              itemBuilder: (context, index) {
                final game = games[index];
                final isSelected = selectedGame?.gameId == game.gameId;
                return _GameChip(
                  game: game,
                  isSelected: isSelected,
                  onTap: () => onGameSelected(game),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _GameChip extends StatelessWidget {
  final Game game;
  final bool isSelected;
  final VoidCallback onTap;

  const _GameChip({
    required this.game,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
        width: 140,
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.15)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Week label
            Text(
              'Week ${game.week}',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 6),
            
            // Teams and score
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _TeamLogo(teamCode: game.awayTeam),
                const SizedBox(width: 8),
                Text(
                  '${game.awayScore}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: game.winner == game.awayTeam
                        ? theme.colorScheme.primary
                        : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              '@',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ),
            const SizedBox(height: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _TeamLogo(teamCode: game.homeTeam),
                const SizedBox(width: 8),
                Text(
                  '${game.homeScore}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: game.winner == game.homeTeam
                        ? theme.colorScheme.primary
                        : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TeamLogo extends StatelessWidget {
  final String teamCode;

  const _TeamLogo({required this.teamCode});

  @override
  Widget build(BuildContext context) {
    // Normalize team codes that don't match asset filenames
    const teamCodeOverrides = {
      'la': 'lar',    // LA Rams uses "lar.png"
      'oak': 'lv',    // Old Oakland -> Las Vegas
      'sd': 'lac',    // Old San Diego -> LA Chargers
      'stl': 'lar',   // Old St. Louis -> LA Rams
    };
    
    final normalizedCode = teamCodeOverrides[teamCode.toLowerCase()] 
        ?? teamCode.toLowerCase();
    final logoPath = 'assets/logos/teams/$normalizedCode.png';
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Image.asset(
        logoPath,
        width: 24,
        height: 24,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: Text(
                teamCode,
                style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold),
              ),
            ),
          );
        },
      ),
    );
  }
}
