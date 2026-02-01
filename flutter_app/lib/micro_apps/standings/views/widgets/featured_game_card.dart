import 'package:flutter/material.dart';
import '../../../../design_tokens.dart';
import '../../../../core/theme/t4l_theme.dart';
import '../../../../core/services/team_service.dart';
import '../../../../core/models/team_model.dart';
import '../../models/game_model.dart';

class FeaturedGameCard extends StatelessWidget {
  final Game game;
  final Team featuredTeam;
  final VoidCallback? onTap;

  const FeaturedGameCard({
    super.key,
    required this.game,
    required this.featuredTeam,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final teamService = TeamService();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = Theme.of(context).extension<T4LThemeColors>()!;

    // Determine colors based on the featured team
    final primaryColor = featuredTeam.primaryColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Label
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.space2,
            vertical: AppSpacing.space1,
          ),
          child: Row(
            children: [
              Icon(Icons.star_rounded, color: primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'Your Matchup',
                style: AppTextStyles.h3.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),

        // The Card
        Container(
          height: 240,
          width: double.infinity,
          margin: const EdgeInsets.symmetric(
            horizontal: AppSpacing.space2,
            vertical: AppSpacing.space1,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppBorders.radiusXl),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF1a1a1a),
                primaryColor.withValues(alpha: 0.4),
                colors.background,
              ],
            ),
            boxShadow: AppShadows.lg,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(AppBorders.radiusXl),
              child: Stack(
                children: [
                  // Spotlights (Atmosphere)
                  Positioned(
                    top: -50,
                    left: -50,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0.3),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: -50,
                    right: -50,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0.3),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Content
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.space2),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Top Row: Status/Notification
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Status Badge (FINAL or Time)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: game.isPlayed
                                    ? Colors.white.withValues(alpha: 0.2)
                                    : primaryColor,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                game.isPlayed ? 'FINAL' : game.gametime,
                                style: AppTextStyles.caption.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.notifications_none,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ],
                        ),

                        // Middle Row: Matchup (Logo - Score - Logo)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildBigTeamColumn(
                              teamService,
                              game.awayTeam,
                              game.awayScore,
                              game.isPlayed,
                              game.winner == game.awayTeam,
                              primaryColor,
                            ),
                            Column(
                              children: [
                                if (game.isPlayed)
                                  const Text(
                                    '-',
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white54,
                                    ),
                                  )
                                else
                                  Text(
                                    'VS',
                                    style: TextStyle(
                                      fontFamily: 'Russo One',
                                      fontSize: 24,
                                      fontStyle: FontStyle.italic,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white.withValues(
                                        alpha: 0.9,
                                      ),
                                    ),
                                  ),
                                Text(
                                  'Week ${game.week}',
                                  style: AppTextStyles.caption.copyWith(
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                            _buildBigTeamColumn(
                              teamService,
                              game.homeTeam,
                              game.homeScore,
                              game.isPlayed,
                              game.winner == game.homeTeam,
                              primaryColor,
                            ),
                          ],
                        ),

                        // Bottom Row: Date & Button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  game.weekday.toUpperCase(),
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.schedule,
                                      color: primaryColor,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      game.gametime,
                                      style: AppTextStyles.caption.copyWith(
                                        color: primaryColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            // Details Button
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Details',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
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
        ),
      ],
    );
  }

  Widget _buildBigTeamColumn(
    TeamService teamService,
    String teamId,
    int? score,
    bool isPlayed,
    bool isWinner,
    Color teamColor,
  ) {
    final team = teamService.getTeams().firstWhere(
          (t) => t.id.toUpperCase() == teamId.toUpperCase(),
          orElse: () => teamService.getTeams().first,
        );

    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(8),
          child: Image.asset(team.logoUrl),
        ),
        const SizedBox(height: 4),
        Text(
          team.id.toUpperCase(),
          style: AppTextStyles.bodySmall.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (isPlayed && score != null)
          Text(
            score.toString(),
            style: AppTextStyles.h2.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
      ],
    );
  }
}
