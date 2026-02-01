/// Game mode picker screen for Player Wordle.
/// Allows users to choose between Daily Challenge and Career Mode.
library;

import 'package:flutter/material.dart';
import '../../../core/os_shell/widgets/t4l_scaffold.dart';
import '../../../design_tokens.dart';
import '../../../core/theme/t4l_theme.dart';
import 'player_wordle_screen.dart';
import 'widgets/how_to_play_card.dart';

/// Enum for game modes.
enum GameMode {
  daily,
  career,
}

/// Screen for selecting the game mode before starting.
class GameModePickerScreen extends StatelessWidget {
  const GameModePickerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<T4LThemeColors>()!;

    return T4LScaffold(
      title: 'Guess the Player',
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.space4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title
              Text(
                'Select Game Mode',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: colors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppSpacing.space6),

              // Game Modes Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _GameModeCard(
                      icon: Icons.calendar_today,
                      title: 'Daily',
                      subtitle: 'Compete globally',
                      accentColor: colors.brand,
                      onTap: () => _navigateToGame(context, GameMode.daily),
                      isCompact: true,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.space3),
                  Expanded(
                    child: _GameModeCard(
                      icon: Icons.trending_up,
                      title: 'Career',
                      subtitle: 'Unlock levels',
                      accentColor: const Color(0xFFF59E0B), // Gold/amber color
                      onTap: () => _navigateToGame(context, GameMode.career),
                      isCompact: true,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.space6),

              // How to Play explanation
              const HowToPlayCard(),

              const SizedBox(height: AppSpacing.space4),

              // Your Stats Preview
              _StatsPreview(colors: colors),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToGame(BuildContext context, GameMode mode) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => PlayerWordleScreen(
          initialMode: mode,
        ),
      ),
    );
  }
}

/// Individual game mode selection card.
class _GameModeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color accentColor;
  final VoidCallback onTap;
  final bool isCompact;

  const _GameModeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.onTap,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.space3),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [accentColor, accentColor.withValues(alpha: 0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppBorders.radiusXl),
          boxShadow: [
            BoxShadow(
              color: accentColor.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(height: AppSpacing.space3),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.9),
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.space3),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppBorders.radiusFull),
              ),
              child: Text(
                'PLAY',
                style: TextStyle(
                  color: accentColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Quick stats preview.
class _StatsPreview extends StatelessWidget {
  final T4LThemeColors colors;

  const _StatsPreview({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space4, vertical: AppSpacing.space3),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppBorders.radiusXl),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(label: 'Total Points', value: '---', colors: colors),
          Container(width: 1, height: 30, color: colors.border),
          _StatItem(label: 'Streak', value: '---', colors: colors),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final T4LThemeColors colors;

  const _StatItem({
    required this.label,
    required this.value,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: colors.textPrimary,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: colors.textSecondary,
          ),
        ),
      ],
    );
  }
}
