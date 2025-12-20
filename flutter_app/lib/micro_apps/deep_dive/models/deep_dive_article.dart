class DeepDiveArticle {
  final String id;
  final String title;
  final String summary;
  final String content; // Markdown support
  final String imageUrl;
  final String? audioUrl;
  final DateTime publishedAt;
  final String author;

  DeepDiveArticle({
    required this.id,
    required this.title,
    required this.summary,
    required this.content,
    required this.imageUrl,
    this.audioUrl,
    required this.publishedAt,
    required this.author,
  });

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
    );
  }
}
