import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/settings_service.dart';
import '../../../../core/models/team_model.dart';
import 'package:tackle4loss_mobile/design_tokens.dart';
import '../../../../core/theme/t4l_theme.dart';
import '../../controllers/standings_controller.dart';
import 'featured_game_card.dart';
import 'timeline_date_header.dart';
import 'timeline_game_row.dart';
import 'week_selector.dart';

/// Schedule tab. Layout matches the new Game Center design:
/// week selector → optional "Your Matchup" featured card → day-grouped
/// timeline of game cards. EMOTIONAL DESIGN: brand color leads.
class ScheduleTab extends StatelessWidget {
  const ScheduleTab({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsService>();
    final selectedTeam = settings.selectedTeam;
    final colors = Theme.of(context).extension<T4LThemeColors>()!;

    return Consumer<StandingsController>(
      builder: (context, controller, _) {
        if (controller.allGames.isEmpty) {
          return _buildEmpty();
        }
        return Column(
          children: [
            WeekSelector(
              weeks: controller.weeks,
              selectedWeek: controller.selectedWeek,
              currentWeek: controller.currentWeek,
              onWeekSelected: controller.selectWeek,
              activeColor: colors.brand,
            ),
            Expanded(
              child: _buildList(context, controller, selectedTeam),
            ),
          ],
        );
      },
    );
  }

  Widget _buildList(
    BuildContext context,
    StandingsController controller,
    Team? themeTeam,
  ) {
    final games = controller.selectedWeekGames;
    final featured = controller.getFeaturedGame(themeTeam?.id);
    final list = featured != null
        ? games.where((g) => g.id != featured.id).toList()
        : games;

    final children = <Widget>[];
    if (featured != null && themeTeam != null) {
      children.add(
        FeaturedGameCard(game: featured, featuredTeam: themeTeam, onTap: () {}),
      );
    }

    for (var i = 0; i < list.length; i++) {
      final g = list[i];
      final newDay = i == 0 || !_sameDay(g.gameday, list[i - 1].gameday);
      if (newDay) {
        children.add(
          TimelineDateHeader(date: g.gameday, week: controller.selectedWeek),
        );
      }
      children.add(TimelineGameRow(game: g, themeTeam: themeTeam));
    }
    children.add(const SizedBox(height: 24));

    return ListView(
      padding: EdgeInsets.zero,
      children: children,
    );
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 36,
            color: Colors.white.withValues(alpha: 0.2),
          ),
          const SizedBox(height: AppSpacing.space2),
          Text(
            'No games scheduled',
            style: AppTextStyles.body.copyWith(
              color: Colors.white.withValues(alpha: 0.4),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
