class TeamArticle {
  final String id;
  final String title;
  final String summary;
  final String imageUrl;
  final String? audioUrl;
  final DateTime publishedAt;
  final String? subHeadline;
  final String? introduction;
  final List<String>? bulletPoints;
  final String? content; // Full content

  const TeamArticle({
    required this.id,
    required this.title,
    required this.summary,
    required this.imageUrl,
    this.audioUrl,
    required this.publishedAt,
    this.subHeadline,
    this.introduction,
    this.bulletPoints,
    this.content,
  });

  factory TeamArticle.fromJson(Map<String, dynamic> json) {
    return TeamArticle(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? json['headline'] ?? '',
      summary: json['summary'] ?? (json['content'] != null ? (json['content'] as String).substring(0, (json['content'] as String).length > 100 ? 100 : (json['content'] as String).length) : ''),
      imageUrl: json['imageUrl'] ?? json['image'] ?? json['image_url'] ?? '',
      audioUrl: json['tts_file'],
      publishedAt: DateTime.tryParse(json['published_at'] ?? json['created_at'] ?? '') ?? DateTime.now(),
      subHeadline: json['sub_headline'],
      introduction: json['introduction'],
      bulletPoints: _parseBulletPoints(json['bullet_points']),
      content: json['content'],
    );
  }

  static List<String>? _parseBulletPoints(dynamic value) {
    if (value == null) return null;
    if (value is List) return value.map((e) => e.toString()).toList();
    if (value is String) {
      // Try to treat as JSON-like string if it looks like a list
      if (value.trim().startsWith('[') && value.trim().endsWith(']')) {
         // Simple cleanup without needing full jsonDecode for now to avoid dealing with imports/errors
         // Alternatively, just split by newline which is safer for text fields
         return value.replaceAll('[', '').replaceAll(']', '').split(',').map((e) => e.trim().replaceAll('"', '')).where((e) => e.isNotEmpty).toList();
      }
      // Assuming newline separated if simple string
      return value.split('\n').where((s) => s.trim().isNotEmpty).toList();
    }
    return [];
  }

  /// Mock factory for UI development
  factory TeamArticle.mock() {
    return TeamArticle(
      id: 'mock-1',
      title: 'Coach Saleh on Strategy Changes for Sunday',
      summary: 'Head coach discusses the defensive adjustments made during practice this week.',
      imageUrl: 'https://images.unsplash.com/photo-1566577739112-5180d4bf9390?q=80&w=3426&auto=format&fit=crop',
      publishedAt: DateTime.now(),
      subHeadline: 'Defensive Line Strategy',
      introduction: 'This is the introduction.',
      bulletPoints: ['Point 1', 'Point 2'],
      content: 'Full content goes here...',
    );
  }
}
