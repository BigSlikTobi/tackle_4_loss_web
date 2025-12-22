import 'package:flutter/material.dart';
import '../../models/breaking_news_article.dart';
import '../../../../design_tokens.dart';

class SideStackWidget extends StatelessWidget {
  final List<BreakingNewsArticle> articles;
  final Color color;
  final Alignment alignment;
  final VoidCallback? onStackTap;

  const SideStackWidget({
    super.key,
    required this.articles,
    required this.color,
    required this.alignment,
    this.onStackTap,
  });

  @override
  Widget build(BuildContext context) {
    if (articles.isEmpty) return const SizedBox.shrink();

    final count = articles.length;
    final isRight = alignment.x > 0;
    
    return GestureDetector(
      onTap: onStackTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(12), // Larger hit area
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color == Colors.white ? Colors.black87 : color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: AppShadows.sm,
          ),
          constraints: const BoxConstraints(
            minWidth: 28,
            minHeight: 28,
          ),
          child: Center(
            child: Text(
              "$count",
              style: TextStyle(
                color: (color == Colors.white ? Colors.black87 : color).computeLuminance() > 0.5 ? Colors.black : Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
