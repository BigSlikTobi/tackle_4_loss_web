import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/analysis_envelope_model.dart';

/// Service for calling the Game Analysis Package cloud function.
/// Fetches enriched game data for FunctionGemma to generate reports.
class GameAnalysisService {
  static final GameAnalysisService _instance = GameAnalysisService._internal();
  factory GameAnalysisService() => _instance;
  GameAnalysisService._internal();

  static const String _endpoint =
      'https://game-analysis-hjm4dt4a5q-uc.a.run.app';

  /// Fetches an analysis envelope for a specific game.
  /// Returns null if the request fails.
  Future<AnalysisEnvelope?> fetchEnvelope({
    required String gameId,
    required int season,
    required int week,
  }) async {
    try {
      final requestBody = {
        'schema_version': '1.0.0',
        'producer': 'flutter_app/game_reports@1.0.0',
        'game_package': {
          'season': season,
          'week': week,
          'game_id': gameId,
          'plays': [], // Empty plays - cloud function fetches from DB
        },
      };

      debugPrint('Calling Game Analysis Package: $_endpoint');
      debugPrint('Request body: $requestBody');

      final response = await http
          .post(
            Uri.parse(_endpoint),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(requestBody),
          )
          .timeout(const Duration(seconds: 30));

      debugPrint('Game Analysis response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        debugPrint('Response keys: ${json.keys}');

        // Check for analysis_envelope first, then enriched_package
        Map<String, dynamic>? envelopeData;

        if (json['analysis_envelope'] != null) {
          debugPrint('Found analysis_envelope!');
          envelopeData = json['analysis_envelope'];
        } else if (json['enriched_package'] != null) {
          debugPrint('Found enriched_package! Using it as envelope source.');
          envelopeData = json['enriched_package'];
        }

        if (envelopeData != null) {
          debugPrint('Parsing envelope data...');
          try {
            return AnalysisEnvelope.fromJson(envelopeData);
          } catch (e) {
            debugPrint('Error parsing envelope: $e');
            // Try to extract game_info from enriched_package
            if (json['enriched_package'] != null) {
              return _parseFromEnrichedPackage(json);
            }
          }
        } else {
          debugPrint('No envelope data in response');
        }
      } else {
        debugPrint('Game Analysis API error: ${response.statusCode}');
        debugPrint('Response: ${response.body}');
      }
    } catch (e) {
      debugPrint('Failed to fetch analysis envelope: $e');
    }
    return null;
  }

  /// Parse envelope from enriched_package format
  AnalysisEnvelope? _parseFromEnrichedPackage(Map<String, dynamic> json) {
    try {
      final enriched = json['enriched_package'];
      final gameInfo = enriched['game_info'] ?? {};

      return AnalysisEnvelope(
        gameHeader: GameHeader(
          gameId: gameInfo['game_id'] ?? '',
          season: gameInfo['season'] ?? 0,
          week: gameInfo['week'] ?? 0,
          awayTeam: gameInfo['away_team'] ?? '',
          homeTeam: gameInfo['home_team'] ?? '',
          awayScore: gameInfo['away_score'] ?? 0,
          homeScore: gameInfo['home_score'] ?? 0,
          gameday: gameInfo['gameday'] ?? '',
          winner: gameInfo['winner'] ?? '',
        ),
        teamSummaries: _parseTeamSummaries(enriched['team_data']),
        playerMap: _parsePlayerMap(enriched['player_data']),
        keySequences: [],
        dataPointers: DataPointers(playByPlayUrl: '', boxScoreUrl: ''),
      );
    } catch (e) {
      debugPrint('Error parsing enriched package: $e');
      return null;
    }
  }

  Map<String, TeamSummary> _parseTeamSummaries(dynamic teamData) {
    final result = <String, TeamSummary>{};
    if (teamData == null) return result;

    try {
      final teams = teamData as Map<String, dynamic>;
      for (final entry in teams.entries) {
        final data = entry.value as Map<String, dynamic>;
        result[entry.key] = TeamSummary(
          teamId: entry.key,
          record: data['record'] ?? '0-0',
          totalYards: data['total_yards'] ?? 0,
          passingYards: data['passing_yards'] ?? 0,
          rushingYards: data['rushing_yards'] ?? 0,
          turnovers: data['turnovers'] ?? 0,
          timeOfPossession: (data['time_of_possession'] ?? 0).toDouble(),
        );
      }
    } catch (e) {
      debugPrint('Error parsing team summaries: $e');
    }
    return result;
  }

  Map<String, PlayerInfo> _parsePlayerMap(dynamic playerData) {
    final result = <String, PlayerInfo>{};
    if (playerData == null) return result;

    try {
      final players = playerData as Map<String, dynamic>;
      for (final entry in players.entries) {
        final data = entry.value as Map<String, dynamic>;
        result[entry.key] = PlayerInfo(
          playerId: entry.key,
          name: data['name'] ?? data['display_name'] ?? 'Unknown',
          position: data['position'] ?? '',
          team: data['team'] ?? '',
          statLine: data['stat_line'] ?? '',
          impactScore: (data['impact_score'] ?? 0).toDouble(),
        );
      }
    } catch (e) {
      debugPrint('Error parsing player map: $e');
    }
    return result;
  }

  /// Checks if the cloud function is reachable.
  Future<bool> isServiceAvailable() async {
    try {
      final response = await http
          .get(Uri.parse(_endpoint))
          .timeout(const Duration(seconds: 5));
      return response.statusCode < 500;
    } catch (e) {
      return false;
    }
  }
}
