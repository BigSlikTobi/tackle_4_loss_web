import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../design_tokens.dart';
import '../../models/team_model.dart';
import '../../services/settings_service.dart';
import '../../theme/t4l_theme.dart';
import '../models/injury_player.dart';
import '../controllers/team_center_controller.dart';

// ─── Brand semantics — sourced from the shared design token layer ────────
const Color _kAccent = AppColors.brandBase;
const Color _kStatusOut = AppColors.statusOut;
const Color _kStatusDoubtful = AppColors.statusDoubtful;
const Color _kStatusQuest = AppColors.statusQuest;

class TeamInjuryReportScreen extends StatefulWidget {
  final Team team;
  final TeamCenterController controller;

  const TeamInjuryReportScreen({
    super.key,
    required this.team,
    required this.controller,
  });

  @override
  State<TeamInjuryReportScreen> createState() => _TeamInjuryReportScreenState();
}

class _TeamInjuryReportScreenState extends State<TeamInjuryReportScreen> {
  String _statusFilter = 'all'; // all | out | doubtful | questionable
  String _posFilter = 'ALL';

  late _InjuryPalette _p;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.controller.loadInjuries(widget.team.id);
      _preloadAllImages();
    });
  }

  void _preloadAllImages() {
    _preloadImages(widget.controller.outInjuries);
    _preloadImages(widget.controller.doubtfulInjuries);
    _preloadImages(widget.controller.questionableInjuries);
  }

  void _preloadImages(List<InjuryPlayer> players) {
    if (!mounted) return;
    for (final p in players) {
      if (p.imageUrl.isNotEmpty) {
        precacheImage(CachedNetworkImageProvider(p.imageUrl), context);
      }
    }
  }

  // ── Data shaping ─────────────────────────────────────────────────────────
  List<_StatusGroup> _buildGroups(TeamCenterController c) {
    final all = <_StatusKey, List<InjuryPlayer>>{
      _StatusKey.out: c.outInjuries,
      _StatusKey.doubtful: c.doubtfulInjuries,
      _StatusKey.questionable: c.questionableInjuries,
    };
    final groups = <_StatusGroup>[];
    for (final key in _StatusKey.values) {
      final players = _filter(all[key]!);
      if (players.isEmpty) continue;
      if (_statusFilter != 'all' && _statusFilter != key.name) continue;
      groups.add(_StatusGroup(key: key, players: players));
    }
    return groups;
  }

  List<InjuryPlayer> _filter(List<InjuryPlayer> players) {
    if (_posFilter == 'ALL') return players;
    return players
        .where((p) => p.position.toUpperCase() == _posFilter)
        .toList();
  }

  List<String> _allPositions(TeamCenterController c) {
    final seen = <String>{};
    final order = <String>[];
    for (final list in [
      c.outInjuries,
      c.doubtfulInjuries,
      c.questionableInjuries,
    ]) {
      for (final p in list) {
        final pos = p.position.toUpperCase();
        if (pos.isEmpty) continue;
        if (seen.add(pos)) order.add(pos);
      }
    }
    order.sort();
    return order;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<T4LThemeColors>()!;
    final isDark = theme.brightness == Brightness.dark;
    final settings = Provider.of<SettingsService>(context);
    _p = _InjuryPalette.from(colors, isDark);

    return ChangeNotifierProvider.value(
      value: widget.controller,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          decoration: BoxDecoration(gradient: settings.backgroundGradient),
          child: Stack(
            children: [
              Positioned.fill(child: Container(color: _p.scrim)),
              SafeArea(
                child: Consumer<TeamCenterController>(
                  builder: (context, controller, _) {
                    final groups = _buildGroups(controller);
                    final positions = _allPositions(controller);

                    return Column(
                      children: [
                        _buildHeader(),
                        _buildSummaryRow(controller),
                        _buildChipsRow(positions),
                        Expanded(
                          child: _buildBody(controller, groups),
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
      padding: const EdgeInsets.fromLTRB(20, 18, 16, 12),
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
            'INJURY REPORT',
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

  // ── SUMMARY PILLS (status filter) ────────────────────────────────────────
  Widget _buildSummaryRow(TeamCenterController c) {
    final outCount = c.outInjuries.length;
    final doubtCount = c.doubtfulInjuries.length;
    final questCount = c.questionableInjuries.length;

    final pills = <_SummaryPill>[
      _SummaryPill(key: 'all', label: 'All', dot: _p.textMuted),
      _SummaryPill(key: 'out', label: '$outCount Out', dot: _kStatusOut),
      _SummaryPill(
        key: 'doubtful',
        label: '$doubtCount Doubtful',
        dot: _kStatusDoubtful,
      ),
      _SummaryPill(
        key: 'questionable',
        label: '$questCount Quest.',
        dot: _kStatusQuest,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: SizedBox(
        height: 30,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: pills.length,
          separatorBuilder: (_, __) => const SizedBox(width: 6),
          itemBuilder: (_, i) {
            final pill = pills[i];
            final active = _statusFilter == pill.key;
            return GestureDetector(
              onTap: () => setState(() => _statusFilter = pill.key),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                decoration: BoxDecoration(
                  color: active ? _p.surfaceMuted : _p.surfaceSubtle,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: _p.chipBorder),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            active ? pill.dot : pill.dot.withValues(alpha: 0.4),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      pill.label,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: active ? _p.textPrimary : _p.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ── POSITION CHIPS ───────────────────────────────────────────────────────
  Widget _buildChipsRow(List<String> positions) {
    final chips = ['ALL', ...positions];
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 4),
      child: SizedBox(
        height: 28,
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
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
  Widget _buildBody(TeamCenterController c, List<_StatusGroup> groups) {
    if (c.isInjuriesLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (c.injuriesError != null) {
      return Center(
        child: Text(
          'Failed to load injuries',
          style: TextStyle(color: _p.textMuted),
        ),
      );
    }
    if (groups.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.health_and_safety_outlined,
              size: 36,
              color: _p.textGhost,
            ),
            const SizedBox(height: 10),
            Text(
              'No injuries match',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _p.textMuted,
              ),
            ),
          ],
        ),
      );
    }

    return CustomScrollView(
      slivers: [
        for (final g in groups) ...[
          SliverPersistentHeader(
            pinned: true,
            delegate: _SectionHeaderDelegate(
              label: g.key.label,
              count: g.players.length,
              dotColor: g.key.dot,
              bg: _p.stickyBg,
              titleColor: g.key.dot,
              countBg: _p.chipBg,
              countColor: _p.textMuted,
            ),
          ),
          SliverList.separated(
            itemCount: g.players.length,
            itemBuilder: (_, i) => _buildInjuryRow(g.players[i], g.key),
            separatorBuilder: (_, __) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Divider(height: 1, thickness: 1, color: _p.separator),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 4)),
        ],
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }

  Widget _buildInjuryRow(InjuryPlayer p, _StatusKey key) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showInjuryDetail(p, key),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          child: Row(
            children: [
              _avatar(p, 40),
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
                        color: _p.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Wrap(
                      spacing: 5,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1,
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
                              letterSpacing: 0.63,
                              color: _p.textSecondary,
                            ),
                          ),
                        ),
                        if (p.injuryType.isNotEmpty)
                          Text(
                            p.injuryType,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: _p.textMuted,
                            ),
                          ),
                        if (p.number.isNotEmpty)
                          Text(
                            _formatNumber(p.number),
                            style: TextStyle(
                              fontSize: 9,
                              color: _p.textGhost,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _statusBadge(key),
                  const SizedBox(height: 5),
                  if (p.participation.isNotEmpty)
                    _practiceBadge(p.participation),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── BADGES ───────────────────────────────────────────────────────────────
  Widget _statusBadge(_StatusKey key) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: key.dot.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        key.label,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.72,
          color: key.dot,
        ),
      ),
    );
  }

  Widget _practiceBadge(String participation) {
    final p = participation.toUpperCase().trim();
    final cfg = _practiceConfig(p);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: cfg.bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: cfg.dotFilled ? cfg.dotColor : Colors.transparent,
              border: cfg.dotFilled
                  ? null
                  : Border.all(color: cfg.dotColor, width: 1),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            cfg.label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.54,
              color: cfg.fg,
            ),
          ),
        ],
      ),
    );
  }

  _PracticeConfig _practiceConfig(String code) {
    switch (code) {
      case 'FP':
      case 'FULL':
        return _PracticeConfig(
          label: 'FP',
          bg: _p.surfaceMuted,
          fg: _p.textSecondary,
          dotColor: _p.textPrimary.withValues(alpha: 0.7),
          dotFilled: true,
        );
      case 'LP':
      case 'LIMITED':
        return _PracticeConfig(
          label: 'LP',
          bg: _p.surfaceSubtle,
          fg: _p.textMuted,
          dotColor: _p.textMuted,
          dotFilled: false,
        );
      case 'DNP':
      case 'OUT':
        return _PracticeConfig(
          label: 'DNP',
          bg: _p.surfaceSubtle,
          fg: _p.textGhost,
          dotColor: _p.textGhost,
          dotFilled: false,
        );
      default:
        return _PracticeConfig(
          label: code.isEmpty ? '—' : code,
          bg: _p.surfaceSubtle,
          fg: _p.textGhost,
          dotColor: _p.textGhost,
          dotFilled: false,
        );
    }
  }

  // ── AVATAR ───────────────────────────────────────────────────────────────
  Widget _avatar(InjuryPlayer p, double size) {
    final fallbackBg = _positionAccent(p.position);
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
              border: Border.all(color: _p.logoRing, width: 1.5),
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

  // ── DETAIL SHEET ─────────────────────────────────────────────────────────
  void _showInjuryDetail(InjuryPlayer p, _StatusKey key) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (_) => _InjuryDetailSheet(
        player: p,
        statusKey: key,
        team: widget.team,
      ),
    );
  }

  // ── HELPERS ──────────────────────────────────────────────────────────────
  Color _positionAccent(String pos) {
    final p = pos.toUpperCase();
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
}

// ─── STATUS KEY ──────────────────────────────────────────────────────────────
enum _StatusKey { out, doubtful, questionable }

extension _StatusKeyX on _StatusKey {
  String get label {
    switch (this) {
      case _StatusKey.out:
        return 'OUT';
      case _StatusKey.doubtful:
        return 'DOUBTFUL';
      case _StatusKey.questionable:
        return 'QUESTIONABLE';
    }
  }

  String get readable {
    switch (this) {
      case _StatusKey.out:
        return 'Out';
      case _StatusKey.doubtful:
        return 'Doubtful';
      case _StatusKey.questionable:
        return 'Questionable';
    }
  }

  Color get dot {
    switch (this) {
      case _StatusKey.out:
        return _kStatusOut;
      case _StatusKey.doubtful:
        return _kStatusDoubtful;
      case _StatusKey.questionable:
        return _kStatusQuest;
    }
  }
}

// ─── DATA HOLDERS ────────────────────────────────────────────────────────────
class _StatusGroup {
  final _StatusKey key;
  final List<InjuryPlayer> players;
  _StatusGroup({required this.key, required this.players});
}

class _SummaryPill {
  final String key;
  final String label;
  final Color dot;
  _SummaryPill({required this.key, required this.label, required this.dot});
}

class _PracticeConfig {
  final String label;
  final Color bg;
  final Color fg;
  final Color dotColor;
  final bool dotFilled;
  _PracticeConfig({
    required this.label,
    required this.bg,
    required this.fg,
    required this.dotColor,
    required this.dotFilled,
  });
}

// ─── PALETTE (theme-aware surface/text/border resolution) ────────────────
class _InjuryPalette {
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

  const _InjuryPalette({
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

  factory _InjuryPalette.from(T4LThemeColors c, bool isDark) {
    if (isDark) {
      return _InjuryPalette(
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
        surfaceSubtle: Colors.white.withValues(alpha: 0.05),
        chipBg: Colors.white.withValues(alpha: 0.05),
        chipBorder: Colors.white.withValues(alpha: 0.1),
        logoRing: Colors.white.withValues(alpha: 0.12),
      );
    }
    return _InjuryPalette(
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

// ─── STICKY SECTION HEADER ───────────────────────────────────────────────────
class _SectionHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String label;
  final int count;
  final Color dotColor;
  final Color bg;
  final Color titleColor;
  final Color countBg;
  final Color countColor;

  _SectionHeaderDelegate({
    required this.label,
    required this.count,
    required this.dotColor,
    required this.bg,
    required this.titleColor,
    required this.countBg,
    required this.countColor,
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
          padding: const EdgeInsets.fromLTRB(20, 0, 16, 0),
          alignment: Alignment.center,
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: dotColor,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Russo One',
                  fontSize: 12,
                  letterSpacing: 0.96,
                  color: titleColor,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: countBg,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$count ${count == 1 ? 'PLAYER' : 'PLAYERS'}',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.54,
                    color: countColor,
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
  bool shouldRebuild(covariant _SectionHeaderDelegate oldDelegate) {
    return oldDelegate.label != label ||
        oldDelegate.count != count ||
        oldDelegate.dotColor != dotColor ||
        oldDelegate.bg != bg ||
        oldDelegate.titleColor != titleColor ||
        oldDelegate.countBg != countBg ||
        oldDelegate.countColor != countColor;
  }
}

// ─── INJURY DETAIL SHEET ─────────────────────────────────────────────────────
class _InjuryDetailSheet extends StatelessWidget {
  final InjuryPlayer player;
  final _StatusKey statusKey;
  final Team team;

  const _InjuryDetailSheet({
    required this.player,
    required this.statusKey,
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
    final handleColor = isDark
        ? Colors.white.withValues(alpha: 0.15)
        : colors.textMuted.withValues(alpha: 0.5);
    final subColor =
        isDark ? Colors.white.withValues(alpha: 0.4) : colors.textSecondary;
    final avatarRing = statusKey.dot.withValues(alpha: 0.27);
    final pillBg = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : colors.textPrimary.withValues(alpha: 0.06);
    final pillFg =
        isDark ? Colors.white.withValues(alpha: 0.5) : colors.textSecondary;

    final initials = player.name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .map((p) => p[0])
        .take(2)
        .join()
        .toUpperCase();

    final bioRows = <List<String>>[
      ['Injury', player.injuryType.isNotEmpty ? player.injuryType : '—'],
      ['Status', statusKey.readable],
      if (player.participation.isNotEmpty)
        ['Practice', _readablePractice(player.participation)],
      if (player.position.isNotEmpty) ['Position', player.position],
      if (player.number.isNotEmpty)
        [
          'Number',
          player.number.startsWith('#') ? player.number : '#${player.number}',
        ],
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
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: avatarRing, width: 2),
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
                          [
                            if (player.number.isNotEmpty)
                              player.number.startsWith('#')
                                  ? player.number
                                  : '#${player.number}',
                            if (player.position.isNotEmpty) player.position,
                            if (player.injuryType.isNotEmpty) player.injuryType,
                          ].join(' · '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: subColor,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: pillBg,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            statusKey.label,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.72,
                              color: pillFg,
                            ),
                          ),
                        ),
                      ],
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
          fontSize: 14,
          color: Colors.white,
        ),
      ),
    );
  }

  String _readablePractice(String code) {
    switch (code.toUpperCase().trim()) {
      case 'FP':
      case 'FULL':
        return 'Full Practice';
      case 'LP':
      case 'LIMITED':
        return 'Limited';
      case 'DNP':
      case 'OUT':
        return 'Did Not Practice';
      default:
        return code;
    }
  }
}
