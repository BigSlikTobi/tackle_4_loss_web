import 'package:flutter/material.dart';
import '../../../../design_tokens.dart';
import '../../../core/os_shell/widgets/t4l_scaffold.dart';
import '../controllers/app_store_controller.dart';
import '../../../core/micro_app.dart';
import '../widgets/featured_card.dart';
import '../widgets/app_list_item.dart';
import '../widgets/app_info_dialog.dart';

class AppStoreScreen extends StatefulWidget {
  const AppStoreScreen({super.key});

  @override
  State<AppStoreScreen> createState() => _AppStoreScreenState();
}

class _AppStoreScreenState extends State<AppStoreScreen> {
  final AppStoreController _controller = AppStoreController();
  // Removed _allApps as we fetch specific lists now

  @override
  void initState() {
    super.initState();
    // No initialization needed for sync controller logic
  }

  void _showAppInfo(BuildContext context, MicroApp app) {
    showDialog(
      context: context,
      builder: (context) => AppInfoDialog(app: app),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Logic Delegated to Controller
    final featuredApp = _controller.getFeaturedApp();
    final otherApps = _controller.getOtherApps();

    return T4LScaffold(
      body: CustomScrollView(
        slivers: [
          // 1. Header (T4L Apps + Avatar)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   Text(
                    'T4L Apps',
                    style: AppTextStyles.display,
                  ),
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.primary,
                    child: Text('TL', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),

          // 2. Featured Section (App of the Month)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                   // Featured Card
                   AppStoreFeaturedCard(
                     category: 'App of the Month',
                     title: featuredApp.name,
                     subtitle: 'Deeply immersive reading.', // Could also be metadata
                     imagePath: featuredApp.storeImageAsset,
                     isInstalled: _controller.isInstalled(featuredApp.id),
                     onInfo: () => _showAppInfo(context, featuredApp),
                     // onAction: null - Disable install/remove for app of the month
                     onTap: () {
                       // Open Detail or Launch
                     },
                   ),
                   const SizedBox(height: 32),
                ],
              ),
            ),
          ),

          // 3. All Apps Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
              child: Row(
                children: [
                  Text(
                    'All Apps',
                    style: AppTextStyles.h2,
                  ),
                  const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                ],
              ),
            ),
          ),

          // 4. Apps List
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final app = otherApps[index];
                  final isInstalled = _controller.isInstalled(app.id);
                  final metadata = _controller.getAppMetadata(app.id);

                  return AppStoreListItem(
                    title: app.name,
                    category: metadata.category, // Dynamic Category
                    icon: app.icon,
                    iconAssetPath: app.iconAssetPath,
                    iconColor: app.themeColor,
                    isInstalled: isInstalled,
                    onTap: () {
                      _showAppInfo(context, app); // Show info/assets on tap
                    },
                    onAction: () {
                      setState(() {
                         _controller.toggleInstall(app.id);
                      });
                    },
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
