import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tackle4loss_mobile/design_tokens.dart';
import '../../../../core/theme/t4l_theme.dart';
import '../../controllers/standings_controller.dart';

/// Filter header for the standings tab.
/// Layout:
///  - Segmented control: Division | Conference | League
///  - AFC / NFC pills (hidden in League view)
///  - Division pills with directional arrows (Division view only)
/// EMOTIONAL DESIGN: the user team's brand color is the leading accent.
class StandingsFilterHeader extends StatelessWidget {
  const StandingsFilterHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<StandingsController>();
    final colors = Theme.of(context).extension<T4LThemeColors>()!;

    return Container(
      color: const Color(0xFF0D130F),
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSegmented(controller, colors),
          if (controller.viewMode != StandingsViewMode.league) ...[
            const SizedBox(height: 8),
            _buildConfRow(controller, colors),
          ],
          if (controller.viewMode == StandingsViewMode.division) ...[
            const SizedBox(height: 8),
            _buildDivisionPills(controller, colors),
          ],
        ],
      ),
    );
  }

  // ── Segmented control ──────────────────────────────────────────────
  Widget _buildSegmented(
      StandingsController controller, T4LThemeColors colors) {
    const items = [
      (StandingsViewMode.division, 'Division'),
      (StandingsViewMode.conference, 'Conference'),
      (StandingsViewMode.league, 'League'),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space2),
      child: Row(
        children: [
          for (var i = 0; i < items.length; i++)
            Expanded(
              child: _SegButton(
                label: items[i].$2,
                active: controller.viewMode == items[i].$1,
                isFirst: i == 0,
                isLast: i == items.length - 1,
                brand: colors.brand,
                contrastText: colors.contrastText,
                onTap: () => controller.setViewMode(items[i].$1),
              ),
            ),
        ],
      ),
    );
  }

  // ── AFC / NFC pills ────────────────────────────────────────────────
  Widget _buildConfRow(StandingsController controller, T4LThemeColors colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space2),
      child: Row(
        children: [
          Expanded(child: _confButton('AFC', controller, colors)),
          const SizedBox(width: 8),
          Expanded(child: _confButton('NFC', controller, colors)),
        ],
      ),
    );
  }

  Widget _confButton(
      String label, StandingsController controller, T4LThemeColors colors) {
    final isSelected = controller.selectedConference == label;
    return GestureDetector(
      onTap: () => controller.filterConference(label),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: AppAnimation.durationFast,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color:
              isSelected ? colors.brand : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(9),
          border: Border.all(
            color:
                isSelected ? colors.brand : Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.caption.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
            color: isSelected
                ? colors.contrastText
                : Colors.white.withValues(alpha: 0.4),
          ),
        ),
      ),
    );
  }

  // ── Division pills ─────────────────────────────────────────────────
  Widget _buildDivisionPills(
      StandingsController controller, T4LThemeColors colors) {
    const divisions = [
      ('North', Icons.arrow_upward),
      ('South', Icons.arrow_downward),
      ('East', Icons.arrow_forward),
      ('West', Icons.arrow_back),
    ];
    return SizedBox(
      height: 28,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space2),
        itemCount: divisions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (context, i) {
          final d = divisions[i];
          final isActive = controller.selectedDivision == d.$1;
          return GestureDetector(
            onTap: () {
              controller.setDivision(d.$1);
              controller.scrollToSection(d.$1);
            },
            child: AnimatedContainer(
              duration: AppAnimation.durationFast,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                color: isActive
                    ? colors.brand.withValues(alpha: 0.18)
                    : Colors.white.withValues(alpha: 0.05),
                border: Border.all(
                  color: isActive
                      ? colors.brand.withValues(alpha: 0.6)
                      : Colors.white.withValues(alpha: 0.08),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    d.$2,
                    size: 11,
                    color: isActive
                        ? colors.brand.computeLuminance() > 0.5
                            ? colors.brand
                            : Color.lerp(colors.brand, Colors.white, 0.5)
                        : Colors.white.withValues(alpha: 0.4),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    d.$1,
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                      color: isActive
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SegButton extends StatelessWidget {
  final String label;
  final bool active;
  final bool isFirst;
  final bool isLast;
  final Color brand;
  final Color contrastText;
  final VoidCallback onTap;

  const _SegButton({
    required this.label,
    required this.active,
    required this.isFirst,
    required this.isLast,
    required this.brand,
    required this.contrastText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const radius = Radius.circular(9);
    final borderRadius = BorderRadius.only(
      topLeft: isFirst ? radius : Radius.zero,
      bottomLeft: isFirst ? radius : Radius.zero,
      topRight: isLast ? radius : Radius.zero,
      bottomRight: isLast ? radius : Radius.zero,
    );
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: AppAnimation.durationFast,
        height: 30,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? brand : Colors.white.withValues(alpha: 0.05),
          borderRadius: borderRadius,
          border: Border.all(
            color: active ? brand : Colors.white.withValues(alpha: 0.08),
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.caption.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
            color: active ? contrastText : Colors.white.withValues(alpha: 0.55),
          ),
        ),
      ),
    );
  }
}
