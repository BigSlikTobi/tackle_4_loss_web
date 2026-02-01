import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/team_model.dart';
import '../../theme/t4l_theme.dart';
import '../models/injury_player.dart';
import '../controllers/team_center_controller.dart';

/// Screen displaying the team's injury report grouped by status.
class TeamInjuryReportScreen extends StatefulWidget {
  final Team team;
  final TeamCenterController controller;

  const TeamInjuryReportScreen({
    super.key,
    required this.team,
    required this.controller,
  });

  @override
  State<TeamInjuryReportScreen> createState() => _TeamInjuryReportScreenState();
}

class _TeamInjuryReportScreenState extends State<TeamInjuryReportScreen> {
  @override
  void initState() {
    super.initState();

    // Load injury data when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.controller.loadInjuries(widget.team.id);
      _preloadAllImages();
    });
  }

  void _preloadAllImages() {
    _preloadImages(widget.controller.outInjuries);
    _preloadImages(widget.controller.doubtfulInjuries);
    _preloadImages(widget.controller.questionableInjuries);
  }

  void _preloadImages(List<InjuryPlayer> players) {
    if (!mounted) return;
    for (final player in players) {
      if (player.imageUrl.isNotEmpty) {
        precacheImage(CachedNetworkImageProvider(player.imageUrl), context);
      }
    }
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

                  // 2. Legend
                  _buildLegend(colors),

                  // 3. Injury Lists
                  Expanded(
                    child: Consumer<TeamCenterController>(
                      builder: (context, controller, child) {
                        if (controller.isInjuriesLoading) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        if (controller.injuriesError != null) {
                          return Center(
                            child: Text(
                              'Failed to load injuries',
                              style: TextStyle(color: colors.textMuted),
                            ),
                          );
                        }

                        final hasNoInjuries = controller.outInjuries.isEmpty &&
                            controller.doubtfulInjuries.isEmpty &&
                            controller.questionableInjuries.isEmpty;

                        if (hasNoInjuries) {
                          return Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.check_circle_outline,
                                    color: Color(0xFF22C55E), size: 48),
                                const SizedBox(height: 12),
                                Text(
                                  'No injuries reported',
                                  style: TextStyle(
                                      color: colors.textPrimary, fontSize: 16),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          children: [
                            if (controller.outInjuries.isNotEmpty)
                              _buildInjurySection('OUT', controller.outInjuries,
                                  const Color(0xFFEF4444), colors),
                            if (controller.doubtfulInjuries.isNotEmpty)
                              _buildInjurySection(
                                  'DOUBTFUL',
                                  controller.doubtfulInjuries,
                                  const Color(0xFFF59E0B),
                                  colors),
                            if (controller.questionableInjuries.isNotEmpty)
                              _buildInjurySection(
                                  'QUESTIONABLE',
                                  controller.questionableInjuries,
                                  const Color(0xFFF59E0B),
                                  colors),
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
            // Centered Logo + Title
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colors.surface.withValues(alpha: 0.2),
                    border:
                        Border.all(color: colors.border.withValues(alpha: 0.5)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Image.asset(
                      widget.team.logoUrl,
                      errorBuilder: (_, __, ___) => Icon(Icons.shield,
                          color: colors.textPrimary, size: 24),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'INJURY REPORT',
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
              top: 0,
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

  Widget _buildLegend(T4LThemeColors colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _legendItem('OUT', const Color(0xFFEF4444), colors),
          const SizedBox(width: 24),
          _legendItem('DOUBTFUL', const Color(0xFFF59E0B), colors),
          const SizedBox(width: 24),
          _legendItem('QUESTIONABLE', const Color(0xFFF59E0B), colors),
        ],
      ),
    );
  }

  Widget _legendItem(String label, Color color, T4LThemeColors colors) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: colors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildInjurySection(String title, List<InjuryPlayer> players,
      Color statusColor, T4LThemeColors colors) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: statusColor,
                    fontFamily: 'Outfit',
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${players.length} ${players.length == 1 ? 'PLAYER' : 'PLAYERS'}',
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Player Cards
          ...players
              .map((player) => _buildPlayerCard(player, statusColor, colors)),
        ],
      ),
    );
  }

  Widget _buildPlayerCard(
      InjuryPlayer player, Color statusColor, T4LThemeColors colors) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Player Image with Number Badge
            Stack(
              children: [
                CachedNetworkImage(
                  imageUrl: player.imageUrl,
                  imageBuilder: (context, imageProvider) => Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: colors.border.withValues(alpha: 0.4)),
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  placeholder: (context, url) => Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: colors.surface.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: colors.border.withValues(alpha: 0.4)),
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
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: colors.surface.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: colors.border.withValues(alpha: 0.4)),
                    ),
                    child: Icon(Icons.person,
                        color: colors.textSecondary, size: 24),
                  ),
                ),
                // Number Badge
                if (player.number.isNotEmpty)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: widget.team.primaryColor,
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(8),
                          bottomLeft: Radius.circular(12),
                        ),
                      ),
                      child: Text(
                        player.number,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(width: 12),

            // Player Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    player.name,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    player.position.toUpperCase(),
                    style: TextStyle(
                      color: widget.team.primaryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Injury Type and Participation chips
                  Row(
                    children: [
                      _buildChip(Icons.medical_services_outlined,
                          player.injuryType, colors),
                      const SizedBox(width: 8),
                      _buildChip(
                          Icons.directions_run, player.participation, colors),
                    ],
                  ),
                ],
              ),
            ),

            // Status Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: statusColor.withValues(alpha: 0.4)),
              ),
              child: Text(
                player.statusLabel,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(IconData icon, String label, T4LThemeColors colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.border.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFF22C55E), size: 12),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
