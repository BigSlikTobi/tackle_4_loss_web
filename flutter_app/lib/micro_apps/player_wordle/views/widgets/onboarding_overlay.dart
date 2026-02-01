import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../design_tokens.dart';
import '../../controllers/player_wordle_controller.dart';
import 'how_to_play_card.dart';

class OnboardingOverlay extends StatefulWidget {
  final VoidCallback onDismiss;

  const OnboardingOverlay({super.key, required this.onDismiss});

  @override
  State<OnboardingOverlay> createState() => _OnboardingOverlayState();
}

class _OnboardingOverlayState extends State<OnboardingOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleDismiss() {
    // Reverse animation then dismiss
    _controller.reverse().then((_) {
      context.read<PlayerWordleController>().markOnboardingSeen();
      widget.onDismiss();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Scrim background
    return Stack(
      children: [
        // Darken background with fade
        FadeTransition(
          opacity: _fadeAnimation,
          child: Container(
            color: Colors.black.withValues(alpha: 0.7),
          ),
        ),

        // Centered Card with Scale/Fade
        Center(
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.space4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const HowToPlayCard(),
                    const SizedBox(height: AppSpacing.space4),

                    // Got it button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _handleDismiss,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.brandBase,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppBorders.radiusXl),
                          ),
                          elevation: 8,
                        ),
                        child: const Text(
                          'Got it!',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
