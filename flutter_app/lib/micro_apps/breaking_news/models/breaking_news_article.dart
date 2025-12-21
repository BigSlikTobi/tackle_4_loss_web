class BreakingNewsArticle {
  final String id;
  final String headline;
  final String? subHeader;
  final String? introductionParagraph;
  final String? content;
  final String? imageUrl;
  final DateTime createdAt;
  final List<dynamic>? teams; // List of team objects from JSON
  final List<dynamic>? players; // List of player ID objects from JSON
  final String? url;
  final String? audioFile;

  BreakingNewsArticle({
    required this.id,
    required this.headline,
    this.subHeader,
    this.introductionParagraph,
    this.content,
    this.imageUrl,
    required this.createdAt,
    this.teams,
    this.players,
    this.url,
    this.audioFile,
  });

  factory BreakingNewsArticle.fromJson(Map<String, dynamic> json) {
    return BreakingNewsArticle(
      id: json['id'] as String,
      headline: json['headline'] as String,
      subHeader: json['subHeader'] as String?,
      introductionParagraph: json['introductionParagraph'] as String?,
      content: json['content'] as String?,
      imageUrl: json['imageUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      teams: json['teams'] as List<dynamic>?,
      players: json['players'] as List<dynamic>?,
      url: json['url'] as String?,
      audioFile: json['audioFile'] as String?,
    );
  }
}
