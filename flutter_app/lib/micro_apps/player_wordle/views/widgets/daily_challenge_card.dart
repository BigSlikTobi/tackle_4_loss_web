/// Daily Challenge card widget for Player Wordle.
library;

import 'package:flutter/material.dart';
import '../../../../design_tokens.dart';
import '../../../../core/theme/t4l_theme.dart';

/// Card promoting the daily challenge mode.
class DailyChallengeCard extends StatelessWidget {
  /// Whether the daily challenge has been completed today
  final bool isCompleted;

  /// Current daily streak
  final int streak;

  /// Callback when user taps to start daily challenge
  final VoidCallback? onStart;

  /// Teams involved in today's challenge (for preview)
  final List<String> teamsInvolved;

  const DailyChallengeCard({
    super.key,
    this.isCompleted = false,
    this.streak = 0,
    this.onStart,
    this.teamsInvolved = const [],
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<T4LThemeColors>()!;

    // Use app brand colors instead of hardcoded purple
    final gradientColors = isCompleted
        ? [
            const Color(0xFF22C55E),
            const Color(0xFF16A34A)
          ] // Green for completed
        : [colors.brand, colors.brand.withValues(alpha: 0.8)]; // Brand color

    return Container(
      padding: const EdgeInsets.all(AppSpacing.space3),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppBorders.radiusXl),
        boxShadow: AppShadows.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Icon(
                isCompleted ? Icons.check_circle : Icons.calendar_today,
                color: colors.contrastText,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.space2),
              Text(
                'Daily Challenge',
                style: TextStyle(
                  color: colors.contrastText,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              if (streak > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: colors.contrastText.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppBorders.radiusFull),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🔥', style: TextStyle(fontSize: 12)),
                      const SizedBox(width: 4),
                      Text(
                        '$streak',
                        style: TextStyle(
                          color: colors.contrastText,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          const SizedBox(height: AppSpacing.space2),

          // Description
          Text(
            isCompleted
                ? 'You\'ve completed today\'s challenge!'
                : 'Same mystery player for everyone. Compete globally!',
            style: TextStyle(
              color: colors.contrastText.withValues(alpha: 0.9),
              fontSize: 12,
            ),
          ),

          const SizedBox(height: AppSpacing.space3),

          // Action Button
          if (!isCompleted)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onStart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.contrastText,
                  foregroundColor: colors.brand,
                  padding:
                      const EdgeInsets.symmetric(vertical: AppSpacing.space2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppBorders.radiusMd),
                  ),
                ),
                child: const Text(
                  'Start Daily Challenge',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.emoji_events, color: Colors.amber, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Come back tomorrow!',
                  style: TextStyle(
                    color: colors.contrastText,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
