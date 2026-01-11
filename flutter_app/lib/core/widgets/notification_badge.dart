import 'package:flutter/material.dart';

/// A small red badge showing "1" for new content notifications.
/// Position this in a Stack at the top-right corner of an icon or widget.
class NotificationBadge extends StatelessWidget {
  final bool show;
  final String? count;

  const NotificationBadge({
    super.key,
    required this.show,
    this.count = '1',
  });

  @override
  Widget build(BuildContext context) {
    if (!show) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: const BoxDecoration(
        color: Colors.red,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      constraints: const BoxConstraints(
        minWidth: 18,
        minHeight: 18,
      ),
      child: Text(
        count ?? '1',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
