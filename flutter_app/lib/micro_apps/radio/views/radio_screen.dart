import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import '../../../../core/os_shell/widgets/t4l_scaffold.dart';
import '../../../../core/services/audio_player_service.dart';
import '../../../design_tokens.dart';
import 'package:tackle4loss_mobile/core/theme/t4l_theme.dart';
import '../controllers/radio_controller.dart';
import 'widgets/radio_station_card.dart';
import 'news_collection_screen.dart';
import 'deep_dive_collection_screen.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/settings_service.dart';
import 'package:tackle4loss_mobile/l10n/app_localizations.dart';

class RadioScreen extends StatefulWidget {
  const RadioScreen({super.key});

  @override
  State<RadioScreen> createState() => _RadioScreenState();
}

class _RadioScreenState extends State<RadioScreen> {
  late RadioController _controller;
  bool _isInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      _controller = Provider.of<RadioController>(context);
      _isInit = true;
    }
  }

  @override
  void dispose() {
    // We don't dispose the controller here anymore because it's provided globally
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _controller = context.watch<RadioController>();
    final colors = Theme.of(context).extension<T4LThemeColors>()!;
    final l10n = AppLocalizations.of(context)!;

    return T4LScaffold(
      title: l10n.radioTitle,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Space (Handled by T4LScaffold, but we need spacing for it if it's floating)
            // T4LScaffold uses a Stack for header, so body goes BEHIND it.
            // We need a top spacer.
            const SizedBox(height: 100), // Approx header height

            // Categories
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: _controller.categories.length,
                itemBuilder: (context, index) {
                  final category = _controller.categories[index];
                  final isSelected = category.id == _controller.selectedCategoryId;
                  
                  // Translate Category Label
                  final translatedLabel = _getCategoryLabel(category.label, l10n);
                  
                  return GestureDetector(
                    onTap: () => _controller.selectCategory(category.id),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? colors.brand : colors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? colors.brandLight : colors.border.withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        translatedLabel,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? Colors.white : colors.textSecondary,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            // Station List
            // Station List
             Expanded(
              child: _controller.isLoading
                  ? Center(child: CircularProgressIndicator(color: colors.brand))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
                      itemCount: _controller.stations.length,
                      itemBuilder: (context, index) {
                        final station = _controller.stations[index];
                        return RadioStationCard(
                          station: station,
                          onTap: () {
                            if (station.id == 'news') {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ChangeNotifierProvider.value(
                                    value: _controller,
                                    child: const NewsCollectionScreen(),
                                  ),
                                ),
                              );
                            } else if (station.id == 'deep_dive_collection') {
                               Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ChangeNotifierProvider.value(
                                    value: _controller,
                                    child: const DeepDiveCollectionScreen(),
                                  ),
                                ),
                              );
                            } else {
                              final settings = Provider.of<SettingsService>(context, listen: false);
                              _controller.playStation(station, languageCode: settings.locale.languageCode);
                            }
                          },
                          onPlayTapped: () {
                            final settings = Provider.of<SettingsService>(context, listen: false);
                            
                            if (station.id == 'news') {
                              _controller.playStation(_controller.dailyBriefingStation, languageCode: settings.locale.languageCode);
                            } else if (station.id == 'deep_dive_collection') {
                              if (_controller.allDeepDives.isNotEmpty) {
                                _controller.playStation(_controller.allDeepDives.first, languageCode: settings.locale.languageCode);
                              }
                            } else {
                              // Regular stations are started via the card tap (onTap); the explicit play button is only used for collection stations.
                            }
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _getCategoryLabel(String key, AppLocalizations l10n) {
    switch (key) {
      case 'radioCategoryAll': return l10n.radioCategoryAll;
      case 'radioCategoryDeepDive': return l10n.radioCategoryDeepDive;
      case 'radioCategoryNews': return l10n.radioCategoryNews;
      default: return key;
    }
  }
}
