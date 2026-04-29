import 'package:flutter/material.dart';
import '../controllers/os_shell_controller.dart';
import '../widgets/app_dock.dart';
import '../widgets/t4l_scaffold.dart';
import 'package:provider/provider.dart';
import '../../services/settings_service.dart';
import '../widgets/news_feed/news_feed_widget.dart';

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
  String? _currentLanguageCode;

  @override
  void initState() {
    super.initState();
    _controller = OSShellController(context);

    // Initial load
    _loadApps();

    // Subtle pulsating animation (breathing/sway effect)
    _rotationController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    )..repeat();

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
    // Apps are managed by InstalledAppsService
  }

  @override
  Widget build(BuildContext context) {
    // Re-initialize animations on hot reload if needed
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
        bottomNavBarOverride: const AppDock(),
        body: SafeArea(
          child: Stack(
            children: [
              // 1. Fixed Header Clearance (Empty space for T4LHeader inside Scaffold)
              // Actually T4LScaffold handles the header positioning.

              // 2. Main Content Feed
              Consumer<OSShellController>(
                builder: (context, shellController, child) {
                  // Show skeleton while loading
                  if (!shellController.isPageReady) {
                    return const OSShellSkeleton();
                  }

                  return const CustomScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    slivers: [
                      // Header Clearance (Handled by T4LScaffold)
                      SliverToBoxAdapter(child: SizedBox(height: 0)),

                      // News Feed (MVP home content)
                      NewsFeedWidget(),

                      // Bottom Clearance for the Dock
                      SliverPadding(
                        padding: EdgeInsets.only(bottom: 140),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OSShellSkeleton extends StatelessWidget {
  const OSShellSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Note: T4LScaffold handles header clearance automatically
        Expanded(
          child: ListView.builder(
            itemCount: 4,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemBuilder: (context, index) => const Padding(
              padding: EdgeInsets.only(bottom: 24),
              child: ShimmerBox(height: 200, borderRadius: 24),
            ),
          ),
        ),
      ],
    );
  }
}
