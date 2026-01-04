/// Game model representing a single NFL game from the standings database.
/// Maps to the `public.games` table schema.
class Game {
  final String id;
  final String gameId;
  final int season;
  final String gameType; // REG, POST, etc.
  final int week;
  final DateTime gameday;
  final String weekday;
  final String gametime;
  final String awayTeam; // 3-letter team code (DAL, PHI, etc.)
  final int? awayScore; // null if game not played yet
  final String homeTeam;
  final int? homeScore;
  final String? location;
  final int? result;
  final int? total;
  final int overtime;
  final String? pfr;
  final String? pff;
  final String? ftn;
  final String? roof;
  final String? surface;
  final int? temp;
  final int? wind;
  final String? referee;
  final String? stadium;

  const Game({
    required this.id,
    required this.gameId,
    required this.season,
    required this.gameType,
    required this.week,
    required this.gameday,
    required this.weekday,
    required this.gametime,
    required this.awayTeam,
    this.awayScore,
    required this.homeTeam,
    this.homeScore,
    this.location,
    this.result,
    this.total,
    required this.overtime,
    this.pfr,
    this.pff,
    this.ftn,
    this.roof,
    this.surface,
    this.temp,
    this.wind,
    this.referee,
    this.stadium,
  });

  /// Whether the game has been played (has scores)
  bool get isPlayed => awayScore != null && homeScore != null;

  /// Whether the game went to overtime
  bool get isOvertime => overtime > 0;

  /// Winner team code (null if tie or not played)
  String? get winner {
    if (!isPlayed) return null;
    if (awayScore! > homeScore!) return awayTeam;
    if (homeScore! > awayScore!) return homeTeam;
    return null; // Tie
  }

  /// Creates a Game from JSON map (from edge function response)
  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      id: json['id'] as String,
      gameId: json['gameId'] as String,
      season: json['season'] as int,
      gameType: json['gameType'] as String,
      week: json['week'] as int,
      gameday: DateTime.parse(json['gameday'] as String),
      weekday: json['weekday'] as String,
      gametime: json['gametime'] as String,
      awayTeam: json['awayTeam'] as String,
      awayScore: json['awayScore'] as int?,
      homeTeam: json['homeTeam'] as String,
      homeScore: json['homeScore'] as int?,
      location: json['location'] as String?,
      result: json['result'] as int?,
      total: json['total'] as int?,
      overtime: json['overtime'] as int? ?? 0,
      pfr: json['pfr'] as String?,
      pff: json['pff'] as String?,
      ftn: json['ftn'] as String?,
      roof: json['roof'] as String?,
      surface: json['surface'] as String?,
      temp: json['temp'] as int?,
      wind: json['wind'] as int?,
      referee: json['referee'] as String?,
      stadium: json['stadium'] as String?,
    );
  }

  /// Converts Game to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'gameId': gameId,
      'season': season,
      'gameType': gameType,
      'week': week,
      'gameday': gameday.toIso8601String().split('T').first,
      'weekday': weekday,
      'gametime': gametime,
      'awayTeam': awayTeam,
      'awayScore': awayScore,
      'homeTeam': homeTeam,
      'homeScore': homeScore,
      'location': location,
      'result': result,
      'total': total,
      'overtime': overtime,
      'pfr': pfr,
      'pff': pff,
      'ftn': ftn,
      'roof': roof,
      'surface': surface,
      'temp': temp,
      'wind': wind,
      'referee': referee,
      'stadium': stadium,
    };
  }

  @override
  String toString() => 'Game($gameId: $awayTeam @ $homeTeam, Week $week)';
}
