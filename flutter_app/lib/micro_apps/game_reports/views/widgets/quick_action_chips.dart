import 'package:flutter/material.dart';

/// Quick action chip buttons for common game report queries.
/// Provides one-tap access to "Recap", "Stats", "MVP" etc.
class QuickActionChips extends StatelessWidget {
  final ValueChanged<String> onAction;
  final bool isLoading;

  const QuickActionChips({
    super.key,
    required this.onAction,
    this.isLoading = false,
  });

  static const List<_QuickAction> _actions = [
    _QuickAction(
      label: 'Recap',
      icon: Icons.sports_football,
      prompt: 'Give me a casual recap of this game',
    ),
    _QuickAction(
      label: 'Stats',
      icon: Icons.bar_chart,
      prompt: 'Show me the key stats breakdown',
    ),
    _QuickAction(
      label: 'MVP',
      icon: Icons.star,
      prompt: 'Who was the MVP of this game and why?',
    ),
    _QuickAction(
      label: 'Key Plays',
      icon: Icons.highlight,
      prompt: 'What were the key plays that decided this game?',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _actions.map((action) {
        return ActionChip(
          avatar: Icon(action.icon, size: 18),
          label: Text(action.label),
          onPressed: isLoading ? null : () => onAction(action.prompt),
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
          labelStyle: theme.textTheme.labelMedium,
        );
      }).toList(),
    );
  }
}

class _QuickAction {
  final String label;
  final IconData icon;
  final String prompt;

  const _QuickAction({
    required this.label,
    required this.icon,
    required this.prompt,
  });
}
