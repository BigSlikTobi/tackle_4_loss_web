/// Player Reveal Card widget shown after game ends.
/// Displays full player profile with photo and stats.
library;

import 'package:flutter/material.dart';
import '../../../../design_tokens.dart';
import '../../../../l10n/app_localizations.dart';
import '../../models/player_model.dart';
import '../../models/game_state.dart';

/// Card displaying the mystery player after game ends.
class PlayerRevealCard extends StatelessWidget {
  /// The revealed mystery player
  final Player player;
  
  /// Game status (won or lost)
  final GameStatus gameStatus;
  
  /// Number of guesses it took to win (if won)
  final int? guessCount;
  
  /// Callback to start a new game
  final VoidCallback onPlayAgain;

  const PlayerRevealCard({
    super.key,
    required this.player,
    required this.gameStatus,
    this.guessCount,
    required this.onPlayAgain,
  });

  @override
  Widget build(BuildContext context) {
    final isWin = gameStatus == GameStatus.won;
    
    return Container(
      margin: const EdgeInsets.all(AppSpacing.space2),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppBorders.radius2Xl),
        boxShadow: AppShadows.lg,
        border: Border.all(
          color: isWin ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
          width: 3,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          _buildHeader(context, isWin),
          // Player photo and info
          _buildPlayerInfo(),
          // Stats grid
          _buildStatsGrid(context),
          // Play again button
          _buildPlayAgainButton(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isWin) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.space2),
      decoration: BoxDecoration(
        color: isWin 
            ? const Color(0xFF22C55E).withValues(alpha: 0.1)
            : const Color(0xFFEF4444).withValues(alpha: 0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppBorders.radius2Xl - 2),
          topRight: Radius.circular(AppBorders.radius2Xl - 2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isWin ? Icons.celebration : Icons.sentiment_dissatisfied,
            color: isWin ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
            size: 28,
          ),
          const SizedBox(width: AppSpacing.space1),
          Text(
            isWin 
                ? '${l10n.playerWordleYouGotIt}${guessCount != null ? " ($guessCount guesses)" : ""}'
                : l10n.playerWordleGameOver,
            style: AppTextStyles.h2.copyWith(
              color: isWin ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerInfo() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.space3),
      child: Column(
        children: [
          // Player photo
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: AppShadows.lg,
              border: Border.all(color: AppColors.brandBase, width: 4),
            ),
            child: CircleAvatar(
              radius: 60,
              foregroundImage: player.headshot != null
                  ? NetworkImage(player.headshot!)
                  : null,
              onForegroundImageError: (_, __) {},
              backgroundColor: AppColors.neutralBorder,
              child: player.headshot == null
                  ? const Icon(Icons.person, size: 60, color: AppColors.textSecondary)
                  : null,
            ),
          ),
          const SizedBox(height: AppSpacing.space2),
          // Player name
          Text(
            player.displayName,
            style: AppTextStyles.h1,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.space1),
          // Team and position
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (player.teamLogo != null) ...[
                Image.network(
                  player.teamLogo!,
                  width: 32,
                  height: 32,
                  errorBuilder: (_, __, ___) => const SizedBox(),
                ),
                const SizedBox(width: AppSpacing.space1),
              ],
              Text(
                '${player.teamName ?? player.team ?? "N/A"} · ${player.position ?? "N/A"}',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          if (player.jerseyNumber != null) ...[
            const SizedBox(height: AppSpacing.space1 / 2),
            Text(
              '#${player.jerseyNumber}',
              style: AppTextStyles.h3.copyWith(
                color: AppColors.brandBase,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final stats = <MapEntry<String, String>>[
      if (player.age != null) MapEntry(l10n.playerWordleStatAge, '${player.age} yrs'),
      if (player.height != null) MapEntry(l10n.playerWordleStatHeight, player.displayHeight),
      if (player.weight != null) MapEntry(l10n.playerWordleStatWeight, '${player.weight} lbs'),
      if (player.college != null) MapEntry(l10n.playerWordleStatCollege, player.college!),
      if (player.yearsExperience != null) 
        MapEntry(l10n.playerWordleStatExperience, '${player.yearsExperience} yrs'),
      if (player.draftYear != null && player.draftRound != null && player.draftPick != null)
        MapEntry(l10n.playerWordleStatDraft, '${player.draftYear} Rd ${player.draftRound} Pick ${player.draftPick}'),
    ];

    if (stats.isEmpty) return const SizedBox();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space2),
      child: Wrap(
        spacing: AppSpacing.space2,
        runSpacing: AppSpacing.space1,
        alignment: WrapAlignment.center,
        children: stats.map((stat) => _buildStatChip(stat.key, stat.value)).toList(),
      ),
    );
  }

  Widget _buildStatChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space2,
        vertical: AppSpacing.space1,
      ),
      decoration: BoxDecoration(
        color: AppColors.neutralSoft,
        borderRadius: BorderRadius.circular(AppBorders.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: AppTypography.fontSizeSm,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: AppTypography.fontSizeSm,
              fontWeight: AppTypography.fontWeightBold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayAgainButton(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.space3),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onPlayAgain,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.brandBase,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.space2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppBorders.radiusXl),
            ),
          ),
          child: Text(
            l10n.playerWordlePlayAgain,
            style: TextStyle(
              fontSize: AppTypography.fontSizeMd,
              fontWeight: AppTypography.fontWeightBold,
            ),
          ),
        ),
      ),
    );
  }
}
