import 'package:flutter/material.dart';
import '../../../../design_tokens.dart';

/// Horizontal scrollable week selector with animated highlighting.
class WeekSelector extends StatefulWidget {
  final List<int> weeks;
  final int selectedWeek;
  final int currentWeek;
  final ValueChanged<int> onWeekSelected;
  final Color? activeColor; // From selected team

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
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedWeek();
    });
  }

  @override
  void didUpdateWidget(WeekSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedWeek != widget.selectedWeek) {
      _scrollToSelectedWeek();
    }
  }

  void _scrollToSelectedWeek() {
    final index = widget.weeks.indexOf(widget.selectedWeek);
    if (index >= 0 && _scrollController.hasClients) {
      final offset =
          (index * 72.0) - (MediaQuery.of(context).size.width / 2) + 36;
      _scrollController.animateTo(
        offset.clamp(0.0, _scrollController.position.maxScrollExtent),
        duration: AppAnimation.durationNormal,
        curve: AppAnimation.curveEaseInOut,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 64, // Increased from 56
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        boxShadow: AppShadows.sm,
      ),
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space1,
          vertical: AppSpacing.space1,
        ),
        itemCount: widget.weeks.length,
        itemBuilder: (context, index) {
          final week = widget.weeks[index];
          final isSelected = week == widget.selectedWeek;
          final isCurrent = week == widget.currentWeek;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _WeekChip(
              week: week,
              isSelected: isSelected,
              isCurrent: isCurrent,
              isDark: isDark,
              onTap: () => widget.onWeekSelected(week),
              activeColor: widget.activeColor ?? AppColors.brandBase,
            ),
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
  final bool isDark;
  final VoidCallback onTap;
  final Color activeColor;

  const _WeekChip({
    required this.week,
    required this.isSelected,
    required this.isCurrent,
    required this.isDark,
    required this.onTap,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    // Logic from RadioHomeWidget:
    // Light Mode (App Light) -> Use Team Color (Dark) for selected
    // Dark Mode (App Dark) -> Use White for selected

    Color backgroundColor;
    Color textColor;
    Color borderColor;

    if (isSelected) {
      if (isDark) {
        // App Dark -> Chip White
        backgroundColor = Colors.white;
        textColor =
            activeColor; // Or Black? Radio used team color foreground on white
        borderColor = Colors.white;
      } else {
        // App Light -> Chip Team Color
        backgroundColor = activeColor;
        textColor = Colors.white;
        borderColor = activeColor;
      }
    } else {
      // Unselected
      backgroundColor = isDark
          ? AppColors.backgroundDark
          : AppColors.neutralSoft;
      textColor = isDark ? AppColors.textSubDark : AppColors.textSubLight;
      borderColor = Colors.transparent;

      if (isCurrent) {
        borderColor =
            activeColor; // Border for current week even if not selected
      }
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppAnimation.durationFast,
        curve: AppAnimation.curveEaseInOut,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space2,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(AppBorders.radiusFull),
          border: isCurrent || isSelected
              ? Border.all(color: borderColor, width: 2)
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Week',
              style: TextStyle(
                fontSize: 10,
                height: 1.1,
                fontWeight: FontWeight.normal,
                color: isSelected
                    ? textColor.withValues(alpha: 0.8)
                    : textColor,
              ),
            ),
            Text(
              week.toString(),
              style: TextStyle(
                fontSize: 14,
                height: 1.1,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
