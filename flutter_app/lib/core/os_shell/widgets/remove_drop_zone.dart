import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class RemoveDropZone extends StatelessWidget {
  final Function(int) onRemove;

  const RemoveDropZone({
    super.key,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return DragTarget<int>(
      onWillAccept: (data) => true,
      onAccept: (index) {
        onRemove(index);
      },
      builder: (context, candidateData, rejectedData) {
        final isHovering = candidateData.isNotEmpty;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          height: 64,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isHovering 
                      ? Colors.red.withOpacity(0.2) 
                      : Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isHovering 
                        ? Colors.red.withOpacity(0.5) 
                        : Colors.white.withOpacity(0.12),
                    width: isHovering ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        LucideIcons.trash2,
                        color: isHovering ? Colors.redAccent : Colors.white70,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Remove',
                        style: TextStyle(
                          color: isHovering ? Colors.redAccent : Colors.white70,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
