import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tackle4loss_mobile/design_tokens.dart';
import '../../widgets/notification_badge.dart';

class T4LFloatingNavBar extends StatefulWidget {
  final VoidCallback onHome;
  final VoidCallback onGameCenter;
  final VoidCallback onHistory;
  final VoidCallback onSettings;
  final VoidCallback onTeamLogo;
  final String? favoriteTeamLogoUrl;
  final String? homeTooltip;
  final String? gameCenterTooltip;
  final String? historyTooltip;
  final String? settingsTooltip;
  final bool showGameCenterBadge;

  const T4LFloatingNavBar({
    super.key,
    required this.onHome,
    required this.onGameCenter,
    required this.onHistory,
    required this.onSettings,
    required this.onTeamLogo,
    this.favoriteTeamLogoUrl,
    this.homeTooltip,
    this.gameCenterTooltip,
    this.historyTooltip,
    this.settingsTooltip,
    this.showGameCenterBadge = false,
  });

  @override
  State<T4LFloatingNavBar> createState() => _T4LFloatingNavBarState();
}

class _T4LFloatingNavBarState extends State<T4LFloatingNavBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(
      begin: 1.0,
      end: 1.25,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Adaptive glass colors
    final glassColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.white.withValues(alpha: 0.6);

    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.12)
        : Colors.white.withValues(alpha: 0.4);

    final shadowColor = isDark
        ? Colors.black.withValues(alpha: 0.3)
        : Colors.black.withValues(alpha: 0.1);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      height: 64,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 1. Bar Background with Glassmorphism
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: glassColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: borderColor,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: shadowColor,
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 2. Navigation Items
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Slot 1: Home (H)
              _NavBarButton(
                onTap: widget.onHome,
                tooltip: widget.homeTooltip,
                svgAsset: 'assets/icons/home.svg',
              ),

              // Slot 2: Game Center with optional badge
              Stack(
                clipBehavior: Clip.none,
                children: [
                  _NavBarButton(
                    onTap: widget.onGameCenter,
                    tooltip: widget.gameCenterTooltip,
                    svgAsset: 'assets/icons/schedule.svg',
                  ),
                  if (widget.showGameCenterBadge)
                    Positioned(
                      top: 4,
                      right: 4,
                      child:
                          NotificationBadge(show: widget.showGameCenterBadge),
                    ),
                ],
              ),

              // Slot 3: Spacer for the Center Button
              const SizedBox(width: 60),

              // Slot 4: History
              _NavBarButton(
                onTap: widget.onHistory,
                tooltip: widget.historyTooltip,
                svgAsset: 'assets/icons/back.svg',
              ),

              // Slot 5: Settings
              _NavBarButton(
                onTap: widget.onSettings,
                tooltip: widget.settingsTooltip,
                svgAsset: 'assets/icons/settings.svg',
              ),
            ],
          ),

          // 3. Center Pop-out Button
          Positioned(
            top: -24,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: widget.onTeamLogo,
                child: AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    final scale = widget.favoriteTeamLogoUrl == null
                        ? _animation.value
                        : 1.0;
                    return Transform.scale(
                      scale: scale,
                      child: Container(
                        width: 64,
                        height: 64,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: widget.favoriteTeamLogoUrl != null
                                ? AppColors.primary
                                : Colors.white24,
                            width: 3,
                          ),
                          boxShadow: [
                            if (widget.favoriteTeamLogoUrl == null)
                              BoxShadow(
                                color: AppColors.primary.withValues(
                                  alpha: 0.3 * (_controller.value),
                                ),
                                blurRadius: 15,
                                spreadRadius: 5 * (_controller.value),
                              ),
                            ...AppShadows.md,
                          ],
                        ),
                        child: child,
                      ),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: widget.favoriteTeamLogoUrl != null
                          ? Image.asset(
                              widget.favoriteTeamLogoUrl!,
                              fit: BoxFit.contain,
                            )
                          : Image.asset(
                              'assets/logos/nfl_logo.png',
                              fit: BoxFit.contain,
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavBarButton extends StatelessWidget {
  final VoidCallback onTap;
  final String? svgAsset;
  final String? tooltip;

  const _NavBarButton({
    required this.onTap,
    this.svgAsset,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip ?? '',
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          child: svgAsset != null
              ? SvgPicture.asset(
                  svgAsset!,
                  width: 24,
                  height: 24,
                  colorFilter: Theme.of(context).brightness == Brightness.dark
                      ? ColorFilter.mode(
                          Colors.white.withValues(alpha: 0.9),
                          BlendMode.srcIn,
                        )
                      : null,
                )
              : const SizedBox.shrink(),
        ),
      ),
    );
  }
}
