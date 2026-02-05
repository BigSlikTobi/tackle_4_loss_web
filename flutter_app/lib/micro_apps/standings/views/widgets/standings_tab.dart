import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tackle4loss_mobile/design_tokens.dart';
import '../../controllers/standings_controller.dart';
import '../../models/team_standing.dart';
import 'standings_filter_header.dart';
import 'team_standings_card.dart';

class StandingsTab extends StatefulWidget {
  const StandingsTab({super.key});

  @override
  State<StandingsTab> createState() => _StandingsTabState();
}

class _StandingsTabState extends State<StandingsTab> {
  String? _expandedTeamId;
  final ScrollController _scrollController = ScrollController();
  final Map<String, GlobalKey> _sectionKeys = {};
  StreamSubscription? _scrollSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = context.read<StandingsController>();
      controller.setScrollController(_scrollController);
      _scrollSubscription =
          controller.scrollRequests.listen(_handleScrollRequest);
    });
  }

  @override
  void dispose() {
    _scrollSubscription?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleScrollRequest(String key) {
    if (!mounted) return;

    final controller = context.read<StandingsController>();
    String? targetKey;
    final normalizedInfo = key.toUpperCase();

    // If a conference is explicitly selected, prioritize that specific key
    if (controller.selectedConference != null) {
      final specificKey =
          "${controller.selectedConference} $normalizedInfo".toUpperCase();
      for (final sectionKey in _sectionKeys.keys) {
        if (sectionKey.toUpperCase().contains(specificKey)) {
          targetKey = sectionKey;
          break;
        }
      }
    }

    // Fallback: Find first matching key (default behavior) if no target found yet
    if (targetKey == null) {
      for (final sectionKey in _sectionKeys.keys) {
        if (sectionKey.toUpperCase().contains(normalizedInfo)) {
          targetKey = sectionKey;
          break;
        }
      }
    }

    if (targetKey != null) {
      final context = _sectionKeys[targetKey]?.currentContext;
      if (context != null) {
        Scrollable.ensureVisible(
          context,
          duration: AppAnimation.durationNormal,
          curve: Curves.easeInOut,
          alignment: 0.05,
        );
      }
    }
  }

  void _onTeamTap(String teamId) {
    setState(() {
      if (_expandedTeamId == teamId) {
        _expandedTeamId = null; // Collapse if already open
      } else {
        _expandedTeamId = teamId; // Expand
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StandingsController>(
      builder: (context, controller, child) {
        if (controller.isLoadingStandings) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.brandBase));
        }

        if (controller.standingsError != null) {
          return _buildErrorState(context, controller);
        }

        if (controller.standings.isEmpty) {
          return _buildEmptyState(context);
        }

        return CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Pinned Filter Header
            SliverPersistentHeader(
              pinned: true,
              delegate: _StandingsHeaderDelegate(
                child: const StandingsFilterHeader(),
                // Increase height if Division view to accommodate stacked filters
                height: controller.viewMode == StandingsViewMode.division
                    ? 160
                    : 110,
              ),
            ),

            // Content
            SliverPadding(
              padding: const EdgeInsets.all(AppSpacing.space2),
              sliver: _buildSliverContent(controller),
            ),

            const SliverToBoxAdapter(
                child: SizedBox(height: 80)), // Bottom padding
          ],
        );
      },
    );
  }

  Widget _buildSliverContent(StandingsController controller) {
    final mode = controller.viewMode;
    final standings = controller.standings;

    if (mode == StandingsViewMode.league) {
      return _buildLeagueView(standings);
    } else if (mode == StandingsViewMode.conference) {
      return _buildConferenceView(standings, controller);
    } else {
      return _buildDivisionView(standings, controller);
    }
  }

  Widget _buildLeagueView(List<ConferenceStandings> standings) {
    // Flatten all teams
    final List<TeamStanding> allTeams = [];
    for (var conf in standings) {
      for (var div in conf.divisions) {
        allTeams.addAll(div.teams);
      }
    }
    // Sort by record
    allTeams.sort((a, b) {
      if (a.winPercentage != b.winPercentage) {
        return b.winPercentage.compareTo(a.winPercentage);
      }
      return b.netPoints.compareTo(a.netPoints);
    });

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSectionHeader("NFL LEAGUE", null),
          ...allTeams.asMap().entries.map((entry) {
            final index = entry.key;
            final team = entry.value;
            return TeamStandingsCard(
              team: team,
              rank: index + 1,
              isExpanded: _expandedTeamId == team.teamId,
              onTap: () => _onTeamTap(team.teamId),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildConferenceView(
      List<ConferenceStandings> standings, StandingsController controller) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var conf in standings) ...[
            // Filter by selection if active
            if (controller.selectedConference == null ||
                controller.selectedConference ==
                    conf.conference.toUpperCase()) ...[
              _buildSectionHeader(conf.conference, conf.conference),

              // Flatten divisions for sorting
              Builder(builder: (context) {
                final confTeams = <TeamStanding>[];
                for (var div in conf.divisions) {
                  confTeams.addAll(div.teams);
                }
                // Sort by Conf ranking logic
                confTeams.sort((a, b) {
                  if (a.winPercentage != b.winPercentage) {
                    return b.winPercentage.compareTo(a.winPercentage);
                  }
                  return b.netPoints.compareTo(a.netPoints);
                });

                return Column(
                  children: [
                    for (int i = 0; i < confTeams.length; i++)
                      TeamStandingsCard(
                        team: confTeams[i],
                        rank: i + 1,
                        isExpanded: _expandedTeamId == confTeams[i].teamId,
                        onTap: () => _onTeamTap(confTeams[i].teamId),
                      )
                  ],
                );
              }),

              const SizedBox(height: 24),
            ]
          ]
        ],
      ),
    );
  }

  Widget _buildDivisionView(
      List<ConferenceStandings> standings, StandingsController controller) {
    final items = <Widget>[];

    for (var conf in standings) {
      // Filter by selection if active
      if (controller.selectedConference != null &&
          controller.selectedConference != conf.conference.toUpperCase()) {
        continue;
      }

      for (var div in conf.divisions) {
        // Fix redundancy: If division mentions conference (e.g. 'AFC EAST'), use it directly.
        // Otherwise prepend. The data usually comes as 'East', so we construct 'AFC EAST'.
        // But if it's already full, we handle it.
        var sectionName =
            "${conf.conference.toUpperCase()} ${div.division.toUpperCase()}";
        if (div.division
            .toUpperCase()
            .contains(conf.conference.toUpperCase())) {
          sectionName = div.division.toUpperCase();
        }

        items.add(_buildSectionHeader(sectionName, sectionName));

        for (int i = 0; i < div.teams.length; i++) {
          final team = div.teams[i];
          items.add(TeamStandingsCard(
            team: team,
            rank: i + 1,
            isExpanded: _expandedTeamId == team.teamId,
            onTap: () => _onTeamTap(team.teamId),
          ));
        }
        items.add(const SizedBox(height: 16));
      }
    }

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: items,
      ),
    );
  }

  Widget _buildSectionHeader(String title, String? keyDetails) {
    if (keyDetails != null) {
      if (!_sectionKeys.containsKey(keyDetails)) {
        _sectionKeys[keyDetails] = GlobalKey();
      }
    }

    return Container(
      key: keyDetails != null ? _sectionKeys[keyDetails] : null,
      padding: const EdgeInsets.symmetric(vertical: 8),
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTextStyles.h2.copyWith(
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w900,
              color: Colors.white.withValues(alpha: 0.9), // Brighter white/grey
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(
      BuildContext context, StandingsController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline,
              size: 48, color: AppColors.breakingNewsRed),
          const SizedBox(height: AppSpacing.space2),
          const Text('Failed to load standings', style: AppTextStyles.h3),
          const SizedBox(height: AppSpacing.space1),
          TextButton(
              onPressed: controller.fetchStandings, child: const Text("Retry")),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return const Center(child: Text("No standings available."));
  }
}

class _StandingsHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  _StandingsHeaderDelegate({required this.child, required this.height});

  @override
  double get minExtent => height;
  @override
  double get maxExtent => height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_StandingsHeaderDelegate oldDelegate) {
    return oldDelegate.child != child || oldDelegate.height != height;
  }
}
