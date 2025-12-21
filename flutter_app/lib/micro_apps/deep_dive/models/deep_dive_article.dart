class ArticleSection {
  final String id;
  final String content;

  ArticleSection({required this.id, required this.content});
}

class DeepDiveArticle {
  final String id;
  final String title;
  final String summary;
  final String? content; // Full content for fallback
  final List<ArticleSection>? sections; // New field for structured content
  final String imageUrl;
  final String? videoUrl;
  final String? audioUrl;
  final DateTime publishedAt;
  final String author;
  final String languageCode;

  DeepDiveArticle({
    required this.id,
    required this.title,
    required this.summary,
    this.content,
    this.sections,
    required this.imageUrl,
    this.audioUrl,
    this.videoUrl,
    required this.publishedAt,
    required this.author,
    required this.languageCode,
  });

  factory DeepDiveArticle.fromJson(Map<String, dynamic> json) {
    List<ArticleSection>? parsedSections;
    if (json['sections'] != null && json['sections'] is Map) {
      final sectionsMap = json['sections'] as Map<String, dynamic>;
      final sortedKeys = sectionsMap.keys.toList()..sort();
      parsedSections = sortedKeys.map((key) {
        return ArticleSection(
          id: key,
          content: sectionsMap[key] as String,
        );
      }).toList();
    }

    String? content = json['content'] as String?;
    
    // Fallback: If content is missing but sections exist, concatenate them
    if ((content == null || content.isEmpty) && parsedSections != null) {
      content = parsedSections.map((s) => s.content).join('\n\n');
    }

    return DeepDiveArticle(
      id: json['id'] as String,
      title: json['title'] as String,
      summary: json['subtitle'] as String,
      content: content,
      sections: parsedSections,
      imageUrl: json['hero_image_url'] as String,
      audioUrl: json['audio_file'] as String?,
      videoUrl: json['video_file'] as String?,
      publishedAt: DateTime.parse(json['published_at'] as String),
      author: json['author'] as String,
      languageCode: json['language_code'] as String,
    );
  }

  // Mock Factory
  factory DeepDiveArticle.mock() {
    return DeepDiveArticle(
      id: 'mock-1',
      title: 'The Evolution of the Spread Offense',
      summary: 'How modern schemes are changing defensive strategies forever.',
      content: '''
## The Rise of Space

In the early 2000s, football was a game of collision. Today, it is a game of space. The rigorous geometry of the gridiron has been stretched, pulled, and manipulated by offensive coordinators who realized that the easiest way to beat a defender is simply to make him cover more grass than he is physically capable of.

### The Quarterback Revolution

Gone are the days of the statue in the pocket. The modern quarterback must be a point guard, a distributor who can diagnose leverage in milliseconds.

> "Speed kills, but space confuses." - Anonymous Scout

This Deep Dive explores the mathematical principles behind the modern spread and why the linebacker position is becoming an endangered species.
      ''',
      imageUrl: 'https://images.unsplash.com/photo-1541534741688-6078c6bfb5c5?q=80&w=3538&auto=format&fit=crop',
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3', // Free test audio
      publishedAt: DateTime.now(),
      author: 'Tobias Latta',
      languageCode: 'en',
    );
  }
}
