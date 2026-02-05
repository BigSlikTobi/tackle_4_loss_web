/// Attribute Tile widget for displaying individual comparison results.
/// Shows color-coded feedback for each player attribute.
library;

import 'package:flutter/material.dart';
import 'package:tackle4loss_mobile/design_tokens.dart';
import '../../models/guess_result.dart';

/// Colors for match status feedback.
class AttributeColors {
  static const Color match = Color(0xFF22C55E); // Green-500
  static const Color partial = Color(0xFFF59E0B); // Amber-500
  static const Color miss = Color(0xFF6B7280); // Gray-500
}

/// A single attribute tile showing comparison result.
class AttributeTile extends StatefulWidget {
  /// The label for this attribute (e.g., "Team", "Age")
  final String label;

  /// The value to display
  final String value;

  /// Match status determining background color
  final MatchStatus status;

  /// Optional arrow direction for numeric comparisons
  final NumericDirection? direction;

  /// Whether this is a "close" match (pulses)
  final bool isClose;

  /// Whether to animate the tile
  final bool animate;

  const AttributeTile({
    super.key,
    required this.label,
    required this.value,
    required this.status,
    this.direction,
    this.isClose = false,
    this.animate = true,
  });

  @override
  State<AttributeTile> createState() => _AttributeTileState();
}

class _AttributeTileState extends State<AttributeTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _flipAnimation;
  bool _showFront = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppAnimation.durationNormal,
      vsync: this,
    );

    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.animate) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          _controller.forward().then((_) {
            if (mounted) {
              setState(() => _showFront = false);
            }
          });
        }
      });
    } else {
      _showFront = false;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _backgroundColor {
    switch (widget.status) {
      case MatchStatus.match:
        return AttributeColors.match;
      case MatchStatus.partial:
        return AttributeColors.partial;
      case MatchStatus.miss:
        return AttributeColors.miss;
    }
  }

  String get _displayValue {
    if (widget.direction != null &&
        widget.direction != NumericDirection.exact) {
      final arrow = widget.direction == NumericDirection.up ? '↑' : '↓';
      return '${widget.value} $arrow';
    }
    return widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Flip effect
        final angle = _flipAnimation.value * 3.14159;
        final showBack = angle > 1.5708; // > 90 degrees

        // Pulse effect for close matches
        double scale = 1.0;
        if (widget.isClose && !_showFront) {
          scale = 1.0 +
              (0.05 *
                  (1 + (DateTime.now().millisecondsSinceEpoch % 1000) / 1000));
        }

        return Transform.scale(
          scale: scale,
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            child: Container(
              decoration: BoxDecoration(
                color: showBack ? _backgroundColor : AppColors.neutralBorder,
                borderRadius: BorderRadius.circular(AppBorders.radiusLg),
                boxShadow: AppShadows.sm,
              ),
              child: SizedBox(
                width: 60,
                height: 60,
                child: showBack
                    ? Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()..rotateY(3.14159),
                        child: _buildContent(),
                      )
                    : _buildFrontContent(),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFrontContent() {
    return const Center(
      child: Text(
        '?',
        style: TextStyle(
          fontSize: AppTypography.fontSizeLg,
          fontWeight: AppTypography.fontWeightBold,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _displayValue,
            style: const TextStyle(
              fontSize: AppTypography.fontSizeSm,
              fontWeight: AppTypography.fontWeightBold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            widget.label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.white.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
