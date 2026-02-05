import 'package:flutter/material.dart';
import '../../../core/os_shell/widgets/t4l_scaffold.dart';
import '../../../core/services/navigation_service.dart';
import '../../../core/app_category.dart';
import '../controllers/app_hub_controller.dart';
import '../../../core/micro_app.dart';
import '../widgets/app_hub_quick_view.dart';
import '../widgets/app_hub_category_section.dart';
import '../../../../l10n/app_localizations.dart';

class AppHubScreen extends StatefulWidget {
  const AppHubScreen({super.key});

  @override
  State<AppHubScreen> createState() => _AppHubScreenState();
}

class _AppHubScreenState extends State<AppHubScreen> {
  final AppHubController _controller = AppHubController();

  void _openApp(BuildContext context, MicroApp app) {
    NavigationService().openApp(context, app);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final quickViewApps = _controller.getQuickViewApps();
    final appsByCategory = _controller.getAppsByCategories();

    // Define category display order
    const categoryOrder = [
      AppCategory.games,
      AppCategory.gameData,
      AppCategory.news,
      AppCategory.content,
    ];

    return T4LScaffold(
      title: l10n.appHubTitle,
      body: CustomScrollView(
        slivers: [
          // 1. Quick View / Highlights Section
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.zero, // T4LScaffold provides header clearance
              child: Column(
                children: [
                  AppHubQuickView(
                    promotedApps: quickViewApps,
                    onAppTap: (app) => _openApp(context, app),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // 2. Category Sections
          ...categoryOrder.map((category) {
            final apps = appsByCategory[category] ?? [];
            if (apps.isEmpty) {
              return const SliverToBoxAdapter(child: SizedBox.shrink());
            }

            return SliverToBoxAdapter(
              child: AppHubCategorySection(
                category: category,
                apps: apps,
                onAppTap: (app) => _openApp(context, app),
              ),
            );
          }),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}
