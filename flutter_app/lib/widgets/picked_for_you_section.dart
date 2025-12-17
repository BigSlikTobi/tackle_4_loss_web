import 'package:flutter/material.dart';
import '../design_tokens.dart';

class PickedForYouSection extends StatelessWidget {
  const PickedForYouSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Personalized',
                  style: TextStyle(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 1.2,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Picked For You',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
            Icon(Icons.more_horiz, color: Colors.grey),
          ],
        ),
        SizedBox(height: 20),
        _buildArticleCard(
          icon: Icons.sports_football,
          title: 'Defensive Strategies 101',
          subtitle: 'Based on your interest in "Tactics"',
          iconBackgroundColor: AppColors.primary.withOpacity(0.2),
          iconColor: AppColors.primary.withOpacity(0.6),
        ),
        SizedBox(height: 16),
        _buildArticleCard(
          icon: Icons.history_edu,
          title: 'The \'85 Bears: A Retrospective',
          subtitle: 'Because you listened to "Legends"',
          iconBackgroundColor: AppColors.secondary.withOpacity(0.2),
          iconColor: AppColors.secondary,
        ),
      ],
    );
  }

  Widget _buildArticleCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconBackgroundColor,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: iconBackgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: AppColors.textSubLight,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }
}
