/// Player grid for selecting a player to guess.
library;

import 'package:flutter/material.dart';
import '../../../../design_tokens.dart';
import '../../../../core/theme/t4l_theme.dart';
import '../../models/player_model.dart';

/// Grid displaying players with headshots and names.
class PlayerGrid extends StatelessWidget {
  /// List of players to display.
  final List<Player> players;

  /// Whether players are loading.
  final bool isLoading;

  /// Callback when a player is selected.
  final ValueChanged<Player> onPlayerSelected;

  /// Set of already guessed player IDs (to show as disabled).
  final Set<String> guessedPlayerIds;

  const PlayerGrid({
    super.key,
    required this.players,
    required this.isLoading,
    required this.onPlayerSelected,
    this.guessedPlayerIds = const {},
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<T4LThemeColors>()!;

    if (isLoading) {
      return const SizedBox(
        height: 120,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (players.isEmpty) {
      return SizedBox(
        height: 80,
        child: Center(
          child: Text(
            'Select a team and position',
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space2),
        itemCount: players.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final player = players[index];
          final isGuessed = guessedPlayerIds.contains(player.playerId);

          return GestureDetector(
            onTap: isGuessed ? null : () => onPlayerSelected(player),
            child: Opacity(
              opacity: isGuessed ? 0.4 : 1.0,
              child: SizedBox(
                width: 72,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Player headshot
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colors.surface,
                        border: Border.all(
                          color: isGuessed ? colors.border : colors.brand.withValues(alpha: 0.3),
                          width: 2,
                        ),
                        boxShadow: AppShadows.sm,
                      ),
                      child: ClipOval(
                        child: player.headshot != null
                            ? Image.network(
                                player.headshot!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => _buildPlaceholder(colors),
                              )
                            : _buildPlaceholder(colors),
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Player name
                    Text(
                      _getShortName(player.displayName),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: isGuessed ? colors.textSecondary : colors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPlaceholder(T4LThemeColors colors) {
    return Container(
      color: colors.border,
      child: Icon(
        Icons.person,
        color: colors.textSecondary,
        size: 32,
      ),
    );
  }

  /// Shorten long names (e.g., "Patrick Mahomes" -> "P. Mahomes").
  String _getShortName(String fullName) {
    final parts = fullName.split(' ');
    if (parts.length <= 1) return fullName;
    if (fullName.length <= 12) return fullName;
    return '${parts.first[0]}. ${parts.skip(1).join(' ')}';
  }
}
