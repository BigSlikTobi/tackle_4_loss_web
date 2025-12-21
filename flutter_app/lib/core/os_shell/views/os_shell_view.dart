import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../../design_tokens.dart';
import '../../app_registry.dart';
import 'dart:math' as math;
import '../../services/installed_apps_service.dart';
import '../controllers/os_shell_controller.dart';
import '../../micro_app.dart';
import '../../services/navigation_service.dart';
import '../widgets/t4l_floating_nav_bar.dart';
import '../widgets/t4l_scaffold.dart';
import 'package:provider/provider.dart';
import '../../services/settings_service.dart';
import '../widgets/featured_app_hero.dart';
import '../widgets/app_grid_item.dart';
import '../widgets/remove_drop_zone.dart';
import '../../../l10n/app_localizations.dart';
import '../widgets/user_settings_dialog.dart';
import '../widgets/team_selector_dialog.dart';

class OSShellView extends StatefulWidget {
  const OSShellView({super.key});

  @override
  State<OSShellView> createState() => _OSShellViewState();
}

class _OSShellViewState extends State<OSShellView> with TickerProviderStateMixin {
  late OSShellController _controller;
  List<MicroApp> _apps = [];
  AnimationController? _rotationController;
  AnimationController? _sheenController;
  bool _isDragging = false;
  String? _currentLanguageCode;

  @override
  void initState() {
    super.initState();
    _controller = OSShellController(context);
    
    // Auto-restore defaults if grid is empty/too small for testing
    // This helps if the user accidentally removed everything
    if (InstalledAppsService().installedApps.length < 2) {
       InstalledAppsService().resetDefaults();
    }
    
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final settings = Provider.of<SettingsService>(context);
    if (_currentLanguageCode != settings.locale.languageCode) {
      _currentLanguageCode = settings.locale.languageCode;
      _controller.loadFeaturedContent(_currentLanguageCode!);
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
    setState(() {
      _apps = InstalledAppsService().installedApps;
    });
  }

  @override
  Widget build(BuildContext context) {
    // For now we just poll/rebuild, later we can use a Stream/Listenable
    _apps = InstalledAppsService().installedApps;
    final settings = Provider.of<SettingsService>(context); // Listen to settings

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
            firstChild: T4LFloatingNavBar(
              homeTooltip: AppLocalizations.of(context)!.navHome,
              appStoreTooltip: AppLocalizations.of(context)!.navAppStore,
              historyTooltip: AppLocalizations.of(context)!.navHistory,
              settingsTooltip: AppLocalizations.of(context)!.navSettings,
              favoriteTeamLogoUrl: settings.selectedTeam?.logoUrl,
              onHome: () => NavigationService().goHome(context),
              onAppStore: () => NavigationService().openAppStore(context),
              onHistory: () => NavigationService().reopenLastApp(context),
              onSettings: () {
                showDialog(
                  context: context,
                  builder: (context) => UserSettingsDialog(),
                );
              },
              onTeamLogo: () {
                if (settings.selectedTeam == null) {
                  showDialog(
                    context: context,
                    builder: (context) => TeamSelectorDialog(),
                  );
                }
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
                  top: MediaQuery.of(context).size.height * 0.45, // Start below Hero
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Center(
                    child: Opacity(
                      opacity: 0.12,
                      child: AnimatedBuilder(
                        animation: Listenable.merge([_rotationController!, _sheenController!]),
                        builder: (context, child) {
                          // Use Sine wave for perfect continuous loop without "stops"
                          // oscillations between -0.22 and 0.22 radians
                          final angle = 0.22 * math.sin(2 * math.pi * _rotationController!.value);
                          
                          final sheenValue = _sheenController!.value;
                          
                          return Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()
                              ..setEntry(3, 2, 0.001) // Perspective
                              ..rotateY(angle),      // Sway left/right
                            child: ShaderMask(
                              shaderCallback: (rect) {
                                  // Create sliding gradient window
                                  return LinearGradient(
                                    begin: Alignment.bottomLeft,
                                    end: Alignment.topRight,
                                    colors: [
                                      Colors.transparent, 
                                      Colors.white.withOpacity(0.4), // The Glow
                                      Colors.transparent
                                    ],
                                    // Move the stops from -0.3 (before start) to 1.3 (after end)
                                    stops: [
                                      sheenValue * 1.6 - 0.6,
                                      sheenValue * 1.6 - 0.3, 
                                      sheenValue * 1.6
                                    ],
                                  ).createShader(rect);
                              },
                              blendMode: BlendMode.srcATop, // Paint sheen ON TOP of existing pixels
                              child: child,
                            ),
                          );
                        },
                        child: SizedBox(
                          width: 300,
                          height: 300,
                          child: Image.asset(
                             settings.selectedTeam!.logoUrl,
                             errorBuilder: (_,__,___) => const SizedBox(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
  
              // 1. Scrollable Content (Hero + Grid)
              Consumer<OSShellController>(
                builder: (context, shellController, child) {
                  return ListenableBuilder(
                    listenable: InstalledAppsService(),
                    builder: (context, child) {
                      // gridApps removed
                      
                      // App of the Month Logic
                      final featuredId = AppRegistry().featuredAppId;
                      // Always show featured hero if one is defined in registry, regardless of grid status
                      final showFeatured = featuredId != null;
          
                      return CustomScrollView(
                        slivers: [
                          // 1. Featured App Hero (As a Sliver)
                          if (showFeatured)
                             SliverToBoxAdapter(
                               child: FeaturedAppHero(
                                 app: AppRegistry().getApp(featuredId!)!,
                                 article: shellController.featuredArticle,
                               ),
                             ),
    
                    // 2. Padding/Spacer between Hero and Grid
                    const SliverPadding(padding: EdgeInsets.only(top: 24)),
    
                    // 3. Staggered App Grid
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      sliver: SliverToBoxAdapter(
                        child: StaggeredGrid.count(
                          crossAxisCount: 4,
                          mainAxisSpacing: 24,
                          crossAxisSpacing: 16,
                          children: [
                            for (int index = 0; index < 20; index++) ...[
                              if (!InstalledAppsService().isOccupySlot(index))
                                Builder(
                                  builder: (context) {
                                    final rawItem = InstalledAppsService().getItemAt(index);
                                    final isEmpty = InstalledAppsService().isEmpty(index);
                                    
                                    if (isEmpty) {
                                      // EMPTY SLOT
                                      return StaggeredGridTile.count(
                                        key: ValueKey('empty_$index'),
                                        crossAxisCellCount: 1,
                                        mainAxisCellCount: 1,
                                        child: DragTarget<int>(
                                          onWillAccept: (data) => true,
                                          onAccept: (fromIndex) {
                                              InstalledAppsService().moveApp(fromIndex, index);
                                          },
                                          builder: (context, candidateData, rejectedData) {
                                            final isHovered = candidateData.isNotEmpty;
                                            return Container(
                                              decoration: BoxDecoration(
                                                color: isHovered ? Colors.white.withOpacity(0.1) : Colors.transparent,
                                                borderRadius: BorderRadius.circular(16),
                                                border: isHovered 
                                                    ? Border.all(color: Colors.white.withOpacity(0.3), width: 1)
                                                    : null,
                                              ),
                                            );
                                          },
                                        ),
                                      );
                                    }

                                    // MASTER APP / WIDGET
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
                                      child: DragTarget<int>(
                                        onWillAccept: (data) => true,
                                        onAccept: (fromIndex) {
                                          if (fromIndex != index) {
                                            InstalledAppsService().moveApp(fromIndex, index);
                                          }
                                        },
                                        builder: (context, candidateData, rejectedData) {
                                          final isHovered = candidateData.isNotEmpty;
                                          
                                          return LongPressDraggable<int>(
                                            data: index,
                                            feedback: _buildDragFeedback(context, child, size: Size(
                                              ((MediaQuery.of(context).size.width - 48 - 48) / 4) * crossAxisCount + (crossAxisCount - 1) * 16,
                                              ((MediaQuery.of(context).size.width - 48 - 48) / 4) * mainAxisCount + (mainAxisCount > 1 ? (mainAxisCount - 1) * 24 : 0),
                                            )),
                                            childWhenDragging: Opacity(
                                              opacity: 0.3, 
                                              child: child
                                            ),
                                            onDragStarted: () => setState(() => _isDragging = true),
                                            onDragEnd: (_) => setState(() => _isDragging = false),
                                            child: Container(
                                              color: Colors.transparent, 
                                              child: isHovered 
                                                ? Opacity(
                                                    opacity: 0.6,
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        border: Border.all(color: AppColors.primary, width: 2),
                                                        borderRadius: BorderRadius.circular(16),
                                                      ),
                                                      child: child,
                                                    ),
                                                  )
                                                : child,
                                            ), 
                                          );
                                        },
                                      ),
                                    );
                                  }
                                )
                            ]
                          ],

                        ),
                      ),
                    ),
                    
                    const SliverPadding(padding: EdgeInsets.only(bottom: 120)),
                  ],
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

Widget _buildDragFeedback(BuildContext context, Widget child, {required Size size}) {
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
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                )
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

class _DockIcon extends StatelessWidget {
  final IconData icon;
  final bool isActive;

  const _DockIcon({required this.icon, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsService>(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: isActive
          ? BoxDecoration(
              color: AppColors.accent,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withOpacity(0.4),
                  blurRadius: 12,
                ),
              ],
            )
          : null,
      child: Icon(
        icon,
        color: isActive 
          ? Colors.black 
          : (settings.isDarkMode ? Colors.white : AppColors.textPrimary),
      ),
    );
  }
}
