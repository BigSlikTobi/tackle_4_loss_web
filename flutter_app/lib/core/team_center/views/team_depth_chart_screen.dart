import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/team_model.dart';
import '../../services/settings_service.dart';
import '../../theme/t4l_theme.dart';
import '../models/depth_chart_player.dart';
import '../controllers/team_center_controller.dart';

// ─── Brand semantic constants (identical in both themes) ─────────────────
const Color _kAccent = Color(0xFF0F3D2E); // brand green
const Color _kGold = Color(0xFFC9A256); // starter / 1ST
const Color _kStatusActive = Color(0xFF4CAF80);
const Color _kStatusQuest = Color(0xFFC9A256);
const Color _kStatusOut = Color(0xFFE06060);

enum _ViewMode { list, overview }

class TeamDepthChartScreen extends StatefulWidget {
  final Team team;
  final TeamCenterController controller;

  const TeamDepthChartScreen({
    super.key,
    required this.team,
    required this.controller,
  });

  @override
  State<TeamDepthChartScreen> createState() => _TeamDepthChartScreenState();
}

class _TeamDepthChartScreenState extends State<TeamDepthChartScreen> {
  static const _units = ['OFFENSE', 'DEFENSE', 'SPECIAL'];

  int _unitIdx = 0;
  String _posFilter = 'ALL';
  _ViewMode _viewMode = _ViewMode.list;

  late _DepthPalette _p;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.controller.loadDepthChart(widget.team.id);
      _preloadAll();
    });
  }

  void _preloadAll() {
    _preloadGroup(widget.controller.offenseDepthChart);
    _preloadGroup(widget.controller.defenseDepthChart);
    _preloadGroup(widget.controller.specialTeamsDepthChart);
  }

  void _preloadGroup(Map<String, List<DepthChartPlayer>> groups) {
    if (!mounted) return;
    for (final players in groups.values) {
      for (final p in players) {
        if (p.imageUrl.isNotEmpty) {
          precacheImage(CachedNetworkImageProvider(p.imageUrl), context);
        }
      }
    }
  }

  Map<String, List<DepthChartPlayer>> _unitGroups(TeamCenterController c) {
    switch (_unitIdx) {
      case 0:
        return c.offenseDepthChart;
      case 1:
        return c.defenseDepthChart;
      default:
        return c.specialTeamsDepthChart;
    }
  }

  void _switchUnit(int i) {
    setState(() {
      _unitIdx = i;
      _posFilter = 'ALL';
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<T4LThemeColors>()!;
    final isDark = theme.brightness == Brightness.dark;
    final settings = Provider.of<SettingsService>(context);
    _p = _DepthPalette.from(colors, isDark);

    return ChangeNotifierProvider.value(
      value: widget.controller,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          decoration: BoxDecoration(gradient: settings.backgroundGradient),
          child: Stack(
            children: [
              // Subtle overlay tint so chrome (text, dividers, sticky headers)
              // stays readable on bright team-color gradients.
              Positioned.fill(
                child: Container(color: _p.scrim),
              ),
              SafeArea(
                child: Consumer<TeamCenterController>(
                  builder: (context, controller, _) {
                    final groups = _unitGroups(controller);
                    final orderedKeys = groups.keys.toList();
                    final filteredKeys = _posFilter == 'ALL'
                        ? orderedKeys
                        : orderedKeys.where((k) => k == _posFilter).toList();

                    return Column(
                      children: [
                        _buildHeader(),
                        _buildUnitTabs(),
                        _buildControlsRow(),
                        _buildChipsRow(orderedKeys),
                        Expanded(
                          child: _buildBody(controller, groups, filteredKeys),
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
              border: Border.all(color: _p.logoRing, width: 2),
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
            'DEPTH CHART',
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
              child: Icon(Icons.close, size: 14, color: _p.textSecondary),
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

  // ── VIEW MODE TOGGLE ─────────────────────────────────────────────────────
  Widget _buildControlsRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: _p.surfaceSubtle,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _p.border),
            ),
            child: Row(
              children: [
                _viewBtn(
                  active: _viewMode == _ViewMode.list,
                  onTap: () => setState(() => _viewMode = _ViewMode.list),
                  icon: Icons.format_list_bulleted,
                  label: 'LIST',
                ),
                _viewBtn(
                  active: _viewMode == _ViewMode.overview,
                  onTap: () => setState(() => _viewMode = _ViewMode.overview),
                  icon: Icons.grid_view,
                  label: 'OVERVIEW',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _viewBtn({
    required bool active,
    required VoidCallback onTap,
    required IconData icon,
    required String label,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: active ? _kAccent : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 12,
              color: active ? Colors.white : _p.textMuted,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.66,
                color: active ? Colors.white : _p.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── CHIPS ────────────────────────────────────────────────────────────────
  Widget _buildChipsRow(List<String> keys) {
    final chips = ['ALL', ...keys];
    // Use intrinsic chip height (~28) + comfortable vertical padding; the
    // earlier fixed height of 38 with internal vertical padding clipped chips.
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 12, 0, 10),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: active ? _kAccent : _p.chipBg,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: active ? _kAccent : _p.chipBorder,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  c.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.7,
                    color: active ? Colors.white : _p.textSecondary,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ── BODY ─────────────────────────────────────────────────────────────────
  Widget _buildBody(
    TeamCenterController c,
    Map<String, List<DepthChartPlayer>> groups,
    List<String> filteredKeys,
  ) {
    if (c.isDepthChartLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (c.depthChartError != null) {
      return Center(
        child: Text(
          'Failed to load depth chart',
          style: TextStyle(color: _p.textMuted),
        ),
      );
    }
    if (groups.isEmpty || filteredKeys.isEmpty) {
      return Center(
        child: Text(
          'No depth chart data available',
          style: TextStyle(color: _p.textMuted),
        ),
      );
    }

    if (_viewMode == _ViewMode.list) {
      return _buildListView(groups, filteredKeys);
    }
    return _buildOverviewView(groups, filteredKeys);
  }

  // ── LIST VIEW ────────────────────────────────────────────────────────────
  Widget _buildListView(
    Map<String, List<DepthChartPlayer>> groups,
    List<String> filteredKeys,
  ) {
    return CustomScrollView(
      slivers: [
        for (final key in filteredKeys) ...[
          SliverPersistentHeader(
            pinned: true,
            delegate: _GroupHeaderDelegate(
              label: _positionLabel(key),
              count: groups[key]!.length,
              bg: _p.stickyBg,
              labelColor: _p.textMuted,
            ),
          ),
          SliverList.separated(
            itemCount: groups[key]!.length,
            itemBuilder: (_, i) {
              final players = groups[key]!;
              final p = players[i];
              return _buildDepthRow(p, key, i, players.length);
            },
            separatorBuilder: (_, __) => Padding(
              padding: const EdgeInsets.only(left: 58, right: 16),
              child: Divider(height: 1, thickness: 1, color: _p.separator),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 4)),
        ],
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }

  Widget _buildDepthRow(
    DepthChartPlayer p,
    String posKey,
    int idx,
    int total,
  ) {
    final isStarter = idx == 0;
    final fade = isStarter ? 1.0 : (idx == 1 ? 0.85 : 0.65);
    final avatarSize = isStarter ? 42.0 : (idx == 1 ? 36.0 : 30.0);
    final nameSize = isStarter ? 15.0 : (idx == 1 ? 13.0 : 12.0);
    final nameWeight = isStarter ? FontWeight.w700 : FontWeight.w600;
    final padV = isStarter ? 10.0 : (idx == 1 ? 8.0 : 6.0);
    final statusKey = _statusKey(p);

    final nameColor = isStarter
        ? _p.textPrimary
        : (idx == 1 ? _p.textSecondary : _p.textMuted);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showPlayerDetail(p, posKey, idx),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: padV),
          child: Opacity(
            opacity: fade,
            child: Row(
              children: [
                _rankPill(idx),
                const SizedBox(width: 10),
                _avatar(p, posKey, statusKey, avatarSize),
                const SizedBox(width: 10),
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
                          color: nameColor,
                          fontSize: nameSize,
                          fontWeight: nameWeight,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            _formatNumber(p.number),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: _p.textMuted,
                            ),
                          ),
                          if (statusKey != 'active') ...[
                            const SizedBox(width: 6),
                            _statusLabel(statusKey),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, size: 16, color: _p.textGhost),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _rankPill(int idx) {
    final label = _rankLabel(idx);
    final isStarter = idx == 0;
    return Container(
      width: 30,
      padding: const EdgeInsets.symmetric(vertical: 3),
      decoration: BoxDecoration(
        color: isStarter
            ? _kGold.withValues(alpha: 0.18)
            : (idx == 1 ? _p.chipBg : _p.chipBgSofter),
        borderRadius: BorderRadius.circular(4),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: TextStyle(
          fontSize: 8,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.64,
          color:
              isStarter ? _kGold : (idx == 1 ? _p.textSecondary : _p.textMuted),
        ),
      ),
    );
  }

  Widget _statusLabel(String statusKey) {
    Color bg;
    Color fg;
    String text;
    switch (statusKey) {
      case 'quest':
        bg = _kStatusQuest.withValues(alpha: 0.15);
        fg = _kStatusQuest;
        text = 'QUEST';
        break;
      case 'out':
        bg = _kStatusOut.withValues(alpha: 0.15);
        fg = _kStatusOut;
        text = 'OUT';
        break;
      default:
        return const SizedBox.shrink();
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 8,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.56,
          color: fg,
        ),
      ),
    );
  }

  // ── OVERVIEW VIEW ────────────────────────────────────────────────────────
  Widget _buildOverviewView(
    Map<String, List<DepthChartPlayer>> groups,
    List<String> filteredKeys,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(14, 4, 14, 24),
      itemCount: filteredKeys.length,
      itemBuilder: (_, i) {
        final key = filteredKeys[i];
        final players = groups[key]!;
        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: _OverviewCard(
            posKey: key,
            posLabel: _positionLabel(key),
            players: players,
            palette: _p,
            onTap: (p, rank) => _showPlayerDetail(p, key, rank),
          ),
        );
      },
    );
  }

  // ── PLAYER DETAIL SHEET ──────────────────────────────────────────────────
  void _showPlayerDetail(DepthChartPlayer p, String posKey, int rank) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (sheetCtx) => _PlayerDetailSheet(
        player: p,
        posKey: posKey,
        posLabel: _positionLabel(posKey),
        rank: rank,
        team: widget.team,
      ),
    );
  }

  // ── AVATAR ───────────────────────────────────────────────────────────────
  Widget _avatar(
    DepthChartPlayer p,
    String posKey,
    String statusKey,
    double size,
  ) {
    final ring = _ringColor(statusKey);
    final dot = _dotColor(statusKey);
    final fallbackBg = _positionAccent(posKey);
    return SizedBox(
      width: size + 6,
      height: size + 6,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Container(
            width: size + 6,
            height: size + 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: ring, width: 2),
            ),
          ),
          ClipOval(
            child: SizedBox(
              width: size,
              height: size,
              child: p.imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: p.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, __) =>
                          _initialsBg(p.name, fallbackBg, size),
                      errorWidget: (_, __, ___) =>
                          _initialsBg(p.name, fallbackBg, size),
                    )
                  : _initialsBg(p.name, fallbackBg, size),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: dot,
                border: Border.all(color: _p.sheetBg, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _initialsBg(String name, Color bg, double size) {
    return Container(
      color: bg,
      alignment: Alignment.center,
      child: Text(
        _initials(name),
        style: TextStyle(
          fontFamily: 'Russo One',
          fontSize: size * 0.32,
          color: Colors.white.withValues(alpha: 0.7),
        ),
      ),
    );
  }

  // ── HELPERS ──────────────────────────────────────────────────────────────
  String _statusKey(DepthChartPlayer p) {
    if (p.hasQuest) return 'quest';
    final s = p.status.toLowerCase();
    if (s.contains('out')) return 'out';
    if (s.contains('ir')) return 'ir';
    if (s.contains('quest')) return 'quest';
    return 'active';
  }

  Color _ringColor(String statusKey) {
    switch (statusKey) {
      case 'quest':
        return _kStatusQuest.withValues(alpha: 0.55);
      case 'out':
      case 'ir':
        return _kStatusOut.withValues(alpha: 0.45);
      default:
        return _kStatusActive.withValues(alpha: 0.4);
    }
  }

  Color _dotColor(String statusKey) {
    switch (statusKey) {
      case 'quest':
        return _kStatusQuest;
      case 'out':
      case 'ir':
        return _kStatusOut;
      default:
        return _kStatusActive;
    }
  }

  Color _positionAccent(String posKey) {
    final p = posKey.toUpperCase();
    if (p.contains('QB') || p.contains('RB')) return const Color(0xFF1A2F4A);
    if (p.contains('WR') || p.contains('TE')) return const Color(0xFF0F2A3A);
    if (p.contains('LT') ||
        p.contains('RT') ||
        p.contains('LG') ||
        p.contains('RG') ||
        p.contains('OL') ||
        p == 'C') {
      return const Color(0xFF1A2F1A);
    }
    if (p.contains('DE') || p.contains('DT') || p.contains('EDGE')) {
      return const Color(0xFF2A1A1A);
    }
    if (p.contains('LB')) return const Color(0xFF2A1F10);
    if (p.contains('CB') || p.contains('DB')) return const Color(0xFF1A2A1A);
    if (p == 'S' || p.contains('FS') || p.contains('SS')) {
      return const Color(0xFF1A2A2A);
    }
    if (p == 'K' || p == 'P' || p == 'LS') return const Color(0xFF1A1A2A);
    if (p == 'KR' || p == 'PR') return const Color(0xFF2A2A1A);
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

  static const _rankLabels = ['1ST', '2ND', '3RD', '4TH', '5TH'];
  String _rankLabel(int idx) =>
      idx < _rankLabels.length ? _rankLabels[idx] : '—';

  String _positionLabel(String key) {
    const map = {
      'QB': 'Quarterback',
      'RB': 'Running Back',
      'FB': 'Fullback',
      'WR': 'Wide Receiver',
      'WR1': 'Wide Receiver 1',
      'WR2': 'Wide Receiver 2',
      'TE': 'Tight End',
      'LT': 'Left Tackle',
      'RT': 'Right Tackle',
      'LG': 'Left Guard',
      'RG': 'Right Guard',
      'C': 'Center',
      'OL': 'Offensive Line',
      'DE': 'Defensive End',
      'LEDE': 'Left End',
      'REDE': 'Right End',
      'DT': 'Defensive Tackle',
      'NT': 'Nose Tackle',
      'EDGE': 'Edge',
      'DL': 'Defensive Line',
      'LB': 'Linebacker',
      'ILB': 'Inside Linebacker',
      'OLB': 'Outside Linebacker',
      'MLB': 'Middle Linebacker',
      'CB': 'Cornerback',
      'LCB': 'Left Corner',
      'RCB': 'Right Corner',
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
    return map[key.toUpperCase()] ?? key;
  }
}

// ─── PALETTE (theme-aware surface/text/border resolution) ────────────────
class _DepthPalette {
  final bool isDark;

  /// Lightly tints the underlying team-color gradient so chrome stays readable
  /// without hiding the team color entirely.
  final Color scrim;

  /// Translucent sheet color used for the dot border cutout, sticky headers,
  /// the detail bottom sheet, etc.
  final Color sheetBg;
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
  final Color chipBgSofter;
  final Color chipBorder;

  final Color logoRing;

  const _DepthPalette({
    required this.isDark,
    required this.scrim,
    required this.sheetBg,
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
    required this.chipBgSofter,
    required this.chipBorder,
    required this.logoRing,
  });

  factory _DepthPalette.from(T4LThemeColors c, bool isDark) {
    if (isDark) {
      return _DepthPalette(
        isDark: true,
        // Slight darken so text reads on bright team gradients while letting
        // the team color clearly show through.
        scrim: Colors.black.withValues(alpha: 0.45),
        sheetBg: const Color(0xFF0D130F),
        stickyBg: Colors.black.withValues(alpha: 0.55),
        border: const Color(0x14FFFFFF),
        separator: const Color(0x0AFFFFFF),
        textPrimary: Colors.white,
        textSecondary: Colors.white.withValues(alpha: 0.6),
        textMuted: Colors.white.withValues(alpha: 0.4),
        textGhost: Colors.white.withValues(alpha: 0.2),
        surfaceMuted: Colors.white.withValues(alpha: 0.1),
        surfaceSubtle: Colors.white.withValues(alpha: 0.06),
        chipBg: Colors.white.withValues(alpha: 0.1),
        chipBgSofter: Colors.white.withValues(alpha: 0.05),
        chipBorder: Colors.white.withValues(alpha: 0.16),
        logoRing: Colors.white.withValues(alpha: 0.18),
      );
    }
    // Light mode — gradient is white→team color, so a soft white scrim keeps
    // the gradient visible while text/chips stay legible.
    return _DepthPalette(
      isDark: false,
      scrim: Colors.white.withValues(alpha: 0.55),
      sheetBg: c.background,
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
      chipBgSofter: Colors.white.withValues(alpha: 0.4),
      chipBorder: c.border,
      logoRing: c.textPrimary.withValues(alpha: 0.12),
    );
  }
}

// ─── STICKY GROUP HEADER ─────────────────────────────────────────────────────
class _GroupHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String label;
  final int count;
  final Color bg;
  final Color labelColor;

  _GroupHeaderDelegate({
    required this.label,
    required this.count,
    required this.bg,
    required this.labelColor,
  });

  @override
  double get minExtent => 38;
  @override
  double get maxExtent => 38;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          color: bg,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          alignment: Alignment.center,
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _kStatusActive.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$count ACTIVE',
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.72,
                    color: _kStatusActive,
                  ),
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
        oldDelegate.labelColor != labelColor;
  }
}

// ─── OVERVIEW CARD ───────────────────────────────────────────────────────────
class _OverviewCard extends StatelessWidget {
  final String posKey;
  final String posLabel;
  final List<DepthChartPlayer> players;
  final _DepthPalette palette;
  final void Function(DepthChartPlayer player, int rank) onTap;

  const _OverviewCard({
    required this.posKey,
    required this.posLabel,
    required this.players,
    required this.palette,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: palette.surfaceSubtle,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: palette.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Vertical position label
              Container(
                width: 40,
                color: _kAccent.withValues(alpha: palette.isDark ? 0.3 : 0.12),
                alignment: Alignment.center,
                child: RotatedBox(
                  quarterTurns: 3,
                  child: Text(
                    posKey.toUpperCase(),
                    style: TextStyle(
                      fontFamily: 'Russo One',
                      fontSize: 11,
                      letterSpacing: 0.66,
                      color: palette.textSecondary,
                    ),
                  ),
                ),
              ),
              // 3 slots
              Expanded(
                child: Row(
                  children: List.generate(3, (i) {
                    final p = i < players.length ? players[i] : null;
                    return Expanded(
                      child: _OverviewSlot(
                        player: p,
                        posKey: posKey,
                        rank: i,
                        showRightBorder: i < 2,
                        palette: palette,
                        onTap: p == null ? null : () => onTap(p, i),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OverviewSlot extends StatelessWidget {
  final DepthChartPlayer? player;
  final String posKey;
  final int rank;
  final bool showRightBorder;
  final _DepthPalette palette;
  final VoidCallback? onTap;

  const _OverviewSlot({
    required this.player,
    required this.posKey,
    required this.rank,
    required this.showRightBorder,
    required this.palette,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isStarter = rank == 0;
    final empty = player == null;

    final bg = isStarter && !empty
        ? _kAccent.withValues(alpha: palette.isDark ? 0.12 : 0.06)
        : Colors.transparent;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: bg,
            border: Border(
              right: showRightBorder
                  ? BorderSide(color: palette.separator)
                  : BorderSide.none,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _rankLabel(rank),
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: isStarter && !empty
                      ? _kGold.withValues(alpha: 0.65)
                      : palette.textMuted,
                ),
              ),
              const SizedBox(height: 4),
              if (empty) _emptyAvatar() else _avatarWithDot(player!),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Text(
                  empty ? 'Open' : _lastName(player!.name),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isStarter && !empty ? 11 : 10,
                    fontWeight: FontWeight.w700,
                    color: empty
                        ? palette.textGhost
                        : (isStarter
                            ? palette.textPrimary
                            : palette.textSecondary),
                    fontStyle: empty ? FontStyle.italic : FontStyle.normal,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyAvatar() {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: palette.surfaceSubtle,
        border: Border.all(color: palette.border),
      ),
      alignment: Alignment.center,
      child: Text(
        '—',
        style: TextStyle(fontSize: 10, color: palette.textGhost),
      ),
    );
  }

  Widget _avatarWithDot(DepthChartPlayer p) {
    final isStarter = rank == 0;
    final statusKey = _statusKeyOf(p);
    final dot = statusKey == 'active'
        ? _kStatusActive
        : (statusKey == 'quest' ? _kStatusQuest : _kStatusOut);
    final accent = _accentForPos(posKey);

    return SizedBox(
      width: 32,
      height: 32,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color:
                    isStarter ? _kGold.withValues(alpha: 0.3) : palette.border,
                width: 1.5,
              ),
            ),
            child: ClipOval(
              child: p.imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: p.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => _initialsBox(p.name, accent),
                      errorWidget: (_, __, ___) => _initialsBox(p.name, accent),
                    )
                  : _initialsBox(p.name, accent),
            ),
          ),
          Positioned(
            right: -1,
            bottom: -1,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: dot,
                border: Border.all(color: palette.sheetBg, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _initialsBox(String name, Color bg) {
    final parts = name.trim().split(RegExp(r'\s+'));
    final initials = parts
        .where((p) => p.isNotEmpty)
        .map((p) => p[0])
        .take(2)
        .join()
        .toUpperCase();
    return Container(
      color: bg,
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          fontFamily: 'Russo One',
          fontSize: 9,
          color: Colors.white.withValues(alpha: 0.7),
        ),
      ),
    );
  }

  String _statusKeyOf(DepthChartPlayer p) {
    if (p.hasQuest) return 'quest';
    final s = p.status.toLowerCase();
    if (s.contains('out')) return 'out';
    if (s.contains('ir')) return 'out';
    if (s.contains('quest')) return 'quest';
    return 'active';
  }

  Color _accentForPos(String key) {
    final p = key.toUpperCase();
    if (p.contains('QB') || p.contains('RB')) return const Color(0xFF1A2F4A);
    if (p.contains('WR') || p.contains('TE')) return const Color(0xFF0F2A3A);
    if (p.contains('LT') ||
        p.contains('RT') ||
        p.contains('LG') ||
        p.contains('RG') ||
        p == 'C') {
      return const Color(0xFF1A2F1A);
    }
    if (p.contains('DE') || p.contains('DT')) return const Color(0xFF2A1A1A);
    if (p.contains('LB')) return const Color(0xFF2A1F10);
    if (p.contains('CB') || p.contains('DB')) return const Color(0xFF1A2A1A);
    if (p == 'S' || p.contains('FS') || p.contains('SS')) {
      return const Color(0xFF1A2A2A);
    }
    return const Color(0xFF1A2A20);
  }

  String _lastName(String full) {
    final parts = full.trim().split(RegExp(r'\s+'));
    return parts.isEmpty ? full : parts.last;
  }

  static const _rankLabels = ['1ST', '2ND', '3RD', '4TH', '5TH'];
  String _rankLabel(int idx) =>
      idx < _rankLabels.length ? _rankLabels[idx] : '—';
}

// ─── PLAYER DETAIL SHEET ─────────────────────────────────────────────────────
class _PlayerDetailSheet extends StatelessWidget {
  final DepthChartPlayer player;
  final String posKey;
  final String posLabel;
  final int rank;
  final Team team;

  const _PlayerDetailSheet({
    required this.player,
    required this.posKey,
    required this.posLabel,
    required this.rank,
    required this.team,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<T4LThemeColors>()!;
    final isDark = theme.brightness == Brightness.dark;

    final sheetBg = isDark ? const Color(0xFF141E16) : colors.surface;
    final topBorder = isDark ? const Color(0x14FFFFFF) : colors.border;
    final dividerColor = isDark ? const Color(0x0DFFFFFF) : colors.border;
    final keyColor =
        isDark ? Colors.white.withValues(alpha: 0.25) : colors.textMuted;
    final valColor =
        isDark ? Colors.white.withValues(alpha: 0.72) : colors.textSecondary;
    final ghostColor = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : colors.textMuted.withValues(alpha: 0.4);
    final handleColor = isDark
        ? Colors.white.withValues(alpha: 0.15)
        : colors.textMuted.withValues(alpha: 0.5);
    final subColor =
        isDark ? Colors.white.withValues(alpha: 0.4) : colors.textSecondary;

    final initials = player.name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .map((p) => p[0])
        .take(2)
        .join()
        .toUpperCase();

    final statusKey = _statusKey();
    final statusLabel = _statusLabelText(statusKey);

    final bioRows = <List<String>>[
      ['Depth', '#${rank + 1} String'],
      ['Position', posLabel],
      ['Number', _formatNumber(player.number)],
      if (statusKey != 'active') ['Status', _statusReadable(statusKey)],
      ['Team', team.id.toUpperCase()],
    ];

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
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _dotColor(statusKey).withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: ClipOval(
                      child: player.imageUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: player.imageUrl,
                              fit: BoxFit.cover,
                              errorWidget: (_, __, ___) =>
                                  _initialsBg(initials, team.primaryColor),
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
                            fontSize: 17,
                            color: colors.textPrimary,
                            letterSpacing: 0.34,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${_formatNumber(player.number)} · ${posKey.toUpperCase()} · ${_rankLabel(rank)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: subColor,
                          ),
                        ),
                        if (statusLabel != null) ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  _dotColor(statusKey).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Text(
                              statusLabel,
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.72,
                                color: _dotColor(statusKey),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _rankLabel(rank),
                    style: TextStyle(
                      fontFamily: 'Russo One',
                      fontSize: 22,
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
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.7,
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
          fontSize: 15,
          color: Colors.white,
        ),
      ),
    );
  }

  String _statusKey() {
    if (player.hasQuest) return 'quest';
    final s = player.status.toLowerCase();
    if (s.contains('out')) return 'out';
    if (s.contains('ir')) return 'ir';
    if (s.contains('quest')) return 'quest';
    return 'active';
  }

  String? _statusLabelText(String key) {
    switch (key) {
      case 'quest':
        return 'QUEST';
      case 'out':
        return 'OUT';
      case 'ir':
        return 'IR';
      default:
        return null;
    }
  }

  String _statusReadable(String key) {
    switch (key) {
      case 'quest':
        return 'Questionable';
      case 'out':
        return 'Out';
      case 'ir':
        return 'Injured Reserve';
      default:
        return 'Active';
    }
  }

  Color _dotColor(String key) {
    switch (key) {
      case 'quest':
        return _kStatusQuest;
      case 'out':
      case 'ir':
        return _kStatusOut;
      default:
        return _kStatusActive;
    }
  }

  String _formatNumber(String num) {
    if (num.isEmpty) return '#';
    return num.startsWith('#') ? num : '#$num';
  }

  static const _rankLabels = ['1ST', '2ND', '3RD', '4TH', '5TH'];
  String _rankLabel(int idx) =>
      idx < _rankLabels.length ? _rankLabels[idx] : '—';
}
