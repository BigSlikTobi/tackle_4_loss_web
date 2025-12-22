import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tackle4loss_mobile/core/os_shell/widgets/t4l_scaffold.dart';
import 'package:tackle4loss_mobile/core/theme/t4l_theme.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:tackle4loss_mobile/core/services/settings_service.dart';
import 'package:tackle4loss_mobile/l10n/app_localizations.dart';
import '../controllers/radio_controller.dart';
import '../models/radio_station.dart';
import 'widgets/radio_station_card.dart';

class NewsCollectionScreen extends StatefulWidget {
  const NewsCollectionScreen({super.key});

  @override
  State<NewsCollectionScreen> createState() => _NewsCollectionScreenState();
}

class _NewsCollectionScreenState extends State<NewsCollectionScreen> {
  late Future<List<Map<String, String>>> _newsFuture;
  
  // Filtering state
  String? _selectedTeamName; // Filter by team name (acting as ID for now)

  @override
  void initState() {
    super.initState();
    final controller = Provider.of<RadioController>(context, listen: false);
    final settings = Provider.of<SettingsService>(context, listen: false);
    _newsFuture = controller.fetchNewsTracks(settings.locale.languageCode);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<T4LThemeColors>()!;
    final l10n = AppLocalizations.of(context)!;
    final controller = Provider.of<RadioController>(context);

    return T4LScaffold(
      title: l10n.radioStationNewsCollectionTitle,
      body: FutureBuilder<List<Map<String, String>>>(
        future: _newsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: colors.brand));
          }
          
          if (snapshot.hasError) {
             return Center(
               child: Text(
                 "Failed to load news collection.", 
                 style: TextStyle(color: colors.textSecondary)
               )
             );
          }

          final allTracks = snapshot.data ?? [];
          
          if (allTracks.isEmpty) {
            return Center(
               child: Text(
                 "No news updates available.", 
                 style: TextStyle(color: colors.textSecondary)
               )
             );
          }

          // 1. Extract Unique Teams for Filter
          final Map<String, String> teams = {};
          for (var track in allTracks) {
            final name = track['teamName'];
            final logo = track['teamLogoUrl'];
            if (name != null && name.isNotEmpty) {
              teams[name] = logo ?? '';
            }
          }

          // 2. Filter Tracks
          final displayedTracks = _selectedTeamName == null 
              ? allTracks 
              : allTracks.where((t) => t['teamName'] == _selectedTeamName).toList();


          return CustomScrollView(
            slivers: [
              // Header & Daily Briefing Card
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    // Header Spacer to avoid overlap with T4LScaffold title
                    const SizedBox(height: 124),

                    // Daily Briefing Card
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: RadioStationCard(
                        station: controller.dailyBriefingStation,
                        onTap: () {
                          final settings = Provider.of<SettingsService>(context, listen: false);
                          controller.playStation(
                            controller.dailyBriefingStation, 
                            languageCode: settings.locale.languageCode
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Filter Header with Dropdown Filter
                    if (teams.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Row(
                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                           children: [
                             Expanded(
                               child: Text(
                                 _selectedTeamName != null ? l10n.radioCollectionTeamNews : l10n.radioCollectionLatestUpdates,
                                 style: TextStyle(
                                   color: colors.textPrimary,
                                   fontSize: 18,
                                   fontWeight: FontWeight.bold,
                                   fontFamily: 'Inter',
                                 ),
                                 maxLines: 1,
                                 overflow: TextOverflow.ellipsis,
                               ),
                             ),
                             const SizedBox(width: 8),
                             
                             Container(
                               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                               decoration: BoxDecoration(
                                 color: colors.surface,
                                 borderRadius: BorderRadius.circular(20),
                                 border: Border.all(color: colors.border.withOpacity(0.3)),
                               ),
                               child: DropdownButtonHideUnderline(
                                 child: DropdownButton<String>(
                                   value: _selectedTeamName, // null is "All"
                                   hint: Row(
                                     children: [
                                       Text(l10n.radioCollectionAllTeams, style: TextStyle(color: colors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
                                     ],
                                   ),
                                   icon: Padding(
                                     padding: const EdgeInsets.only(left: 8.0),
                                     child: Icon(Icons.filter_list_rounded, color: colors.brand, size: 20),
                                   ),
                                   dropdownColor: colors.surface,
                                   borderRadius: BorderRadius.circular(16),
                                   items: [
                                     // "All" Item
                                     DropdownMenuItem<String>(
                                       value: null,
                                       child: Row(
                                         children: [
                                           Icon(Icons.public, size: 18, color: colors.textSecondary),
                                           const SizedBox(width: 8),
                                           Text(l10n.radioCollectionAllTeams, style: TextStyle(color: colors.textPrimary, fontSize: 13)),
                                         ],
                                       ),
                                     ),
                                     // Team Items
                                     ...teams.entries.map((entry) {
                                       return DropdownMenuItem<String>(
                                         value: entry.key,
                                         child: Row(
                                           mainAxisSize: MainAxisSize.min,
                                           children: [
                                             if (entry.value.isNotEmpty)
                                               Image.network(entry.value, width: 20, height: 20, errorBuilder: (c,e,s)=>const SizedBox(width:20)),
                                             const SizedBox(width: 8),
                                             Text(
                                               entry.key, 
                                               style: TextStyle(color: colors.textPrimary, fontSize: 13),
                                               overflow: TextOverflow.ellipsis,
                                              ),
                                           ],
                                         ),
                                       );
                                     }).toList(),
                                   ],
                                   onChanged: (value) {
                                     setState(() {
                                       _selectedTeamName = value;
                                     });
                                   },
                                 ),
                               ),
                             ),
                           ],
                        ),
                      ),
                    
                    if (teams.isEmpty) const SizedBox(height: 24), // Spacer if no filter (loading/empty)

                    const SizedBox(height: 4),
                  ],
                ),
              ),

              // Masonry Grid
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                sliver: SliverMasonryGrid.count(
                  crossAxisCount: 2,
                  childCount: displayedTracks.length,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  itemBuilder: (context, index) {
                    final track = displayedTracks[index];
                    final double ratio = (index % 3 == 0) ? 1.0 : (index % 3 == 1) ? 0.75 : 1.25;
                    return _buildNewsCard(context, track, controller, ratio);
                  },
                ),
              ),
              
              // Bottom Spacer
              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNewsCard(BuildContext context, Map<String, String> track, RadioController controller, double aspectRatio) {
    final colors = Theme.of(context).extension<T4LThemeColors>()!;
    final l10n = AppLocalizations.of(context)!;
    
    return GestureDetector(
      onTap: () {
        controller.playTrack(track);
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
             content: Text(l10n.radioPlaying(track['title'] ?? '')),
             backgroundColor: colors.surface,
             duration: const Duration(seconds: 1),
           )
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                AspectRatio(
                  aspectRatio: aspectRatio,
                  child: Image.network(
                    track['imageUrl']!,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Container(color: colors.surface),
                  ),
                ),
                // Gradient Overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.3),
                          Colors.black.withOpacity(0.7),
                        ],
                        stops: const [0.6, 0.8, 1.0],
                      ),
                    ),
                  ),
                ),
                // Play Button (Small, floating)
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colors.brand.withOpacity(0.9), // Glassy brand
                      shape: BoxShape.circle,
                      boxShadow: [
                         BoxShadow(
                           color: Colors.black.withOpacity(0.3),
                           blurRadius: 4,
                         ),
                      ],
                    ),
                    child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Minimal Text Block
          if (track['teamName'] != null && track['teamName']!.isNotEmpty)
            Text(
              track['teamName']!.toUpperCase(),
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: colors.brandLight,
                letterSpacing: 0.8,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            
          const SizedBox(height: 4),
          
          Text(
            track['title']!,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
              height: 1.3,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
