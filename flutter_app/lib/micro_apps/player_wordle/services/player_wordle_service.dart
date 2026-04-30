/// Stubbed in MVP slim — Player Wordle is flag-off and the underlying
/// edge functions (`get-random-player`, `get-daily-player`, `search-players`,
/// `compare-player-guess`, `get-player-details`) are gone with the new main
/// Supabase project.
///
// TODO(restore-on-revive): wire to new edge functions when the game returns.
library;

import 'package:flutter/foundation.dart';

import '../models/player_model.dart';
import '../models/guess_result.dart';
import '../models/game_state.dart';

class PlayerWordleService {
  PlayerWordleService();

  @protected
  PlayerWordleService.testing();

  Future<String> getRandomPlayerId(
      {Difficulty difficulty = Difficulty.pro}) async {
    throw UnimplementedError(
      'PlayerWordleService.getRandomPlayerId is disabled in MVP slim.',
    );
  }

  Future<DailyPlayerResult> getDailyPlayerId(
      {Difficulty difficulty = Difficulty.pro}) async {
    throw UnimplementedError(
      'PlayerWordleService.getDailyPlayerId is disabled in MVP slim.',
    );
  }

  Future<List<Player>> searchPlayers(
    String query, {
    int limit = 10,
    int offset = 0,
    String? team,
    String? position,
    String difficulty = 'pro',
  }) async {
    return const [];
  }

  Future<GuessResult> compareGuess({
    required String guessedPlayerId,
    required String mysteryPlayerId,
  }) async {
    throw UnimplementedError(
      'PlayerWordleService.compareGuess is disabled in MVP slim.',
    );
  }

  Future<Player> getPlayerDetails(String playerId) async {
    throw UnimplementedError(
      'PlayerWordleService.getPlayerDetails is disabled in MVP slim.',
    );
  }
}

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
