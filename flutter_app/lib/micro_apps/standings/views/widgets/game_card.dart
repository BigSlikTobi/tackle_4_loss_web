import 'package:flutter/material.dart';
import '../../../../design_tokens.dart';
import '../../../../core/services/team_service.dart';
import '../../../../core/models/team_model.dart';
import '../../models/game_model.dart';

/// A card displaying a single NFL game matchup with team logos and scores.
class GameCard extends StatelessWidget {
  final Game game;
  final VoidCallback? onTap;
  final Team? themeTeam;

  const GameCard({super.key, required this.game, this.onTap, this.themeTeam});

  @override
  Widget build(BuildContext context) {
    final teamService = TeamService();
    final isAppDark = Theme.of(context).brightness == Brightness.dark;

    Color backgroundColor;
    bool isCardDark;

    if (themeTeam != null) {
      // User Personalization Logic:
      if (isAppDark) {
        // Dark Mode -> Light Card (Secondary Color)
        backgroundColor = themeTeam!.secondaryColor;
        // Determine text color based on secondary color brightness
        // Rough estimate: If secondary is light (like Silver/Yellow), card is Light.
        // If secondary is dark (like Black for Falcons/Raiders), card is Dark.
        // For simplicity, we assume secondary is "Lighter" than primary.
        isCardDark = backgroundColor.computeLuminance() < 0.5;
      } else {
        // Light Mode -> Dark Card (Primary Color)
        backgroundColor = themeTeam!.primaryColor;
        isCardDark = true; // Primary usually dark
      }
    } else {
      // Fallback (No user team selected): Use Home Team & Opposite Logic (Dark/White)
      final homeTeam = teamService.getTeams().firstWhere(
            (t) => t.id.toUpperCase() == game.homeTeam.toUpperCase(),
            orElse: () => teamService.getTeams().first,
          );
      backgroundColor = isAppDark ? Colors.white : homeTeam.primaryColor;
      isCardDark = !isAppDark;
    }

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space2,
        vertical: AppSpacing.space1,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppBorders.radiusLg),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppBorders.radiusLg),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.space2),
            child: Column(
              children: [
                // Game info header
                _buildGameHeader(context, isCardDark),
                const SizedBox(height: AppSpacing.space1),
                // Matchup row
                _buildMatchupRow(context, teamService, isCardDark),
                const SizedBox(height: AppSpacing.space2),
                // Details footer
                _buildGameDetails(context, isCardDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGameHeader(BuildContext context, bool isCardDark) {
    final dateStr = _formatGameDate(game.gameday);
    final timeStr = game.gametime;

    // If card is dark (Team Color), text acts as "Light Mode logic" (White)
    // If card is light (White), text acts as "Dark Mode logic" (Black/Grey)
    final textColor = isCardDark
        ? Colors.white.withValues(alpha: 0.8)
        : AppColors.textSubLight;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Date and time
        Text(
          game.isPlayed ? dateStr : '$dateStr • $timeStr',
          style: AppTextStyles.caption.copyWith(color: textColor),
        ),
        // Status indicators
        Row(
          children: [
            if (game.isOvertime)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.space1,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.brandBase.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppBorders.radiusSm),
                ),
                child: Text(
                  'OT',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.brandBase,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            if (!game.isPlayed)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.space1,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppBorders.radiusSm),
                ),
                child: Text(
                  'UPCOMING',
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildMatchupRow(
    BuildContext context,
    TeamService teamService,
    bool isCardDark,
  ) {
    return Row(
      children: [
        // Away team
        Expanded(
          child: _buildTeamColumn(
            context,
            teamService,
            game.awayTeam,
            game.awayScore,
            isWinner: game.winner == game.awayTeam,
            isCardDark: isCardDark,
          ),
        ),
        // VS / Score divider
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space1),
          child: game.isPlayed
              ? Text(
                  '-',
                  style: AppTextStyles.h2.copyWith(
                    color: isCardDark ? Colors.white70 : AppColors.textSubLight,
                  ),
                )
              : Text(
                  '@',
                  style: AppTextStyles.body.copyWith(
                    color: isCardDark ? Colors.white70 : AppColors.textSubLight,
                  ),
                ),
        ),
        // Home team
        Expanded(
          child: _buildTeamColumn(
            context,
            teamService,
            game.homeTeam,
            game.homeScore,
            isWinner: game.winner == game.homeTeam,
            isCardDark: isCardDark,
            isHome: true,
          ),
        ),
      ],
    );
  }

  Widget _buildTeamColumn(
    BuildContext context,
    TeamService teamService,
    String teamCode,
    int? score, {
    required bool isWinner,
    required bool isCardDark, // Renamed for clarity
    bool isHome = false,
  }) {
    final team = teamService.getTeams().firstWhere(
          (t) => t.id.toUpperCase() == teamCode.toUpperCase(),
          orElse: () => teamService.getTeams().first,
        );

    return Column(
      children: [
        // Team indicator bar (small line above logo)
        Container(
          width: 20,
          height: 3,
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: team.primaryColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        // Team logo
        // Team logo
        Container(
          width: 48,
          height: 48,
          padding:
              const EdgeInsets.all(4), // Add padding for white circle effect
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.transparent,
          ),
          child: Image.asset(
            team.logoUrl,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: team.primaryColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  teamCode,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        // Team name
        Text(
          teamCode,
          style: AppTextStyles.bodySmall.copyWith(
            fontWeight: isWinner ? FontWeight.bold : FontWeight.normal,
            color: isCardDark ? Colors.white : AppColors.textMainLight,
          ),
        ),
        // Score
        if (game.isPlayed)
          Text(
            score.toString(),
            style: AppTextStyles.h2.copyWith(
              fontWeight: isWinner ? FontWeight.bold : FontWeight.normal,
              color: isWinner
                  // Winner: White if dark card, Team Color if light card
                  ? (isCardDark ? Colors.white : team.primaryColor)
                  : (isCardDark ? Colors.white70 : AppColors.textMainLight),
            ),
          ),
        // Home indicator
        if (isHome)
          Text(
            'HOME',
            style: AppTextStyles.caption.copyWith(
              fontSize: 9,
              color: isCardDark ? Colors.white60 : AppColors.textSubLight,
            ),
          ),
      ],
    );
  }

  Widget _buildGameDetails(BuildContext context, bool isCardDark) {
    if (game.stadium == null && game.temp == null && game.referee == null) {
      return const SizedBox.shrink();
    }

    final textColor = isCardDark ? Colors.white60 : AppColors.textSubLight;
    final iconColor = isCardDark
        ? Colors.white38
        : AppColors.textSubLight.withValues(alpha: 0.5);

    return Container(
      padding: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isCardDark ? Colors.white12 : AppColors.neutralBorder,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Stadium
          if (game.stadium != null)
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  Icon(Icons.stadium_outlined, size: 14, color: iconColor),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      game.stadium!,
                      style: AppTextStyles.caption.copyWith(
                        fontSize: 11,
                        color: textColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

          // Temp & Ref (Right aligned)
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (game.temp != null) ...[
                  const SizedBox(width: 8),
                  Icon(Icons.thermostat, size: 14, color: iconColor),
                  const SizedBox(width: 2),
                  Text(
                    '${game.temp}°',
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 11,
                      color: textColor,
                    ),
                  ),
                ],
                if (game.referee != null) ...[
                  const SizedBox(width: 8),
                  Icon(Icons.sports, size: 14, color: iconColor),
                  const SizedBox(width: 2),
                  Text(
                    'Ref: ${game.referee!.split(' ').last}', // Just last name to save space
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 11,
                      color: textColor,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatGameDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${days[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
  }
}
