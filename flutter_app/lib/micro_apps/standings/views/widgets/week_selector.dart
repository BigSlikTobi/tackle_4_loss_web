import 'package:flutter/material.dart';
import 'package:tackle4loss_mobile/design_tokens.dart';
import '../../../../core/theme/t4l_theme.dart';
import '../../controllers/standings_controller.dart';

/// Horizontally scrolling week chips.
/// EMOTIONAL DESIGN: the active chip uses the user team's brand color as text
/// when light, otherwise stays white-on-brand for the current-week ring.
class WeekSelector extends StatefulWidget {
  final List<int> weeks;
  final int selectedWeek;
  final int currentWeek;
  final ValueChanged<int> onWeekSelected;
  final Color? activeColor;

  const WeekSelector({
    super.key,
    required this.weeks,
    required this.selectedWeek,
    required this.currentWeek,
    required this.onWeekSelected,
    this.activeColor,
  });

  @override
  State<WeekSelector> createState() => _WeekSelectorState();
}

class _WeekSelectorState extends State<WeekSelector> {
  late final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelected());
  }

  @override
  void didUpdateWidget(WeekSelector old) {
    super.didUpdateWidget(old);
    if (old.selectedWeek != widget.selectedWeek) _scrollToSelected();
  }

  void _scrollToSelected() {
    final i = widget.weeks.indexOf(widget.selectedWeek);
    if (i < 0 || !_scrollController.hasClients) return;
    final offset = (i * 60.0) - (MediaQuery.of(context).size.width / 2) + 30;
    _scrollController.animateTo(
      offset.clamp(0.0, _scrollController.position.maxScrollExtent),
      duration: AppAnimation.durationNormal,
      curve: AppAnimation.curveEaseInOut,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brand = widget.activeColor ??
        Theme.of(context).extension<T4LThemeColors>()?.brand ??
        AppColors.brandBase;
    return Container(
      height: 68,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
      ),
      child: ListView.separated(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.space2, vertical: 8),
        itemCount: widget.weeks.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (context, i) {
          final w = widget.weeks[i];
          return _WeekChip(
            week: w,
            isSelected: w == widget.selectedWeek,
            isCurrent: w == widget.currentWeek,
            brand: brand,
            onTap: () => widget.onWeekSelected(w),
          );
        },
      ),
    );
  }
}

class _WeekChip extends StatelessWidget {
  final int week;
  final bool isSelected;
  final bool isCurrent;
  final Color brand;
  final VoidCallback onTap;

  const _WeekChip({
    required this.week,
    required this.isSelected,
    required this.isCurrent,
    required this.brand,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final (top, main) = StandingsController.getWeekLabels(week);
    final activeBg = Colors.white.withValues(alpha: 0.95);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: AppAnimation.durationFast,
        constraints: const BoxConstraints(minWidth: 48),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? activeBg : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : isCurrent
                    ? brand
                    : Colors.white.withValues(alpha: 0.08),
            width: isCurrent && !isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              top.toUpperCase(),
              style: AppTextStyles.caption.copyWith(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                color: isSelected
                    ? Colors.black.withValues(alpha: 0.5)
                    : Colors.white.withValues(alpha: 0.35),
                height: 1.2,
              ),
            ),
            Text(
              main,
              style: TextStyle(
                fontFamily: 'Russo One',
                fontSize: 14,
                height: 1.2,
                color: isSelected
                    ? const Color(0xFF0B1810)
                    : Colors.white.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
