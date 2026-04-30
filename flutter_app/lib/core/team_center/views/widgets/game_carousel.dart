import 'package:flutter/material.dart';
import '../../../../micro_apps/standings/models/game_model.dart';
import '../../../models/team_model.dart';
import '../../../services/team_service.dart';

const Color _kGold = Color(0xFFC9A256);
const Color _kWin = Color(0xFF4CAF80);
const Color _kLoss = Color(0xFFE06060);

/// Carousel of team games. Center card = most-recent completed game,
/// swipe right (or arrow) → older games, swipe left (or arrow) → upcoming.
class GameCarousel extends StatefulWidget {
  final Team team;
  final List<Game> games;
  final int initialIndex;

  const GameCarousel({
    super.key,
    required this.team,
    required this.games,
    required this.initialIndex,
  });

  @override
  State<GameCarousel> createState() => _GameCarouselState();
}

class _GameCarouselState extends State<GameCarousel> {
  late int _centerIdx;
  double _dragDelta = 0;

  @override
  void initState() {
    super.initState();
    _centerIdx = widget.initialIndex.clamp(0, widget.games.length - 1);
  }

  bool get _canGoLeft => _centerIdx > 0; // newer/upcoming
  bool get _canGoRight => _centerIdx < widget.games.length - 1; // older

  void _navigate(int dir) {
    final next = _centerIdx + dir;
    if (next >= 0 && next < widget.games.length) {
      setState(() => _centerIdx = next);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.games.isEmpty) return const SizedBox.shrink();
    final current = widget.games[_centerIdx];
    final isUpcoming = !current.isPlayed;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _sectionLabel('GAMES'),
              Text(
                isUpcoming ? 'UPCOMING' : 'RESULT',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.25),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 156,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragUpdate: (d) => _dragDelta += d.delta.dx,
            onHorizontalDragEnd: (_) {
              if (_dragDelta < -40) {
                _navigate(1);
              } else if (_dragDelta > 40) {
                _navigate(-1);
              }
              _dragDelta = 0;
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                ..._buildVisibleCards(),
                Positioned(
                  left: 4,
                  child: _navButton(
                    icon: Icons.chevron_left,
                    enabled: _canGoLeft,
                    onTap: () => _navigate(-1),
                  ),
                ),
                Positioned(
                  right: 4,
                  child: _navButton(
                    icon: Icons.chevron_right,
                    enabled: _canGoRight,
                    onTap: () => _navigate(1),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '← UPCOMING',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.7,
                  color: _kGold.withValues(alpha: 0.6),
                ),
              ),
              Text(
                'OLDER →',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.7,
                  color: Colors.white.withValues(alpha: 0.25),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        _buildDots(),
      ],
    );
  }

  List<Widget> _buildVisibleCards() {
    final cards = <Widget>[];
    // Build outermost first so center is on top via zIndex via order.
    for (final pos in [-2, 2, -1, 1, 0]) {
      final idx = _centerIdx + pos;
      if (idx < 0 || idx >= widget.games.length) continue;
      cards.add(_buildCard(widget.games[idx], pos));
    }
    return cards;
  }

  Widget _buildCard(Game game, int position) {
    final abs = position.abs();
    final scale = abs == 0 ? 1.0 : (abs == 1 ? 0.78 : 0.64);
    final opacity = abs == 0 ? 1.0 : (abs == 1 ? 0.72 : 0.45);
    const cardW = 200.0;
    const cardH = 140.0;
    const spacing = 148.0;
    final dx = position * spacing;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOutCubic,
      left: null,
      right: null,
      child: AnimatedOpacity(
        opacity: opacity,
        duration: const Duration(milliseconds: 380),
        child: Transform.translate(
          offset: Offset(dx, 0),
          child: Transform.scale(
            scale: scale,
            child: GestureDetector(
              onTap: () {
                if (abs == 0) return;
                _navigate(position > 0 ? 1 : -1);
              },
              child: SizedBox(
                width: cardW,
                height: cardH,
                child: _GameCardContent(
                  game: game,
                  team: widget.team,
                  isCenter: abs == 0,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _navButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.25,
      child: IgnorePointer(
        ignoring: !enabled,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: Icon(icon, size: 18, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.games.length, (i) {
        final active = i == _centerIdx;
        return GestureDetector(
          onTap: () => setState(() => _centerIdx = i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 2.5),
            width: active ? 16 : 5,
            height: 5,
            decoration: BoxDecoration(
              color: active ? _kWin : Colors.white.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        );
      }),
    );
  }

  Widget _sectionLabel(String text) => Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.1,
          color: Colors.white.withValues(alpha: 0.4),
        ),
      );
}

class _GameCardContent extends StatelessWidget {
  final Game game;
  final Team team;
  final bool isCenter;

  const _GameCardContent({
    required this.game,
    required this.team,
    required this.isCenter,
  });

  bool get _teamIsHome => game.homeTeam.toUpperCase() == team.id.toUpperCase();

  String get _opponentAbbr => _teamIsHome ? game.awayTeam : game.homeTeam;

  Color get _opponentColor {
    final t = TeamService()
        .getTeams()
        .where((x) => x.id.toUpperCase() == _opponentAbbr.toUpperCase())
        .toList();
    return t.isNotEmpty ? t.first.primaryColor : const Color(0xFF1F2A22);
  }

  int? get _teamScore => _teamIsHome ? game.homeScore : game.awayScore;
  int? get _oppScore => _teamIsHome ? game.awayScore : game.homeScore;

  String get _result {
    if (!game.isPlayed) return 'U';
    if (_teamScore! > _oppScore!) return 'W';
    if (_teamScore! < _oppScore!) return 'L';
    return 'T';
  }

  String _formatDate() {
    const months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];
    return '${months[game.gameday.month - 1]} ${game.gameday.day}';
  }

  @override
  Widget build(BuildContext context) {
    final oppColor = _opponentColor;
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: isCenter ? 0.5 : 0.3,
                ),
                blurRadius: isCenter ? 40 : 16,
                offset: Offset(0, isCenter ? 12 : 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Stack(
              children: [
                // Opponent color gradient
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          oppColor.withValues(alpha: 0.93),
                          oppColor.withValues(alpha: 0.53),
                        ],
                      ),
                    ),
                  ),
                ),
                // Bottom dark fade
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.1),
                          Colors.black.withValues(alpha: 0.55),
                        ],
                      ),
                    ),
                  ),
                ),
                // Content
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 26),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'WEEK ${game.week} · ${_teamIsHome ? "HOME" : "AWAY"}',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.9,
                          color: Colors.white.withValues(alpha: 0.55),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _buildTeamSide(
                              abbr: team.id.toUpperCase(),
                              color: team.primaryColor,
                              labelColor: Colors.white,
                            ),
                            _buildScoreOrTime(),
                            _buildTeamSide(
                              abbr: _opponentAbbr.toUpperCase(),
                              color: oppColor,
                              labelColor: Colors.white.withValues(alpha: 0.85),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Footer
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.25),
                    padding: const EdgeInsets.fromLTRB(14, 6, 14, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDate(),
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.6,
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                        ),
                        if (game.stadium != null && game.stadium!.isNotEmpty)
                          Flexible(
                            child: Text(
                              game.stadium!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withValues(alpha: 0.35),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Center glow
        if (isCenter)
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(19),
                  border: Border.all(
                    color: _kWin.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTeamSide({
    required String abbr,
    required Color color,
    required Color labelColor,
  }) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.22),
                width: 1.5,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              abbr,
              style: const TextStyle(
                fontFamily: 'Russo One',
                fontSize: 10,
                color: Colors.white,
                letterSpacing: 0.2,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            abbr,
            style: TextStyle(
              fontFamily: 'Russo One',
              fontSize: 14,
              color: labelColor,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreOrTime() {
    if (!game.isPlayed) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            game.gametime.isNotEmpty ? game.gametime : 'TBD',
            style: const TextStyle(
              fontFamily: 'Russo One',
              fontSize: 13,
              color: _kGold,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 4),
          _badge(
            text: 'UPCOMING',
            bg: _kGold.withValues(alpha: 0.2),
            fg: _kGold,
          ),
        ],
      );
    }
    final teamColor =
        _result == 'W' ? _kWin : (_result == 'L' ? _kLoss : Colors.white);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${_teamScore ?? 0}',
              style: TextStyle(
                fontFamily: 'Russo One',
                fontSize: 22,
                color: teamColor,
                letterSpacing: 0.7,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Text(
                '–',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.3),
                ),
              ),
            ),
            Text(
              '${_oppScore ?? 0}',
              style: TextStyle(
                fontFamily: 'Russo One',
                fontSize: 22,
                color: Colors.white.withValues(alpha: 0.7),
                letterSpacing: 0.7,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        _badge(
          text: _result == 'W' ? 'WIN' : (_result == 'L' ? 'LOSS' : 'TIE'),
          bg: _result == 'W'
              ? _kWin.withValues(alpha: 0.25)
              : (_result == 'L'
                  ? _kLoss.withValues(alpha: 0.2)
                  : Colors.white.withValues(alpha: 0.15)),
          fg: _result == 'W' ? _kWin : (_result == 'L' ? _kLoss : Colors.white),
        ),
      ],
    );
  }

  Widget _badge({required String text, required Color bg, required Color fg}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.9,
          color: fg,
        ),
      ),
    );
  }
}
