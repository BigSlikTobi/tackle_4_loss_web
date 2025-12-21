import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../design_tokens.dart';
import '../../micro_app.dart';
import '../../services/navigation_service.dart';
import 'package:provider/provider.dart';
import '../../services/settings_service.dart';
import '../../../../micro_apps/deep_dive/models/deep_dive_article.dart';

class FeaturedAppHero extends StatelessWidget {
  final MicroApp app;
  final DeepDiveArticle? article;

  const FeaturedAppHero({super.key, required this.app, this.article});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsService>(context);
    // Use Team Color if selected, otherwise fallback to App's Theme Color
    final brandingColor = settings.selectedTeam?.primaryColor ?? app.themeColor;

    // Dynamic data logic
    final displayTitle = article?.title ?? app.name.toUpperCase();
    final displaySubtitle = article?.summary ?? 'APP OF THE MONTH';
    final displayImageUrl = article?.imageUrl;

    // Golden Ratio: approx 0.382 of screen height (The smaller side)
    final double heroHeight = MediaQuery.of(context).size.height * 0.381966;

    return GestureDetector(
      onTap: () => NavigationService().openApp(context, app),
      child: Container(
        height: heroHeight,
        width: double.infinity,
        margin: EdgeInsets.zero,
        decoration: BoxDecoration(
          // Ambient depth shadow
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 1. Image + Gradient + Mask Logic
            ShaderMask(
              shaderCallback: (rect) {
                return const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent, 
                    Colors.black,       
                    Colors.black,       
                    Colors.transparent  
                  ],
                  stops: [0.0, 0.08, 0.92, 1.0], 
                ).createShader(rect);
              },
              blendMode: BlendMode.dstIn,
              child: Stack(
                fit: StackFit.expand,
                children: [
                   // Background Image
                  if (displayImageUrl != null)
                    Image.network(
                      displayImageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Image.asset(
                        app.storeImageAsset,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(color: brandingColor),
                      ),
                    )
                  else
                    Image.network(
                      'https://images.unsplash.com/photo-1541534741688-6078c6bfb5c5?q=80&w=2938&auto=format&fit=crop',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                         return Image.asset(
                           app.storeImageAsset, 
                           fit: BoxFit.cover,
                           errorBuilder: (_, __, ___) => Container(color: brandingColor),
                         );
                      },
                    ),
                  
                  // Grounded Gradient Overlay (Cinematic Depth)
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          // Mix team color with black for a "grounded" look at the bottom
                          Color.lerp(brandingColor, Colors.black, 0.7)!.withOpacity(0.9),
                          Color.lerp(brandingColor, Colors.black, 0.3)!.withOpacity(0.4),
                          Colors.black.withOpacity(0.4), // Dark top
                        ],
                        stops: const [0.0, 0.4, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 1a. Top Blur (Glassmorphism for Header Area)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 100,
              child: ShaderMask(
                shaderCallback: (rect) {
                  return const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black, Colors.transparent],
                    stops: [0.0, 1.0],
                  ).createShader(rect);
                },
                blendMode: BlendMode.dstIn,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                  child: Container(color: Colors.transparent),
                ),
              ),
            ),

            // 2. Content Overlay
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  
                  // Tag / CTA "App of the Month"
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC9A256), // Gold color
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(width: 8),
                        const Text(
                          'FEATURED APP',
                          style: TextStyle(
                            color: Color(0xFF0f3d2e),
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          width: 4, 
                          height: 4, 
                          decoration: const BoxDecoration(
                            color: Color(0xFF0f3d2e),
                            shape: BoxShape.circle
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          app.name.toUpperCase(),
                          style: const TextStyle(
                            color: Color(0xFF0f3d2e),
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Title (More intense 3D shadow)
                  Text(
                    displayTitle.toUpperCase(), 
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 40, // Slightly smaller to prevent overflow
                      fontWeight: FontWeight.w900, 
                      height: 0.95,
                      letterSpacing: -1.0,
                      fontStyle: FontStyle.italic,
                      shadows: [
                        Shadow(
                          color: Colors.black87,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),

                  // Subtitle
                  Text(
                    displaySubtitle, 
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white, 
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                      shadows: [
                        Shadow(
                          color: Colors.black54,
                          blurRadius: 4,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
