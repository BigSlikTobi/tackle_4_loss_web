import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../models/game_model.dart';

/// Service for fetching standings data from the Supabase edge function.
class StandingsService {
  late final SupabaseClient _supabase;
  static const String _functionName = 'get-latest-standings';

  /// Default constructor - initializes Supabase client
  StandingsService() : _supabase = Supabase.instance.client;
  
  /// Testing constructor - allows subclasses without Supabase initialization
  @protected
  StandingsService.testing() : _supabase = _DummySupabaseClient();

  /// Fetches all games from the standings table.
  /// Returns games sorted by season (desc), week, and gameday.
  Future<List<Game>> fetchGames() async {
    try {
      final response = await _supabase.functions.invoke(_functionName);

      if (response.status != 200) {
        throw Exception('Failed to fetch standings: ${response.status}');
      }

      final List<dynamic> jsonList = response.data as List<dynamic>;
      return jsonList
          .map((json) => Game.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('StandingsService.fetchGames error: $e');
      rethrow;
    }
  }

  /// Groups games by week number.
  /// Returns a map where keys are week numbers and values are lists of games.
  Map<int, List<Game>> groupGamesByWeek(List<Game> games) {
    final Map<int, List<Game>> grouped = {};
    
    for (final game in games) {
      grouped.putIfAbsent(game.week, () => []).add(game);
    }
    
    return grouped;
  }

  /// Finds the current week based on today's date.
  /// Returns the week whose games are closest to today (either next or previous).
  int findCurrentWeek(List<Game> games, DateTime today) {
    if (games.isEmpty) return 1;

    // Find the game with the closest gameday to today
    Game? closestGame;
    int minDiff = 999999;

    for (final game in games) {
      final diff = (game.gameday.difference(today).inDays).abs();
      if (diff < minDiff) {
        minDiff = diff;
        closestGame = game;
      }
    }

    return closestGame?.week ?? 1;
  }

  /// Gets all unique weeks from the games list, sorted.
  List<int> getWeeks(List<Game> games) {
    final weeks = games.map((g) => g.week).toSet().toList();
    weeks.sort();
    return weeks;
  }
}

/// Dummy SupabaseClient for testing constructors - never actually used
/// since mock classes override all methods that use the client.
class _DummySupabaseClient implements SupabaseClient {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
