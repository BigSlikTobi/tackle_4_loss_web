import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/team_model.dart';
import '../../theme/t4l_theme.dart';
import '../models/depth_chart_player.dart';
import '../controllers/team_center_controller.dart';

/// Screen displaying the team's depth chart organized by position groups.
class TeamDepthChartScreen extends StatefulWidget {
  final Team team;
  final TeamCenterController controller;

  const TeamDepthChartScreen({
    super.key,
    required this.team,
    required this.controller,
  });

  @override
  State<TeamDepthChartScreen> createState() => _TeamDepthChartScreenState();
}

class _TeamDepthChartScreenState extends State<TeamDepthChartScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ['OFFENSE', 'DEFENSE', 'SPECIAL'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);

    // Load depth chart data when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.controller.loadDepthChart(widget.team.id);

      // Preload images for all tabs after data loads
      _preloadAllImages();
    });
  }

  void _preloadAllImages() {
    _preloadPositionGroupImages(widget.controller.offenseDepthChart);
    _preloadPositionGroupImages(widget.controller.defenseDepthChart);
    _preloadPositionGroupImages(widget.controller.specialTeamsDepthChart);
  }

  void _preloadPositionGroupImages(
      Map<String, List<DepthChartPlayer>> positionGroups) {
    if (!mounted) return;
    for (final players in positionGroups.values) {
      for (final player in players) {
        if (player.imageUrl.isNotEmpty) {
          precacheImage(CachedNetworkImageProvider(player.imageUrl), context);
        }
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<T4LThemeColors>()!;

    return ChangeNotifierProvider.value(
      value: widget.controller,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            // Background Blur
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(color: Colors.transparent),
              ),
            ),

            // Gradient overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      widget.team.primaryColor.withValues(alpha: 0.15),
                      colors.background.withValues(alpha: 0.0),
                    ],
                    stops: const [0.0, 0.4],
                  ),
                ),
              ),
            ),

            SafeArea(
              child: Column(
                children: [
                  // 1. Header
                  _buildHeader(colors),

                  // 2. Tabs
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    child: _buildSegmentedControl(colors),
                  ),

                  // 3. Tab Bar View
                  Expanded(
                    child: Consumer<TeamCenterController>(
                      builder: (context, controller, child) {
                        if (controller.isDepthChartLoading) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        if (controller.depthChartError != null) {
                          return Center(
                            child: Text(
                              'Failed to load depth chart',
                              style: TextStyle(color: colors.textMuted),
                            ),
                          );
                        }

                        return TabBarView(
                          controller: _tabController,
                          children: [
                            _buildDepthChartList(
                                controller.offenseDepthChart, colors),
                            _buildDepthChartList(
                                controller.defenseDepthChart, colors),
                            _buildDepthChartList(
                                controller.specialTeamsDepthChart, colors),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(T4LThemeColors colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: SizedBox(
        width: double.infinity,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Centered Title
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colors.surface.withValues(alpha: 0.2),
                    border:
                        Border.all(color: colors.border.withValues(alpha: 0.5)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: Image.asset(
                      widget.team.logoUrl,
                      errorBuilder: (_, __, ___) => Icon(Icons.shield,
                          color: colors.textPrimary, size: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'TEAM DEPTH CHART',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontWeight: FontWeight.w900,
                    fontStyle: FontStyle.italic,
                    fontSize: 20,
                    color: colors.textPrimary.withValues(alpha: 0.9),
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),

            // Close Button
            Positioned(
              right: 0,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colors.surface.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close, color: colors.textPrimary, size: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentedControl(T4LThemeColors colors) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.border.withValues(alpha: 0.3)),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: widget.team.primaryColor,
          borderRadius: BorderRadius.circular(24),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: colors.textSecondary,
        labelStyle: const TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        tabs: _tabs.map((t) => Tab(text: t)).toList(),
      ),
    );
  }

  Widget _buildDepthChartList(
      Map<String, List<DepthChartPlayer>> positionGroups,
      T4LThemeColors colors) {
    if (positionGroups.isEmpty) {
      return Center(
        child: Text(
          'No depth chart data available',
          style: TextStyle(color: colors.textMuted),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: positionGroups.length,
      itemBuilder: (context, index) {
        final entry = positionGroups.entries.elementAt(index);
        final groupName = entry.key;
        final players = entry.value;

        return _buildPositionGroup(groupName, players, colors);
      },
    );
  }

  Widget _buildPositionGroup(
      String groupName, List<DepthChartPlayer> players, T4LThemeColors colors) {
    final activeCount = players.length;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Position Group Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  groupName,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontFamily: 'Outfit',
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    letterSpacing: 0.5,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B4D3E).withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: const Color(0xFF22C55E).withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    '$activeCount ACTIVE',
                    style: const TextStyle(
                      color: Color(0xFF22C55E),
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Player List
          ...players.map((player) => _buildPlayerRow(player, colors)),
        ],
      ),
    );
  }

  Widget _buildPlayerRow(DepthChartPlayer player, T4LThemeColors colors) {
    final isStarter = player.isStarter;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(
            color: isStarter ? const Color(0xFF22C55E) : Colors.transparent,
            width: 3,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            // Player Image
            CachedNetworkImage(
              imageUrl: player.imageUrl,
              imageBuilder: (context, imageProvider) => Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isStarter
                        ? widget.team.primaryColor
                        : colors.border.withValues(alpha: 0.4),
                    width: isStarter ? 2 : 1,
                  ),
                  image: DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              placeholder: (context, url) => Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: colors.surface.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(10),
                  border:
                      Border.all(color: colors.border.withValues(alpha: 0.4)),
                ),
                child: Center(
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: widget.team.primaryColor),
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: colors.surface.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(10),
                  border:
                      Border.all(color: colors.border.withValues(alpha: 0.4)),
                ),
                child:
                    Icon(Icons.person, color: colors.textSecondary, size: 20),
              ),
            ),

            const SizedBox(width: 12),

            // Player Name & Number
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          player.name,
                          style: TextStyle(
                            color: colors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (player.isHot) ...[
                        const SizedBox(width: 6),
                        const Icon(Icons.bolt,
                            color: Color(0xFF22C55E), size: 16),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '#${player.number}',
                    style: TextStyle(
                      color: isStarter
                          ? widget.team.primaryColor
                          : colors.textMuted,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),

            // Quest Badge (if applicable)
            if (player.hasQuest)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B4D3E).withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.workspace_premium,
                        color: Color(0xFF22C55E), size: 12),
                    SizedBox(width: 4),
                    Text(
                      'QUEST.',
                      style: TextStyle(
                        color: Color(0xFF22C55E),
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),

            // Navigation Chevron
            Icon(
              Icons.chevron_right,
              color: colors.textMuted.withValues(alpha: 0.5),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
