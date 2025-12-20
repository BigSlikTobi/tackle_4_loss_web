import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../../../design_tokens.dart';
import '../../../core/os_shell/widgets/t4l_scaffold.dart';
import '../../../core/adk/widgets/t4l_hero_header.dart';
import '../controllers/deep_dive_controller.dart';

class DeepDiveScreen extends StatefulWidget {
  const DeepDiveScreen({super.key});

  @override
  State<DeepDiveScreen> createState() => _DeepDiveScreenState();
}

class _DeepDiveScreenState extends State<DeepDiveScreen> {
  final DeepDiveController _controller = DeepDiveController();

  @override
  void initState() {
    super.initState();
    _controller.loadLatestArticle();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: T4LScaffold(
        body: Consumer<DeepDiveController>(
          builder: (context, controller, child) {
            if (controller.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final article = controller.article;
            if (article == null) {
              return const Center(
                  child: Text('No article found',
                      style: TextStyle(color: Colors.white)));
            }

            return CustomScrollView(
              slivers: [
                // 1. ADK Hero Header
                T4LHeroHeader(
                  title: 'DEEP DIVE',
                  imageUrl: article.imageUrl,
                ),

                // 2. Article Content
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category / Tag
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'TACTICAL ANALYSIS',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.background,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Title
                        Text(
                          article.title,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Summary
                        Text(
                          article.summary,
                          style: const TextStyle(
                            fontSize: 18,
                            color: AppColors.textSecondary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Audio Player Row (Placeholder)
                        GestureDetector(
                          onTap: controller.toggleAudio,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.textPrimary.withOpacity(0.1)),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  controller.isPlayingAudio
                                      ? Icons.pause_circle_filled
                                      : Icons.play_circle_fill,
                                  color: AppColors.primary,
                                  size: 40,
                                ),
                                const SizedBox(width: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Listen to this article',
                                      style: TextStyle(
                                          color: AppColors.textPrimary, fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      '4 min listen • ${article.author}',
                                      style: TextStyle(
                                        color: AppColors.textSecondary.withOpacity(0.7),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Markdown Body
                        MarkdownBody(
                          data: article.content,
                          styleSheet: MarkdownStyleSheet(
                            p: const TextStyle(color: AppColors.textSecondary, fontSize: 16, height: 1.6),
                            h2: const TextStyle(color: AppColors.textPrimary, fontSize: 24, fontWeight: FontWeight.bold),
                            h3: const TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w600),
                            blockquote: const TextStyle(color: AppColors.accent, fontStyle: FontStyle.italic),
                          ),
                        ),
                        const SizedBox(height: 100), // Bottom padding
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
