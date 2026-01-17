import 'package:flutter/material.dart';
import '../../../../design_tokens.dart';
import '../../../../core/services/navigation_service.dart';
import '../../../../core/services/team_service.dart';
import '../../../../core/app_registry.dart';
import '../../controllers/standings_controller.dart';
import '../../models/game_model.dart';

/// Home screen widget for the Standings app (2x2 size).
/// Shows upcoming/recent games and current week summary.
class StandingsWidget extends StatefulWidget {
  const StandingsWidget({super.key});

  @override
  State<StandingsWidget> createState() => _StandingsWidgetState();
}

class _StandingsWidgetState extends State<StandingsWidget> {
  final StandingsController _controller = StandingsController();

  @override
  void initState() {
    super.initState();
    _controller.fetchGames();
    _controller.addListener(_onControllerUpdate);
  }

  void _onControllerUpdate() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        final app = AppRegistry().getApp('standings');
        if (app != null) {
          NavigationService().openApp(context, app);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.brandBase, AppColors.brandLight],
          ),
          borderRadius: BorderRadius.circular(AppBorders.radiusXl),
          boxShadow: AppShadows.md,
        ),
        padding: const EdgeInsets.all(AppSpacing.space2),
        child: _controller.isLoading
            ? _buildLoadingState()
            : _controller.error != null
            ? _buildErrorState()
            : _buildContent(isDark),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.sports_football,
            size: 32,
            color: Colors.white.withValues(alpha: 0.7),
          ),
          const SizedBox(height: 8),
          Text(
            'Standings',
            style: AppTextStyles.bodySmall.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(bool isDark) {
    final games = _controller.selectedWeekGames;
    final upcomingGames = games.where((g) => !g.isPlayed).take(2).toList();
    final recentGames = games.where((g) => g.isPlayed).take(2).toList();

    final displayGames = upcomingGames.isNotEmpty ? upcomingGames : recentGames;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              StandingsController.getWeekLabel(_controller.currentWeek),
              style: AppTextStyles.h3.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.space1),
        // Games preview
        Expanded(
          child: displayGames.isEmpty
              ? Center(
                  child: Text(
                    'No games',
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: displayGames
                      .map((game) => _buildGamePreview(game))
                      .toList(),
                ),
        ),
      ],
    );
  }

  Widget _buildGamePreview(Game game) {
    final teamService = TeamService();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space1,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppBorders.radiusMd),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Away team
          _buildTeamInfo(teamService, game.awayTeam, game.awayScore),
          // VS / Score
          Text(
            game.isPlayed ? '-' : '@',
            style: AppTextStyles.caption.copyWith(
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          // Home team
          _buildTeamInfo(teamService, game.homeTeam, game.homeScore),
        ],
      ),
    );
  }

  Widget _buildTeamInfo(TeamService teamService, String teamCode, int? score) {
    final team = teamService.getTeams().firstWhere(
      (t) => t.id.toUpperCase() == teamCode.toUpperCase(),
      orElse: () => teamService.getTeams().first,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          padding: const EdgeInsets.all(2),
          child: Image.asset(
            team.logoUrl,
            width: 16,
            height: 16,
            errorBuilder: (context, error, stackTrace) => Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: team.primaryColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  teamCode[0],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 4),
        if (score != null)
          Text(
            score.toString(),
            style: AppTextStyles.bodySmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          )
        else
          Text(
            teamCode,
            style: AppTextStyles.caption.copyWith(
              color: Colors.white,
              fontSize: 10,
            ),
          ),
      ],
    );
  }
}
