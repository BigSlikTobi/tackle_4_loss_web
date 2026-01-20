/// Types of content that can appear in the news feed
enum FeedItemType {
  newsUpdate,
  video,       // Future: video content
  personalized, // Future: personalized recommendations
  deepDive,    // Deep dive article content
}

/// Base class for all feed items - extensible for future content types
sealed class FeedItem {
  final String id;
  final DateTime createdAt;
  final FeedItemType type;

  FeedItem({
    required this.id,
    required this.createdAt,
    required this.type,
  });

  factory FeedItem.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String? ?? 'newsUpdate';
    
    switch (type) {
      case 'video':
        return VideoFeedItem.fromJson(json);
      case 'personalized':
        return PersonalizedFeedItem.fromJson(json);
      case 'deepDive':
        return DeepDiveFeedItem.fromJson(json);
      case 'newsUpdate':
      default:
        return NewsFeedItem.fromJson(json);
    }
  }
}

/// News update feed item (x_post + image + source + headline + players + teams)
class NewsFeedItem extends FeedItem {
  final String xPost;
  final String? imageUrl;
  final String? source;
  final String? headline;
  final List<dynamic>? players; // List of player objects with headshot_url
  final List<dynamic>? teams;   // List of team objects with team_id

  NewsFeedItem({
    required super.id,
    required this.xPost,
    this.imageUrl,
    this.source,
    this.headline,
    this.players,
    this.teams,
    required super.createdAt,
  }) : super(type: FeedItemType.newsUpdate);

  factory NewsFeedItem.fromJson(Map<String, dynamic> json) {
    return NewsFeedItem(
      id: json['id'] as String,
      xPost: json['xPost'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      source: json['source'] as String?,
      headline: json['headline'] as String?,
      players: json['players'] as List<dynamic>?,
      teams: json['teams'] as List<dynamic>?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

/// Placeholder for future video feed items
class VideoFeedItem extends FeedItem {
  final String title;
  final String? thumbnailUrl;
  final String videoUrl;
  final Duration? duration;

  VideoFeedItem({
    required super.id,
    required this.title,
    this.thumbnailUrl,
    required this.videoUrl,
    this.duration,
    required super.createdAt,
  }) : super(type: FeedItemType.video);

  factory VideoFeedItem.fromJson(Map<String, dynamic> json) {
    return VideoFeedItem(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      thumbnailUrl: json['thumbnailUrl'] as String?,
      videoUrl: json['videoUrl'] as String? ?? '',
      duration: json['durationSeconds'] != null 
          ? Duration(seconds: json['durationSeconds'] as int)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

/// Placeholder for future personalized content items
class PersonalizedFeedItem extends FeedItem {
  final String title;
  final String subtitle;
  final String? imageUrl;
  final String? actionUrl;

  PersonalizedFeedItem({
    required super.id,
    required this.title,
    required this.subtitle,
    this.imageUrl,
    this.actionUrl,
    required super.createdAt,
  }) : super(type: FeedItemType.personalized);

  factory PersonalizedFeedItem.fromJson(Map<String, dynamic> json) {
    return PersonalizedFeedItem(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      actionUrl: json['actionUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

/// Deep dive article feed item
class DeepDiveFeedItem extends FeedItem {
  final String articleId;
  final String title;
  final String summary;
  final String? imageUrl;
  final String author;

  DeepDiveFeedItem({
    required super.id,
    required this.articleId,
    required this.title,
    required this.summary,
    this.imageUrl,
    required this.author,
    required super.createdAt,
  }) : super(type: FeedItemType.deepDive);

  factory DeepDiveFeedItem.fromJson(Map<String, dynamic> json) {
    return DeepDiveFeedItem(
      id: json['id'] as String,
      articleId: json['articleId'] as String,
      title: json['title'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      author: json['author'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
