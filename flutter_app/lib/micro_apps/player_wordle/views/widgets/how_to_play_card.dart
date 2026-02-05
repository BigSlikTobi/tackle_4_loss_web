import 'package:flutter/material.dart';
import 'package:tackle4loss_mobile/design_tokens.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/theme/t4l_theme.dart';

class HowToPlayCard extends StatefulWidget {
  const HowToPlayCard({super.key});

  @override
  State<HowToPlayCard> createState() => _HowToPlayCardState();
}

class _HowToPlayCardState extends State<HowToPlayCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Animation<double>> _fadeAnimations = [];
  final List<Animation<Offset>> _slideAnimations = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Staggered animations for 3 steps
    for (int i = 0; i < 3; i++) {
      final start = 0.2 + (i * 0.15);
      final end = start + 0.4;

      _fadeAnimations.add(
        Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Interval(start, end, curve: Curves.easeOut),
          ),
        ),
      );

      _slideAnimations.add(
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Interval(start, end, curve: Curves.easeOutCubic),
          ),
        ),
      );
    }

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).extension<T4LThemeColors>()!;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.space3),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppBorders.radiusXl),
        boxShadow: AppShadows.sm,
        border: Border.all(color: colors.border),
      ),
      child: Column(
        children: [
          Text(
            l10n.playerWordleInstructionPrimary,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.space3),

          // Step 1
          _buildAnimatedStep(
            context,
            index: 0,
            icon: Icons.search,
            color: AppColors.brandBase,
            text: l10n.playerWordleInstructionSecondary,
          ),
          const SizedBox(height: AppSpacing.space2),

          // Step 2
          _buildAnimatedStep(
            context,
            index: 1,
            icon: Icons.palette,
            color: const Color(0xFF22C55E),
            text: l10n.playerWordleInstructionStep2,
          ),
          const SizedBox(height: AppSpacing.space2),

          // Step 3
          _buildAnimatedStep(
            context,
            index: 2,
            icon: Icons.emoji_events,
            color: const Color(0xFFF59E0B),
            text: l10n.playerWordleInstructionStep3,
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedStep(
    BuildContext context, {
    required int index,
    required IconData icon,
    required Color color,
    required String text,
  }) {
    final colors = Theme.of(context).extension<T4LThemeColors>()!;
    return FadeTransition(
      opacity: _fadeAnimations[index],
      child: SlideTransition(
        position: _slideAnimations[index],
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: AppSpacing.space2),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 13,
                  color: colors.textSecondary,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
