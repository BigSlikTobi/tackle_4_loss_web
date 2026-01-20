import 'dart:ui';
import 'package:flutter/material.dart';
import '../../models/team_article.dart';

class DailyUpdateCard extends StatelessWidget {
  final TeamArticle? article; // Can be null for loading/empty state
  final VoidCallback onTap;
  final VoidCallback? onImageTap;
  final Color? teamColor;

  const DailyUpdateCard({
    super.key,
    this.article,
    required this.onTap,
    this.onImageTap,
    this.teamColor,
  });

  @override
  Widget build(BuildContext context) {
    if (article == null) {
      return _buildSkeleton(context);
    }

    final displayTitle = article!.title.isNotEmpty ? article!.title : 'Latest Team Update';

    return Container(
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: GestureDetector(
          onTap: onImageTap,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Hero Image
              Image.network(
                article!.imageUrl.isNotEmpty 
                    ? article!.imageUrl 
                    : 'https://images.unsplash.com/photo-1566577739112-5180d4bf9390?q=80&w=3426&auto=format&fit=crop',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: const Color(0xFF1F2937),
                  child: const Center(
                    child: Icon(Icons.image_not_supported, color: Colors.white24, size: 40),
                  ),
                ),
              ),

              // Gradient Overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.0),
                      Colors.black.withValues(alpha: 0.6),
                      Colors.black.withValues(alpha: 0.9),
                    ],
                    stops: const [0.3, 0.7, 1.0],
                  ),
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     // Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: (teamColor ?? const Color(0xFF0F5132)).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: (teamColor ?? const Color(0xFF4ADE80)).withValues(alpha: 0.5),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        'DAILY UPDATE',
                        style: TextStyle(
                          color: teamColor ?? const Color(0xFF4ADE80),
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    
                    const Spacer(),
                    
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Text Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                displayTitle, // "Coach Saleh on Strategy..."
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  height: 1.2,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                // Placeholder format: "October 14 • 2 min watch"
                                // In real app, format article!.publishedAt
                                'Today • Listen now', 
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(width: 16),
                        
                        // Glassmorphic Play Button
                        GestureDetector(
                          onTap: onTap,
                          child: ClipOval(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withValues(alpha: 0.2),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.3),
                                    width: 1.5,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.play_arrow_rounded,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkeleton(BuildContext context) {
    return Container(
      height: 220,
       decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          color: Colors.white24,
        ),
      ),
    );
  }
}
