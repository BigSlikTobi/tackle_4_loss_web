import 'package:flutter/material.dart';
import 'package:tackle4loss_mobile/design_tokens.dart';
import '../../../../core/theme/t4l_theme.dart';
import '../../../../core/services/team_service.dart';
import '../../../../core/services/team_logo_service.dart';
import '../../../../core/models/team_model.dart';
import '../../models/game_model.dart';

/// "Your Matchup" card. EMOTIONAL DESIGN: brand color (user team) drives the
/// border accent and the Details button.
class FeaturedGameCard extends StatelessWidget {
  final Game game;
  final Team featuredTeam;
  final VoidCallback? onTap;

  const FeaturedGameCard({
    super.key,
    required this.game,
    required this.featuredTeam,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<T4LThemeColors>()!;
    final teamService = TeamService();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.space3, 14, AppSpacing.space3, 8),
          child: Text(
            'YOUR MATCHUP',
            style: AppTextStyles.caption.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
              color: Colors.white.withValues(alpha: 0.35),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.fromLTRB(
              AppSpacing.space2, 0, AppSpacing.space2, 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colors.brand.withValues(alpha: 0.3)),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(14),
              child: Column(
                children: [
                  _buildTopRow(),
                  _buildTeamsRow(teamService),
                  _buildBottomRow(colors),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              game.isPlayed ? 'FINAL' : 'UPCOMING',
              style: AppTextStyles.caption.copyWith(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                color: Colors.white.withValues(alpha: 0.55),
              ),
            ),
          ),
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.07),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_none,
              size: 14,
              color: Colors.white.withValues(alpha: 0.35),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamsRow(TeamService teamService) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 2, 14, 8),
      child: Row(
        children: [
          Expanded(
            child: _matchupTeam(
              teamService: teamService,
              teamId: game.awayTeam,
              score: game.awayScore,
              isWinner: game.winner == game.awayTeam,
              alignEnd: false,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '–',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Week ${game.week}',
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.25),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _matchupTeam(
              teamService: teamService,
              teamId: game.homeTeam,
              score: game.homeScore,
              isWinner: game.winner == game.homeTeam,
              alignEnd: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _matchupTeam({
    required TeamService teamService,
    required String teamId,
    required int? score,
    required bool isWinner,
    required bool alignEnd,
  }) {
    final logo = Container(
      width: 38,
      height: 38,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
              color: Color(0x4D000000), blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.all(3),
      child: ClipOval(
        child: Image.asset(
          TeamLogoService.getLogoPath(teamId),
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) =>
              const Icon(Icons.shield, size: 18, color: Colors.black54),
        ),
      ),
    );
    final abbr = Text(
      teamId.toUpperCase(),
      style: AppTextStyles.body.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.4,
        color: Colors.white.withValues(alpha: 0.65),
      ),
    );
    final scoreWidget = (game.isPlayed && score != null)
        ? Text(
            '$score',
            style: TextStyle(
              fontFamily: 'Russo One',
              fontSize: 26,
              height: 1,
              color: isWinner
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.35),
            ),
          )
        : null;

    final children = <Widget>[
      logo,
      const SizedBox(width: 8),
      abbr,
      if (scoreWidget != null) ...[
        const Spacer(),
        scoreWidget,
      ],
    ];
    return Row(
      mainAxisAlignment:
          alignEnd ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: alignEnd ? children.reversed.toList() : children,
    );
  }

  Widget _buildBottomRow(T4LThemeColors colors) {
    final brandIsLight = colors.brand.computeLuminance() > 0.5;
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            game.weekday.toUpperCase(),
            style: AppTextStyles.caption.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: Colors.white.withValues(alpha: 0.35),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 5),
            decoration: BoxDecoration(
              color: colors.brand,
              borderRadius: BorderRadius.circular(7),
            ),
            child: Text(
              'Details',
              style: AppTextStyles.caption.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
                color: brandIsLight ? const Color(0xFF0B1810) : Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
