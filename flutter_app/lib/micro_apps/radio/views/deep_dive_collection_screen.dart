import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tackle4loss_mobile/core/os_shell/widgets/t4l_scaffold.dart';
import 'package:tackle4loss_mobile/core/theme/t4l_theme.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:tackle4loss_mobile/core/services/settings_service.dart';
import 'package:tackle4loss_mobile/l10n/app_localizations.dart';
import '../controllers/radio_controller.dart';
import '../models/radio_station.dart';

class DeepDiveCollectionScreen extends StatelessWidget {
  const DeepDiveCollectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<T4LThemeColors>()!;
    final l10n = AppLocalizations.of(context)!;
    final controller = Provider.of<RadioController>(context);
    final stations = controller.allDeepDives;

    return T4LScaffold(
      title: l10n.radioCategoryDeepDive, // Or a specific title for the collection "Deep Dives"
      body: stations.isEmpty
          ? Center(
              child: Text(
                "Check back soon for new stories.", // Using generic friendly text as requested
                style: TextStyle(color: colors.textSecondary),
              ),
            )
          : CustomScrollView(
              slivers: [
                // Header Spacer to avoid overlap with T4LScaffold title
                const SliverToBoxAdapter(
                  child: SizedBox(height: 124),
                ),
                
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  sliver: SliverMasonryGrid.count(
                    crossAxisCount: 2,
                    childCount: stations.length,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    itemBuilder: (context, index) {
                      final station = stations[index];
                      // Use similar aspect ratio logic as news for visual variety
                      final double ratio = (index % 3 == 0) ? 1.0 : (index % 3 == 1) ? 0.75 : 1.25;
                      return _buildDeepDiveCard(context, station, controller, ratio);
                    },
                  ),
                ),

                const SliverToBoxAdapter(
                  child: SizedBox(height: 100),
                ),
              ],
            ),
    );
  }

  Widget _buildDeepDiveCard(BuildContext context, RadioStation station, RadioController controller, double aspectRatio) {
    final colors = Theme.of(context).extension<T4LThemeColors>()!;
    final l10n = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: () {
        final settings = Provider.of<SettingsService>(context, listen: false);
        controller.playStation(station, languageCode: settings.locale.languageCode);
        
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
             content: Text(l10n.radioPlaying(station.title)),
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
                    station.imageUrl,
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
          
          Text(
            station.title,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          
          const SizedBox(height: 4),

          Text(
            station.description,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: colors.textSecondary,
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
