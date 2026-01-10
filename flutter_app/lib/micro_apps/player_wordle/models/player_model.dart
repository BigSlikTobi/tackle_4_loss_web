/// Player model for the NFL Guessing Game.
/// Represents an NFL player with all attributes used for comparison.
library;

/// Positions considered offensive
const offensivePositions = [
  'QB', 'RB', 'FB', 'WR', 'TE', 'OT', 'OG', 'C', 'T', 'G'
];

/// Positions considered defensive
const defensivePositions = [
  'DE', 'DT', 'NT', 'LB', 'ILB', 'OLB', 'MLB', 'CB', 'S', 'SS', 'FS', 'DB', 'EDGE'
];

/// Represents an NFL player with all attributes.
class Player {
  final String playerId;
  final String displayName;
  final String? team;
  final String? conference;
  final String? division;
  final String? position;
  final int? jerseyNumber;
  final int? age;
  final int? height; // Height in inches
  final String? headshot;
  final String? college;
  final String? teamName;
  final String? teamLogo;
  final int? weight;
  final int? yearsExperience;
  final int? draftYear;
  final int? draftRound;
  final int? draftPick;

  const Player({
    required this.playerId,
    required this.displayName,
    this.team,
    this.conference,
    this.division,
    this.position,
    this.jerseyNumber,
    this.age,
    this.height,
    this.headshot,
    this.college,
    this.teamName,
    this.teamLogo,
    this.weight,
    this.yearsExperience,
    this.draftYear,
    this.draftRound,
    this.draftPick,
  });

  /// Returns which side of the ball the player is on.
  String get sideOfBall {
    final pos = position?.toUpperCase() ?? '';
    if (offensivePositions.contains(pos)) return 'Offense';
    if (defensivePositions.contains(pos)) return 'Defense';
    return 'Special';
  }

  /// Formatted height display (e.g., "6'2\"").
  String get displayHeight {
    if (height == null) return 'N/A';
    final feet = height! ~/ 12;
    final inches = height! % 12;
    return "$feet'$inches\"";
  }

  /// Creates a Player from JSON returned by the API.
  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      playerId: json['playerId'] ?? json['player_id'] ?? '',
      displayName: json['displayName'] ?? json['display_name'] ?? 'Unknown',
      team: json['team'] as String?,
      conference: json['conference'] as String?,
      division: json['division'] as String?,
      position: json['position'] as String?,
      jerseyNumber: json['jerseyNumber'] as int? ?? json['jersey_number'] as int?,
      age: json['age'] as int?,
      height: json['height'] as int?,
      headshot: json['headshot'] as String?,
      college: json['college'] as String?,
      teamName: json['teamName'] as String?,
      teamLogo: json['teamLogo'] as String?,
      weight: json['weight'] as int?,
      yearsExperience: json['yearsExperience'] as int?,
      draftYear: json['draftYear'] as int?,
      draftRound: json['draftRound'] as int?,
      draftPick: json['draftPick'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
    'playerId': playerId,
    'displayName': displayName,
    'team': team,
    'conference': conference,
    'division': division,
    'position': position,
    'jerseyNumber': jerseyNumber,
    'age': age,
    'height': height,
    'headshot': headshot,
    'college': college,
    'teamName': teamName,
    'teamLogo': teamLogo,
    'weight': weight,
    'yearsExperience': yearsExperience,
    'draftYear': draftYear,
    'draftRound': draftRound,
    'draftPick': draftPick,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Player &&
          runtimeType == other.runtimeType &&
          playerId == other.playerId;

  @override
  int get hashCode => playerId.hashCode;
}
