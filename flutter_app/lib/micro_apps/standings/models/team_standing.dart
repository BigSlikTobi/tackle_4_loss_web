/// Model representing a team's standing in the NFL.
class TeamStanding {
  final String teamId;
  final String teamName;
  final String conference;
  final String division;
  final String logoUrl;
  final int season;
  final int wins;
  final int losses;
  final int ties;
  final int pointsFor;
  final int pointsAgainst;
  final int conferenceWins;
  final int conferenceLosses;
  final int divisionWins;
  final int divisionLosses;
  final double winPercentage;
  final int netPoints;

  const TeamStanding({
    required this.teamId,
    required this.teamName,
    required this.conference,
    required this.division,
    required this.logoUrl,
    required this.season,
    required this.wins,
    required this.losses,
    required this.ties,
    required this.pointsFor,
    required this.pointsAgainst,
    required this.conferenceWins,
    required this.conferenceLosses,
    required this.divisionWins,
    required this.divisionLosses,
    required this.winPercentage,
    required this.netPoints,
  });

  /// Creates a TeamStanding from JSON.
  factory TeamStanding.fromJson(Map<String, dynamic> json) {
    return TeamStanding(
      teamId: json['teamId'] as String? ?? '',
      teamName: json['teamName'] as String? ?? '',
      conference: json['conference'] as String? ?? '',
      division: json['division'] as String? ?? '',
      logoUrl: json['logoUrl'] as String? ?? '',
      season: json['season'] as int? ?? 0,
      wins: json['wins'] as int? ?? 0,
      losses: json['losses'] as int? ?? 0,
      ties: json['ties'] as int? ?? 0,
      pointsFor: json['pointsFor'] as int? ?? 0,
      pointsAgainst: json['pointsAgainst'] as int? ?? 0,
      conferenceWins: json['conferenceWins'] as int? ?? 0,
      conferenceLosses: json['conferenceLosses'] as int? ?? 0,
      divisionWins: json['divisionWins'] as int? ?? 0,
      divisionLosses: json['divisionLosses'] as int? ?? 0,
      winPercentage: (json['winPercentage'] as num?)?.toDouble() ?? 0.0,
      netPoints: json['netPoints'] as int? ?? 0,
    );
  }

  /// Formatted record string (e.g., "13-4" or "13-3-1").
  String get record {
    if (ties > 0) {
      return '$wins-$losses-$ties';
    }
    return '$wins-$losses';
  }

  /// Formatted win percentage (e.g., ".765").
  String get formattedWinPercentage {
    return '.${(winPercentage * 1000).round().toString().padLeft(3, '0')}';
  }

  /// Formatted division record (e.g., "5-1").
  String get divisionRecord {
    return '$divisionWins-$divisionLosses';
  }

  /// Formatted conference record (e.g., "9-3").
  String get conferenceRecord {
    return '$conferenceWins-$conferenceLosses';
  }

  /// Formatted net points (e.g., "+157" or "-23").
  String get formattedNetPoints {
    if (netPoints > 0) {
      return '+$netPoints';
    }
    return '$netPoints';
  }
}

/// Model representing a division's standings.
class DivisionStandings {
  final String division;
  final List<TeamStanding> teams;

  const DivisionStandings({
    required this.division,
    required this.teams,
  });

  /// Creates a DivisionStandings from JSON.
  factory DivisionStandings.fromJson(Map<String, dynamic> json) {
    final teamsJson = json['teams'] as List<dynamic>? ?? [];
    return DivisionStandings(
      division: json['division'] as String? ?? '',
      teams: teamsJson
          .map((t) => TeamStanding.fromJson(t as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Full division name (e.g., "AFC East").
  String fullName(String conference) {
    return '$conference $division';
  }
}

/// Model representing a conference's standings.
class ConferenceStandings {
  final String conference;
  final List<DivisionStandings> divisions;

  const ConferenceStandings({
    required this.conference,
    required this.divisions,
  });

  /// Creates a ConferenceStandings from JSON.
  factory ConferenceStandings.fromJson(Map<String, dynamic> json) {
    final divisionsJson = json['divisions'] as List<dynamic>? ?? [];
    return ConferenceStandings(
      conference: json['conference'] as String? ?? '',
      divisions: divisionsJson
          .map((d) => DivisionStandings.fromJson(d as Map<String, dynamic>))
          .toList(),
    );
  }
}
