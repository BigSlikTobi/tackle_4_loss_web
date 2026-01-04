import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../design_tokens.dart';
import '../../theme/t4l_theme.dart';
import '../../services/team_service.dart';
import '../../models/team_model.dart';
import '../../../micro_apps/standings/models/game_model.dart';

/// Compact, semi-transparent game card for the carousel display.
/// Uses EMOTIONAL DESIGN: background uses brandLight with transparency.
/// Works for both completed and upcoming games.
class GameCarouselCard extends StatelessWidget {
  final Game game;
  final Team featuredTeam;
  final bool isCenter;
  final VoidCallback? onTap;

  const GameCarouselCard({
    super.key,
    required this.game,
    required this.featuredTeam,
    this.isCenter = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final teamService = TeamService();
    final colors = Theme.of(context).extension<T4LThemeColors>()!;
    final teamId = featuredTeam.id.toUpperCase();

    final isHome = game.homeTeam.toUpperCase() == teamId;
    final opponentId = isHome ? game.awayTeam : game.homeTeam;

    final opponent = teamService.getTeams().firstWhere(
      (t) => t.id.toUpperCase() == opponentId.toUpperCase(),
      orElse: () => teamService.getTeams().first,
    );

    final isPlayed = game.isPlayed;

    // Calculate result for played games
    String? resultText;
    Color? resultColor;
    if (isPlayed) {
      final teamScore = isHome ? game.homeScore : game.awayScore;
      final opponentScore = isHome ? game.awayScore : game.homeScore;
      final isWin =
          teamScore != null &&
          opponentScore != null &&
          teamScore > opponentScore;
      final isTie =
          teamScore != null &&
          opponentScore != null &&
          teamScore == opponentScore;
      resultText = isWin ? 'W' : (isTie ? 'T' : 'L');
      resultColor = isWin
          ? const Color(0xFF22C55E)
          : (isTie ? Colors.amber : AppColors.breakingNewsRed);
    }

    // Base transparency - cards are more transparent for overlay effect
    final baseOpacity = isCenter ? 0.85 : 0.65;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 70,
        width: 120,
        decoration: BoxDecoration(
          color: colors.brandLight.withValues(alpha: baseOpacity),
          borderRadius: BorderRadius.circular(AppBorders.radiusMd),
          border: Border.all(
            color: colors.brand.withValues(alpha: isCenter ? 0.5 : 0.2),
            width: isCenter ? 2 : 1,
          ),
          boxShadow: isCenter
              ? [
                  BoxShadow(
                    color: colors.brand.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppBorders.radiusMd),
          child: Stack(
            children: [
              // Result bar at bottom for played games
              if (isPlayed && resultColor != null)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 3,
                  child: Container(color: resultColor),
                ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Header: Label
                      Text(
                        isPlayed ? 'W${game.week}' : 'WEEK ${game.week}',
                        style: AppTextStyles.caption.copyWith(
                          color: isPlayed
                              ? colors.contrastText.withValues(alpha: 0.5)
                              : colors.brand,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 3),

                      // Main Content Row
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (isPlayed && resultText != null) ...[
                            // W/L Badge
                            Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                color: resultColor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Center(
                                child: Text(
                                  resultText,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            // Score
                            Text(
                              '${isHome ? game.homeScore : game.awayScore}-${isHome ? game.awayScore : game.homeScore}',
                              style: TextStyle(
                                color: colors.contrastText,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 4),
                          ],

                          // Opponent Logo
                          Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            padding: const EdgeInsets.all(2),
                            child: Image.asset(opponent.logoUrl),
                          ),

                          if (!isPlayed) ...[
                            const SizedBox(width: 3),
                            // VS text for upcoming games
                            Text(
                              isHome ? 'vs' : '@',
                              style: TextStyle(
                                color: colors.contrastText.withValues(
                                  alpha: 0.5,
                                ),
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ],
                      ),

                      // Date/Time for upcoming games
                      if (!isPlayed) ...[
                        const SizedBox(height: 2),
                        Text(
                          _formatGameTime(game),
                          style: TextStyle(
                            color: colors.contrastText.withValues(alpha: 0.6),
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatGameTime(Game game) {
    final dayFormat = DateFormat('EEE');
    return '${dayFormat.format(game.gameday)} ${game.gametime}';
  }
}
