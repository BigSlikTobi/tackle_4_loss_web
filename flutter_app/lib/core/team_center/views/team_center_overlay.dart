import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/team_model.dart';
import '../controllers/team_center_controller.dart';
import 'widgets/games_timeline.dart';
import 'widgets/daily_update_card.dart';
import 'widgets/team_menu_button.dart';
import '../../os_shell/widgets/mini_player.dart';
import 'team_roster_screen.dart';
import 'team_depth_chart_screen.dart';
import 'team_injury_report_screen.dart';
import 'team_article_screen.dart';

/// Overlay widget that displays the Team Center dashboard.
class TeamCenterOverlay extends StatefulWidget {
  final Team team;
  final String languageCode;

  const TeamCenterOverlay({super.key, required this.team, required this.languageCode});

  /// Static method to show the overlay as a dialog.
  static Future<void> show(BuildContext context, Team team) {
    final languageCode = Localizations.localeOf(context).languageCode;
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Team Center',
      barrierColor: Colors.black.withValues(alpha: 0.5), // Backdropp color
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) => TeamCenterOverlay(team: team, languageCode: languageCode),
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: anim1,
            curve: Curves.easeOutCubic,
          )),
          child: child,
        );
      },
    );
  }

  @override
  State<TeamCenterOverlay> createState() => _TeamCenterOverlayState();
}

class _TeamCenterOverlayState extends State<TeamCenterOverlay> {
  late TeamCenterController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TeamCenterController()
      ..loadTeamData(widget.team, languageCode: widget.languageCode)
      ..loadTeamRoster(widget.team.id);

    // Preload Defense images when roster arrives
    _controller.addListener(_preloadDefenseImages);
  }

  @override
  void dispose() {
    _controller.removeListener(_preloadDefenseImages);
    _controller.dispose();
    super.dispose();
  }

  void _preloadDefenseImages() {
    if (_controller.defenseRoster.isNotEmpty) {
      if (!mounted) return;
      for (final player in _controller.defenseRoster) {
        precacheImage(NetworkImage(player.imageUrl), context);
      }
      // Remove listener to run only once (or keep if roster can update)
      _controller.removeListener(_preloadDefenseImages);
    }
  }

  @override
  Widget build(BuildContext context) {
    
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Scaffold(
        backgroundColor: Colors.black.withValues(alpha: 0.1), // Transparent background to show overlay nature
        body: Stack(
          children: [
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(color: Colors.transparent),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
              // 1. Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
                child: _buildHeader(context),
              ),

              // 2. Scrollable Content
              Expanded(
                child: Consumer<TeamCenterController>(
                  builder: (context, controller, _) {
                    if (controller.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    
                    // Prepare games for timeline
                    // We need past, last, next. 
                    // Controller provides allTeamGames, lastGame, nextGame.
                    // Logic: 'Last' is played. 'Next' is upcoming. 'Past' is 'Last - 1'.
                    // For now, simpler logic based on available props to not over-engineer before backend fix.
                    
                    // Hacky "Past Game" find for UI demo
                    final games = controller.allTeamGames;
                    final lastGame = controller.lastGame;
                    var pastGameIndex = -1;
                    if (lastGame != null) {
                       pastGameIndex = games.indexOf(lastGame) - 1;
                    }
                    final pastGame = (pastGameIndex >= 0 && pastGameIndex < games.length) 
                        ? games[pastGameIndex] 
                        : null;

                    return SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          const SizedBox(height: 10),
                          
                          // Timeline
                          GamesTimeline(
                            pastGame: pastGame,
                            lastGame: controller.lastGame,
                            nextGame: controller.nextGame,
                            teamColor: widget.team.primaryColor,
                            teamId: widget.team.id,
                          ),
                          
                          const SizedBox(height: 30),
                          
                          // Daily Update
                          DailyUpdateCard(
                            article: controller.todaysArticle,
                            teamColor: widget.team.primaryColor,
                            onTap: () => controller.playArticleAudio(),
                            onImageTap: () {
                              if (controller.todaysArticle != null) {
                                Navigator.of(context).push(
                                  PageRouteBuilder(
                                    opaque: false, // Keep previous route visible
                                    pageBuilder: (context, animation, secondaryAnimation) => TeamArticleScreen(
                                      articleId: controller.todaysArticle!.id,
                                      languageCode: widget.languageCode,
                                      initialArticle: controller.todaysArticle,
                                    ),
                                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                      return FadeTransition(
                                        opacity: animation,
                                        child: child,
                                      );
                                    },
                                  ),
                                );
                              }
                            },
                          ),
                          
                          const SizedBox(height: 30),
                          
                          // Menu Buttons
                          TeamMenuButton(
                            label: 'Roster',
                            icon: Icons.people_outline,
                            iconAssetPath: 'assets/icons/roster.svg',
                            color: widget.team.primaryColor,
                            onTap: () {
                              final controller = context.read<TeamCenterController>(); // Get existing controller
                              showGeneralDialog(
                                context: context,
                                barrierDismissible: true,
                                barrierLabel: 'Team Roster',
                                barrierColor: Colors.black.withValues(alpha: 0.5),
                                transitionDuration: const Duration(milliseconds: 300),
                                pageBuilder: (context, anim1, anim2) => TeamRosterScreen(
                                  team: widget.team, 
                                  controller: controller, // Pass it
                                ),
                                transitionBuilder: (context, anim1, anim2, child) {
                                  return SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(1, 0), // Slide from right
                                      end: Offset.zero,
                                    ).animate(CurvedAnimation(
                                      parent: anim1,
                                      curve: Curves.easeOutCubic,
                                    )),
                                    child: child,
                                  );
                                },
                              );
                            },
                          ),
                          TeamMenuButton(
                            label: 'Depth Chart',
                            icon: Icons.list_alt,
                            iconAssetPath: 'assets/icons/depth.svg',
                            color: widget.team.primaryColor,
                            onTap: () {
                              final controller = context.read<TeamCenterController>();
                              showGeneralDialog(
                                context: context,
                                barrierDismissible: true,
                                barrierLabel: 'Team Depth Chart',
                                barrierColor: Colors.black.withValues(alpha: 0.5),
                                transitionDuration: const Duration(milliseconds: 300),
                                pageBuilder: (context, anim1, anim2) => TeamDepthChartScreen(
                                  team: widget.team,
                                  controller: controller,
                                ),
                                transitionBuilder: (context, anim1, anim2, child) {
                                  return SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(1, 0),
                                      end: Offset.zero,
                                    ).animate(CurvedAnimation(
                                      parent: anim1,
                                      curve: Curves.easeOutCubic,
                                    )),
                                    child: child,
                                  );
                                },
                              );
                            },
                          ),
                          TeamMenuButton(
                            label: 'Injuries',
                            icon: Icons.local_hospital_outlined,
                            iconAssetPath: 'assets/icons/injuries.svg',
                            color: widget.team.primaryColor,
                            onTap: () {
                              final controller = context.read<TeamCenterController>();
                              showGeneralDialog(
                                context: context,
                                barrierDismissible: true,
                                barrierLabel: 'Team Injury Report',
                                barrierColor: Colors.black.withValues(alpha: 0.5),
                                transitionDuration: const Duration(milliseconds: 300),
                                pageBuilder: (context, anim1, anim2) => TeamInjuryReportScreen(
                                  team: widget.team,
                                  controller: controller,
                                ),
                                transitionBuilder: (context, anim1, anim2, child) {
                                  return SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(1, 0),
                                      end: Offset.zero,
                                    ).animate(CurvedAnimation(
                                      parent: anim1,
                                      curve: Curves.easeOutCubic,
                                    )),
                                    child: child,
                                  );
                                },
                              );
                            },
                          ),
                          
                          const SizedBox(height: 40),
                          
                          const SizedBox(height: 10),
                        ],
                      ),
                    );

                      },
                    ),
                  ),
                ],
              ),
            ),
             // 3. Mini Player (pinned to absolute bottom)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                top: false,
                child: const Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: MiniPlayer(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Centered Content
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.white.withValues(alpha: 0.05),
                border: Border.all(color: Colors.white10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Image.asset(
                  widget.team.logoUrl,
                  errorBuilder: (_, __, ___) => const Icon(Icons.shield, color: Colors.white, size: 20),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'TEAM CENTER',
              style: TextStyle(
                fontFamily: 'Outfit',
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
                fontSize: 22,
                color: Colors.white.withValues(alpha: 0.9),
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),

        // Close Button
        Positioned(
          right: 0,
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 20),
            ),
          ),
        ),
      ],
    ),
  );
}
}
