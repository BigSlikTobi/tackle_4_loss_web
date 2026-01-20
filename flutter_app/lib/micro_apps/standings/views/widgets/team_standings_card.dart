import 'package:flutter/material.dart';
import '../../../../design_tokens.dart';
import '../../../../core/theme/t4l_theme.dart';
import '../../../../core/services/team_logo_service.dart';
import '../../models/team_standing.dart';

/// Expandable card showing a team's standings.
/// Uses EMOTIONAL DESIGN: all backgrounds use brandLight (team's secondary color).
class TeamStandingsCard extends StatelessWidget {
  final TeamStanding team;
  final int rank;
  final bool isExpanded;
  final VoidCallback onTap;

  const TeamStandingsCard({
    super.key,
    required this.team,
    required this.rank,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<T4LThemeColors>()!;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppAnimation.durationFast,
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(bottom: AppSpacing.space1),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppBorders.radiusMd),
          // EMOTIONAL DESIGN: Use brandLight as card background
          color: colors.brandLight,
          border: Border.all(
            color: isExpanded
                ? colors.brand
                : colors.brand.withValues(alpha: 0.3),
            width: isExpanded ? 2 : 1,
          ),
          boxShadow: isExpanded
              ? [
                  BoxShadow(
                    color: colors.brand.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: colors.brandLight.withValues(alpha: 0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppBorders.radiusMd),
          child: Column(
            children: [
              // Main content row
              _buildMainRow(colors),
              // Expandable details
              AnimatedCrossFade(
                firstChild: const SizedBox(height: 0),
                secondChild: _buildExpandedDetails(colors),
                crossFadeState: isExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: AppAnimation.durationFast,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Main always-visible row with rank, logo, name, record
  Widget _buildMainRow(T4LThemeColors colors) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.space2),
      decoration: BoxDecoration(
        // Slight gradient for depth
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [colors.brandLight, colors.brand.withValues(alpha: 0.15)],
        ),
      ),
      child: Row(
        children: [
          // Rank number
          _buildRankBadge(colors),
          const SizedBox(width: AppSpacing.space2),
          // Team logo
          _buildTeamLogo(colors),
          const SizedBox(width: AppSpacing.space2),
          // Team name and subtitle
          Expanded(child: _buildTeamInfo(colors)),
          // Record
          _buildRecord(colors),
          const SizedBox(width: AppSpacing.space1),
          // Expand/collapse indicator
          Icon(
            isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_right,
            color: colors.contrastText.withValues(alpha: 0.6),
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildRankBadge(T4LThemeColors colors) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: colors.brand.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          '$rank',
          style: AppTextStyles.h3.copyWith(
            color: colors.contrastText,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildTeamLogo(T4LThemeColors colors) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: colors.brand.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(4),
      child: Image.asset(
        TeamLogoService.getLogoPath(team.teamId),
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const Icon(Icons.error),
      ),
    );
  }

  Widget _buildTeamInfo(T4LThemeColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                team.teamName,
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.bold,
                  // EMOTIONAL: Use contrast text
                  color: colors.contrastText,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isExpanded) ...[
              const SizedBox(width: AppSpacing.space1),
              _buildClinchedBadge(colors),
            ],
          ],
        ),
        Text(
          team.teamName, // Could be city name
          style: AppTextStyles.caption.copyWith(
            color: colors.contrastText.withValues(alpha: 0.6),
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ],
    );
  }

  Widget _buildClinchedBadge(T4LThemeColors colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: colors.brand,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'CLINCHED',
        style: TextStyle(
          // EMOTIONAL: Contrast text on brand background
          color: colors.contrastText,
          fontWeight: FontWeight.w900,
          fontSize: 10,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildRecord(T4LThemeColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          team.record,
          style: AppTextStyles.h3.copyWith(
            fontWeight: FontWeight.bold,
            color: colors.contrastText,
          ),
        ),
      ],
    );
  }

  /// Expanded details section
  Widget _buildExpandedDetails(T4LThemeColors colors) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.space2,
        0,
        AppSpacing.space2,
        AppSpacing.space2,
      ),
      decoration: BoxDecoration(color: colors.brand.withValues(alpha: 0.1)),
      child: Row(
        // EMOTIONAL: Use contrast text on brand background
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStatColumn('CONF', team.conferenceRecord, colors),
          _buildStatColumn('DIV', team.divisionRecord, colors),
          _buildStatColumn('PF', '${team.pointsFor}', colors),
          _buildStatColumn('PA', '${team.pointsAgainst}', colors),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, T4LThemeColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: colors.contrastText.withValues(alpha: 0.6),
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.bold,
            color: colors.contrastText,
          ),
        ),
      ],
    );
  }
}
