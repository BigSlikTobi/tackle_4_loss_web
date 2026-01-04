import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tackle4loss_mobile/design_tokens.dart';
import 'package:tackle4loss_mobile/core/theme/t4l_theme.dart';
import 'package:tackle4loss_mobile/core/services/team_service.dart';
import 'package:tackle4loss_mobile/core/models/team_model.dart';
import 'package:tackle4loss_mobile/micro_apps/standings/models/game_model.dart';

/// Card showing the last game result with W/L indicator.
/// Uses EMOTIONAL DESIGN: background uses brandLight (team's secondary color).
class GameResultCard extends StatelessWidget {
  final Game game;
  final Team featuredTeam;
  final VoidCallback? onTap;

  const GameResultCard({
    super.key,
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
        height: 100,
        width: 160,
        decoration: BoxDecoration(
          // EMOTIONAL DESIGN: Use brandLight for card background
          color: colors.brandLight,
          borderRadius: BorderRadius.circular(AppBorders.radiusLg),
          border: Border.all(
            color: colors.brand.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: colors.brandLight.withValues(alpha: 0.3),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
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
                child: Container(color: resultColor),
              ),

              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'LAST GAME',
                      style: AppTextStyles.caption.copyWith(
                        // EMOTIONAL: Use contrastText
                        color: colors.contrastText.withValues(alpha: 0.6),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        // W/L Badge
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: resultColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Center(
                            child: Text(
                              resultText,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        // Score
                        Text(
                          '${teamScore ?? 0}-${opponentScore ?? 0}',
                          style: TextStyle(
                            // EMOTIONAL: Use contrastText
                            color: colors.contrastText,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        // Opponent Logo
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          padding: const EdgeInsets.all(2),
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

/// Card showing the next upcoming game.
/// Uses EMOTIONAL DESIGN: background uses brandLight (team's secondary color).
class UpcomingGameCard extends StatelessWidget {
  final Game game;
  final Team featuredTeam;
  final VoidCallback? onTap;

  const UpcomingGameCard({
    super.key,
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
        height: 100,
        width: 160,
        decoration: BoxDecoration(
          // EMOTIONAL DESIGN: Use brandLight for card background
          color: colors.brandLight,
          borderRadius: BorderRadius.circular(AppBorders.radiusLg),
          border: Border.all(
            color: colors.brand.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: colors.brandLight.withValues(alpha: 0.3),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'NEXT UP',
                style: AppTextStyles.caption.copyWith(
                  // EMOTIONAL: Use brand color for accent
                  color: colors.brand,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildTeamLogo(isHome ? opponent : team),
                  Text(
                    'VS',
                    style: TextStyle(
                      color: colors.contrastText.withValues(alpha: 0.5),
                      fontSize: 12,
                    ),
                  ),
                  _buildTeamLogo(isHome ? team : opponent),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                gameDateTime,
                style: TextStyle(
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

  Widget _buildTeamLogo(Team team) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
      ),
      padding: const EdgeInsets.all(2),
      child: Image.asset(team.logoUrl),
    );
  }
}
