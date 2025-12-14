import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models.dart';
import '../services/breaking_news_service.dart';
import '../design_tokens.dart';

class BreakingNewsDetailScreen extends StatefulWidget {
  final String initialNewsId;
  final List<BreakingNews> allNews;

  const BreakingNewsDetailScreen({
    super.key,
    required this.initialNewsId,
    required this.allNews,
  });

  @override
  State<BreakingNewsDetailScreen> createState() => _BreakingNewsDetailScreenState();
}

class _BreakingNewsDetailScreenState extends State<BreakingNewsDetailScreen> {
  final BreakingNewsService _service = BreakingNewsService();
  String _currentId = '';
  BreakingNewsDetail? _detail;
  bool _isLoading = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _currentId = widget.initialNewsId;
    _fetchDetail(_currentId);
  }

  Future<void> _fetchDetail(String id) async {
    setState(() {
      _isLoading = true;
      _detail = null; // Clear previous content while loading
    });
    
    // Reset scroll
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }

    try {
      final detail = await _service.fetchBreakingNewsDetail(id);
      if (mounted) {
        setState(() {
          _detail = detail;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _navigateTo(String id) {
    setState(() => _currentId = id);
    _fetchDetail(id);
  }

  @override
  Widget build(BuildContext context) {
    // Navigation Logic
    final currentIndex = widget.allNews.indexWhere((n) => n.id == _currentId);
    final previousArticle = currentIndex > 0 ? widget.allNews[currentIndex - 1] : null;
    final nextArticle = currentIndex != -1 && currentIndex < widget.allNews.length - 1 
        ? widget.allNews[currentIndex + 1] 
        : null;

    // Use current detail or fallback to finding the item in the list for initial headline/image while loading
    final currentListItem = widget.allNews.firstWhere((n) => n.id == _currentId, orElse: () => widget.allNews[0]);
    final heroImage = _detail?.imageUrl ?? currentListItem.imageUrl;
    final headline = _detail?.headline ?? currentListItem.headline;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Main Scrollable Content
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Hero Image App Bar
              SliverAppBar(
                expandedHeight: 400.0,
                floating: false,
                pinned: false, // Let it scroll away
                backgroundColor: Colors.black,
                automaticallyImplyLeading: false, // Custom back button
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (heroImage != null)
                        CachedNetworkImage(
                          imageUrl: heroImage,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(color: Colors.grey[900]),
                          errorWidget: (context, url, error) => Container(color: Colors.grey[900]),
                        )
                      else
                        Container(
                          color: Colors.black,
                          child: const Center(child: Text("T4L", style: TextStyle(color: Colors.white10, fontSize: 80, fontWeight: FontWeight.w900))),
                        ),
                      
                      // Gradient Overlays
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.black54, Colors.transparent, Colors.black87],
                            stops: [0.0, 0.4, 1.0],
                          ),
                        ),
                      ),

                      // Headline Overlay
                      Positioned(
                        bottom: 32,
                        left: 24,
                        right: 24,
                        child: Text(
                          headline,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            height: 1.1,
                            letterSpacing: -0.5,
                            shadows: [Shadow(color: Colors.black54, offset: Offset(0, 4), blurRadius: 10)],
                          ),
                        ),
                      ),

                      // Image Source
                      if (_detail?.imageSource != null)
                        Positioned(
                          bottom: 12,
                          right: 16,
                          child: Text(
                            "Image: ${_detail!.imageSource}",
                            style: const TextStyle(
                              color: Colors.white38,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Content Body
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator(color: AppColors.breakingNewsRed))
                    else if (_detail != null) ...[
                      // Introduction
                      if (_detail!.introduction.isNotEmpty)
                        Container(
                          decoration: const BoxDecoration(
                            border: Border(left: BorderSide(color: AppColors.breakingNewsRed, width: 4)),
                          ),
                          padding: const EdgeInsets.only(left: 16, top: 4, bottom: 4),
                          margin: const EdgeInsets.only(bottom: 32),
                          child: Text(
                            _detail!.introduction,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600, // Medium/SemiBold
                              height: 1.5,
                              color: AppColors.neutralText,
                            ),
                          ),
                        ),
                      
                      // Markdown Content
                      MarkdownBody(
                        data: _detail!.content,
                        styleSheet: MarkdownStyleSheet(
                          p: const TextStyle(fontSize: 18, height: 1.6, color: AppColors.neutralText),
                          h1: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, height: 1.4, color: AppColors.neutralText),
                          h2: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, height: 1.4, color: AppColors.neutralText),
                          blockSpacing: 24.0,
                        ),
                      ),

                      // Source Link
                      if (_detail?.sourceUrl != null) ...[
                        const SizedBox(height: 32),
                        const Divider(height: 1, color: AppColors.neutralBorder),
                        const SizedBox(height: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "SOURCE",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: AppColors.neutralTextLight,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            InkWell(
                              onTap: () async {
                                final uri = Uri.parse(_detail!.sourceUrl!);
                                if (await canLaunchUrl(uri)) {
                                  await launchUrl(uri);
                                }
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    Uri.parse(_detail!.sourceUrl!).host.replaceFirst('www.', ''),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.neutralText,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(LucideIcons.externalLink, size: 12, color: AppColors.neutralTextLight),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],

                      const SizedBox(height: 64),

                      // Navigation Footer
                      const Divider(height: 1, color: AppColors.neutralBorder),
                      const SizedBox(height: 32),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Previous Button
                          if (previousArticle != null)
                             InkWell(
                               onTap: () => _navigateTo(previousArticle.id),
                               borderRadius: BorderRadius.circular(8),
                               child: Row(
                                 children: [
                                   // Thumbnail
                                   Container(
                                     width: 48,
                                     height: 48,
                                     decoration: BoxDecoration(
                                       borderRadius: BorderRadius.circular(8),
                                       color: AppColors.neutralSoft,
                                       image: previousArticle.imageUrl != null ? DecorationImage(
                                         image: CachedNetworkImageProvider(previousArticle.imageUrl!),
                                         fit: BoxFit.cover,
                                       ) : null,
                                     ),
                                     child: previousArticle.imageUrl == null ? const Icon(LucideIcons.chevronLeft, size: 16, color: Colors.grey) : null,
                                   ),
                                   const SizedBox(width: 12),
                                   Column(
                                     crossAxisAlignment: CrossAxisAlignment.start,
                                     children: [
                                       const Text(
                                         "PREVIOUS",
                                         style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1.2),
                                       ),
                                     ],
                                   ),
                                 ],
                               ),
                             )
                          else
                             const SizedBox(width: 48),

                          // Next Button
                          if (nextArticle != null)
                             InkWell(
                               onTap: () => _navigateTo(nextArticle.id),
                               borderRadius: BorderRadius.circular(8),
                               child: Row(
                                 children: [
                                   Column(
                                     crossAxisAlignment: CrossAxisAlignment.end,
                                     children: [
                                       const Text(
                                         "NEXT",
                                         style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1.2),
                                       ),
                                     ],
                                   ),
                                   const SizedBox(width: 12),
                                   // Thumbnail
                                   Container(
                                     width: 48,
                                     height: 48,
                                     decoration: BoxDecoration(
                                       borderRadius: BorderRadius.circular(8),
                                       color: AppColors.neutralSoft,
                                       image: nextArticle.imageUrl != null ? DecorationImage(
                                          image: CachedNetworkImageProvider(nextArticle.imageUrl!),
                                          fit: BoxFit.cover,
                                       ) : null,
                                     ),
                                     child: nextArticle.imageUrl == null ? const Icon(LucideIcons.chevronRight, size: 16, color: Colors.grey) : null,
                                   ),
                                 ],
                               ),
                             )
                          else
                             const SizedBox(width: 48),
                        ],
                      ),
                      const SizedBox(height: 100), // Bottom padding
                    ],
                  ]),
                ),
              ),
            ],
          ),

          // Custom Back Button (Fixed)
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 20,
            child: GestureDetector(
               onTap: () => Navigator.of(context).pop(),
               child: Container(
                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                 decoration: BoxDecoration(
                   color: Colors.white, // White background simple pill
                   borderRadius: BorderRadius.circular(100),
                   boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
                 ),
                 child: const Row(
                   children: [
                     Icon(LucideIcons.arrowLeft, size: 18, color: Colors.black),
                     SizedBox(width: 4),
                     Text("Back", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                   ],
                 ),
               ),
            ),
          ),

          // Floating Audio Button
          Positioned(
            right: 20,
            bottom: 40,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(100),
                boxShadow: AppShadows.lg,
                border: Border.all(color: AppColors.neutralBorder),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                     // TODO: Implement audio playback for breaking news, or remove this button if not supported.
                     // Placeholder action
                     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Audio playback mock trigger")));
                  },
                  borderRadius: BorderRadius.circular(100),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(LucideIcons.volume2, size: 18, color: Colors.black),
                        SizedBox(width: 8),
                        Text(
                          "AUDIO",
                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.0),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
