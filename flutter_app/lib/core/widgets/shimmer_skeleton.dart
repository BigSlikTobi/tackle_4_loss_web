import 'package:flutter/material.dart';

/// A shimmer animation widget that creates a loading skeleton effect.
/// Uses a sliding gradient to create the shimmer animation.
class ShimmerBox extends StatefulWidget {
  final double? width;
  final double? height;
  final double borderRadius;
  final Color? baseColor;
  final Color? highlightColor;

  const ShimmerBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 8.0,
    this.baseColor,
    this.highlightColor,
  });

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = widget.baseColor ??
        (isDark ? Colors.grey[800]! : Colors.grey[300]!);
    final highlightColor = widget.highlightColor ??
        (isDark ? Colors.grey[700]! : Colors.grey[100]!);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                baseColor,
                highlightColor,
                baseColor,
              ],
              stops: [
                0.0,
                0.5 + (_animation.value * 0.5),
                1.0,
              ].map((v) => v.clamp(0.0, 1.0)).toList(),
            ),
          ),
        );
      },
    );
  }
}

/// Circular shimmer for avatars and logos
class ShimmerCircle extends StatelessWidget {
  final double size;

  const ShimmerCircle({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: ShimmerBox(
        width: size,
        height: size,
        borderRadius: size / 2,
      ),
    );
  }
}

/// Shimmer line for text placeholders
class ShimmerText extends StatelessWidget {
  final double width;
  final double height;

  const ShimmerText({
    super.key,
    required this.width,
    this.height = 14,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerBox(
      width: width,
      height: height,
      borderRadius: 4,
    );
  }
}

/// Skeleton for a single news feed item
class NewsFeedItemSkeleton extends StatelessWidget {
  const NewsFeedItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with accent bar
          Row(
            children: [
              ShimmerBox(width: 3, height: 40, borderRadius: 2),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerText(width: 120),
                    const SizedBox(height: 6),
                    ShimmerText(width: 80, height: 10),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          
          // Team logos row
          Row(
            children: [
              ShimmerCircle(size: 28),
              const SizedBox(width: 6),
              ShimmerCircle(size: 28),
              const SizedBox(width: 12),
              ShimmerCircle(size: 32),
              const SizedBox(width: 6),
              ShimmerCircle(size: 32),
            ],
          ),
          const SizedBox(height: 14),
          
          // Image placeholder
          ShimmerBox(
            width: double.infinity,
            height: 200,
            borderRadius: 12,
          ),
          const SizedBox(height: 14),
          
          // Body text lines
          const ShimmerText(width: double.infinity),
          const SizedBox(height: 8),
          ShimmerText(width: MediaQuery.of(context).size.width * 0.7),
          const SizedBox(height: 8),
          ShimmerText(width: MediaQuery.of(context).size.width * 0.5),
          
          const SizedBox(height: 24),
          // Separator
          ShimmerBox(width: double.infinity, height: 1, borderRadius: 0),
        ],
      ),
    );
  }
}

/// Full OS Shell skeleton with app grid and feed placeholders
class OSShellSkeleton extends StatelessWidget {
  const OSShellSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 80),
          
          // App grid skeleton (3 rows x 4 cols)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 24,
                crossAxisSpacing: 16,
                childAspectRatio: 0.85,
              ),
              itemCount: 8,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    Expanded(
                      child: ShimmerBox(borderRadius: 16),
                    ),
                    const SizedBox(height: 8),
                    ShimmerText(width: 50, height: 10),
                  ],
                );
              },
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Feed header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Expanded(child: ShimmerBox(height: 2, borderRadius: 1)),
                const SizedBox(width: 16),
                ShimmerText(width: 60),
                const SizedBox(width: 16),
                Expanded(child: ShimmerBox(height: 2, borderRadius: 1)),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Feed items
          Expanded(
            child: ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              itemBuilder: (context, index) => const NewsFeedItemSkeleton(),
            ),
          ),
        ],
      ),
    );
  }
}

/// Generic list skeleton for breaking news, deep dive, etc.
class ListSkeleton extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;

  const ListSkeleton({
    super.key,
    this.itemCount = 5,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: itemBuilder,
    );
  }
}

/// Card skeleton for list items
class CardSkeleton extends StatelessWidget {
  final double height;
  
  const CardSkeleton({super.key, this.height = 120});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ShimmerBox(
        width: double.infinity,
        height: height,
        borderRadius: 16,
      ),
    );
  }
}

/// Standings table skeleton
class StandingsSkeleton extends StatelessWidget {
  const StandingsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tab bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (i) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: ShimmerBox(width: 80, height: 36, borderRadius: 18),
            )),
          ),
        ),
        // Table rows
        Expanded(
          child: ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 10,
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  ShimmerText(width: 24),
                  const SizedBox(width: 12),
                  ShimmerCircle(size: 32),
                  const SizedBox(width: 12),
                  Expanded(child: ShimmerText(width: 100)),
                  ShimmerText(width: 40),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
