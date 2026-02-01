import 'dart:math' as math;
import 'package:flutter/material.dart';

class CircularDialMenu extends StatefulWidget {
  final List<Widget> children;
  final double radius;
  final double itemSpacing; // in radians

  const CircularDialMenu({
    super.key,
    required this.children,
    this.radius = 250,
    this.itemSpacing = 0.7, // ~40 degrees
  });

  @override
  State<CircularDialMenu> createState() => _CircularDialMenuState();
}

class _CircularDialMenuState extends State<CircularDialMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _currentAngle = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = const AlwaysStoppedAnimation(0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final delta = details.delta.dx * 0.005;
    setState(() {
      _currentAngle += delta;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    final targetIndex = (-_currentAngle / widget.itemSpacing).round();
    final clampedIndex = targetIndex.clamp(0, widget.children.length - 1);
    final targetAngle = -clampedIndex * widget.itemSpacing;

    _animation = Tween<double>(
      begin: _currentAngle,
      end: targetAngle,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward(from: 0).then((_) {
      setState(() {
        _currentAngle = targetAngle;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: SizedBox(
        height: 300,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final angle =
                _controller.isAnimating ? _animation.value : _currentAngle;
            return Stack(
              alignment: Alignment.center,
              children: [
                // Background visual
                Positioned(
                  bottom: -widget.radius,
                  child: Container(
                    width: widget.radius * 2,
                    height: widget.radius * 2,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.05),
                        width: 1,
                      ),
                      gradient: RadialGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.05),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                // Items
                ...List.generate(widget.children.length, (index) {
                  const itemBaseAngle = -math.pi / 2;
                  final itemOffset = index * widget.itemSpacing;
                  final finalAngle = itemBaseAngle + angle + itemOffset;

                  final centerX = MediaQuery.of(context).size.width / 2;
                  final centerY = widget.radius + 50;

                  final x = centerX + widget.radius * math.cos(finalAngle);
                  final y = centerY + widget.radius * math.sin(finalAngle);

                  final dist = (finalAngle - (-math.pi / 2)).abs();
                  final scale = math.max(0.6, 1.0 - (dist * 0.5));
                  final opacity = math.max(0.3, 1.0 - (dist * 0.8));

                  return Positioned(
                    left: x - 80,
                    top: y - 50,
                    child: Transform.scale(
                      scale: scale,
                      child: Opacity(
                        opacity: opacity.clamp(0.0, 1.0),
                        child: Transform.rotate(
                          angle: finalAngle + math.pi / 2,
                          child: widget.children[index],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            );
          },
        ),
      ),
    );
  }
}
