import 'package:flutter/material.dart';
import 'package:tackle4loss_mobile/design_tokens.dart';
import '../../../../core/theme/t4l_theme.dart';
import '../../../../core/services/team_logo_service.dart';
import '../../models/team_standing.dart';

/// Compact standings row.
/// EMOTIONAL DESIGN: the user's team brand color drives every accent
/// (playoff border, my-team highlight, rank/text emphasis).
class TeamStandingsCard extends StatelessWidget {
  final TeamStanding team;
  final int rank;
  final bool isPlayoff;
  final bool isWildcard;
  final bool isMyTeam;
  final VoidCallback onTap;

  const TeamStandingsCard({
    super.key,
    required this.team,
    required this.rank,
    required this.onTap,
    this.isPlayoff = false,
    this.isWildcard = false,
    this.isMyTeam = false,
  });

  static const _wildcardGold = Color(0xFFC9A256);

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<T4LThemeColors>()!;

    final Color leftBorderColor = isPlayoff
        ? colors.brand
        : isWildcard
            ? _wildcardGold.withValues(alpha: 0.6)
            : Colors.transparent;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.space2, vertical: 8),
        decoration: BoxDecoration(
          color: isMyTeam ? colors.brand.withValues(alpha: 0.14) : null,
          border: Border(
            left: BorderSide(color: leftBorderColor, width: 3),
            bottom: BorderSide(
                color: Colors.white.withValues(alpha: 0.04), width: 1),
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 20,
              child: Text(
                '$rank',
                textAlign: TextAlign.center,
                style: AppTextStyles.caption.copyWith(
                  fontFamily: 'Russo One',
                  fontSize: 13,
                  color: isPlayoff || isWildcard
                      ? Colors.white.withValues(alpha: 0.7)
                      : Colors.white.withValues(alpha: 0.3),
                ),
              ),
            ),
            const SizedBox(width: 10),
            _buildLogo(),
            const SizedBox(width: 10),
            Expanded(child: _buildTeamInfo(colors)),
            _buildStat(team.wins.toString(),
                emphasized: true, color: Colors.white.withValues(alpha: 0.85)),
            _buildStat(team.losses.toString()),
            _buildStat(team.formattedWinPercentage),
            const SizedBox(width: 4),
            Icon(
              Icons.chevron_right,
              size: 16,
              color: Colors.white.withValues(alpha: 0.25),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      padding: const EdgeInsets.all(3),
      child: ClipOval(
        child: Image.asset(
          TeamLogoService.getLogoPath(team.teamId),
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) =>
              const Icon(Icons.shield, size: 18, color: Colors.black54),
        ),
      ),
    );
  }

  Widget _buildTeamInfo(T4LThemeColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          team.teamName,
          style: AppTextStyles.body.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (isMyTeam)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              'YOUR TEAM',
              style: AppTextStyles.caption.copyWith(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.7,
                color: colors.brand.computeLuminance() > 0.5
                    ? colors.brand
                    : Color.lerp(colors.brand, Colors.white, 0.55),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStat(String value, {bool emphasized = false, Color? color}) {
    return SizedBox(
      width: 32,
      child: Text(
        value,
        textAlign: TextAlign.center,
        style: AppTextStyles.caption.copyWith(
          fontSize: 12,
          fontWeight: emphasized ? FontWeight.w800 : FontWeight.w600,
          color: color ?? Colors.white.withValues(alpha: 0.55),
        ),
      ),
    );
  }
}
