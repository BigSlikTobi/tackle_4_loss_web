import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/team_model.dart';
import '../../theme/t4l_theme.dart';
import '../models/roster_player.dart';
import '../controllers/team_center_controller.dart';

class TeamRosterScreen extends StatefulWidget {
  final Team team;
  final TeamCenterController controller;

  const TeamRosterScreen({
    super.key,
    required this.team,
    required this.controller,
  });

  @override
  State<TeamRosterScreen> createState() => _TeamRosterScreenState();
}

class _TeamRosterScreenState extends State<TeamRosterScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ['OFFENSE', 'DEFENSE', 'SPECIAL TEAMS'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this, initialIndex: 1);
    
    // Load roster data when screen opens (safe due to controller check)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.controller.loadTeamRoster(widget.team.id);
      
      // Preload Offense and Special Teams since Defense was preloaded in Overlay
      _preloadImages(widget.controller.offenseRoster);
      _preloadImages(widget.controller.specialTeamsRoster);
    });
  }

  void _preloadImages(List<RosterPlayer> players) {
    if (!mounted) return;
    for (final player in players) {
      precacheImage(CachedNetworkImageProvider(player.imageUrl), context);
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ChangeNotifierProvider.value(
      value: widget.controller,
      child: Scaffold(
        backgroundColor: Colors.transparent, // Transparent for blur to work
        body: Stack(
          children: [
          // Background Blur (same as TeamCenterOverlay)
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
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: _buildSegmentedControl(colors, isDark),
                ),

                // 3. Tab Bar View (Lists)
                Expanded(
                  child: Consumer<TeamCenterController>(
                    builder: (context, controller, child) {
                      if (controller.isRosterLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      
                      if (controller.rosterError != null) {
                         return Center(
                           child: Text(
                             'Failed to load roster',
                               style: TextStyle(color: colors.textMuted),
                           ),
                         );
                      }

                      return TabBarView(
                        controller: _tabController,
                        children: [
                          _buildRosterList(controller.offenseRoster, colors),
                          _buildRosterList(controller.defenseRoster, colors),
                          _buildRosterList(controller.specialTeamsRoster, colors),
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
    ));
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
                    border: Border.all(color: colors.border.withValues(alpha: 0.5)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: Image.asset(
                      widget.team.logoUrl,
                      errorBuilder: (_, __, ___) => Icon(Icons.shield, color: colors.textPrimary, size: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'TEAM ROSTER',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontWeight: FontWeight.w900,
                    fontStyle: FontStyle.italic,
                    fontSize: 22,
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

  Widget _buildSegmentedControl(T4LThemeColors colors, bool isDark) {
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
        labelColor: Colors.white, // Always white on brand-colored pill
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

  Widget _buildRosterList(List<RosterPlayer> players, T4LThemeColors colors) {
    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: players.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final player = players[index];
        return _buildPlayerCard(player, colors);
      },
    );
  }

  Widget _buildPlayerCard(RosterPlayer player, T4LThemeColors colors) {
    // Split name for formatting if possible
    final names = player.name.split(' ');
    final firstName = names.isNotEmpty ? names.first : '';
    final surname = names.length > 1 ? names.sublist(1).join(' ') : '';
    final displayName = names.length > 1 ? '$firstName\n$surname' : player.name;

    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.95), // More opaque for visibility
        borderRadius: BorderRadius.circular(36),
        border: Border.all(color: colors.border.withValues(alpha: 0.4)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          // Avatar with Caching
          CachedNetworkImage(
            imageUrl: player.imageUrl,
            imageBuilder: (context, imageProvider) => Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: imageProvider,
                  fit: BoxFit.cover,
                ),
                border: Border.all(color: colors.border.withValues(alpha: 0.5)),
              ),
            ),
            placeholder: (context, url) => Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.surface.withValues(alpha: 0.5),
                border: Border.all(color: colors.border.withValues(alpha: 0.5)),
              ),
              child: Center(
                child: SizedBox(
                   width: 20, 
                   height: 20, 
                   child: CircularProgressIndicator(strokeWidth: 2, color: widget.team.primaryColor),
                ),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.surface,
                border: Border.all(color: colors.border.withValues(alpha: 0.5)),
              ),
              child: Icon(Icons.person, color: colors.textSecondary),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Name & Number
          Expanded(
            flex: 4,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    height: 1.1,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  player.number,
                  style: TextStyle(
                    color: widget.team.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          
          // Position
          Expanded(
            flex: 1,
            child: Center(
              child: Container(
                constraints: const BoxConstraints(minWidth: 32),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                decoration: BoxDecoration(
                  color: colors.surface.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  player.position,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  softWrap: false,
                ),
              ),
            ),
          ),
          
          // Experience
          Expanded(
            flex: 1,
            child: Text(
              player.experience,
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          // College
          Expanded(
            flex: 2,
            child: Text(
              player.college.toUpperCase(),
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          
          const SizedBox(width: 16),
        ],
      ),
    );
  }
}
