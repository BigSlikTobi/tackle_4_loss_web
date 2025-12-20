import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _controller = OSShellController(context);
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
  void dispose() {
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

    return T4LScaffold(
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
            final app = InstalledAppsService().gridApps[fromIndex];
            if (app != null) {
               InstalledAppsService().uninstall(app.id);
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
            ListenableBuilder(
              listenable: InstalledAppsService(),
              builder: (context, child) {
                final gridApps = InstalledAppsService().gridApps; // Sparse list (16)
                final installedApps = gridApps.whereType<MicroApp>().toList(); // Dense list for logic
                
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
                         ),
                       ),
    
                    // 2. Padding/Spacer between Hero and Grid
                    const SliverPadding(padding: EdgeInsets.only(top: 24)),
    
                    // 3. App Grid (Fixed 16 Slots)
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      sliver: SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4, 
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 24, // increased vertical spacing if needed, but 24 is fine
                          childAspectRatio: 0.70, // More vertical space for text
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final app = gridApps[index];
                            
                            return DragTarget<int>(
                              onWillAccept: (data) => true,
                              onAccept: (fromIndex) {
                                InstalledAppsService().moveApp(fromIndex, index);
                              },
                              builder: (context, candidateData, rejectedData) {
                                final isCandidate = candidateData.isNotEmpty;
                                
                                // Empty Slot
                                if (app == null) {
                                  return Container(
                                    decoration: isCandidate ? BoxDecoration(
                                      border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
                                      borderRadius: BorderRadius.circular(18),
                                      color: Colors.white.withOpacity(0.1),
                                    ) : null,
                                  );
                                }
                                
                                // Occupied Slot
                                return LongPressDraggable<int>(
                                  data: index,
                                  onDragStarted: () => setState(() => _isDragging = true),
                                  onDragEnd: (_) => setState(() => _isDragging = false),
                                  onDraggableCanceled: (_, __) => setState(() => _isDragging = false),
                                  feedback: Opacity(
                                    opacity: 0.75, 
                                    child: SizedBox(
                                      width: 80, 
                                      height: 80, 
                                      child: Material(
                                        color: Colors.transparent,
                                        child: OSShellAppItem(
                                          app: app, 
                                          onTap: (){} // Disable tap while dragging
                                        ),
                                      ),
                                    ),
                                  ),
                                  childWhenDragging: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                  ),
                                  child: isCandidate 
                                      // Visual feedback if we are dragging ONTO this app (Swap target)
                                      ? Opacity(
                                          opacity: 0.5,
                                          child: OSShellAppItem(
                                            app: app, 
                                            onTap: () => NavigationService().openApp(context, app)
                                          ),
                                        )
                                      : OSShellAppItem(
                                          app: app, 
                                          onTap: () => NavigationService().openApp(context, app)
                                        ),
                                );
                              },
                            );
                          },
                          childCount: 16, // Always 16 slots
                        ),
                      ),
                    ),
    
                    // 4. Bottom Padding for Floating Nav Bar
                    const SliverPadding(padding: EdgeInsets.only(bottom: 120)),
                  ],
                );
              },
            ),
          ],
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
