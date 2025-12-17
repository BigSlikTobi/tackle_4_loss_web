import 'package:flutter/material.dart';
import 'dart:ui';
import '../design_tokens.dart';

class BottomNavigation extends StatelessWidget {
  const BottomNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.cardDark.withOpacity(0.8)
                : Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.white.withOpacity(0.4),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.home,
                label: 'Home',
                isSelected: true,
                context: context,
              ),
              _buildNavItem(
                icon: Icons.podcasts,
                label: 'Deep Dive',
                context: context,
              ),
              const SizedBox(width: 40), // Space for the center button
              _buildNavItem(
                icon: Icons.scoreboard,
                label: 'Scores',
                context: context,
              ),
              _buildNavItem(
                icon: Icons.person,
                label: 'Profile',
                context: context,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    bool isSelected = false,
    required BuildContext context,
  }) {
    final color = isSelected
        ? (Theme.of(context).brightness == Brightness.dark
            ? AppColors.secondary
            : AppColors.primary)
        : (Theme.of(context).brightness == Brightness.dark
            ? AppColors.textSubDark
            : AppColors.textSubLight);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 9,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
