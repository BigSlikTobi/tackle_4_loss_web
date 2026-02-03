class TeamReference {
  final String teamId;
  final String? logoUrl;

  TeamReference({required this.teamId, this.logoUrl});

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

  PlayerReference({this.headshotUrl, this.name, this.id});

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
    final createdAtValue = json['created_at'] ?? json['createdAt'];
    final createdAtString = createdAtValue is String ? createdAtValue : null;

    return BreakingNewsArticle(
      id: json['id'].toString(), // Safely handle int or String Ids
      headline: json['headline'] as String,
      subHeader: json['sub_header'] as String? ?? json['subHeader'] as String?,
      introductionParagraph:
          json['introduction_paragraph'] as String? ??
          json['introductionParagraph'] as String?,
      content: json['content'] as String?,
      imageUrl: json['image_url'] as String? ?? json['imageUrl'] as String?,
      createdAt: createdAtString != null
          ? DateTime.parse(createdAtString)
          : DateTime.now(),
      teams: (json['teams'] as List<dynamic>?)
          ?.whereType<Map>()
          .map((e) => TeamReference.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      players: (json['players'] as List<dynamic>?)
          ?.whereType<Map>()
          .map((e) => PlayerReference.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      url: json['url'] as String?,
      audioFile: json['audio_file'] as String? ?? json['audioFile'] as String?,
    );
  }
}
