import 'package:flutter/material.dart';
import 'package:tackle4loss_mobile/design_tokens.dart';
import '../../../../core/theme/t4l_theme.dart';
import '../../../../core/services/team_logo_service.dart';
import '../../../../core/models/team_model.dart';
import '../../models/game_model.dart';

/// Single schedule row: vertical time line on the left, game card on the right.
/// EMOTIONAL DESIGN: the brand color drives the time-line accent, the
/// "upcoming" gradient, and the user-team highlight on the score.
class TimelineGameRow extends StatelessWidget {
  final Game game;
  final Team? themeTeam;

  const TimelineGameRow({super.key, required this.game, this.themeTeam});

  static const _phoneBg = Color(0xFF0D130F);
  static const _mnfGold = Color(0xFFC9A256);

  bool get _isPrimeTime {
    final hh = int.tryParse(game.gametime.split(':').first) ?? 0;
    return hh >= 20;
  }

  bool get _isMNF => game.weekday.toLowerCase().startsWith('mon');

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<T4LThemeColors>()!;
    return IntrinsicHeight(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.space2, 6, AppSpacing.space2, 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTimeColumn(colors),
            Expanded(child: _buildCard(colors)),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeColumn(T4LThemeColors colors) {
    return SizedBox(
      width: 48,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: Center(
              child: Container(
                width: 2,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              width: 2,
              height: 28,
              color: colors.brand,
            ),
          ),
          Container(
            color: _phoneBg,
            padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 4),
            child: Text(
              game.gametime,
              style: TextStyle(
                fontFamily: 'Russo One',
                fontSize: 13,
                color: Colors.white.withValues(alpha: 0.55),
                height: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(T4LThemeColors colors) {
    final gradient = _cardGradient(colors);
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          border:
              Border.all(color: Colors.white.withValues(alpha: 0.06), width: 1),
        ),
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 11),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeaderRow(),
            const SizedBox(height: 8),
            _buildMatchupRow(colors),
          ],
        ),
      ),
    );
  }

  LinearGradient _cardGradient(T4LThemeColors colors) {
    if (_isPrimeTime) {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0x4D3C2878), Color(0x331E1446)],
      );
    }
    if (!game.isPlayed) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          colors.brand.withValues(alpha: 0.25),
          colors.brand.withValues(alpha: 0.10),
        ],
      );
    }
    // Played: warm orange-tinted background like the design
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0x2EC9641E), Color(0x1FB43C14)],
    );
  }

  Widget _buildHeaderRow() {
    return Row(
      children: [
        Expanded(
          child: Text(
            game.stadium ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.38),
            ),
          ),
        ),
        if (_isPrimeTime)
          _badge('PRIME TIME',
              bg: Colors.white.withValues(alpha: 0.12),
              fg: Colors.white.withValues(alpha: 0.6)),
        if (_isMNF) ...[
          if (_isPrimeTime) const SizedBox(width: 4),
          _badge('MNF', bg: _mnfGold.withValues(alpha: 0.18), fg: _mnfGold),
        ],
      ],
    );
  }

  Widget _badge(String label, {required Color bg, required Color fg}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          fontSize: 8,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.0,
          color: fg,
        ),
      ),
    );
  }

  Widget _buildMatchupRow(T4LThemeColors colors) {
    return Row(
      children: [
        Expanded(child: _teamSide(game.awayTeam, leading: true)),
        if (game.isPlayed)
          ..._scoreCenter(colors)
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              game.gametime,
              style: AppTextStyles.caption.copyWith(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.7,
                color: Colors.white.withValues(alpha: 0.3),
              ),
            ),
          ),
        Expanded(child: _teamSide(game.homeTeam, leading: false)),
      ],
    );
  }

  List<Widget> _scoreCenter(T4LThemeColors colors) {
    final awayWon = game.winner == game.awayTeam;
    final homeWon = game.winner == game.homeTeam;
    Color color(bool won) =>
        won ? Colors.white : Colors.white.withValues(alpha: 0.38);
    return [
      Text(
        '${game.awayScore ?? 0}',
        style: TextStyle(
          fontFamily: 'Russo One',
          fontSize: 18,
          color: color(awayWon),
          height: 1,
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Text(
          '–',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Colors.white.withValues(alpha: 0.2),
          ),
        ),
      ),
      Text(
        '${game.homeScore ?? 0}',
        style: TextStyle(
          fontFamily: 'Russo One',
          fontSize: 18,
          color: color(homeWon),
          height: 1,
        ),
      ),
    ];
  }

  Widget _teamSide(String teamId, {required bool leading}) {
    final logo = Container(
      width: 28,
      height: 28,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
              color: Color(0x40000000), blurRadius: 4, offset: Offset(0, 1)),
        ],
      ),
      padding: const EdgeInsets.all(2.5),
      child: ClipOval(
        child: Image.asset(
          TeamLogoService.getLogoPath(teamId),
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) =>
              const Icon(Icons.shield, size: 14, color: Colors.black54),
        ),
      ),
    );
    final abbr = Text(
      teamId.toUpperCase(),
      style: AppTextStyles.body.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.4,
        color: Colors.white.withValues(alpha: 0.75),
      ),
    );
    final children = <Widget>[
      logo,
      const SizedBox(width: 6),
      abbr,
    ];
    return Row(
      mainAxisAlignment:
          leading ? MainAxisAlignment.start : MainAxisAlignment.end,
      children: leading ? children : children.reversed.toList(),
    );
  }
}
