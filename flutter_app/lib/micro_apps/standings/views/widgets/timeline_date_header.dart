import 'package:flutter/material.dart';
import '../../../../design_tokens.dart';
import 'package:intl/intl.dart';
import '../../controllers/standings_controller.dart';

class TimelineDateHeader extends StatelessWidget {
  final DateTime date;
  final int week;
  final Color? themeColor;

  const TimelineDateHeader({
    super.key,
    required this.date,
    this.week = 18,
    this.themeColor,
  });

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('EEEE, MMM d').format(date).toUpperCase();
    final primaryColor = themeColor ?? AppColors.brandBase;

    return Padding(
      padding: const EdgeInsets.only(
        bottom: AppSpacing.space2,
        top: AppSpacing.space2,
      ),
      child: Row(
        children: [
          // Timeline dot
          Container(
            width: 32,
            alignment: Alignment.center,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: primaryColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.5),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.space2),
          // Date Text
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                dateStr,
                style: AppTextStyles.h3.copyWith(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                '${StandingsController.getWeekLabel(week)} ${week <= 18 ? 'Regular Season' : 'Post-Season'}',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSubLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
