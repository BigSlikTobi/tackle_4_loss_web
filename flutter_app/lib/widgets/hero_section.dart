import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../design_tokens.dart';
import '../models.dart';

class HeroSection extends StatelessWidget {
  final Article? article;
  final VoidCallback? onReadMore;

  const HeroSection({super.key, this.article, this.onReadMore});

  @override
  Widget build(BuildContext context) {
    if (article == null) {
      return Container(
        color: AppColors.primary,
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          article!.heroImage,
          fit: BoxFit.cover,
          color: AppColors.primary.withOpacity(0.9),
          colorBlendMode: BlendMode.overlay,
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.primary.withOpacity(0.4),
                AppColors.primary.withOpacity(0.6),
                AppColors.primary,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        ),
        Positioned(
          bottom: 64,
          left: 24,
          right: 24,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified, color: AppColors.primary, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'Deep Dive',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                article!.title.toUpperCase(),
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 36,
                  height: 0.95,
                  fontStyle: FontStyle.italic,
                  shadows: [
                    const Shadow(
                      blurRadius: 4.0,
                      color: Colors.black,
                      offset: Offset(2.0, 2.0),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                article!.subtitle,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  height: 1.5,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: onReadMore,
                    icon: const Icon(Icons.play_circle, size: 20),
                    label: const Text('Listen Now'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      textStyle: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: const Icon(Icons.bookmark_border, color: Colors.white, size: 20),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
