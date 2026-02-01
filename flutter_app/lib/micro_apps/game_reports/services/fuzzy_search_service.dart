import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Service for calling the fuzzy_search cloud function.
/// Used to look up players, teams, and games by name.
class FuzzySearchService {
  static const String _endpoint =
      'https://fuzzy-search-hjm4dt4a5q-uc.a.run.app';

  /// Search for players matching a query.
  Future<List<FuzzySearchResult>> searchPlayers(
    String query, {
    String? team,
    String? position,
    int limit = 5,
  }) async {
    return _search(
      entityType: 'players',
      query: query,
      filters: {
        if (team != null) 'team': team,
        if (position != null) 'position': position,
      },
      limit: limit,
    );
  }

  /// Search for teams matching a query.
  Future<List<FuzzySearchResult>> searchTeams(
    String query, {
    int limit = 5,
  }) async {
    return _search(
      entityType: 'teams',
      query: query,
      limit: limit,
    );
  }

  /// Search for games matching a query.
  Future<List<FuzzySearchResult>> searchGames(
    String query, {
    int? week,
    int? season,
    int limit = 5,
  }) async {
    return _search(
      entityType: 'games',
      query: query,
      filters: {
        if (week != null) 'week': week,
        if (season != null) 'season': season,
      },
      limit: limit,
    );
  }

  Future<List<FuzzySearchResult>> _search({
    required String entityType,
    required String query,
    Map<String, dynamic>? filters,
    int limit = 5,
  }) async {
    try {
      final body = {
        'entity_type': entityType,
        'query': query,
        'limit': limit,
        if (entityType == 'players' && filters != null)
          'player_filters': filters,
        if (entityType == 'games' && filters != null) 'game_filters': filters,
      };

      final response = await http
          .post(
            Uri.parse(_endpoint),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final results = json['results'] as List? ?? [];
        return results.map((r) => FuzzySearchResult.fromJson(r)).toList();
      } else {
        debugPrint('Fuzzy search error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('Fuzzy search failed: $e');
      return [];
    }
  }
}

/// Result from fuzzy search.
class FuzzySearchResult {
  final String id;
  final String name;
  final double score;
  final Map<String, dynamic> data;

  FuzzySearchResult({
    required this.id,
    required this.name,
    required this.score,
    required this.data,
  });

  factory FuzzySearchResult.fromJson(Map<String, dynamic> json) {
    return FuzzySearchResult(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? json['display_name']?.toString() ?? '',
      score: (json['score'] ?? json['match_score'] ?? 0).toDouble(),
      data: json,
    );
  }
}
