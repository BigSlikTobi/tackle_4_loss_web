import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tackle4loss_mobile/core/theme/t4l_theme.dart';
import 'package:tackle4loss_mobile/core/services/settings_service.dart';
import 'package:tackle4loss_mobile/l10n/app_localizations.dart';
import 'package:tackle4loss_mobile/micro_apps/radio/views/radio_screen.dart';
import 'package:tackle4loss_mobile/micro_apps/radio/controllers/radio_controller.dart';

class RadioHomeWidget extends StatefulWidget {
  const RadioHomeWidget({super.key});

  @override
  State<RadioHomeWidget> createState() => _RadioHomeWidgetState();
}

class _RadioHomeWidgetState extends State<RadioHomeWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late ScrollController _scrollController;
  late AnimationController _marqueeController;
  double _lastMarqueeExtent = 0;
  bool _marqueeActive = false;
  bool _marqueeCheckScheduled = false;
  static const double _marqueeSpeedPxPerSecond = 30;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scrollController = ScrollController();

    _marqueeController = AnimationController(vsync: this)
      ..addListener(() {
        if (!_scrollController.hasClients) return;
        final maxScroll = _scrollController.position.maxScrollExtent;
        if (maxScroll <= 0) return;
        _scrollController.jumpTo(_marqueeController.value * maxScroll);
      });

    _scheduleMarqueeCheck();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scheduleMarqueeCheck();
  }

  @override
  void didUpdateWidget(covariant RadioHomeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _scheduleMarqueeCheck();
  }

  void _scheduleMarqueeCheck() {
    if (_marqueeCheckScheduled) return;
    _marqueeCheckScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) => _evaluateMarquee());
  }

  void _evaluateMarquee() {
    _marqueeCheckScheduled = false;
    if (!mounted || !_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final tickerEnabled = TickerMode.of(context);
    final shouldRun = tickerEnabled && maxScroll > 0;

    if (shouldRun) {
      if (_marqueeActive &&
          (_lastMarqueeExtent - maxScroll).abs() < 0.5 &&
          _marqueeController.isAnimating) {
        return;
      }

      _lastMarqueeExtent = maxScroll;
      final durationMs = (maxScroll / _marqueeSpeedPxPerSecond * 1000)
          .round()
          .clamp(1000, 60000);
      _marqueeController.duration = Duration(milliseconds: durationMs);
      if (!_marqueeController.isAnimating) {
        _marqueeController.repeat();
      }
      _marqueeActive = true;
    } else {
      if (_marqueeActive) {
        _marqueeController.stop();
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(0);
        }
      }
      _marqueeActive = false;
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _marqueeController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _scheduleMarqueeCheck();
    final defaultColors = Theme.of(context).extension<T4LThemeColors>()!;
    final l10n = AppLocalizations.of(context)!;

    final radioController = Provider.of<RadioController>(context);
    final settings = Provider.of<SettingsService>(context); // Listen to changes
    final selectedTeam = settings.selectedTeam;
    final isDarkMode = settings.isDarkMode;

    // Theming Logic:
    Color backgroundColor;
    Color foregroundColor;
    Color iconBackgroundColor;
    Color iconColor;

    if (isDarkMode) {
      // Dark Mode (App is Dark): Widget is Light (White)
      backgroundColor = Colors.white;
      // Text is dark (Team or Black)
      foregroundColor =
          selectedTeam != null ? selectedTeam.primaryColor : Colors.black;
      // Play button background: Dark (Team Color)
      iconBackgroundColor = selectedTeam != null
          ? selectedTeam.primaryColor
          : defaultColors.brand;
      // Play Icon: White
      iconColor = Colors.white;
    } else {
      // Light Mode (App is Light): Widget is Dark (Team Color)
      backgroundColor = selectedTeam != null
          ? selectedTeam.primaryColor
          : const Color(0xFF1A1A1A);
      foregroundColor = Colors.white;
      iconBackgroundColor = Colors.white;
      iconColor = selectedTeam != null
          ? selectedTeam.primaryColor
          : defaultColors.brand;
    }

    return Stack(
      children: [
        // 1. Background Container with Watermark (Clipped)
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: BoxDecoration(
                color: backgroundColor,
                // Subtle shadow dependent on mode
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: isDarkMode ? 0.2 : 0.4,
                    ),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Watermark Logo (Positioned behind text area)
                  if (selectedTeam != null)
                    Positioned(
                      right: 25, // Moved 40px left (-15 + 40)
                      top: -10,
                      bottom: -10,
                      child: Opacity(
                        opacity: 0.3,
                        child: Image.asset(
                          selectedTeam.logoUrl,
                          width: 70,
                          fit: BoxFit.contain,
                          color: foregroundColor,
                          colorBlendMode: BlendMode.srcIn,
                          errorBuilder: (c, e, s) => const SizedBox(),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),

        // 2. Main Content
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              // Emotional Play Button
              GestureDetector(
                onTap: () {
                  radioController.playStation(
                    radioController.dailyBriefingStation,
                    languageCode: settings.locale.languageCode,
                  );
                },
                child: ScaleTransition(
                  scale: Tween<double>(begin: 1.0, end: 1.1).animate(
                    CurvedAnimation(
                      parent: _pulseController,
                      curve: Curves.easeInOut,
                    ),
                  ),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: iconBackgroundColor,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.play_arrow_rounded,
                      color: iconColor,
                      size: 28,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Content Area
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const RadioScreen(),
                      ),
                    );
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.radioTitle,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: foregroundColor,
                          height: 1.1,
                        ),
                        maxLines: 1,
                      ),
                      const SizedBox(height: 2),
                      // Rolling Headline Text
                      SizedBox(
                        height: 16,
                        child: ListView(
                          controller: _scrollController,
                          scrollDirection: Axis.horizontal,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            Text(
                              radioController.latestNewsHeadline ??
                                  "${l10n.radioCategoryDeepDive} · ${l10n.radioCategoryNews}",
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12,
                                // Slightly transparent foreground for description
                                color: foregroundColor.withValues(alpha: 0.85),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 60),
                            if (radioController.latestNewsHeadline != null)
                              Text(
                                radioController.latestNewsHeadline!,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12,
                                  color: foregroundColor.withValues(
                                    alpha: 0.85,
                                  ),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
