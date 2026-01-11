import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../app_registry.dart';
import 'dart:math' as math;
import '../../services/installed_apps_service.dart';
import '../../services/new_content_service.dart';
import '../controllers/os_shell_controller.dart';
import '../../services/navigation_service.dart';
import '../widgets/t4l_floating_nav_bar.dart';
import '../widgets/t4l_scaffold.dart';
import 'package:provider/provider.dart';
import '../../services/settings_service.dart';
import '../widgets/news_feed/news_feed_widget.dart';
import '../widgets/app_grid_item.dart';
import '../widgets/remove_drop_zone.dart';
import '../../../l10n/app_localizations.dart';

import '../../team_center/views/team_center_overlay.dart';
import '../widgets/user_settings_dialog.dart';
import '../widgets/team_selector_dialog.dart';
import '../../widgets/shimmer_skeleton.dart';

class OSShellView extends StatefulWidget {
  const OSShellView({super.key});

  @override
  State<OSShellView> createState() => _OSShellViewState();
}

class _OSShellViewState extends State<OSShellView>
    with TickerProviderStateMixin {
  late OSShellController _controller;
  AnimationController? _rotationController;
  AnimationController? _sheenController;
  bool _isDragging = false;
  int? _draggedIndex; // Track what we are dragging (source index)
  int? _hoverTargetIndex; // Track where we are hovering
  String? _currentLanguageCode;

  @override
  void initState() {
    super.initState();
    _controller = OSShellController(context);

    // Auto-restore validation logic removed per user request
    // if (InstalledAppsService().installedApps.length < 2) {
    //    InstalledAppsService().resetDefaults();
    // }

    _loadApps(); // Initial load

    // Subtle pulsating animation (breathing/sway effect) - Linear loop for Sine wave
    _rotationController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    )..repeat(); // No reverse needed for Sine

    // Reflection/Sheen animation
    _sheenController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat();
  }

  // ... (didChangeDependencies, dispose, _loadApps unchanged) ...

  /// Determines if a slot is part of the "Phantom" footprint of the dragged item
  /// Returns: 0 = No, 1 = Valid Phantom, 2 = Invalid Phantom
  int _getPhantomStatus(int slotIndex) {
    if (!_isDragging || _draggedIndex == null || _hoverTargetIndex == null) {
      return 0;
    }

    final service = InstalledAppsService();
    final item = service.getItemAt(_draggedIndex!);
    final isWidget = item.contains('|widget');

    if (isWidget) {
      // Dynamic Widget Logic
      final appId = item.split('|').first;
      final app = AppRegistry().getApp(appId);
      
      int width = 2;
      int height = 2;
      if (app != null) {
        width = app.widgetSize.width.toInt();
        height = app.widgetSize.height.toInt();
      }

      // Calculate the slots relative to the hover target
      final target = _hoverTargetIndex!;
      final cols = 4; // gridCols
      final rows = 5; // gridRows

      // Check bounds of the "phantom widget" placed at target
      // This is implicit in canPlaceWidgetAt but useful here to define visual feedback
      
      final phantomSlots = <int>[];
      for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
          phantomSlots.add(target + x + (y * cols));
        }
      }

      if (phantomSlots.contains(slotIndex)) {
        // This slot is part of the phantom
        // Check validity of the move
        final isValid = service.canPlaceWidgetAt(
          target,
          width,
          height,
          ignoreIndex: _draggedIndex!,
        );
        return isValid ? 1 : 2;
      }
    } else {
      // 1x1 Logic
      if (slotIndex == _hoverTargetIndex) {
        return 1; // Always valid to swap/move 1x1
      }
    }
    return 0;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final settings = Provider.of<SettingsService>(context);
    if (_currentLanguageCode != settings.locale.languageCode) {
      _currentLanguageCode = settings.locale.languageCode;
      _controller.initLoadAll(_currentLanguageCode!);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _rotationController?.dispose();
    _sheenController?.dispose();
    super.dispose();
  }

  void _loadApps() {
    // setState(() {
    //   _apps = InstalledAppsService().installedApps;
    // });
  }

  @override
  Widget build(BuildContext context) {
    // For now we just poll/rebuild, later we can use a Stream/Listenable
    // _apps removed as it was unused local field, using service directly
    final settings = Provider.of<SettingsService>(
      context,
    ); // Listen to settings

    // Ensure animation controllers are initialized (Hot Reload defense)
    _rotationController ??= AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    )..repeat();

    _sheenController ??= AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat();

    return ChangeNotifierProvider.value(
      value: _controller,
      child: T4LScaffold(
        showCloseButton: false, // Shell is the root
        bottomNavBarOverride: AnimatedCrossFade(
          duration: const Duration(milliseconds: 200),
          crossFadeState: _isDragging
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,

          // State 1: Dock
          firstChild: ListenableBuilder(
            listenable: NewContentService(),
            builder: (context, child) {
              return T4LFloatingNavBar(
                homeTooltip: AppLocalizations.of(context)!.navHome,
                appStoreTooltip: AppLocalizations.of(context)!.navAppHub,
                historyTooltip: AppLocalizations.of(context)!.navHistory,
                settingsTooltip: AppLocalizations.of(context)!.navSettings,
                favoriteTeamLogoUrl: settings.selectedTeam?.logoUrl,
                showAppHubBadge: NewContentService().hasNewAppsInHub,
                onHome: () => NavigationService().goHome(context),
                onAppStore: () {
                  NewContentService().markAppHubSeen();
                  NavigationService().openAppHub(context);
                },
                onHistory: () => NavigationService().reopenLastApp(context),
                onSettings: () {
                  NavigationService().openSettings(
                    context,
                    (context) => const UserSettingsDialog(),
                  );
                },
                onTeamLogo: () {
                  if (settings.selectedTeam == null) {
                    NavigationService().openTeamSelector(
                      context,
                      (context) => const TeamSelectorDialog(),
                    );
                  } else {
                    NavigationService().openTeamCenter(
                      context,
                      () => TeamCenterOverlay.show(context, settings.selectedTeam!),
                    );
                  }
                },
              );
            },
          ),

          // State 2: Remove Zone (Trash)
          secondChild: RemoveDropZone(
            onRemove: (fromIndex) {
              final rawItem = InstalledAppsService().getItemAt(fromIndex);
              if (rawItem != '__EMPTY__') {
                final appId = rawItem.split('|').first;
                InstalledAppsService().uninstall(appId);
              }
            },
          ),
        ),
        body: SafeArea(
          child: Stack(
            children: [
              // 0. Ambient Watermark (Behind Grid, Below Hero)
              if (settings.selectedTeam != null)
                Positioned(
                  top:
                      MediaQuery.of(context).size.height *
                      0.45, // Start below Hero
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Center(
                    child: Opacity(
                      opacity: 0.12,
                      child: AnimatedBuilder(
                        animation: Listenable.merge([
                          _rotationController!,
                          _sheenController!,
                        ]),
                        builder: (context, child) {
                          // Use Sine wave for perfect continuous loop without "stops"
                          // oscillations between -0.22 and 0.22 radians
                          final angle =
                              0.22 *
                              math.sin(
                                2 * math.pi * _rotationController!.value,
                              );

                          final sheenValue = _sheenController!.value;

                          return Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()
                              ..setEntry(3, 2, 0.001) // Perspective
                              ..rotateY(angle), // Sway left/right
                            child: ShaderMask(
                              shaderCallback: (rect) {
                                // Create sliding gradient window
                                return LinearGradient(
                                  begin: Alignment.bottomLeft,
                                  end: Alignment.topRight,
                                  colors: [
                                    Colors.transparent,
                                    Colors.white.withValues(
                                      alpha: 0.4,
                                    ), // The Glow
                                    Colors.transparent,
                                  ],
                                  // Move the stops from -0.3 (before start) to 1.3 (after end)
                                  stops: [
                                    sheenValue * 1.6 - 0.6,
                                    sheenValue * 1.6 - 0.3,
                                    sheenValue * 1.6,
                                  ],
                                ).createShader(rect);
                              },
                              blendMode: BlendMode
                                  .srcATop, // Paint sheen ON TOP of existing pixels
                              child: child,
                            ),
                          );
                        },
                        child: SizedBox(
                          width: 300,
                          height: 300,
                          child: Image.asset(
                            settings.selectedTeam!.logoUrl,
                            errorBuilder: (_, __, ___) => const SizedBox(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

              // 1. Fixed App Grid + Scrollable Feed Layout
              Consumer<OSShellController>(
                builder: (context, shellController, child) {
                  // Show skeleton while loading
                  if (!shellController.isPageReady) {
                    return const OSShellSkeleton();
                  }
                  
                  return ListenableBuilder(
                    listenable: InstalledAppsService(),
                    builder: (context, child) {
                      return AnimatedOpacity(
                        opacity: 1.0,
                        duration: const Duration(milliseconds: 300),
                        child: Column(
                        children: [
                          // 1. Header Clearance
                          const SizedBox(height: 80),

                          // 2. Golden Upper Section (flex: 1 = 38.2%) - App Grid + Separator
                          // Using flex ratio 1000:1618 ≈ 1:φ for golden ratio proportions
                          Flexible(
                            flex: 1000, // Upper = 1 unit (38.2% of 2.618 total)
                            child: Column(
                              children: [
                                // App Grid Section
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24.0,
                                    ),
                                    child: LayoutBuilder(
                                      builder: (context, constraints) {
                                        final totalWidth = constraints.maxWidth;
                                        const crossAxisCount = 4;
                                        const crossAxisSpacing = 16.0;
                                        final cellWidth =
                                            (totalWidth -
                                                (crossAxisSpacing *
                                                    (crossAxisCount - 1))) /
                                            crossAxisCount;

                                        return Stack(
                                          children: [
                                            StaggeredGrid.count(
                                              crossAxisCount: 4,
                                              mainAxisSpacing: 24,
                                              crossAxisSpacing: 16,
                                              children: [
                                                for (
                                                  int index = 0;
                                                  index < 20;
                                                  index++
                                                ) ...[
                                                  if (!InstalledAppsService()
                                                      .isOccupySlot(index))
                                                    _buildGridItem(
                                                      context,
                                                      index,
                                                      cellWidth,
                                                    ),
                                                ],
                                              ],
                                            ),

                                            Positioned.fill(
                                              child: IgnorePointer(
                                                ignoring: !_isDragging,
                                                child: GridView.count(
                                                  physics:
                                                      const NeverScrollableScrollPhysics(),
                                                  crossAxisCount: 4,
                                                  mainAxisSpacing: 0,
                                                  crossAxisSpacing: 0,
                                                  childAspectRatio:
                                                      (totalWidth / 4) /
                                                      (cellWidth / 0.85 + 24),
                                                  children: List.generate(12, (
                                                    index,
                                                  ) {
                                                    return _buildDropZone(
                                                      index,
                                                    );
                                                  }),
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                ),

                                // Visual separator removed to avoid double header
                                const SizedBox(height: 16),
                              ],
                            ),
                          ),

                          // 3. Golden Lower Section (flex: 1618 = 61.8%) - Scrollable News Feed
                          Flexible(
                            flex:
                                1618, // Lower = φ units (61.8% of 2.618 total)
                            child: CustomScrollView(
                              slivers: const [
                                NewsFeedWidget(),
                                SliverPadding(
                                  padding: EdgeInsets.only(bottom: 120),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridItem(BuildContext context, int index, double cellWidth) {
    final rawItem = InstalledAppsService().getItemAt(index);
    final isEmpty = InstalledAppsService().isEmpty(index);

    if (isEmpty) {
      return StaggeredGridTile.count(
        crossAxisCellCount: 1,
        mainAxisCellCount: 1,
        child: const SizedBox(),
      );
    }

    final appId = rawItem.split('|').first;
    final isWidget = rawItem.contains('|widget');
    final app = AppRegistry().getApp(appId);

    if (app == null) return const SizedBox.shrink();

    int crossAxisCount = 1;
    num mainAxisCount = 1.4;
    Widget child;

    if (isWidget && app.hasWidget) {
      final size = app.widgetSize;
      crossAxisCount = size.width.toInt();
      mainAxisCount = size.height.toInt();
      child = app.widgetBuilder(context);
    } else {
      child = OSShellAppItem(
        app: app,
        onTap: () => NavigationService().openApp(context, app),
      );
    }

    return StaggeredGridTile.count(
      key: ValueKey(app.id),
      crossAxisCellCount: crossAxisCount,
      mainAxisCellCount: mainAxisCount,
      child: LongPressDraggable<int>(
        data: index,
        feedback: _buildDragFeedback(
          context,
          child,
          size: Size(
            cellWidth * crossAxisCount + (16 * (crossAxisCount - 1)),
            (cellWidth / 0.85) * mainAxisCount + (24 * (mainAxisCount - 1)),
          ),
        ),
        childWhenDragging: Opacity(opacity: 0.3, child: child),
        onDragStarted: () => setState(() {
          _isDragging = true;
          _draggedIndex = index;
        }),
        onDragEnd: (_) => setState(() {
          _isDragging = false;
          _draggedIndex = null;
          _hoverTargetIndex = null;
        }),
        child: child,
      ),
    );
  }

  Widget _buildDropZone(int index) {
    final phantomStatus = _getPhantomStatus(index);
    Color? phantomColor;
    if (phantomStatus == 1) phantomColor = Colors.green.withValues(alpha: 0.3);
    if (phantomStatus == 2) phantomColor = Colors.red.withValues(alpha: 0.3);

    return DragTarget<int>(
      onWillAcceptWithDetails: (details) {
        if (_hoverTargetIndex != index) {
          setState(() => _hoverTargetIndex = index);
        }
        return true;
      },
      onLeave: (_) {
        if (_hoverTargetIndex == index) {
          setState(() => _hoverTargetIndex = null);
        }
      },
      onAcceptWithDetails: (details) {
        final fromIndex = details.data;
        if (fromIndex != index) {
          InstalledAppsService().moveApp(fromIndex, index);
          setState(() {
            _isDragging = false;
            _draggedIndex = null;
            _hoverTargetIndex = null;
          });
        }
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          // Internal padding to match the visual StaggeredGrid spacing
          // StaggeredGrid has 16 horizontal gap, 24 vertical gap.
          // Since this overlay is gapless (cells touch), we add margin to the colored box.
          padding: const EdgeInsets.fromLTRB(0, 0, 16, 24),
          color: Colors.transparent, // Hit test target fills the whole cell
          child: Container(
            decoration: BoxDecoration(
              color: phantomColor ?? Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              border: phantomColor != null
                  ? Border.all(
                      color: phantomStatus == 1 ? Colors.green : Colors.red,
                      width: 2,
                    )
                  : null,
            ),
          ),
        );
      },
    );
  }

  Widget _buildDragFeedback(
    BuildContext context,
    Widget child, {
    required Size size,
  }) {
    // IgnorePointer is crucial to let drag events pass through to the DragTarget below
    return IgnorePointer(
      child: Material(
        color: Colors.transparent,
        child: SizedBox(
          width: size.width,
          height: size.height,
          child: Transform.scale(
            scale: 1.05, // Slight pop effect
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
