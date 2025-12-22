import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/t4l_theme.dart';
import '../../../../core/services/navigation_service.dart';
import '../../../../core/app_registry.dart';
import '../../controllers/breaking_news_controller.dart';

import 'package:tackle4loss_mobile/l10n/app_localizations.dart';

class BreakingNewsWidget extends StatelessWidget {
  final BreakingNewsController? controller;

  const BreakingNewsWidget({super.key, this.controller});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => controller ?? (BreakingNewsController()..loadNews()),
      child: const _BreakingNewsWidgetContent(),
    );
  }
}

class _BreakingNewsWidgetContent extends StatelessWidget {
  const _BreakingNewsWidgetContent();

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<BreakingNewsController>(context);
    final colors = Theme.of(context).extension<T4LThemeColors>()!;
    
    final article = controller.savedArticles.isNotEmpty 
        ? controller.savedArticles.first 
        : (controller.articles.isNotEmpty ? controller.articles.first : null);

    final imageUrl = article?.imageUrl;

    return GestureDetector(
      onTap: () {
        final app = AppRegistry().getApp('breaking_news');
        if (app != null) {
          NavigationService().openApp(context, app);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
             BoxShadow(
               color: Colors.black.withOpacity(0.1),
               blurRadius: 10,
               offset: const Offset(0, 4),
             )
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: article == null
            ? (controller.isLoading 
                ? const Center(child: CircularProgressIndicator())
                : Center(child: Icon(Icons.flash_on_rounded, color: colors.textSecondary, size: 40)))
            : Stack(
                fit: StackFit.expand,
                children: [
                   // Background Image
                   if (imageUrl != null)
                     CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(color: colors.surface),
                        errorWidget: (context, url, error) => Container(color: colors.surface),
                     )
                   else
                      Container(color: colors.surface),
                   
                   // Gradient Overlay
                   Container(
                     decoration: BoxDecoration(
                       gradient: LinearGradient(
                         begin: Alignment.topCenter,
                         end: Alignment.bottomCenter,
                         colors: [
                           Colors.transparent,
                           Colors.black.withOpacity(0.8),
                         ],
                         stops: const [0.4, 1.0],
                       ),
                     ),
                   ),
                   
                   // Content
                   Padding(
                     padding: const EdgeInsets.all(16.0),
                     child: Column(
                       mainAxisAlignment: MainAxisAlignment.end,
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                          // Tag
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: colors.breakingNewsRed,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              AppLocalizations.of(context)!.breakingNewsTag,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            article.headline,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                          ),
                          if (controller.savedArticles.contains(article))
                             Padding(
                               padding: const EdgeInsets.only(top: 8),
                               child: Row(
                                 children: [
                                   Icon(Icons.bookmark, color: colors.brand, size: 14),
                                   const SizedBox(width: 4),
                                   Text(
                                     AppLocalizations.of(context)!.breakingNewsSavedLabel, 
                                     style: TextStyle(color: colors.brand, fontSize: 12)
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
