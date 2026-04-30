import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../design_tokens.dart';
import '../../models/team_model.dart';
import '../../services/settings_service.dart';
import '../../theme/t4l_theme.dart';
import '../models/roster_player.dart';
import '../controllers/team_center_controller.dart';

// Brand-green accent shared by chips/tabs (sourced from design tokens).
const Color _kAccent = AppColors.brandBase;

class TeamRosterScreen extends StatefulWidget {
  final Team team;
  final TeamCenterController controller;

  const TeamRosterScreen({
    super.key,
    required this.team,
    required this.controller,
  });

  @override
  State<TeamRosterScreen> createState() => _TeamRosterScreenState();
}

class _TeamRosterScreenState extends State<TeamRosterScreen> {
  static const _units = ['OFFENSE', 'DEFENSE', 'SPECIAL'];

  int _unitIdx = 1; // Defense default — matches existing app behavior
  String _posFilter = 'ALL';
  String _query = '';
  final TextEditingController _searchCtl = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  late _RosterPalette _p;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.controller.loadTeamRoster(widget.team.id);
      _preloadImages(widget.controller.offenseRoster);
      _preloadImages(widget.controller.specialTeamsRoster);
    });
  }

  @override
  void dispose() {
    _searchCtl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _preloadImages(List<RosterPlayer> players) {
    if (!mounted) return;
    for (final p in players) {
      if (p.imageUrl.isNotEmpty) {
        precacheImage(CachedNetworkImageProvider(p.imageUrl), context);
      }
    }
  }

  void _switchUnit(int idx) {
    setState(() {
      _unitIdx = idx;
      _posFilter = 'ALL';
      _query = '';
      _searchCtl.clear();
    });
  }

  List<RosterPlayer> _unitRoster(TeamCenterController c) {
    switch (_unitIdx) {
      case 0:
        return c.offenseRoster;
      case 2:
        return c.specialTeamsRoster;
      default:
        return c.defenseRoster;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<T4LThemeColors>()!;
    final isDark = theme.brightness == Brightness.dark;
    final settings = Provider.of<SettingsService>(context);
    _p = _RosterPalette.from(colors, isDark);

    return ChangeNotifierProvider.value(
      value: widget.controller,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          decoration: BoxDecoration(gradient: settings.backgroundGradient),
          child: Stack(
            children: [
              // Subtle scrim so chrome stays readable on bright team gradients
              // without hiding the team color.
              Positioned.fill(child: Container(color: _p.scrim)),
              SafeArea(
                child: Consumer<TeamCenterController>(
                  builder: (context, controller, _) {
                    final players = _unitRoster(controller);
                    final positions = _orderedPositions(players);
                    final filtered = _filter(players);

                    return Column(
                      children: [
                        _buildHeader(),
                        _buildUnitTabs(),
                        _buildSearchRow(),
                        _buildChipsRow(positions),
                        const SizedBox(height: 4),
                        Expanded(
                          child: _buildBody(controller, filtered),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── HEADER ───────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 16, 14),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: _p.border)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.team.primaryColor,
              border: Border.all(
                color: _p.surfaceMuted,
                width: 2,
              ),
            ),
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: Image.asset(
                widget.team.logoUrl,
                errorBuilder: (_, __, ___) => Text(
                  widget.team.id.toUpperCase(),
                  style: const TextStyle(
                    fontFamily: 'Russo One',
                    fontSize: 9,
                    color: Colors.white,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'TEAM ROSTER',
            style: TextStyle(
              fontFamily: 'Russo One',
              fontSize: 20,
              fontStyle: FontStyle.italic,
              letterSpacing: 0.8,
              color: _p.textPrimary,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _p.surfaceMuted,
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.close,
                size: 14,
                color: _p.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── UNIT TABS ────────────────────────────────────────────────────────────
  Widget _buildUnitTabs() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: _p.border)),
      ),
      child: Row(
        children: List.generate(_units.length, (i) {
          final active = i == _unitIdx;
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _switchUnit(i),
              child: Container(
                padding: const EdgeInsets.fromLTRB(4, 8, 4, 10),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: active ? _kAccent : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  _units[i],
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.99,
                    color: active ? _p.textPrimary : _p.textMuted,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ── SEARCH ROW ───────────────────────────────────────────────────────────
  Widget _buildSearchRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: _p.surfaceSubtle,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _searchFocus.hasFocus
                ? _kAccent.withValues(alpha: 0.6)
                : _p.chipBorder,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.search,
              size: 16,
              color: _p.textMuted,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _searchCtl,
                focusNode: _searchFocus,
                onChanged: (v) => setState(() => _query = v),
                style: TextStyle(
                  color: _p.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  border: InputBorder.none,
                  hintText: 'Search players, position, college…',
                  hintStyle: TextStyle(
                    color: _p.textGhost,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            if (_query.isNotEmpty)
              GestureDetector(
                onTap: () {
                  _searchCtl.clear();
                  setState(() => _query = '');
                  _searchFocus.requestFocus();
                },
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _p.surfaceMuted,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.close,
                    size: 10,
                    color: _p.textSecondary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── CHIPS ────────────────────────────────────────────────────────────────
  Widget _buildChipsRow(List<String> positions) {
    final chips = ['ALL', ...positions];
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 4),
      child: SizedBox(
        height: 30,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: chips.length,
          separatorBuilder: (_, __) => const SizedBox(width: 6),
          itemBuilder: (_, i) {
            final c = chips[i];
            final active = c == _posFilter;
            return GestureDetector(
              onTap: () => setState(() => _posFilter = c),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: active ? _kAccent : _p.chipBg,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: active ? _kAccent : _p.chipBorder,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  c,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.77,
                    color: active ? Colors.white : _p.textMuted,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ── LIST ─────────────────────────────────────────────────────────────────
  Widget _buildBody(TeamCenterController c, List<RosterPlayer> filtered) {
    if (c.isRosterLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (c.rosterError != null) {
      return Center(
        child: Text(
          'Failed to load roster',
          style: TextStyle(color: _p.textMuted),
        ),
      );
    }
    if (filtered.isEmpty) return _buildEmpty();

    final groups = _groupByPosition(filtered);

    return CustomScrollView(
      slivers: [
        for (final g in groups) ...[
          SliverPersistentHeader(
            pinned: true,
            delegate: _GroupHeaderDelegate(
              label: _positionLabel(g.position),
              count: g.players.length,
              bg: _p.stickyBg,
              labelColor: _p.textMuted,
              countColor: _p.textGhost,
            ),
          ),
          SliverList.separated(
            itemCount: g.players.length,
            itemBuilder: (_, i) => _buildPlayerRow(g.players[i]),
            separatorBuilder: (_, __) => Padding(
              padding: const EdgeInsets.only(left: 72, right: 16),
              child: Divider(
                height: 1,
                thickness: 1,
                color: _p.separator,
              ),
            ),
          ),
        ],
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_off,
            size: 40,
            color: _p.surfaceMuted,
          ),
          const SizedBox(height: 10),
          Text(
            'No players found',
            style: TextStyle(
              color: _p.textMuted,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Try a different search or filter',
            style: TextStyle(
              color: _p.textMuted,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // ── PLAYER ROW ───────────────────────────────────────────────────────────
  Widget _buildPlayerRow(RosterPlayer p) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showPlayerDetail(p),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              SizedBox(
                width: 26,
                child: Text(
                  _formatNumber(p.number),
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontFamily: 'Russo One',
                    fontSize: 15,
                    color: _p.textGhost,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _buildAvatar(p),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      p.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _p.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _kAccent.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            p.position.toUpperCase(),
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.72,
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if ((p.experience.isNotEmpty &&
                            p.experience.trim() != '—') ||
                        (p.college.isNotEmpty && p.college != 'N/A')) ...[
                      const SizedBox(height: 3),
                      Text(
                        _metaLine(p),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: _p.textMuted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right,
                size: 18,
                color: _p.textGhost,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(RosterPlayer p) {
    final fallbackBg = _positionAccent(p.position);
    final initials = _initials(p.name);
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: _p.logoRing,
          width: 2,
        ),
      ),
      child: ClipOval(
        child: p.imageUrl.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: p.imageUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  color: fallbackBg,
                  alignment: Alignment.center,
                  child: Text(
                    initials,
                    style: TextStyle(
                      fontFamily: 'Russo One',
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ),
                errorWidget: (_, __, ___) => Container(
                  color: fallbackBg,
                  alignment: Alignment.center,
                  child: Text(
                    initials,
                    style: TextStyle(
                      fontFamily: 'Russo One',
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              )
            : Container(
                color: fallbackBg,
                alignment: Alignment.center,
                child: Text(
                  initials,
                  style: TextStyle(
                    fontFamily: 'Russo One',
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ),
      ),
    );
  }

  // ── DETAIL SHEET ─────────────────────────────────────────────────────────
  void _showPlayerDetail(RosterPlayer p) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (_) => _PlayerDetailSheet(player: p, team: widget.team),
    );
  }

  // ── HELPERS ──────────────────────────────────────────────────────────────
  List<RosterPlayer> _filter(List<RosterPlayer> players) {
    final q = _query.trim().toLowerCase();
    return players.where((p) {
      final matchPos = _posFilter == 'ALL' || p.position == _posFilter;
      if (!matchPos) return false;
      if (q.isEmpty) return true;
      return p.name.toLowerCase().contains(q) ||
          p.position.toLowerCase().contains(q) ||
          p.college.toLowerCase().contains(q);
    }).toList();
  }

  List<String> _orderedPositions(List<RosterPlayer> players) {
    final seen = <String>{};
    final ordered = <String>[];
    for (final p in players) {
      if (p.position.isEmpty) continue;
      if (seen.add(p.position)) ordered.add(p.position);
    }
    ordered.sort((a, b) {
      final aOrder = _positionOrder(a);
      final bOrder = _positionOrder(b);
      if (aOrder != bOrder) return aOrder.compareTo(bOrder);
      return a.compareTo(b);
    });
    return ordered;
  }

  List<_PositionGroup> _groupByPosition(List<RosterPlayer> players) {
    final map = <String, List<RosterPlayer>>{};
    for (final p in players) {
      map.putIfAbsent(p.position, () => []).add(p);
    }
    final positions = map.keys.toList()
      ..sort((a, b) {
        final aOrder = _positionOrder(a);
        final bOrder = _positionOrder(b);
        if (aOrder != bOrder) return aOrder.compareTo(bOrder);
        return a.compareTo(b);
      });
    return [
      for (final pos in positions)
        _PositionGroup(position: pos, players: map[pos]!),
    ];
  }

  int _positionOrder(String pos) {
    const order = [
      // offense
      'QB', 'RB', 'FB', 'WR', 'TE',
      'LT', 'LG', 'C', 'RG', 'RT', 'OL', 'T', 'G',
      // defense
      'DE', 'DT', 'NT', 'EDGE', 'DL',
      'LB', 'ILB', 'OLB', 'MLB',
      'CB', 'NB', 'S', 'FS', 'SS', 'DB',
      // special
      'K', 'P', 'LS', 'KR', 'PR',
    ];
    final idx = order.indexOf(pos.toUpperCase());
    return idx >= 0 ? idx : 999;
  }

  String _positionLabel(String pos) {
    const map = {
      'QB': 'Quarterback',
      'RB': 'Running Back',
      'FB': 'Fullback',
      'WR': 'Wide Receiver',
      'TE': 'Tight End',
      'LT': 'Left Tackle',
      'RT': 'Right Tackle',
      'LG': 'Left Guard',
      'RG': 'Right Guard',
      'C': 'Center',
      'OL': 'Offensive Line',
      'T': 'Tackle',
      'G': 'Guard',
      'DE': 'Defensive End',
      'DT': 'Defensive Tackle',
      'NT': 'Nose Tackle',
      'EDGE': 'Edge',
      'DL': 'Defensive Line',
      'LB': 'Linebacker',
      'ILB': 'Inside Linebacker',
      'OLB': 'Outside Linebacker',
      'MLB': 'Middle Linebacker',
      'CB': 'Cornerback',
      'NB': 'Nickel Back',
      'S': 'Safety',
      'FS': 'Free Safety',
      'SS': 'Strong Safety',
      'DB': 'Defensive Back',
      'K': 'Kicker',
      'P': 'Punter',
      'LS': 'Long Snapper',
      'KR': 'Kick Returner',
      'PR': 'Punt Returner',
    };
    return map[pos.toUpperCase()] ?? pos.toUpperCase();
  }

  Color _positionAccent(String pos) {
    const offense = ['QB', 'RB', 'FB', 'WR', 'TE'];
    const oline = ['LT', 'RT', 'LG', 'RG', 'C', 'OL', 'T', 'G'];
    const dline = ['DE', 'DT', 'NT', 'EDGE', 'DL'];
    const lb = ['LB', 'ILB', 'OLB', 'MLB'];
    const db = ['CB', 'NB', 'S', 'FS', 'SS', 'DB'];
    final p = pos.toUpperCase();
    if (offense.contains(p)) return const Color(0xFF1A2F4A);
    if (oline.contains(p)) return const Color(0xFF1A2F1A);
    if (dline.contains(p)) return const Color(0xFF2A1A1A);
    if (lb.contains(p)) return const Color(0xFF2A1F10);
    if (db.contains(p)) return const Color(0xFF1A2A2A);
    return const Color(0xFF1A2A20);
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    final letters = parts.where((p) => p.isNotEmpty).map((p) => p[0]).toList();
    return letters.take(2).join().toUpperCase();
  }

  String _formatNumber(String num) {
    if (num.isEmpty) return '#';
    return num.startsWith('#') ? num : '#$num';
  }

  String _metaLine(RosterPlayer p) {
    final parts = <String>[];
    final exp = p.experience.trim();
    if (exp.isNotEmpty && exp != '—') parts.add(exp);
    if (p.college.isNotEmpty && p.college != 'N/A') parts.add(p.college);
    return parts.join(' · ');
  }
}

// ─── POSITION GROUP MODEL ────────────────────────────────────────────────────
class _PositionGroup {
  final String position;
  final List<RosterPlayer> players;
  _PositionGroup({required this.position, required this.players});
}

// ─── STICKY GROUP HEADER ─────────────────────────────────────────────────────
class _GroupHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String label;
  final int count;
  final Color bg;
  final Color labelColor;
  final Color countColor;

  _GroupHeaderDelegate({
    required this.label,
    required this.count,
    required this.bg,
    required this.labelColor,
    required this.countColor,
  });

  @override
  double get minExtent => 36;
  @override
  double get maxExtent => 36;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          color: bg,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  fontFamily: 'Russo One',
                  fontSize: 11,
                  letterSpacing: 1.1,
                  color: labelColor,
                ),
              ),
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: countColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _GroupHeaderDelegate oldDelegate) {
    return oldDelegate.label != label ||
        oldDelegate.count != count ||
        oldDelegate.bg != bg ||
        oldDelegate.labelColor != labelColor ||
        oldDelegate.countColor != countColor;
  }
}

// ─── PLAYER DETAIL SHEET ─────────────────────────────────────────────────────
class _PlayerDetailSheet extends StatelessWidget {
  final RosterPlayer player;
  final Team team;

  const _PlayerDetailSheet({required this.player, required this.team});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<T4LThemeColors>()!;
    final isDark = theme.brightness == Brightness.dark;

    final sheetBg = isDark ? const Color(0xFF141E16) : colors.surface;
    final topBorder = isDark ? const Color(0x14FFFFFF) : colors.border;
    final dividerColor = isDark ? const Color(0x0DFFFFFF) : colors.border;
    final keyColor =
        isDark ? Colors.white.withValues(alpha: 0.28) : colors.textMuted;
    final valColor =
        isDark ? Colors.white.withValues(alpha: 0.75) : colors.textSecondary;
    final ghostColor = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : colors.textMuted.withValues(alpha: 0.4);
    final handleColor = isDark
        ? Colors.white.withValues(alpha: 0.15)
        : colors.textMuted.withValues(alpha: 0.5);
    final subColor =
        isDark ? Colors.white.withValues(alpha: 0.4) : colors.textSecondary;
    final avatarRing =
        isDark ? Colors.white.withValues(alpha: 0.2) : colors.border;

    final initials = player.name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .map((p) => p[0])
        .take(2)
        .join()
        .toUpperCase();

    final bioRows = <List<String>>[];
    if (player.position.isNotEmpty) bioRows.add(['Position', player.position]);
    if (player.experience.trim().isNotEmpty &&
        player.experience.trim() != '—') {
      bioRows.add(['Experience', player.experience]);
    }
    if (player.college.isNotEmpty && player.college != 'N/A') {
      bioRows.add(['College', player.college]);
    }
    bioRows.add(['Team', team.id.toUpperCase()]);

    return Container(
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: topBorder)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: handleColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
              child: Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: avatarRing, width: 2),
                    ),
                    child: ClipOval(
                      child: player.imageUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: player.imageUrl,
                              fit: BoxFit.cover,
                              errorWidget: (_, __, ___) => _initialsBg(
                                initials,
                                team.primaryColor,
                              ),
                            )
                          : _initialsBg(initials, team.primaryColor),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          player.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Russo One',
                            fontSize: 18,
                            color: colors.textPrimary,
                            letterSpacing: 0.36,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          [
                            player.position,
                            if (player.experience.trim().isNotEmpty &&
                                player.experience.trim() != '—')
                              '${player.experience} Exp',
                            if (player.college.isNotEmpty &&
                                player.college != 'N/A')
                              player.college,
                          ].join(' · '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: subColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    player.number.startsWith('#')
                        ? player.number
                        : '#${player.number}',
                    style: TextStyle(
                      fontFamily: 'Russo One',
                      fontSize: 32,
                      color: ghostColor,
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: dividerColor),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
              child: Column(
                children: [
                  for (int i = 0; i < bioRows.length; i++) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            bioRows[i][0].toUpperCase(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.66,
                              color: keyColor,
                            ),
                          ),
                          Flexible(
                            child: Text(
                              bioRows[i][1],
                              textAlign: TextAlign.right,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: valColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (i < bioRows.length - 1)
                      Divider(height: 1, color: dividerColor),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _initialsBg(String initials, Color color) {
    return Container(
      color: color,
      alignment: Alignment.center,
      child: Text(
        initials,
        style: const TextStyle(
          fontFamily: 'Russo One',
          fontSize: 16,
          color: Colors.white,
        ),
      ),
    );
  }
}

// ─── PALETTE (theme-aware surface/text/border resolution) ────────────────
class _RosterPalette {
  final bool isDark;
  final Color scrim;
  final Color stickyBg;
  final Color border;
  final Color separator;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color textGhost;
  final Color surfaceMuted;
  final Color surfaceSubtle;
  final Color chipBg;
  final Color chipBorder;
  final Color logoRing;

  const _RosterPalette({
    required this.isDark,
    required this.scrim,
    required this.stickyBg,
    required this.border,
    required this.separator,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.textGhost,
    required this.surfaceMuted,
    required this.surfaceSubtle,
    required this.chipBg,
    required this.chipBorder,
    required this.logoRing,
  });

  factory _RosterPalette.from(T4LThemeColors c, bool isDark) {
    if (isDark) {
      return _RosterPalette(
        isDark: true,
        scrim: Colors.black.withValues(alpha: 0.45),
        stickyBg: Colors.black.withValues(alpha: 0.55),
        border: const Color(0x14FFFFFF),
        separator: const Color(0x0AFFFFFF),
        textPrimary: Colors.white,
        textSecondary: Colors.white.withValues(alpha: 0.6),
        textMuted: Colors.white.withValues(alpha: 0.4),
        textGhost: Colors.white.withValues(alpha: 0.22),
        surfaceMuted: Colors.white.withValues(alpha: 0.1),
        surfaceSubtle: Colors.white.withValues(alpha: 0.06),
        chipBg: Colors.white.withValues(alpha: 0.07),
        chipBorder: Colors.white.withValues(alpha: 0.12),
        logoRing: Colors.white.withValues(alpha: 0.15),
      );
    }
    return _RosterPalette(
      isDark: false,
      scrim: Colors.white.withValues(alpha: 0.55),
      stickyBg: Colors.white.withValues(alpha: 0.7),
      border: c.border,
      separator: c.border.withValues(alpha: 0.5),
      textPrimary: c.textPrimary,
      textSecondary: c.textSecondary,
      textMuted: c.textMuted,
      textGhost: c.textMuted.withValues(alpha: 0.55),
      surfaceMuted: c.textPrimary.withValues(alpha: 0.06),
      surfaceSubtle: c.textPrimary.withValues(alpha: 0.04),
      chipBg: Colors.white.withValues(alpha: 0.6),
      chipBorder: c.border,
      logoRing: c.textPrimary.withValues(alpha: 0.12),
    );
  }
}
