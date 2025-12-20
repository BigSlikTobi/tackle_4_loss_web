import 'package:flutter/material.dart';
import '../../../../design_tokens.dart';

class T4LHeroHeader extends StatelessWidget {
  final String title;
  final String imageUrl;
  final double expandedHeight;

  const T4LHeroHeader({
    super.key,
    required this.title,
    required this.imageUrl,
    this.expandedHeight = 400.0,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: expandedHeight,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.background,
      automaticallyImplyLeading: false, // Scaffold handles the close button
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontFamily: 'RussoOne', // Should match tokens or be passed in
            letterSpacing: 2.0,
            shadows: [Shadow(color: AppColors.background, blurRadius: 10)],
            fontSize: 16,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
            ),
            // Gradient Overlay
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.background.withOpacity(0.54),
                    Colors.transparent,
                    AppColors.background.withOpacity(0.87),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
