import 'package:flutter/material.dart';
import '../../models/report_request.dart';

/// Widget for selecting the report style.
class StyleSelector extends StatelessWidget {
  final ReportStyle selectedStyle;
  final ValueChanged<ReportStyle> onStyleChanged;

  const StyleSelector({
    super.key,
    required this.selectedStyle,
    required this.onStyleChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Report Style',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Row(
          children: ReportStyle.values.map((style) {
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: style != ReportStyle.values.last ? 8 : 0,
                ),
                child: _StyleChip(
                  style: style,
                  isSelected: style == selectedStyle,
                  onTap: () => onStyleChanged(style),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _StyleChip extends StatelessWidget {
  final ReportStyle style;
  final bool isSelected;
  final VoidCallback onTap;

  const _StyleChip({
    required this.style,
    required this.isSelected,
    required this.onTap,
  });

  IconData get _icon {
    switch (style) {
      case ReportStyle.casual:
        return Icons.chat_bubble_outline;
      case ReportStyle.detailed:
        return Icons.description_outlined;
      case ReportStyle.stats:
        return Icons.bar_chart;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.15)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              _icon,
              size: 24,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 4),
            Text(
              style.displayName,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              style.description,
              textAlign: TextAlign.center,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                fontSize: 10,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
