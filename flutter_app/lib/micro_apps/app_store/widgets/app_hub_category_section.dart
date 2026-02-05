import 'package:flutter/material.dart';
import 'package:tackle4loss_mobile/design_tokens.dart';
import '../../../../core/theme/t4l_theme.dart';
import '../../../core/micro_app.dart';
import '../../../core/app_category.dart';
import '../../../../l10n/app_localizations.dart';
import 'app_hub_compact_card.dart';

/// A category section widget for the App Hub with horizontal scrolling cards.
class AppHubCategorySection extends StatelessWidget {
  final AppCategory category;
  final List<MicroApp> apps;
  final void Function(MicroApp app) onAppTap;

  const AppHubCategorySection({
    super.key,
    required this.category,
    required this.apps,
    required this.onAppTap,
  });

  IconData _getCategoryIcon() {
    switch (category) {
      case AppCategory.games:
        return Icons.sports_esports;
      case AppCategory.gameData:
        return Icons.bar_chart;
      case AppCategory.content:
        return Icons.article;
      case AppCategory.news:
        return Icons.newspaper;
      case AppCategory.system:
        return Icons.settings;
    }
  }

  String _getCategoryLabel(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (category) {
      case AppCategory.games:
        return l10n.categoryGames;
      case AppCategory.gameData:
        return l10n.categoryGameData;
      case AppCategory.content:
        return l10n.categoryContent;
      case AppCategory.news:
        return l10n.categoryNews;
      case AppCategory.system:
        return 'System';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<T4LThemeColors>()!;

    // Don't render if no apps in this category
    if (apps.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Row(
            children: [
              // Category Icon
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: colors.brand.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getCategoryIcon(),
                  color: colors.brand,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),

              // Category Title
              Text(
                _getCategoryLabel(context),
                style: AppTextStyles.h3.copyWith(
                  color: colors.textPrimary,
                ),
              ),

              const Spacer(),

              // See All (future enhancement)
              // TextButton(
              //   onPressed: onSeeAll,
              //   child: Text('See All'),
              // ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Horizontal App List
        SizedBox(
          height: 160,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: apps.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final app = apps[index];
              return AppHubCompactCard(
                app: app,
                onTap: () => onAppTap(app),
              );
            },
          ),
        ),

        const SizedBox(height: 24),
      ],
    );
  }
}
