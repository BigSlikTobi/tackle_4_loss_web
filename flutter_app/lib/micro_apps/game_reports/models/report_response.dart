/// Represents a generated game report.
class ReportResponse {
  /// The original game ID this report is for.
  final String gameId;
  
  /// The team names for display.
  final String awayTeam;
  final String homeTeam;
  
  /// Final scores.
  final int awayScore;
  final int homeScore;
  
  /// The main report headline.
  final String headline;
  
  /// The body content of the report.
  final String body;
  
  /// Key highlights/moments from the game.
  final List<String> highlights;
  
  /// Whether this report was enhanced with cloud AI.
  final bool isCloudEnhanced;
  
  /// Timestamp when the report was generated.
  final DateTime generatedAt;

  const ReportResponse({
    required this.gameId,
    required this.awayTeam,
    required this.homeTeam,
    required this.awayScore,
    required this.homeScore,
    required this.headline,
    required this.body,
    this.highlights = const [],
    this.isCloudEnhanced = false,
    required this.generatedAt,
  });
  
  /// Get the winner team name, or null for a tie.
  String? get winner {
    if (awayScore > homeScore) return awayTeam;
    if (homeScore > awayScore) return homeTeam;
    return null; // Tie
  }
  
  /// Get the loser team name, or null for a tie.
  String? get loser {
    if (awayScore > homeScore) return homeTeam;
    if (homeScore > awayScore) return awayTeam;
    return null; // Tie
  }
  
  /// Get a formatted score string (e.g., "Cowboys 31 - 24 Eagles").
  String get formattedScore => '$awayTeam $awayScore - $homeScore $homeTeam';
  
  /// Get the point differential (absolute value).
  int get scoreDifferential => (awayScore - homeScore).abs();
  
  /// Whether this was a close game (within 7 points).
  bool get wasCloseGame => scoreDifferential <= 7;
  
  /// Whether this was a blowout (20+ point difference).
  bool get wasBlowout => scoreDifferential >= 20;
}
