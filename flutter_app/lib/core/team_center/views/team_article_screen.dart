import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/team_article.dart';

class TeamArticleScreen extends StatefulWidget {
  final String articleId;
  final String languageCode;
  final TeamArticle? initialArticle;

  const TeamArticleScreen({
    super.key,
    required this.articleId,
    required this.languageCode,
    this.initialArticle,
  });

  @override
  State<TeamArticleScreen> createState() => _TeamArticleScreenState();
}

class _TeamArticleScreenState extends State<TeamArticleScreen> {
  late Future<TeamArticle> _articleFuture;

  @override
  void initState() {
    super.initState();
    _articleFuture = _loadArticleDetails();
  }

  Future<TeamArticle> _loadArticleDetails() async {
    // If we have initial data with content/subHeadline/etc, return it.
    // However, initialArticle usually comes from the list/daily update which might only have title/summary.
    // So we fetch to be sure we have everything.

    try {
      final response = await Supabase.instance.client.functions.invoke(
        'get-team-article-detail',
        body: {'id': widget.articleId, 'language_code': widget.languageCode},
      );

      final data = response.data;
      if (data != null) {
        // Merge with initial data if needed, but the endpoint returns full data.
        // We create a new object from the response.
        // The response structure matches what TeamArticle.fromJson expects mostly,
        // but we need to ensure ID is there as the function returns specific fields.
        // The function selects: id, headline, image, sub_headline, introduction, bullet_points, content
        // (Wait, my implementation of get-team-article-detail selected: headline, image, sub_headline, introduction, bullet_points, content and mapped image to full URL. It did NOT select ID in the select string explicitly in the 'data' passed to fromJson unless I merge it.)

        // Actually, looking at my edge function implementation:
        // .select('headline, image, sub_headline, introduction, bullet_points, content')
        // It returns JSON { headline: ..., image: ..., ... }
        // TeamArticle.fromJson expects 'id'.

        final Map<String, dynamic> json = Map<String, dynamic>.from(data);
        json['id'] = widget.articleId; // Inject ID

        return TeamArticle.fromJson(json);
      }
    } catch (e) {
      debugPrint('Error fetching article details: $e');
    }

    if (widget.initialArticle != null) {
      return widget.initialArticle!;
    }

    throw Exception('Failed to load article');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Transparent for glassmorphism
      extendBodyBehindAppBar: true, // Allow content to go behind app bar
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                color: Colors.black
                    .withValues(alpha: 0.5), // More transparent dark overlay
              ),
            ),
          ),

          // Content
          SafeArea(
            child: FutureBuilder<TeamArticle>(
              future: _articleFuture,
              initialData:
                  widget.initialArticle, // Show what we have while loading
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    snapshot.data == null) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError && snapshot.data == null) {
                  return Center(
                      child: Text("Error: ${snapshot.error}",
                          style: const TextStyle(color: Colors.white)));
                }

                final article = snapshot.data;
                if (article == null) {
                  return const Center(
                      child: Text("Article not found",
                          style: TextStyle(color: Colors.white)));
                }

                return SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Headline
                      Text(
                        article.title,
                        style: const TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // 2. Image
                      if (article.imageUrl.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            article.imageUrl,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              height: 200,
                              color: Colors.grey[900],
                              child: const Center(
                                  child: Icon(Icons.broken_image,
                                      color: Colors.white54)),
                            ),
                          ),
                        ),

                      const SizedBox(height: 24),

                      // 3. Sub-headline
                      if (article.subHeadline != null &&
                          article.subHeadline!.isNotEmpty) ...[
                        Text(
                          article.subHeadline!,
                          style: const TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFE5E7EB), // Gray-200
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // 4. Bullet Points (Moved above Introduction)
                      if (article.bulletPoints != null &&
                          article.bulletPoints!.isNotEmpty) ...[
                        ...article.bulletPoints!.map((point) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(top: 6),
                                    child: Icon(Icons.circle,
                                        size: 6, color: Colors.blueAccent),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      point,
                                      style: const TextStyle(
                                        fontFamily: 'Outfit',
                                        fontSize: 16,
                                        color: Color(0xFFD1D5DB),
                                        height: 1.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )),
                        const SizedBox(height: 24),
                      ],

                      // 5. Introduction (Moved below Bullet Points)
                      if (article.introduction != null &&
                          article.introduction!.isNotEmpty) ...[
                        Text(
                          article.introduction!,
                          style: const TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 16,
                            color: Color(0xFFD1D5DB), // Gray-300
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // 6. Content
                      if (article.content != null &&
                          article.content!.isNotEmpty)
                        Text(
                          article.content!,
                          style: const TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 16,
                            color: Color(0xFFD1D5DB),
                            height: 1.6,
                          ),
                        ),

                      const SizedBox(height: 40),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
