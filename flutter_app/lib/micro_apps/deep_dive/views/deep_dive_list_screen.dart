import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:tackle4loss_mobile/core/os_shell/widgets/t4l_scaffold.dart';
import 'package:tackle4loss_mobile/micro_apps/deep_dive/controllers/deep_dive_controller.dart';
import 'package:tackle4loss_mobile/micro_apps/deep_dive/views/deep_dive_screen.dart';
import 'package:tackle4loss_mobile/micro_apps/deep_dive/models/deep_dive_article.dart';
import '../../../../design_tokens.dart';

import '../../../../core/services/settings_service.dart';

class DeepDiveListScreen extends StatefulWidget {
  const DeepDiveListScreen({super.key});

  @override
  State<DeepDiveListScreen> createState() => _DeepDiveListScreenState();
}

class _DeepDiveListScreenState extends State<DeepDiveListScreen> {
  final DeepDiveController _controller = DeepDiveController();
  String? _currentLanguage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final settings = Provider.of<SettingsService>(context);
    final languageCode = settings.locale.languageCode;
    
    // Reload if language changed or first load
    if (_currentLanguage != languageCode) {
      _currentLanguage = languageCode;
      _controller.loadAllArticles(languageCode);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsService>(context);
    return ChangeNotifierProvider.value(
      value: _controller,
      child: T4LScaffold(
        title: 'Deep Dives', // Pass title to scaffold
        body: Consumer<DeepDiveController>(
          builder: (context, controller, child) {
            if (controller.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.articles.isEmpty) {
               return Center(
                  child: Text('No deep dives found.',
                      style: TextStyle(color: settings.isDarkMode ? Colors.white70 : AppColors.textPrimary)));
            }
            
            return CustomScrollView(
              slivers: [
                const SliverToBoxAdapter(
                  child: SizedBox(height: 120), // Height of Header + SafeArea + 8px padding
                ),

                // Featured Article (First Item)
                if (controller.articles.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Builder(
                      builder: (context) {
                        final article = controller.articles.first;
                        return _ImmersiveDeepDiveCard(
                          article: article,
                          isGrid: false, // Huge featured card
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => DeepDiveScreen(article: article),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),

                // Grid (Remaining Items)
                if (controller.articles.length > 1)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 0.65,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          // Offset index by 1 because first item is featured
                          final article = controller.articles[index + 1];
                          return _ImmersiveDeepDiveCard(
                            article: article,
                            isGrid: true, // Grid card style
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => DeepDiveScreen(article: article),
                                ),
                              );
                            },
                          );
                        },
                        childCount: controller.articles.length - 1,
                      ),
                    ),
                  ),
                
                // Bottom Padding
                const SliverToBoxAdapter(child: SizedBox(height: 120)),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ImmersiveDeepDiveCard extends StatelessWidget {
  final DeepDiveArticle article;
  final VoidCallback onTap;
  final bool isGrid;

  const _ImmersiveDeepDiveCard({
    required this.article,
    required this.onTap,
    this.isGrid = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: isGrid ? null : 480, // Fixed height for featured, explicit control for grid (via aspect ratio)
        margin: isGrid 
            ? null // Grid handles its own spacing
            : const EdgeInsets.symmetric(horizontal: 16, vertical: 16), // Margin for featured card
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: isGrid ? 10 : 20, // More blurry shadow for big card
              offset: Offset(0, isGrid ? 5 : 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1. Background Image (Immersive)
              Hero(
                tag: 'hero-${article.id}',
                child: CachedNetworkImage(
                  imageUrl: article.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: AppColors.surface,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: AppColors.surface,
                    child: const Center(
                      child: Icon(Icons.broken_image, color: Colors.white24, size: 32),
                    ),
                  ),
                ),
              ),

              // 2. Cinematic Gradient Overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.0),
                      Colors.black.withOpacity(0.5),
                      Colors.black.withOpacity(0.9),
                    ],
                    stops: const [0.0, 0.4, 0.7, 1.0],
                  ),
                ),
              ),

              // 3. Top Metadata (Glassmorphism Pill)
              // Make simpler/smaller for grid
              Positioned(
                top: 12,
                left: 12,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: isGrid ? 10 : 12, vertical: isGrid ? 4 : 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: isGrid 
                        ? Text(
                            "${article.publishedAt.day}.${article.publishedAt.month}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          )
                        : Row(
                            children: [
                              Icon(Icons.calendar_today_outlined, 
                                  size: 12, color: Colors.white.withOpacity(0.9)),
                              const SizedBox(width: 6),
                              Text(
                                "${article.publishedAt.day}.${article.publishedAt.month}.${article.publishedAt.year}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                    ),
                  ),
                ),
              ),

                // 4. Content Content (Bottom)
                Positioned(
                  bottom: isGrid ? 16 : 24,
                  left: isGrid ? 16 : 24,
                  right: isGrid ? 16 : 24,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Author Label
                      Row(
                        children: [
                          Container(
                            width: isGrid ? 16 : 20, 
                            height: isGrid ? 16 : 20, 
                            decoration: const BoxDecoration(
                              color: AppColors.accent,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.person, size: isGrid ? 10 : 12, color: Colors.black),
                          ),
                          SizedBox(width: isGrid ? 6 : 8),
                          Expanded(
                            child: Text(
                              article.author.toUpperCase(),
                              style: TextStyle(
                                color: AppColors.accent,
                                fontSize: isGrid ? 10 : 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: isGrid ? 0.8 : 1.0,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: isGrid ? 8 : 12),
                      
                      // Huge Title
                      Text(
                        article.title,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: isGrid ? 18 : 28, // Dynamic sizing
                          height: 1.1,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: isGrid ? -0.3 : -0.5,
                        ),
                        maxLines: isGrid ? 4 : 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      if (!isGrid) ...[
                        const SizedBox(height: 12),
                        // Subtitle / Summary (Only for featured card)
                        Text(
                          article.summary,
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.4,
                            color: Colors.white.withOpacity(0.8),
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ]
                    ],
                  ),
                ),
              
              // 5. Ripple Effect
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onTap,
                  splashColor: Colors.white.withOpacity(0.1),
                  highlightColor: Colors.white.withOpacity(0.05),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
