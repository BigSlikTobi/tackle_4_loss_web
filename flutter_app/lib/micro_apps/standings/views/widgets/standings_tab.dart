import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tackle4loss_mobile/design_tokens.dart';
import '../../../../core/services/settings_service.dart';
import '../../../../core/theme/t4l_theme.dart';
import '../../controllers/standings_controller.dart';
import '../../models/team_standing.dart';
import 'standings_filter_header.dart';
import 'team_standings_card.dart';

/// Result of building a single standings section.
class _Section {
  final String title;
  final String? subtitle;
  final List<TeamStanding> teams;
  final int playoffCutoff;
  final String? scrollKey;

  _Section({
    required this.title,
    required this.teams,
    required this.playoffCutoff,
    this.subtitle,
    this.scrollKey,
  });
}

class StandingsTab extends StatefulWidget {
  const StandingsTab({super.key});

  @override
  State<StandingsTab> createState() => _StandingsTabState();
}

class _StandingsTabState extends State<StandingsTab> {
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
    final normalized = key.toUpperCase();

    if (controller.selectedConference != null) {
      final specific =
          '${controller.selectedConference} $normalized'.toUpperCase();
      for (final k in _sectionKeys.keys) {
        if (k.toUpperCase().contains(specific)) {
          targetKey = k;
          break;
        }
      }
    }
    targetKey ??= _sectionKeys.keys.firstWhere(
      (k) => k.toUpperCase().contains(normalized),
      orElse: () => '',
    );

    if (targetKey.isNotEmpty) {
      final ctx = _sectionKeys[targetKey]?.currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(
          ctx,
          duration: AppAnimation.durationNormal,
          curve: Curves.easeInOut,
          alignment: 0.05,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StandingsController>(
      builder: (context, controller, _) {
        if (controller.isLoadingStandings) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.brandBase));
        }
        if (controller.standingsError != null) {
          return _buildErrorState(controller);
        }
        if (controller.standings.isEmpty) {
          return const Center(child: Text('No standings available.'));
        }

        final myTeamId =
            context.watch<SettingsService>().selectedTeam?.id.toUpperCase();
        final sections = _buildSections(controller);

        final headerHeight = controller.viewMode == StandingsViewMode.division
            ? 132.0
            : controller.viewMode == StandingsViewMode.conference
                ? 92.0
                : 50.0;

        return CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverPersistentHeader(
              pinned: true,
              delegate: _StandingsHeaderDelegate(
                child: const StandingsFilterHeader(),
                height: headerHeight,
              ),
            ),
            SliverToBoxAdapter(child: _buildColumnHeaders()),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) => _buildSection(sections[i], myTeamId),
                childCount: sections.length,
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        );
      },
    );
  }

  // ── Column headers (W / L / PCT) ───────────────────────────────────
  Widget _buildColumnHeaders() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(64, 6, AppSpacing.space2, 4),
      child: Row(
        children: [
          const Spacer(),
          for (final h in ['W', 'L', 'PCT'])
            SizedBox(
              width: 32,
              child: Text(
                h,
                textAlign: TextAlign.center,
                style: AppTextStyles.caption.copyWith(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.7,
                  color: Colors.white.withValues(alpha: 0.22),
                ),
              ),
            ),
          const SizedBox(width: 20),
        ],
      ),
    );
  }

  // ── Section + cutoff line + rows ───────────────────────────────────
  Widget _buildSection(_Section section, String? myTeamId) {
    final colors = Theme.of(context).extension<T4LThemeColors>()!;
    final key = _ensureSectionKey(section.scrollKey);
    final cutoff = section.playoffCutoff;

    final children = <Widget>[
      Container(
        key: key,
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.space2, 12, AppSpacing.space2, 6),
        child: Row(
          children: [
            Flexible(
              child: Text(
                section.title,
                style: AppTextStyles.h3.copyWith(
                  fontFamily: 'Russo One',
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  letterSpacing: 0.6,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ),
            if (section.subtitle != null)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(
                  section.subtitle!,
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withValues(alpha: 0.25),
                  ),
                ),
              ),
          ],
        ),
      ),
    ];

    for (var i = 0; i < section.teams.length; i++) {
      if (i == cutoff) {
        children.add(_buildPlayoffLine(colors));
      }
      final team = section.teams[i];
      final isPlayoff = i < cutoff;
      final isWildcard = !isPlayoff && i < cutoff + 3 && cutoff > 1;
      children.add(
        TeamStandingsCard(
          team: team,
          rank: i + 1,
          isPlayoff: isPlayoff,
          isWildcard: isWildcard,
          isMyTeam: myTeamId != null && team.teamId.toUpperCase() == myTeamId,
          onTap: () {},
        ),
      );
    }

    children.add(const SizedBox(height: 12));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }

  Widget _buildPlayoffLine(T4LThemeColors colors) {
    return Padding(
      padding: const EdgeInsets.only(left: 52, right: AppSpacing.space2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colors.brand,
                  colors.brand.withValues(alpha: 0.2),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 2, bottom: 2),
            child: Text(
              'PLAYOFF LINE',
              style: AppTextStyles.caption.copyWith(
                fontSize: 8,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
                color: colors.brand.computeLuminance() > 0.5
                    ? colors.brand
                    : Color.lerp(colors.brand, Colors.white, 0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  GlobalKey? _ensureSectionKey(String? scrollKey) {
    if (scrollKey == null) return null;
    return _sectionKeys.putIfAbsent(scrollKey, () => GlobalKey());
  }

  // ── Section building ───────────────────────────────────────────────
  List<_Section> _buildSections(StandingsController controller) {
    final mode = controller.viewMode;
    if (mode == StandingsViewMode.league) {
      return _leagueSections(controller);
    }
    if (mode == StandingsViewMode.conference) {
      return _conferenceSections(controller);
    }
    return _divisionSections(controller);
  }

  List<_Section> _leagueSections(StandingsController controller) {
    return controller.standings.map((conf) {
      final teams = <TeamStanding>[];
      for (final d in conf.divisions) {
        teams.addAll(d.teams);
      }
      teams.sort(_byRank((t) => t.conferenceRank));
      return _Section(
        title: conf.conference.toUpperCase(),
        subtitle: '· ALL TEAMS',
        teams: teams,
        playoffCutoff: _playoffCutoff(teams),
        scrollKey: conf.conference.toUpperCase(),
      );
    }).toList();
  }

  List<_Section> _conferenceSections(StandingsController controller) {
    final selected = controller.selectedConference;
    return controller.standings
        .where(
            (c) => selected == null || c.conference.toUpperCase() == selected)
        .map((conf) {
      final teams = <TeamStanding>[];
      for (final d in conf.divisions) {
        teams.addAll(d.teams);
      }
      teams.sort(_byRank((t) => t.conferenceRank));
      return _Section(
        title: '${conf.conference.toUpperCase()} STANDINGS',
        teams: teams,
        playoffCutoff: _playoffCutoff(teams),
        scrollKey: conf.conference.toUpperCase(),
      );
    }).toList();
  }

  List<_Section> _divisionSections(StandingsController controller) {
    final selectedDivision = controller.selectedDivision.toUpperCase();
    final selectedConf = controller.selectedConference;
    final sections = <_Section>[];

    for (final conf in controller.standings) {
      if (selectedConf != null &&
          conf.conference.toUpperCase() != selectedConf) {
        continue;
      }
      for (final div in conf.divisions) {
        if (div.division.toUpperCase() != selectedDivision) continue;
        final sortedTeams = [...div.teams]
          ..sort(_byRank((t) => t.divisionRank));
        sections.add(_Section(
          title:
              '${conf.conference.toUpperCase()} ${div.division.toUpperCase()}',
          teams: sortedTeams,
          // Draw the line after the last team from this division that's
          // currently in the playoffs (division winner + any wildcards).
          playoffCutoff: _playoffCutoff(sortedTeams),
          scrollKey:
              '${conf.conference.toUpperCase()} ${div.division.toUpperCase()}',
        ));
      }
    }
    return sections;
  }

  /// Sort by the given server-supplied rank (ascending). Teams without a
  /// rank fall to the bottom and are ordered by win pct / net points so the
  /// list still degrades gracefully if the backend stops emitting ranks.
  static int Function(TeamStanding, TeamStanding) _byRank(
      int? Function(TeamStanding) pickRank) {
    return (a, b) {
      final ra = pickRank(a);
      final rb = pickRank(b);
      if (ra != null && rb != null) return ra.compareTo(rb);
      if (ra != null) return -1;
      if (rb != null) return 1;
      if (a.winPercentage != b.winPercentage) {
        return b.winPercentage.compareTo(a.winPercentage);
      }
      return b.netPoints.compareTo(a.netPoints);
    };
  }

  /// Index after the last team in [teams] currently holding a conference
  /// playoff seed (1–7). Drives the playoff line position so it lands right
  /// below the deepest seeded team in the section regardless of sort order.
  /// Returns 0 if no team in the section is in the playoffs.
  static int _playoffCutoff(List<TeamStanding> teams) {
    int lastSeededIndex = -1;
    for (int i = 0; i < teams.length; i++) {
      if (teams[i].inPlayoffs) lastSeededIndex = i;
    }
    return lastSeededIndex + 1;
  }

  Widget _buildErrorState(StandingsController controller) {
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
              onPressed: controller.fetchStandings, child: const Text('Retry')),
        ],
      ),
    );
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
  bool shouldRebuild(_StandingsHeaderDelegate old) =>
      old.child != child || old.height != height;
}
