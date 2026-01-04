import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/team_model.dart';
import '../../widgets/circular_dial_menu.dart';
import '../controllers/team_center_controller.dart';
import '../../../micro_apps/standings/views/widgets/game_cards.dart';
import '../../../micro_apps/game_reports/views/game_report_screen.dart';

/// Overlay widget that displays the Team Center using a circular dial menu.
/// Shows the selected team's Last Game and Next Game.
class TeamCenterOverlay extends StatelessWidget {
  final Team team;

  const TeamCenterOverlay({super.key, required this.team});

  /// Static method to show the overlay as a dialog.
  static Future<void> show(BuildContext context, Team team) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Team Center',
      barrierColor: Colors.black.withValues(alpha: 0.85),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) => TeamCenterOverlay(team: team),
      transitionBuilder: (context, anim1, anim2, child) {
        return Transform.scale(
          scale: CurvedAnimation(
            parent: anim1,
            curve: Curves.easeOutBack,
          ).value,
          child: FadeTransition(opacity: anim1, child: child),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TeamCenterController()..loadTeamData(team),
      child: Material(
        type: MaterialType.transparency,
        child: Consumer<TeamCenterController>(
          builder: (context, controller, _) {
            return Stack(
              children: [
                // Main Content
                if (controller.isLoading)
                  const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                else if (controller.allTeamGames.isEmpty)
                  Center(
                    child: Text(
                      'No team data available',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(color: Colors.white),
                    ),
                  )
                else
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: CircularDialMenu(
                        radius: 200,
                        itemSpacing: 0.8,
                        children: _buildGameCards(context, controller, team),
                      ),
                    ),
                  ),

                // Close Button Top Right
                Positioned(
                  top: 60,
                  right: 20,
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),

                // Title Top Center
                Positioned(
                  top: 70,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Column(
                      children: [
                        Text(
                          team.name.toUpperCase(),
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                        ),
                        Text(
                          'TEAM CENTER',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: Colors.white54,
                                letterSpacing: 4,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Build game card widgets for display (last, current, next only)
  List<Widget> _buildGameCards(
    BuildContext context,
    TeamCenterController controller,
    Team team,
  ) {
    final List<Widget> cards = [];
    final games = controller.allTeamGames;

    if (games.isEmpty) return cards;

    // Find the index of first upcoming game
    int nextGameIndex = games.length; // Default to end if all played
    for (int i = 0; i < games.length; i++) {
      if (!games[i].isPlayed) {
        nextGameIndex = i;
        break;
      }
    }

    // Get last played game (one before nextGameIndex)
    final lastGameIndex = nextGameIndex > 0 ? nextGameIndex - 1 : -1;

    // Get game after next
    final afterNextIndex = nextGameIndex + 1 < games.length
        ? nextGameIndex + 1
        : -1;

    // Build cards for only these 3 games
    // 1. Last played game
    if (lastGameIndex >= 0) {
      final game = games[lastGameIndex];
      cards.add(
        GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => GameReportScreen(initialGame: game),
              ),
            );
          },
          child: GameResultCard(game: game, featuredTeam: team),
        ),
      );
    }

    // 2. Next upcoming game
    if (nextGameIndex < games.length) {
      final game = games[nextGameIndex];
      cards.add(UpcomingGameCard(game: game, featuredTeam: team));
    }

    // 3. Game after next
    if (afterNextIndex >= 0 && afterNextIndex < games.length) {
      final game = games[afterNextIndex];
      cards.add(UpcomingGameCard(game: game, featuredTeam: team));
    }

    return cards;
  }
}
