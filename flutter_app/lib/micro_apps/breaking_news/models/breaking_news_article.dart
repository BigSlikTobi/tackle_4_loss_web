class BreakingNewsArticle {
  final String id;
  final String title;
  final String description;
  final String source;
  final DateTime publishedAt;
  final String imageUrl;

  BreakingNewsArticle({
    required this.id,
    required this.title,
    required this.description,
    required this.source,
    required this.publishedAt,
    required this.imageUrl,
  });

  factory BreakingNewsArticle.mock(int index) {
    return BreakingNewsArticle(
      id: 'news-$index',
      title: 'Star QB Agrees to Record-Breaking Extension: \$275 Million Deal',
      description: 'The franchise quarterback has secured his future with the team, setting a new market standard for the position.',
      source: 'NFL Network',
      publishedAt: DateTime.now().subtract(Duration(hours: index * 2)),
      imageUrl: 'https://images.unsplash.com/photo-1566577739112-5180d4bf9390?q=80&w=3426&auto=format&fit=crop', // Stadium/Football generic
    );
  }
}
