import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tackle4loss_mobile/design_tokens.dart';
import '../../../../core/theme/t4l_theme.dart';
import '../../controllers/standings_controller.dart';

/// Filter header for standings view with view mode and conference toggles.
/// Uses EMOTIONAL DESIGN: all button backgrounds use brandLight.
class StandingsFilterHeader extends StatelessWidget {
  const StandingsFilterHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<StandingsController>();
    final colors = Theme.of(context).extension<T4LThemeColors>()!;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space2,
        vertical: AppSpacing.space1,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Row 1: View Modes (Conference / Division / League)
          _buildViewModeSelector(controller, colors),

          // Row 2: Secondary Filters
          if (controller.viewMode == StandingsViewMode.conference) ...[
            const SizedBox(height: AppSpacing.space1),
            _buildConferenceToggles(controller, colors),
          ] else if (controller.viewMode == StandingsViewMode.division) ...[
            const SizedBox(height: AppSpacing.space1),
            _buildConferenceToggles(controller, colors),
            const SizedBox(height: AppSpacing.space1),
            _buildRegionButtons(controller, colors),
          ],
        ],
      ),
    );
  }

  /// View mode selector (Conference / Division / League)
  Widget _buildViewModeSelector(
    StandingsController controller,
    T4LThemeColors colors,
  ) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        // EMOTIONAL DESIGN: Use brandLight for background
        color: colors.brandLight,
        borderRadius: BorderRadius.circular(AppBorders.radiusMd),
        border: Border.all(color: colors.brand.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          _buildModeButton(
            label: 'Conference',
            isActive: controller.viewMode == StandingsViewMode.conference,
            onTap: () => controller.setViewMode(StandingsViewMode.conference),
            colors: colors,
          ),
          _buildDivider(colors),
          _buildModeButton(
            label: 'Division',
            isActive: controller.viewMode == StandingsViewMode.division,
            onTap: () => controller.setViewMode(StandingsViewMode.division),
            colors: colors,
          ),
          _buildDivider(colors),
          _buildModeButton(
            label: 'League',
            isActive: controller.viewMode == StandingsViewMode.league,
            onTap: () => controller.setViewMode(StandingsViewMode.league),
            colors: colors,
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    required T4LThemeColors colors,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          decoration: isActive
              ? BoxDecoration(
                  color: colors.brand,
                  borderRadius: BorderRadius.circular(AppBorders.radiusMd - 2),
                )
              : null,
          margin: const EdgeInsets.all(2),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTextStyles.body.copyWith(
              // EMOTIONAL: Active uses contrastText, inactive uses contrastText with opacity
              color: isActive
                  ? colors.contrastText
                  : colors.contrastText.withValues(alpha: 0.6),
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider(T4LThemeColors colors) {
    return Container(
      width: 1,
      height: 20,
      color: colors.brand.withValues(alpha: 0.3),
    );
  }

  /// Conference toggle buttons (AFC / NFC)
  Widget _buildConferenceToggles(
    StandingsController controller,
    T4LThemeColors colors,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildConferenceButton('AFC', controller, colors),
        const SizedBox(width: AppSpacing.space2),
        _buildConferenceButton('NFC', controller, colors),
      ],
    );
  }

  Widget _buildConferenceButton(
    String label,
    StandingsController controller,
    T4LThemeColors colors,
  ) {
    final isSelected = controller.selectedConference == label;

    return GestureDetector(
      onTap: () => controller.filterConference(label),
      child: AnimatedContainer(
        duration: AppAnimation.durationFast,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space4,
          vertical: AppSpacing.space1,
        ),
        decoration: BoxDecoration(
          // EMOTIONAL: Selected uses brand, unselected uses brandLight
          color: isSelected ? colors.brand : colors.brandLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:
                isSelected ? colors.brand : colors.brand.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.caption.copyWith(
            // EMOTIONAL: Use contrastText for both states
            color: colors.contrastText,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// Region navigation buttons (North / South / East / West)
  Widget _buildRegionButtons(
    StandingsController controller,
    T4LThemeColors colors,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildRegionButton('North', Icons.arrow_upward, controller, colors),
          const SizedBox(width: AppSpacing.space1),
          _buildRegionButton('South', Icons.arrow_downward, controller, colors),
          const SizedBox(width: AppSpacing.space1),
          _buildRegionButton('East', Icons.arrow_forward, controller, colors),
          const SizedBox(width: AppSpacing.space1),
          _buildRegionButton('West', Icons.arrow_back, controller, colors),
        ],
      ),
    );
  }

  Widget _buildRegionButton(
    String label,
    IconData icon,
    StandingsController controller,
    T4LThemeColors colors,
  ) {
    return GestureDetector(
      onTap: () => controller.scrollToSection(label),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space2,
          vertical: AppSpacing.space1,
        ),
        decoration: BoxDecoration(
          // EMOTIONAL: Use brandLight for button background
          color: colors.brandLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colors.brand.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: colors.brand),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: colors.brand,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
