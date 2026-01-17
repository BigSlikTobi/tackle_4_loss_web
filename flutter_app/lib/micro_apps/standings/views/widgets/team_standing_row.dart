import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../design_tokens.dart';
import '../../../../core/theme/t4l_theme.dart';
import '../../models/team_standing.dart';

/// A single team's row in the standings table.
/// Uses EMOTIONAL DESIGN: inherits background from parent, uses contrastText for text.
class TeamStandingRow extends StatelessWidget {
  final TeamStanding standing;
  final int rank;
  final bool isUserTeam;

  const TeamStandingRow({
    super.key,
    required this.standing,
    required this.rank,
    this.isUserTeam = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<T4LThemeColors>()!;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space2,
        vertical: AppSpacing.space2,
      ),
      decoration: BoxDecoration(
        // Highlight user's team with brand color tint
        color: isUserTeam
            ? colors.brand.withValues(alpha: 0.15)
            : Colors.transparent,
        border: Border(
          bottom: BorderSide(
            color: colors.brand.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Rank
          SizedBox(
            width: 24,
            child: Text(
              '$rank',
              style: AppTextStyles.caption.copyWith(
                // EMOTIONAL: Use contrast text
                color: colors.contrastText.withValues(alpha: 0.8),
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: AppSpacing.space2),

          // Team Logo
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(2),
            child: ClipOval(
              child: CachedNetworkImage(
                imageUrl: standing.logoUrl,
                width: 24,
                height: 24,
                fit: BoxFit.contain,
                placeholder: (context, url) => const SizedBox(),
                errorWidget: (context, url, error) =>
                    const Icon(Icons.sports_football, size: 16),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.space2),

          // Team Name
          Expanded(
            flex: 3,
            child: Text(
              standing.teamName,
              style: AppTextStyles.bodySmall.copyWith(
                // EMOTIONAL: Use contrast text
                color: colors.contrastText,
                fontWeight: isUserTeam ? FontWeight.w700 : FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Record (W-L)
          SizedBox(
            width: 48,
            child: Text(
              standing.record,
              style: AppTextStyles.bodySmall.copyWith(
                color: colors.contrastText,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Win Percentage
          SizedBox(
            width: 48,
            child: Text(
              standing.formattedWinPercentage,
              style: AppTextStyles.caption.copyWith(
                color: colors.contrastText.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Net Points (Point Differential)
          SizedBox(
            width: 48,
            child: Text(
              standing.formattedNetPoints,
              style: AppTextStyles.caption.copyWith(
                // Color based on positive/negative
                color: standing.netPoints > 0
                    ? Colors.green
                    : standing.netPoints < 0
                    ? AppColors.breakingNewsRed
                    : colors.contrastText.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
