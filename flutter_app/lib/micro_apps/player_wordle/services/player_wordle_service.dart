/// Service for the NFL Guessing Game.
/// Handles all API calls to Supabase edge functions.
library;

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/player_model.dart';
import '../models/guess_result.dart';
import '../models/game_state.dart';

/// Service for interacting with the Player Wordle game backend.
class PlayerWordleService {
  late final SupabaseClient _supabase;

  /// Default constructor - initializes Supabase client.
  PlayerWordleService() : _supabase = Supabase.instance.client;

  /// Testing constructor - allows subclasses without Supabase initialization.
  @protected
  PlayerWordleService.testing() : _supabase = _DummySupabaseClient();

  /// Fetches a random player ID for a new game.
  Future<String> getRandomPlayerId({Difficulty difficulty = Difficulty.pro}) async {
    try {
      final response = await _supabase.functions.invoke(
        'get-random-player',
        body: {'difficulty': difficulty.name},
      );

      if (response.status != 200) {
        throw Exception('Failed to get random player: ${response.status}');
      }

      final data = response.data as Map<String, dynamic>;
      return data['playerId'] as String;
    } catch (e) {
      debugPrint('PlayerWordleService.getRandomPlayerId error: $e');
      rethrow;
    }
  }

  /// Fetches the daily challenge player ID.
  /// Returns the same player for all users on the same day.
  Future<DailyPlayerResult> getDailyPlayerId({Difficulty difficulty = Difficulty.pro}) async {
    try {
      final response = await _supabase.functions.invoke(
        'get-daily-player',
        body: {'difficulty': difficulty.name},
      );

      if (response.status != 200) {
        throw Exception('Failed to get daily player: ${response.status}');
      }

      final data = response.data as Map<String, dynamic>;
      return DailyPlayerResult(
        playerId: data['playerId'] as String,
        date: data['date'] as String,
        teamsInvolved: (data['teamsInvolved'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList() ?? [],
      );
    } catch (e) {
      debugPrint('PlayerWordleService.getDailyPlayerId error: $e');
      rethrow;
    }
  }

  /// Searches for players by name (autocomplete) with optional filters.
  Future<List<Player>> searchPlayers(
    String query, {
    int limit = 10,
    int offset = 0,
    String? team,
    String? position,
    String difficulty = 'pro',
  }) async {
    // Allow search with empty query if filters are active (browse mode)
    final hasFilters = team != null || position != null;
    if (query.isEmpty && !hasFilters) return [];

    try {
      final response = await _supabase.functions.invoke(
        'search-players',
        body: {
          'query': query, 
          'limit': limit,
          'offset': offset,
          if (team != null) 'team': team,
          if (position != null) 'position': position,
          'difficulty': difficulty, 
        },
      );

      if (response.status != 200) {
        throw Exception('Failed to search players: ${response.status}');
      }

      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((json) => Player.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('PlayerWordleService.searchPlayers error: $e');
      rethrow;
    }
  }

  /// Compares a guessed player against the mystery player.
  Future<GuessResult> compareGuess({
    required String guessedPlayerId,
    required String mysteryPlayerId,
  }) async {
    try {
      final response = await _supabase.functions.invoke(
        'compare-player-guess',
        body: {
          'guessedPlayerId': guessedPlayerId,
          'mysteryPlayerId': mysteryPlayerId,
        },
      );

      if (response.status != 200) {
        throw Exception('Failed to compare guess: ${response.status}');
      }

      final data = response.data as Map<String, dynamic>;
      return GuessResult.fromJson(data);
    } catch (e) {
      debugPrint('PlayerWordleService.compareGuess error: $e');
      rethrow;
    }
  }

  /// Gets full player details for the reveal screen.
  Future<Player> getPlayerDetails(String playerId) async {
    try {
      final response = await _supabase.functions.invoke(
        'get-player-details',
        body: {'playerId': playerId},
      );

      if (response.status != 200) {
        throw Exception('Failed to get player details: ${response.status}');
      }

      final data = response.data as Map<String, dynamic>;
      return Player.fromJson(data);
    } catch (e) {
      debugPrint('PlayerWordleService.getPlayerDetails error: $e');
      rethrow;
    }
  }
}

/// Dummy SupabaseClient for testing constructors.
class _DummySupabaseClient implements SupabaseClient {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

/// Result from daily player endpoint.
class DailyPlayerResult {
  final String playerId;
  final String date;
  final List<String> teamsInvolved;

  const DailyPlayerResult({
    required this.playerId,
    required this.date,
    required this.teamsInvolved,
  });
}
