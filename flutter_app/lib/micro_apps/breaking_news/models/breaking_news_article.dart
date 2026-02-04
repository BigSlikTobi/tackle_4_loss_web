class TeamReference {
  final String teamId;
  final String? logoUrl;

  TeamReference({
    required this.teamId,
    this.logoUrl,
  });

  factory TeamReference.fromJson(Map<String, dynamic> json) {
    return TeamReference(
      teamId: json['team_id']?.toString() ?? '',
      logoUrl: json['logo_url'] as String?,
    );
  }
}

class PlayerReference {
  final String? headshotUrl;
  final String? name;
  final String? id;

  PlayerReference({
    this.headshotUrl,
    this.name,
    this.id,
  });

  factory PlayerReference.fromJson(Map<String, dynamic> json) {
    return PlayerReference(
      headshotUrl: json['headshot_url'] as String?,
      name: json['name'] as String?,
      id: json['id']?.toString(),
    );
  }
}

class BreakingNewsArticle {
  final String id;
  final String headline;
  final String? subHeader;
  final String? introductionParagraph;
  final String? content;
  final String? imageUrl;
  final DateTime createdAt;
  final List<TeamReference>? teams;
  final List<PlayerReference>? players;
  final String? url;
  final String? audioFile;
  final String? sourceUrl;
  final String? imageSource;

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
    this.sourceUrl,
    this.imageSource,
    String? sourceName,
  }) : _sourceName = sourceName;

  /// Helper to get a displayable source name from the URL or return "Source"
  String get sourceName {
    // If we have an explicit source name from the API (joined table), use it
    if (_sourceName != null && _sourceName.isNotEmpty) {
      return _sourceName;
    }
    
    // Fallback to parsing URL
    if (sourceUrl == null) return 'Source';
    try {
      final uri = Uri.parse(sourceUrl!);
      return uri.host.replaceFirst('www.', '');
    } catch (_) {
      return 'Source';
    }
  }

  // Internal storage for source name from API
  final String? _sourceName;

  factory BreakingNewsArticle.fromJson(Map<String, dynamic> json) {
    return BreakingNewsArticle(
      id: json['id'].toString(), // Safely handle int or String Ids
      headline: json['headline'] as String,
      subHeader: json['subHeader'] as String?,
      introductionParagraph: json['introductionParagraph'] as String?,
      content: json['content'] as String?,
      imageUrl: json['imageUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      teams: (json['teams'] as List<dynamic>?)
          ?.whereType<Map>()
          .map((e) => TeamReference.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      players: (json['players'] as List<dynamic>?)
          ?.whereType<Map>()
          .map((e) => PlayerReference.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      url: json['url'] as String?,
      audioFile: json['audioFile'] as String?,
      sourceUrl: (json['source_url'] ?? json['sourceUrl']) as String?,
      imageSource: (json['image_source'] ?? json['imageSource']) as String?,
      // Pass source_name through constructor to private field
      sourceName: (json['source_name'] ?? json['sourceName']) as String?,
    );
  }
}
