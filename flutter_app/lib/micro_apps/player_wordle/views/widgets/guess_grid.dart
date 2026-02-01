/// Guess Grid widget displaying all previous guesses in the game.
library;

import 'package:flutter/material.dart';
import '../../../../design_tokens.dart';
import '../../../../l10n/app_localizations.dart';
import '../../models/guess_result.dart';
import 'attribute_tile.dart';

/// Grid displaying all guesses made in the current game.
class GuessGrid extends StatelessWidget {
  /// List of all guesses made
  final List<GuessResult> guesses;

  /// Maximum number of guesses allowed
  final int maxGuesses;

  const GuessGrid({
    super.key,
    required this.guesses,
    this.maxGuesses = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header row with attribute labels
        _buildHeaderRow(context),
        const SizedBox(height: AppSpacing.space1),
        // Guess rows
        Expanded(
          child: ListView.separated(
            itemCount: guesses.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: AppSpacing.space1),
            itemBuilder: (context, index) =>
                _buildGuessRow(context, guesses[index], index),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderRow(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final headers = [
      l10n.playerWordleHeaderPlayer,
      l10n.playerWordleHeaderConf,
      l10n.playerWordleHeaderDiv,
      l10n.playerWordleHeaderTeam,
      l10n.playerWordleHeaderPos,
      l10n.playerWordleHeaderNum,
      l10n.playerWordleHeaderAge,
      l10n.playerWordleHeaderHt,
    ];

    return Row(
      children: headers.map((header) {
        return Expanded(
          flex: header == 'Player' ? 2 : 1,
          child: Center(
            child: Text(
              header,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: AppTypography.fontWeightBold,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGuessRow(BuildContext context, GuessResult guess, int index) {
    final l10n = AppLocalizations.of(context)!;
    final player = guess.guessedPlayer;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.space1 / 2),
      child: Row(
        children: [
          // Player name
          Expanded(
            flex: 2,
            child: _buildPlayerCell(player),
          ),
          // Conference
          Expanded(
            child: AttributeTile(
              label: l10n.playerWordleHeaderConf,
              value: player.conference ?? '?',
              status: guess.conferenceMatch,
              animate: index == guesses.length - 1,
            ),
          ),
          // Division
          Expanded(
            child: AttributeTile(
              label: l10n.playerWordleHeaderDiv,
              value: _shortDivision(player.division),
              status: guess.divisionMatch,
              animate: index == guesses.length - 1,
            ),
          ),
          // Team
          Expanded(
            child: AttributeTile(
              label: l10n.playerWordleHeaderTeam,
              value: player.team ?? '?',
              status: guess.teamMatch,
              animate: index == guesses.length - 1,
            ),
          ),
          // Position
          Expanded(
            child: AttributeTile(
              label: l10n.playerWordleHeaderPos,
              value: player.position ?? '?',
              status: guess.positionMatch,
              animate: index == guesses.length - 1,
            ),
          ),
          // Jersey Number
          Expanded(
            child: AttributeTile(
              label: l10n.playerWordleHeaderNum,
              value: player.jerseyNumber?.toString() ?? '?',
              status: guess.jerseyComparison.match
                  ? MatchStatus.match
                  : (guess.jerseyComparison.isClose
                      ? MatchStatus.partial
                      : MatchStatus.miss),
              direction: guess.jerseyComparison.direction,
              isClose: guess.jerseyComparison.isClose,
              animate: index == guesses.length - 1,
            ),
          ),
          // Age
          Expanded(
            child: AttributeTile(
              label: l10n.playerWordleHeaderAge,
              value: player.age?.toString() ?? '?',
              status: guess.ageComparison.match
                  ? MatchStatus.match
                  : (guess.ageComparison.isClose
                      ? MatchStatus.partial
                      : MatchStatus.miss),
              direction: guess.ageComparison.direction,
              isClose: guess.ageComparison.isClose,
              animate: index == guesses.length - 1,
            ),
          ),
          // Height
          Expanded(
            child: AttributeTile(
              label: l10n.playerWordleHeaderHt,
              value: player.displayHeight,
              status: guess.heightComparison.match
                  ? MatchStatus.match
                  : (guess.heightComparison.isClose
                      ? MatchStatus.partial
                      : MatchStatus.miss),
              direction: guess.heightComparison.direction,
              isClose: guess.heightComparison.isClose,
              animate: index == guesses.length - 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerCell(player) {
    return Container(
      padding: const EdgeInsets.only(right: AppSpacing.space1),
      child: Row(
        children: [
          // Player photo
          CircleAvatar(
            radius: 20,
            foregroundImage:
                player.headshot != null ? NetworkImage(player.headshot!) : null,
            onForegroundImageError: (_, __) {},
            backgroundColor: AppColors.neutralBorder,
            child: const Icon(Icons.person,
                size: 20, color: AppColors.textSecondary),
          ),
          const SizedBox(width: 8),
          // Player name
          Expanded(
            child: Text(
              player.displayName,
              style: const TextStyle(
                fontSize: AppTypography.fontSizeSm,
                fontWeight: AppTypography.fontWeightBold,
                color: AppColors.textPrimary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _shortDivision(String? division) {
    if (division == null) return '?';
    // Extract just the direction (North, South, East, West)
    final parts = division.split(' ');
    if (parts.length > 1) {
      return parts[1].substring(0, 1); // N, S, E, W
    }
    return division.substring(0, 1);
  }
}
