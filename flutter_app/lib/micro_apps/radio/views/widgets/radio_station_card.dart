import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tackle4loss_mobile/core/theme/t4l_theme.dart';
import '../../models/radio_station.dart';
import 'package:tackle4loss_mobile/l10n/app_localizations.dart';

class RadioStationCard extends StatefulWidget {
  final RadioStation station;
  final VoidCallback onTap;
  final VoidCallback? onPlayTapped;

  const RadioStationCard({
    super.key,
    required this.station,
    required this.onTap,
    this.onPlayTapped,
  });

  @override
  State<RadioStationCard> createState() => _RadioStationCardState();
}

class _RadioStationCardState extends State<RadioStationCard> {
  int _currentImageIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startSlideshow();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
  
  void _startSlideshow() {
    final images = widget.station.slideshowImages;
    if (images != null && images.length > 1) {
      _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
        if (mounted) {
          setState(() {
            _currentImageIndex = (_currentImageIndex + 1) % images.length;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<T4LThemeColors>()!;
    final images = widget.station.slideshowImages;
    final hasSlideshow = images != null && images.isNotEmpty;
    
    // Determine current image URL
    String currentImageUrl = widget.station.imageUrl;
    if (hasSlideshow) {
       currentImageUrl = images[_currentImageIndex];
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
           BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        children: [
          // Main Content Area (Tap to Navigate)
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: widget.onTap,
              child: Row(
                children: [
                  // Image
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      bottomLeft: Radius.circular(8),
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 800),
                      child: Image.network(
                        currentImageUrl,
                        key: ValueKey(currentImageUrl), // Important for animation
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 80,
                          height: 80,
                          color: colors.background,
                          child: Icon(Icons.music_note, color: colors.textMuted),
                        ),
                      ),
                    ),
                  ),
                  
                  // Text Content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _localize(widget.station.title, context),
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: colors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _localize(widget.station.description, context),
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              color: colors.textSecondary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Play Button Area (Tap to Play)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onPlayTapped ?? widget.onTap,
            child: Padding(
              padding: const EdgeInsets.only(right: 16, left: 8, top: 16, bottom: 16), // Increased tap area
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.brand,
                  boxShadow: [
                    BoxShadow(
                      color: colors.brand.withOpacity(0.3),
                      offset: const Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _localize(String key, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (key) {
      case 'radioStationLatestDeepDivesTitle': return l10n.radioStationLatestDeepDivesTitle;
      case 'radioStationLatestDeepDivesDesc': return l10n.radioStationLatestDeepDivesDesc;
      case 'radioStationDailyBriefingTitle': return l10n.radioStationDailyBriefingTitle;
      case 'radioStationDailyBriefingDesc': return l10n.radioStationDailyBriefingDesc;
      case 'radioStationDeepDiveClassicsTitle': return l10n.radioStationDeepDiveClassicsTitle;
      case 'radioStationDeepDiveClassicsDesc': return l10n.radioStationDeepDiveClassicsDesc;
      case 'radioStationNewsTitle': return l10n.radioStationNewsTitle;
      case 'radioStationNewsDesc': return l10n.radioStationNewsDesc;
      case 'radioStationNewsCollectionTitle': return l10n.radioStationNewsCollectionTitle;
      case 'radioStationNewsCollectionDesc': return l10n.radioStationNewsCollectionDesc;
      case 'radioStationDeepDiveCollectionTitle': return "Deep Dives";
      case 'radioStationDeepDiveCollectionDesc': return "All the best stories.";
      default: return key;
    }
  }
}
