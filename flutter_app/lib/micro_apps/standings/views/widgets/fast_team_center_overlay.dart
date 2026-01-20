import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../design_tokens.dart';
import '../../../../core/theme/t4l_theme.dart';
import '../../../../core/services/team_service.dart';
import '../../../../core/models/team_model.dart';
import '../../models/game_model.dart';

/// Overlay showing last game and next game for the user's team.
/// Uses EMOTIONAL DESIGN: all backgrounds use brandLight (team's secondary color).
class FastTeamCenterOverlay extends StatelessWidget {
  final Game? lastGame;
  final Game? nextGame;
  final Team featuredTeam;
  final VoidCallback? onLastGameTap;
  final VoidCallback? onNextGameTap;

  const FastTeamCenterOverlay({
    super.key,
    this.lastGame,
    this.nextGame,
    required this.featuredTeam,
    this.onLastGameTap,
    this.onNextGameTap,
  });

  @override
  Widget build(BuildContext context) {
    if (lastGame == null && nextGame == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space3,
        vertical: AppSpacing.space2,
      ),
      child: Row(
        children: [
          if (lastGame != null)
            Expanded(
              child: _LastGameCard(
                game: lastGame!,
                featuredTeam: featuredTeam,
                onTap: onLastGameTap,
              ),
            ),
          if (lastGame != null && nextGame != null)
            const SizedBox(width: AppSpacing.space2),
          if (nextGame != null)
            Expanded(
              child: _NextGameCard(
                game: nextGame!,
                featuredTeam: featuredTeam,
                onTap: onNextGameTap,
              ),
            ),
        ],
      ),
    );
  }
}

/// Last game card with W/L indicator.
class _LastGameCard extends StatelessWidget {
  final Game game;
  final Team featuredTeam;
  final VoidCallback? onTap;

  const _LastGameCard({
    required this.game,
    required this.featuredTeam,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final teamService = TeamService();
    final colors = Theme.of(context).extension<T4LThemeColors>()!;
    final teamId = featuredTeam.id.toUpperCase();

    final isHome = game.homeTeam.toUpperCase() == teamId;
    final teamScore = isHome ? game.homeScore : game.awayScore;
    final opponentScore = isHome ? game.awayScore : game.homeScore;
    final opponentId = isHome ? game.awayTeam : game.homeTeam;

    final isWin =
        teamScore != null && opponentScore != null && teamScore > opponentScore;
    final isTie =
        teamScore != null &&
        opponentScore != null &&
        teamScore == opponentScore;

    final resultColor = isWin
        ? const Color(0xFF22C55E)
        : (isTie ? Colors.amber : AppColors.breakingNewsRed);
    final resultText = isWin ? 'W' : (isTie ? 'T' : 'L');

    final opponent = teamService.getTeams().firstWhere(
      (t) => t.id.toUpperCase() == opponentId.toUpperCase(),
      orElse: () => teamService.getTeams().first,
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          // EMOTIONAL DESIGN: Use brandLight for background
          color: colors.brandLight,
          borderRadius: BorderRadius.circular(AppBorders.radiusLg),
          border: Border.all(
            color: colors.brand.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppBorders.radiusLg),
          child: Stack(
            children: [
              // Result bar at bottom
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 4,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [resultColor.withValues(alpha: 0.8), resultColor],
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'LAST GAME',
                      style: AppTextStyles.caption.copyWith(
                        color: colors.contrastText.withValues(alpha: 0.6),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        // W/L Badge
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: resultColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Center(
                            child: Text(
                              resultText,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Score
                        Text(
                          '${teamScore ?? 0} - ${opponentScore ?? 0}',
                          style: AppTextStyles.h3.copyWith(
                            color: colors.contrastText,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        // Opponent logo
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.white.withValues(alpha: 0.9),
                          ),
                          padding: const EdgeInsets.all(4),
                          child: Image.asset(opponent.logoUrl),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Next game card with matchup.
class _NextGameCard extends StatelessWidget {
  final Game game;
  final Team featuredTeam;
  final VoidCallback? onTap;

  const _NextGameCard({
    required this.game,
    required this.featuredTeam,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final teamService = TeamService();
    final colors = Theme.of(context).extension<T4LThemeColors>()!;
    final teamId = featuredTeam.id.toUpperCase();

    final isHome = game.homeTeam.toUpperCase() == teamId;
    final opponentId = isHome ? game.awayTeam : game.homeTeam;

    final team = teamService.getTeams().firstWhere(
      (t) => t.id.toUpperCase() == teamId,
      orElse: () => teamService.getTeams().first,
    );

    final opponent = teamService.getTeams().firstWhere(
      (t) => t.id.toUpperCase() == opponentId.toUpperCase(),
      orElse: () => teamService.getTeams().first,
    );

    final dayFormat = DateFormat('EEE');
    final gameDateTime = '${dayFormat.format(game.gameday)} ${game.gametime}';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          // EMOTIONAL DESIGN: Use brandLight for background
          color: colors.brandLight,
          borderRadius: BorderRadius.circular(AppBorders.radiusLg),
          border: Border.all(
            color: colors.brand.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'NEXT UP',
                style: AppTextStyles.caption.copyWith(
                  color: colors.brand,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _TeamBadge(team: isHome ? opponent : team, colors: colors),
                  const SizedBox(width: 8),
                  Text(
                    'VS',
                    style: AppTextStyles.caption.copyWith(
                      color: colors.contrastText.withValues(alpha: 0.5),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _TeamBadge(team: isHome ? team : opponent, colors: colors),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                gameDateTime,
                style: AppTextStyles.caption.copyWith(
                  color: colors.contrastText.withValues(alpha: 0.7),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Small team badge with logo.
class _TeamBadge extends StatelessWidget {
  final Team team;
  final T4LThemeColors colors;

  const _TeamBadge({required this.team, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.white.withValues(alpha: 0.9),
        border: Border.all(
          color: colors.brand.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(4),
      child: Image.asset(team.logoUrl),
    );
  }
}
