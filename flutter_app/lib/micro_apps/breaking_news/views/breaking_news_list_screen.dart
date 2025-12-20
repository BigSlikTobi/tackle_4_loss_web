import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../design_tokens.dart';
import '../../../core/os_shell/widgets/t4l_scaffold.dart';
import '../controllers/breaking_news_controller.dart';
import 'package:intl/intl.dart';

class BreakingNewsListScreen extends StatefulWidget {
  const BreakingNewsListScreen({super.key});

  @override
  State<BreakingNewsListScreen> createState() => _BreakingNewsListScreenState();
}

class _BreakingNewsListScreenState extends State<BreakingNewsListScreen> {
  final BreakingNewsController _controller = BreakingNewsController();

  @override
  void initState() {
    super.initState();
    _controller.loadNews();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: T4LScaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Area (Custom for this app, not HeroHeader)
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 60, 24, 24), // Top padding for Close button space
                child: Text(
                  'BREAKING NEWS',
                  style: TextStyle(
                    fontFamily: 'RussoOne',
                    fontSize: 28,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),

            // News List
            Expanded(
              child: Consumer<BreakingNewsController>(
                builder: (context, controller, child) {
                  if (controller.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: controller.articles.length,
                    itemBuilder: (context, index) {
                      final article = controller.articles[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 24),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Image
                            AspectRatio(
                              aspectRatio: 16 / 9,
                              child: Image.network(
                                article.imageUrl,
                                fit: BoxFit.cover,
                              ),
                            ),
                            
                            // Text Section
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Source & Time Tag
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          article.source.toUpperCase(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        DateFormat('h:mm a').format(article.publishedAt),
                                        style: TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  
                                  // Headline
                                  Text(
                                    article.title,
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      height: 1.2,
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 8),
                                  
                                  // Description
                                  Text(
                                    article.description,
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 14,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
