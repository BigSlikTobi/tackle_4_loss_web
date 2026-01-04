import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/os_shell/widgets/t4l_scaffold.dart';
import '../../../design_tokens.dart';
import '../../../core/services/settings_service.dart';

import '../controllers/standings_controller.dart';
import 'widgets/schedule_tab.dart';
import 'widgets/standings_tab.dart';

/// Main screen for the Game Center micro app.
/// Displays NFL schedule and standings with tabbed navigation.
class StandingsScreen extends StatelessWidget {
  const StandingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StandingsController()..fetchGames(),
      child: const _StandingsScreenContent(),
    );
  }
}

class _StandingsScreenContent extends StatelessWidget {
  const _StandingsScreenContent();

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsService>(context);
    final selectedTeam = settings.selectedTeam;

    return T4LScaffold(
      title: 'Game Center',
      body: Consumer<StandingsController>(
        builder: (context, controller, child) {
          if (controller.isLoading &&
              controller.activeTab == GameCenterTab.schedule) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.brandBase),
            );
          }

          if (controller.error != null &&
              controller.activeTab == GameCenterTab.schedule) {
            return _buildErrorState(context, controller);
          }

          return Column(
            children: [
              // Floating Header Spacer
              const SizedBox(height: 130),

              // Tab Selector
              _buildTabSelector(
                context,
                controller,
                selectedTeam?.primaryColor,
              ),

              // Tab Content
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: controller.activeTab == GameCenterTab.schedule
                      ? const ScheduleTab()
                      : const StandingsTab(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTabSelector(
    BuildContext context,
    StandingsController controller,
    Color? accentColor,
  ) {
    final activeColor = accentColor ?? AppColors.brandBase;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space3,
        vertical: AppSpacing.space2,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(AppBorders.radiusLg),
        ),
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            _buildTabButton(
              context,
              label: 'Schedule',
              icon: Icons.calendar_month_rounded,
              isActive: controller.activeTab == GameCenterTab.schedule,
              activeColor: activeColor,
              onTap: () => controller.switchTab(GameCenterTab.schedule),
            ),
            _buildTabButton(
              context,
              label: 'Standings',
              icon: Icons.leaderboard_rounded,
              isActive: controller.activeTab == GameCenterTab.standings,
              activeColor: activeColor,
              onTap: () => controller.switchTab(GameCenterTab.standings),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required bool isActive,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.space2),
          decoration: BoxDecoration(
            color: isActive ? activeColor : Colors.transparent,
            borderRadius: BorderRadius.circular(AppBorders.radiusMd),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: activeColor.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isActive
                    ? Colors.white
                    : (isDark ? AppColors.textSubDark : AppColors.textSubLight),
              ),
              const SizedBox(width: AppSpacing.space1),
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: isActive
                      ? Colors.white
                      : (isDark
                            ? AppColors.textSubDark
                            : AppColors.textSubLight),
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    StandingsController controller,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: AppColors.breakingNewsRed),
          const SizedBox(height: AppSpacing.space2),
          Text('Failed to load data', style: AppTextStyles.h3),
          const SizedBox(height: AppSpacing.space1),
          Text(
            controller.error ?? 'Unknown error',
            style: AppTextStyles.caption,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.space3),
          ElevatedButton.icon(
            onPressed: controller.fetchGames,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brandBase,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
