import 'package:flutter/material.dart';
import '../../../../design_tokens.dart';
import '../../../core/os_shell/widgets/t4l_scaffold.dart';
import '../../../core/services/navigation_service.dart';
import '../../../core/app_category.dart';
import '../controllers/app_hub_controller.dart';
import '../../../core/micro_app.dart';
import '../widgets/app_hub_featured_card.dart';
import '../widgets/app_hub_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/theme/t4l_theme.dart';

class AppHubScreen extends StatefulWidget {
  const AppHubScreen({super.key});

  @override
  State<AppHubScreen> createState() => _AppHubScreenState();
}

class _AppHubScreenState extends State<AppHubScreen> {
  final AppHubController _controller = AppHubController();
  AppCategory? _selectedCategory;

  String _getCategoryLabel(BuildContext context, AppCategory category) {
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

  void _openApp(BuildContext context, MicroApp app) {
    NavigationService().openApp(context, app);
  }

  String _getFeaturedLabel(BuildContext context, MicroApp app) {
    final l10n = AppLocalizations.of(context)!;
    switch (app.category) {
      case AppCategory.games:
        return l10n.appHubFeaturedGames;
      case AppCategory.content:
        return l10n.appHubFeaturedContent;
      case AppCategory.gameData:
        return l10n.appHubFeaturedGameData;
      case AppCategory.news:
        return l10n.appHubFeaturedNews;
      default:
        return l10n.appHubFeaturedTitle;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<T4LThemeColors>()!;
    final l10n = AppLocalizations.of(context)!;

    final featuredApp = _controller.getFeaturedApp();
    final otherApps = _controller.getOtherApps(category: _selectedCategory);
    final categories = _controller.getCategories();

    return T4LScaffold(
      title: l10n.appHubTitle,
      body: CustomScrollView(
        slivers: [
          // 1. Featured Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 130, left: 24, right: 24),
              child: Column(
                children: [
                  AppHubFeaturedCard(
                    category: _getFeaturedLabel(context, featuredApp),
                    title: featuredApp.name,
                    subtitle: featuredApp.description,
                    imagePath: featuredApp.storeImageAsset,
                    onTap: () => _openApp(context, featuredApp),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // 2. Category Chips
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    // "All" chip
                    _CategoryChip(
                      label: l10n.appHubAllApps,
                      isSelected: _selectedCategory == null,
                      onTap: () => setState(() => _selectedCategory = null),
                    ),
                    const SizedBox(width: 8),
                    // Category chips
                    ...categories.map((category) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _CategoryChip(
                            label: _getCategoryLabel(context, category),
                            isSelected: _selectedCategory == category,
                            onTap: () =>
                                setState(() => _selectedCategory = category),
                          ),
                        )),
                  ],
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // 3. All Apps Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
              child: Text(
                _selectedCategory == null
                    ? l10n.appHubAllApps
                    : _getCategoryLabel(context, _selectedCategory!),
                style: AppTextStyles.h2.copyWith(color: colors.textPrimary),
              ),
            ),
          ),

          // 4. Apps Grid
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.95,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final app = otherApps[index];
                  return AppHubCard(
                    app: app,
                    onOpen: () => _openApp(context, app),
                  );
                },
                childCount: otherApps.length,
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<T4LThemeColors>()!;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? colors.brand : colors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? colors.brand : colors.border.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : colors.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
