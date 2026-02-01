import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/settings_service.dart';
import '../../../../core/models/team_model.dart';
import '../../../../design_tokens.dart';
import '../../../../core/theme/t4l_theme.dart';
import '../../controllers/standings_controller.dart';
import 'featured_game_card.dart';
import 'timeline_date_header.dart';
import 'timeline_game_row.dart';
import 'week_selector.dart';

/// Schedule tab for the Game Center.
/// Displays NFL games organized by week with team logos.
class ScheduleTab extends StatelessWidget {
  const ScheduleTab({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsService>(context);
    final selectedTeam = settings.selectedTeam;

    return Consumer<StandingsController>(
      builder: (context, controller, child) {
        if (controller.allGames.isEmpty) {
          return _buildEmptyState(context);
        }

        return Column(
          children: [
            // Week selector
            WeekSelector(
              weeks: controller.weeks,
              selectedWeek: controller.selectedWeek,
              currentWeek: controller.currentWeek,
              onWeekSelected: controller.selectWeek,
              activeColor: Theme.of(context).extension<T4LThemeColors>()!.brand,
            ),
            // Games list
            Expanded(
              child: _buildGamesList(context, controller, selectedTeam),
            ),
          ],
        );
      },
    );
  }

  Widget _buildGamesList(
    BuildContext context,
    StandingsController controller,
    Team? themeTeam,
  ) {
    final games = controller.selectedWeekGames;

    // 1. Find Featured Game (User's Team)
    final featuredGame = controller.getFeaturedGame(themeTeam?.id);

    // 2. Filter list (Exclude featured game to avoid dupes)
    final listGames = featuredGame != null
        ? games.where((g) => g.id != featuredGame.id).toList()
        : games;

    final children = <Widget>[];

    // Add Featured Game
    if (featuredGame != null) {
      children.add(
        FeaturedGameCard(
          game: featuredGame,
          featuredTeam: themeTeam!,
          onTap: () {},
        ),
      );
    }

    // Process Timeline Items
    if (listGames.isNotEmpty) {
      for (int i = 0; i < listGames.length; i++) {
        final game = listGames[i];
        final isNewDay =
            i == 0 || !_isSameDay(game.gameday, listGames[i - 1].gameday);

        if (isNewDay) {
          children.add(
            TimelineDateHeader(
              date: game.gameday,
              week: controller.selectedWeek,
              themeColor: Theme.of(context).extension<T4LThemeColors>()!.brand,
            ),
          );
        }

        children.add(
          TimelineGameRow(
            game: game,
            themeTeam: themeTeam,
          ),
        );
      }
    }

    return ListView(
      padding: const EdgeInsets.only(
        top: AppSpacing.space1,
        bottom: AppSpacing.space6,
        left: AppSpacing.space3,
        right: AppSpacing.space3,
      ),
      children: children,
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Widget _buildEmptyState(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.sports_football,
            size: 64,
            color: isDark ? AppColors.textSubDark : AppColors.textSubLight,
          ),
          const SizedBox(height: AppSpacing.space2),
          Text(
            'No games found',
            style: AppTextStyles.h3.copyWith(
              color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
            ),
          ),
          const SizedBox(height: AppSpacing.space1),
          const Text(
            'Check back later for game schedules',
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }
}
