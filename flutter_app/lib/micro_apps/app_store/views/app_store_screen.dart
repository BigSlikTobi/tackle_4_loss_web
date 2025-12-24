import 'package:flutter/material.dart';
import '../../../../design_tokens.dart';
import '../../../core/os_shell/widgets/t4l_scaffold.dart';
import '../controllers/app_store_controller.dart';
import '../../../core/micro_app.dart';
import '../widgets/featured_card.dart';
import '../widgets/app_list_item.dart';
import '../widgets/app_info_dialog.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/theme/t4l_theme.dart';

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

  void _showInstallOptions(BuildContext context, MicroApp app) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text('Install ${app.name}'),
        children: [
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _controller.toggleInstall(app.id, asWidget: false);
              });
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                   Icon(Icons.app_shortcut, size: 24),
                   SizedBox(width: 12),
                   Text('Standard Icon', style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ),
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                 _controller.toggleInstall(app.id, asWidget: true);
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                   Icon(Icons.widgets, size: 24, color: AppColors.accent),
                   const SizedBox(width: 12),
                   Text('Home Screen Widget (${app.widgetSize.width.toInt()}x${app.widgetSize.height.toInt()})',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Logic Delegated to Controller
    final colors = Theme.of(context).extension<T4LThemeColors>()!;
    final l10n = AppLocalizations.of(context)!;
    
    final featuredApp = _controller.getFeaturedApp();
    final otherApps = _controller.getOtherApps();

    return T4LScaffold(
      title: l10n.appStoreTitle,
      body: CustomScrollView(
        slivers: [
          // 1. Featured Section (App of the Month)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 130, left: 24, right: 24), // Added top padding for header
              child: Column(



                children: [
                   // Featured Card
                   AppStoreFeaturedCard(
                     category: l10n.appStoreFeaturedTitle,
                     title: featuredApp.name,
                     subtitle: l10n.appStoreFeaturedSubtitle,
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
                    l10n.appStoreAllApps,
                    style: AppTextStyles.h2.copyWith(color: colors.textPrimary),
                  ),
                  Icon(Icons.chevron_right, color: colors.textSecondary),
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
                      if (isInstalled) {
                         setState(() {
                           _controller.toggleInstall(app.id);
                         });
                      } else {
                         if (app.hasWidget) {
                           _showInstallOptions(context, app);
                         } else {
                           setState(() {
                             _controller.toggleInstall(app.id);
                           });
                         }
                      }
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
