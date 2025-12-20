import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../design_tokens.dart';

class T4LFloatingNavBar extends StatefulWidget {
  final VoidCallback onHome;
  final VoidCallback onAppStore;
  final VoidCallback onHistory;
  final VoidCallback onSettings;
  final VoidCallback onTeamLogo;
  final String? favoriteTeamLogoUrl;
  final String? homeTooltip;
  final String? appStoreTooltip;
  final String? historyTooltip;
  final String? settingsTooltip;

  const T4LFloatingNavBar({
    super.key,
    required this.onHome,
    required this.onAppStore,
    required this.onHistory,
    required this.onSettings,
    required this.onTeamLogo,
    this.favoriteTeamLogoUrl,
    this.homeTooltip,
    this.appStoreTooltip,
    this.historyTooltip,
    this.settingsTooltip,
  });

  @override
  State<T4LFloatingNavBar> createState() => _T4LFloatingNavBarState();
}

class _T4LFloatingNavBarState extends State<T4LFloatingNavBar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.12),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
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
                child: Text(
                  'H',
                  style: GoogleFonts.anton(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),

              // Slot 2: App Store
              _NavBarButton(
                onTap: widget.onAppStore,
                tooltip: widget.appStoreTooltip,
                icon: LucideIcons.layoutGrid,
              ),

              // Slot 3: Spacer for the Center Button
              const SizedBox(width: 60),

              // Slot 4: History
              _NavBarButton(
                onTap: widget.onHistory,
                tooltip: widget.historyTooltip,
                icon: LucideIcons.history,
                opacity: 0.6,
              ),

              // Slot 5: Settings
              _NavBarButton(
                onTap: widget.onSettings,
                tooltip: widget.settingsTooltip,
                icon: LucideIcons.user,
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
                    final scale = widget.favoriteTeamLogoUrl == null ? _animation.value : 1.0;
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
                                color: AppColors.primary.withOpacity(0.3 * (_controller.value)),
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
  final IconData? icon;
  final Widget? child;
  final String? tooltip;
  final double opacity;

  const _NavBarButton({
    required this.onTap,
    this.icon,
    this.child,
    this.tooltip,
    this.opacity = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip ?? '',
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Opacity(
          opacity: opacity,
          child: Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            child: child ??
                Icon(
                  icon,
                  color: Colors.white70,
                  size: 24,
                ),
          ),
        ),
      ),
    );
  }
}
