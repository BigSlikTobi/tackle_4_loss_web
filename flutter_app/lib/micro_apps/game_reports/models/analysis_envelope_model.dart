// Top-level analysis envelope returned by the cloud function.
class AnalysisEnvelope {
  final GameHeader gameHeader;
  final Map<String, TeamSummary> teamSummaries;
  final Map<String, PlayerInfo> playerMap;
  final List<KeySequence> keySequences;
  final DataPointers dataPointers;

  AnalysisEnvelope({
    required this.gameHeader,
    required this.teamSummaries,
    required this.playerMap,
    required this.keySequences,
    required this.dataPointers,
  });

  factory AnalysisEnvelope.fromJson(Map<String, dynamic> json) {
    return AnalysisEnvelope(
      gameHeader: GameHeader.fromJson(json['game_header'] ?? {}),
      teamSummaries: (json['team_summaries'] as Map<String, dynamic>? ?? {})
          .map((k, v) => MapEntry(k, TeamSummary.fromJson(v))),
      playerMap: (json['player_map'] as Map<String, dynamic>? ?? {}).map(
        (k, v) => MapEntry(k, PlayerInfo.fromJson(v)),
      ),
      keySequences: (json['key_sequences'] as List? ?? [])
          .map((e) => KeySequence.fromJson(e))
          .toList(),
      dataPointers: DataPointers.fromJson(json['data_pointers'] ?? {}),
    );
  }

  /// Converts the envelope to a compact string for LLM context.
  String toContextString() {
    final buffer = StringBuffer();

    // Game header
    buffer.writeln('GAME: ${gameHeader.awayTeam} @ ${gameHeader.homeTeam}');
    buffer.writeln('SCORE: ${gameHeader.awayScore} - ${gameHeader.homeScore}');
    buffer.writeln('DATE: ${gameHeader.gameday}, Week ${gameHeader.week}');
    buffer.writeln();

    // Team summaries
    buffer.writeln('TEAM SUMMARIES:');
    for (final entry in teamSummaries.entries) {
      final team = entry.value;
      buffer.writeln(
        '- ${entry.key}: ${team.record} record, ${team.totalYards} yards, ${team.turnovers} turnovers',
      );
    }
    buffer.writeln();

    // Key players
    buffer.writeln('KEY PLAYERS:');
    for (final entry in playerMap.entries.take(5)) {
      final player = entry.value;
      buffer.writeln(
        '- ${player.name} (${player.position}): ${player.statLine}',
      );
    }

    return buffer.toString();
  }
}

/// Game header with basic info.
class GameHeader {
  final String gameId;
  final int season;
  final int week;
  final String awayTeam;
  final String homeTeam;
  final int awayScore;
  final int homeScore;
  final String gameday;
  final String winner;

  GameHeader({
    required this.gameId,
    required this.season,
    required this.week,
    required this.awayTeam,
    required this.homeTeam,
    required this.awayScore,
    required this.homeScore,
    required this.gameday,
    required this.winner,
  });

  factory GameHeader.fromJson(Map<String, dynamic> json) {
    return GameHeader(
      gameId: json['game_id'] ?? '',
      season: json['season'] ?? 0,
      week: json['week'] ?? 0,
      awayTeam: json['away_team'] ?? '',
      homeTeam: json['home_team'] ?? '',
      awayScore: json['away_score'] ?? 0,
      homeScore: json['home_score'] ?? 0,
      gameday: json['gameday'] ?? '',
      winner: json['winner'] ?? '',
    );
  }
}

/// Summary statistics for a team.
class TeamSummary {
  final String teamId;
  final String record;
  final int totalYards;
  final int passingYards;
  final int rushingYards;
  final int turnovers;
  final double timeOfPossession;

  TeamSummary({
    required this.teamId,
    required this.record,
    required this.totalYards,
    required this.passingYards,
    required this.rushingYards,
    required this.turnovers,
    required this.timeOfPossession,
  });

  factory TeamSummary.fromJson(Map<String, dynamic> json) {
    return TeamSummary(
      teamId: json['team_id'] ?? '',
      record: json['record'] ?? '',
      totalYards: json['total_yards'] ?? 0,
      passingYards: json['passing_yards'] ?? 0,
      rushingYards: json['rushing_yards'] ?? 0,
      turnovers: json['turnovers'] ?? 0,
      timeOfPossession: (json['time_of_possession'] ?? 0).toDouble(),
    );
  }
}

/// Player info with stats.
class PlayerInfo {
  final String playerId;
  final String name;
  final String position;
  final String team;
  final String statLine;
  final double impactScore;

  PlayerInfo({
    required this.playerId,
    required this.name,
    required this.position,
    required this.team,
    required this.statLine,
    required this.impactScore,
  });

  factory PlayerInfo.fromJson(Map<String, dynamic> json) {
    return PlayerInfo(
      playerId: json['player_id'] ?? '',
      name: json['name'] ?? 'Unknown',
      position: json['position'] ?? '',
      team: json['team'] ?? '',
      statLine: json['stat_line'] ?? '',
      impactScore: (json['impact_score'] ?? 0).toDouble(),
    );
  }
}

/// Key game sequence (drive, scoring play, etc.)
class KeySequence {
  final String type;
  final String description;
  final int quarter;
  final String time;

  KeySequence({
    required this.type,
    required this.description,
    required this.quarter,
    required this.time,
  });

  factory KeySequence.fromJson(Map<String, dynamic> json) {
    return KeySequence(
      type: json['type'] ?? '',
      description: json['description'] ?? '',
      quarter: json['quarter'] ?? 0,
      time: json['time'] ?? '',
    );
  }
}

/// Pointers to additional data sources.
class DataPointers {
  final String playByPlayUrl;
  final String boxScoreUrl;

  DataPointers({required this.playByPlayUrl, required this.boxScoreUrl});

  factory DataPointers.fromJson(Map<String, dynamic> json) {
    return DataPointers(
      playByPlayUrl: json['play_by_play_url'] ?? '',
      boxScoreUrl: json['box_score_url'] ?? '',
    );
  }
}
