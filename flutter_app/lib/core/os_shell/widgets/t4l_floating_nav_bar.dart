import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tackle4loss_mobile/design_tokens.dart';
import '../../widgets/notification_badge.dart';

/// Floating dock — V3 design (segmented pill with badge floating above).
///
/// Three labelled buttons (Home / Schedule / Settings) inside a glass pill,
/// with the team badge resting above the dock and overlapping its top edge
/// by 10px. Inspired by `components-floating-dock.html` V3.
class T4LFloatingNavBar extends StatefulWidget {
  final VoidCallback onHome;
  final VoidCallback onGameCenter;
  final VoidCallback onSettings;
  final VoidCallback onTeamLogo;
  final String? favoriteTeamLogoUrl;
  final String? homeTooltip;
  final String? gameCenterTooltip;
  final String? settingsTooltip;
  final bool showGameCenterBadge;

  /// Which dock tab is currently active. Defaults to home.
  final T4LNavTab activeTab;

  const T4LFloatingNavBar({
    super.key,
    required this.onHome,
    required this.onGameCenter,
    required this.onSettings,
    required this.onTeamLogo,
    this.favoriteTeamLogoUrl,
    this.homeTooltip,
    this.gameCenterTooltip,
    this.settingsTooltip,
    this.showGameCenterBadge = false,
    this.activeTab = T4LNavTab.home,
  });

  @override
  State<T4LFloatingNavBar> createState() => _T4LFloatingNavBarState();
}

enum T4LNavTab { home, schedule, settings }

class _T4LFloatingNavBarState extends State<T4LFloatingNavBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController = AnimationController(
    duration: const Duration(seconds: 2),
    vsync: this,
  )..repeat(reverse: true);

  static const double _badgeSize = 54;
  static const double _badgeOverlap = 10;
  static const double _dockHeight = 58;

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final activeColor = isDark ? const Color(0xFF4ADE80) : AppColors.brandBase;
    final inactiveIcon =
        isDark ? const Color(0xFFA1A1AA) : const Color(0xFF555555);
    final inactiveLabel =
        isDark ? const Color(0xFF71717A) : const Color(0xFF888888);

    final glassColor = isDark
        ? const Color(0xFF1A1C1C).withValues(alpha: 0.82)
        : Colors.white.withValues(alpha: 0.72);
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.white.withValues(alpha: 0.9);
    final dividerColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.08);
    final activeBg = isDark
        ? const Color(0xFF4ADE80).withValues(alpha: 0.12)
        : AppColors.brandBase.withValues(alpha: 0.10);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: SizedBox(
        // Pill height + badge protrusion above the pill.
        height: _dockHeight + (_badgeSize - _badgeOverlap),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            // ─── Pill dock ──────────────────────────────────────────
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: _dockHeight,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(9999),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                  child: Container(
                    decoration: BoxDecoration(
                      color: glassColor,
                      borderRadius: BorderRadius.circular(9999),
                      border: Border.all(color: borderColor, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black
                              .withValues(alpha: isDark ? 0.35 : 0.13),
                          blurRadius: 28,
                          offset: const Offset(0, 8),
                        ),
                        BoxShadow(
                          color: Colors.black
                              .withValues(alpha: isDark ? 0.2 : 0.07),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: _NavButton(
                            tooltip: widget.homeTooltip,
                            label: 'Home',
                            svgAsset: 'assets/icons/home.svg',
                            onTap: widget.onHome,
                            active: widget.activeTab == T4LNavTab.home,
                            activeColor: activeColor,
                            inactiveIcon: inactiveIcon,
                            inactiveLabel: inactiveLabel,
                            activeBg: activeBg,
                          ),
                        ),
                        _Divider(color: dividerColor),
                        Expanded(
                          child: Stack(
                            clipBehavior: Clip.none,
                            fit: StackFit.expand,
                            alignment: Alignment.center,
                            children: [
                              _NavButton(
                                tooltip: widget.gameCenterTooltip,
                                label: 'Schedule',
                                svgAsset: 'assets/icons/schedule.svg',
                                onTap: widget.onGameCenter,
                                active: widget.activeTab == T4LNavTab.schedule,
                                activeColor: activeColor,
                                inactiveIcon: inactiveIcon,
                                inactiveLabel: inactiveLabel,
                                activeBg: activeBg,
                              ),
                              if (widget.showGameCenterBadge)
                                Positioned(
                                  top: 4,
                                  right: 8,
                                  child: NotificationBadge(
                                      show: widget.showGameCenterBadge),
                                ),
                            ],
                          ),
                        ),
                        _Divider(color: dividerColor),
                        Expanded(
                          child: _NavButton(
                            tooltip: widget.settingsTooltip,
                            label: 'Settings',
                            svgAsset: 'assets/icons/settings.svg',
                            onTap: widget.onSettings,
                            active: widget.activeTab == T4LNavTab.settings,
                            activeColor: activeColor,
                            inactiveIcon: inactiveIcon,
                            inactiveLabel: inactiveLabel,
                            activeBg: activeBg,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ─── Team badge floating above ──────────────────────────
            Positioned(
              top: 0,
              child: GestureDetector(
                onTap: widget.onTeamLogo,
                behavior: HitTestBehavior.opaque,
                child: AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    final scale = widget.favoriteTeamLogoUrl == null
                        ? 1.0 + 0.06 * _pulseController.value
                        : 1.0;
                    return Transform.scale(scale: scale, child: child);
                  },
                  child: Container(
                    width: _badgeSize,
                    height: _badgeSize,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(17),
                      border: Border.all(color: activeColor, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: isDark
                              ? Colors.black.withValues(alpha: 0.5)
                              : AppColors.brandBase.withValues(alpha: 0.30),
                          blurRadius: 28,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(5),
                    clipBehavior: Clip.antiAlias,
                    child: Image.asset(
                      widget.favoriteTeamLogoUrl ?? 'assets/logos/nfl_logo.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final String? tooltip;
  final String label;
  final String svgAsset;
  final VoidCallback onTap;
  final bool active;
  final Color activeColor;
  final Color inactiveIcon;
  final Color inactiveLabel;
  final Color activeBg;

  const _NavButton({
    required this.tooltip,
    required this.label,
    required this.svgAsset,
    required this.onTap,
    required this.active,
    required this.activeColor,
    required this.inactiveIcon,
    required this.inactiveLabel,
    required this.activeBg,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = active ? activeColor : inactiveIcon;
    final labelColor = active ? activeColor : inactiveLabel;

    return Tooltip(
      message: tooltip ?? label,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 44,
          margin: const EdgeInsets.symmetric(vertical: 7, horizontal: 2),
          decoration: BoxDecoration(
            color: active ? activeBg : Colors.transparent,
            borderRadius: BorderRadius.circular(9999),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                svgAsset,
                width: 20,
                height: 20,
                colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
              ),
              const SizedBox(height: 3),
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.27,
                  color: labelColor,
                  height: 1.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  final Color color;
  const _Divider({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 28, color: color);
  }
}
