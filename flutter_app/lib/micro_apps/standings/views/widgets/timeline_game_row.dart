import 'package:flutter/material.dart';
import '../../../../design_tokens.dart';
import '../../../../core/theme/t4l_theme.dart';
import '../../models/game_model.dart';
import '../../../../core/services/team_service.dart';
import '../../../../core/models/team_model.dart';

/// A row displaying a single game in the schedule timeline.
/// Uses emotional design: card backgrounds use the team's secondary color (brandLight).
class TimelineGameRow extends StatelessWidget {
  final Game game;
  final Team? themeTeam;

  const TimelineGameRow({super.key, required this.game, this.themeTeam});

  @override
  Widget build(BuildContext context) {
    final teamService = TeamService();
    final colors = Theme.of(context).extension<T4LThemeColors>()!;

    // Parse time for display
    final timeParts = game.gametime.split(' ');
    String displayTime = game.gametime;
    String meridiem = '';

    if (timeParts.length > 1) {
      displayTime = timeParts[0];
      meridiem = timeParts[1];
    }

    // Check if this is a prime time game (evening games)
    final isPrimeTime =
        game.gametime.contains('20:') ||
        game.gametime.contains('21:') ||
        (game.gametime.contains('PM') &&
            (game.gametime.startsWith('8') || game.gametime.startsWith('9')));

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.space2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          _buildTimelineIndicator(colors),
          const SizedBox(width: AppSpacing.space2),
          // Game card
          Expanded(
            child: _buildGameCard(
              context,
              colors,
              teamService,
              displayTime,
              meridiem,
              isPrimeTime,
            ),
          ),
        ],
      ),
    );
  }

  /// Timeline vertical line indicator
  Widget _buildTimelineIndicator(T4LThemeColors colors) {
    return Container(
      width: 32,
      alignment: Alignment.center,
      child: Container(
        width: 3,
        height: 100,
        decoration: BoxDecoration(
          color: colors.brandLight,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  /// Main game card with emotional design colors
  Widget _buildGameCard(
    BuildContext context,
    T4LThemeColors colors,
    TeamService teamService,
    String displayTime,
    String meridiem,
    bool isPrimeTime,
  ) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        // EMOTIONAL DESIGN: Use brandLight (team's secondary color) as background
        color: colors.brandLight,
        borderRadius: BorderRadius.circular(AppBorders.radiusMd),
        border: Border.all(
          color: colors.brand.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.brandLight.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Time section (left side)
          _buildTimeSection(colors, displayTime, meridiem),
          // Game info section (right side)
          Expanded(
            child: _buildGameInfo(context, colors, teamService, isPrimeTime),
          ),
        ],
      ),
    );
  }

  /// Left side time display
  Widget _buildTimeSection(
    T4LThemeColors colors,
    String displayTime,
    String meridiem,
  ) {
    return Container(
      width: 70,
      decoration: BoxDecoration(
        color: colors.brand.withValues(alpha: 0.2),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppBorders.radiusMd),
          bottomLeft: Radius.circular(AppBorders.radiusMd),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            displayTime,
            style: AppTextStyles.h3.copyWith(
              fontWeight: FontWeight.bold,
              // EMOTIONAL: Use contrast text color
              color: colors.contrastText,
              height: 1.0,
            ),
          ),
          if (meridiem.isNotEmpty)
            Text(
              meridiem,
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.bold,
                color: colors.contrastText.withValues(alpha: 0.7),
                fontSize: 10,
              ),
            ),
        ],
      ),
    );
  }

  /// Right side game information
  Widget _buildGameInfo(
    BuildContext context,
    T4LThemeColors colors,
    TeamService teamService,
    bool isPrimeTime,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Header row: Stadium + Prime Time badge
          Row(
            children: [
              Expanded(
                child: Text(
                  game.stadium ?? '',
                  style: AppTextStyles.caption.copyWith(
                    color: colors.contrastText.withValues(alpha: 0.6),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isPrimeTime) _buildPrimeTimeBadge(colors),
            ],
          ),
          const Spacer(),
          // Teams matchup row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTeamDisplay(
                teamService,
                game.awayTeam,
                game.awayScore,
                colors,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  game.isPlayed ? '-' : 'vs',
                  style: TextStyle(
                    color: colors.contrastText.withValues(alpha: 0.5),
                    fontWeight: FontWeight.bold,
                    fontSize: game.isPlayed ? 14 : 12,
                  ),
                ),
              ),
              _buildTeamDisplay(
                teamService,
                game.homeTeam,
                game.homeScore,
                colors,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Prime time badge
  Widget _buildPrimeTimeBadge(T4LThemeColors colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: colors.brand,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'PRIME TIME',
        style: TextStyle(
          fontSize: 8,
          fontWeight: FontWeight.bold,
          // EMOTIONAL: Contrast text on brand background
          color: colors.contrastText,
        ),
      ),
    );
  }

  /// Single team display with logo and score
  Widget _buildTeamDisplay(
    TeamService teamService,
    String teamId,
    int? score,
    T4LThemeColors colors,
  ) {
    final team = teamService.getTeams().firstWhere(
      (t) => t.id.toUpperCase() == teamId.toUpperCase(),
      orElse: () => teamService.getTeams().first,
    );

    final isWinner = game.winner == teamId;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(4),
          child: Image.asset(team.logoUrl),
        ),
        const SizedBox(width: 4),
        Text(
          teamId.toUpperCase(),
          style: TextStyle(
            color: isWinner ? colors.brand : colors.contrastText,
            fontWeight: isWinner ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
        if (game.isPlayed && score != null) ...[
          const SizedBox(width: 6),
          Text(
            score.toString(),
            style: TextStyle(
              color: isWinner
                  ? colors.brand
                  : colors.contrastText.withValues(alpha: 0.8),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ],
    );
  }
}
