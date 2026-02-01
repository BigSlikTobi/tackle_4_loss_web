import 'package:flutter/material.dart';
import '../../../../design_tokens.dart';
import '../../../../core/theme/t4l_theme.dart';
import '../../models/team_standing.dart';
import 'team_standing_row.dart';

/// Card showing a division's standings with header and team rows.
/// Uses EMOTIONAL DESIGN: all backgrounds use brandLight (team's secondary color).
class DivisionStandingsCard extends StatelessWidget {
  final String conference;
  final DivisionStandings division;
  final String? userTeamId;

  const DivisionStandingsCard({
    super.key,
    required this.conference,
    required this.division,
    this.userTeamId,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<T4LThemeColors>()!;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.space3),
      decoration: BoxDecoration(
        // EMOTIONAL DESIGN: Use brandLight as card background
        color: colors.brandLight,
        borderRadius: BorderRadius.circular(AppBorders.radiusXl),
        border: Border.all(
          color: colors.brand.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.brandLight.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Division Header
          _buildHeader(colors),
          // Column Headers
          _buildColumnHeaders(colors),
          // Team Rows
          ...division.teams.asMap().entries.map((entry) {
            final index = entry.key;
            final team = entry.value;
            return TeamStandingRow(
              standing: team,
              rank: index + 1,
              isUserTeam: userTeamId != null &&
                  team.teamId.toUpperCase() == userTeamId!.toUpperCase(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildHeader(T4LThemeColors colors) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space3,
        vertical: AppSpacing.space2,
      ),
      decoration: BoxDecoration(
        // Conference color tint on brandLight background
        color: _getConferenceColor().withValues(alpha: 0.2),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppBorders.radiusXl),
        ),
      ),
      child: Row(
        children: [
          // Conference color indicator
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: _getConferenceColor(),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: AppSpacing.space2),
          Text(
            division.fullName(conference),
            style: AppTextStyles.body.copyWith(
              // EMOTIONAL: Use contrast text
              color: colors.contrastText,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColumnHeaders(T4LThemeColors colors) {
    final headerStyle = AppTextStyles.caption.copyWith(
      color: colors.contrastText.withValues(alpha: 0.6),
      fontWeight: FontWeight.w600,
      fontSize: 10,
    );

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space2,
        vertical: AppSpacing.space1,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: colors.brand.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: Text('#', style: headerStyle, textAlign: TextAlign.center),
          ),
          const SizedBox(width: AppSpacing.space2),
          const SizedBox(width: 28), // Logo space
          const SizedBox(width: AppSpacing.space2),
          Expanded(flex: 3, child: Text('TEAM', style: headerStyle)),
          SizedBox(
            width: 48,
            child: Text('W-L', style: headerStyle, textAlign: TextAlign.center),
          ),
          SizedBox(
            width: 48,
            child: Text('PCT', style: headerStyle, textAlign: TextAlign.center),
          ),
          SizedBox(
            width: 48,
            child: Text('PD', style: headerStyle, textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }

  Color _getConferenceColor() {
    return conference.toUpperCase() == 'AFC'
        ? const Color(0xFFD50A0A) // AFC Red
        : const Color(0xFF003087); // NFC Blue
  }
}
