import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tackle4loss_mobile/design_tokens.dart';
import '../../controllers/standings_controller.dart';

/// Sticky-style date divider used between days in the schedule timeline.
class TimelineDateHeader extends StatelessWidget {
  final DateTime date;
  final int week;
  final Color? themeColor; // kept for compat; not used in new design

  const TimelineDateHeader({
    super.key,
    required this.date,
    this.week = 18,
    this.themeColor,
  });

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('EEEE, MMM d').format(date).toUpperCase();
    final isPost = week > 18;
    final sub =
        '${StandingsController.getWeekLabel(week)} ${isPost ? 'Post-Season' : 'Regular Season'}';
    return Container(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.space3, 14, AppSpacing.space3, 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            dateStr,
            style: AppTextStyles.caption.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: Colors.white.withValues(alpha: 0.3),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            sub,
            style: AppTextStyles.caption.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.22),
            ),
          ),
        ],
      ),
    );
  }
}
