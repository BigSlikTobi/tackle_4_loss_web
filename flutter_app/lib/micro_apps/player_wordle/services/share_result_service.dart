library;

import 'package:share_plus/share_plus.dart';
import '../models/game_state.dart';
import '../models/guess_result.dart';

/// Service for sharing Player Wordle game results.
class ShareResultService {
  /// Emoji for exact match
  static const String _matchEmoji = '🟩';
  /// Emoji for partial match
  static const String _partialEmoji = '🟨';
  /// Emoji for miss
  static const String _missEmoji = '⬜';

  /// Generate an emoji grid from the game's guesses.
  /// Each row represents a guess, each column an attribute.
  /// Attributes: Conference, Division, Team, Position, Jersey, Age, Height
  static String generateEmojiGrid(GameState gameState) {
    final buffer = StringBuffer();
    
    for (final guess in gameState.guesses) {
      buffer.writeln(_guessToEmojiRow(guess));
    }
    
    return buffer.toString().trim();
  }

  /// Convert a single guess to an emoji row.
  static String _guessToEmojiRow(GuessResult guess) {
    final emojis = [
      _matchStatusToEmoji(guess.conferenceMatch),
      _matchStatusToEmoji(guess.divisionMatch),
      _matchStatusToEmoji(guess.teamMatch),
      _matchStatusToEmoji(guess.positionMatch),
      _numericToEmoji(guess.jerseyComparison),
      _numericToEmoji(guess.ageComparison),
      _numericToEmoji(guess.heightComparison),
    ];
    return emojis.join();
  }

  /// Convert MatchStatus to emoji.
  static String _matchStatusToEmoji(MatchStatus status) {
    switch (status) {
      case MatchStatus.match:
        return _matchEmoji;
      case MatchStatus.partial:
        return _partialEmoji;
      case MatchStatus.miss:
        return _missEmoji;
    }
  }

  /// Convert NumericComparison to emoji.
  static String _numericToEmoji(NumericComparison comparison) {
    if (comparison.match) {
      return _matchEmoji;
    } else if (comparison.isClose) {
      return _partialEmoji;
    } else {
      return _missEmoji;
    }
  }

  /// Generate full share text including title and grid.
  static String generateShareText(GameState gameState, {String? playerName}) {
    final guessCount = gameState.guesses.length;
    final maxGuesses = gameState.maxGuesses;
    final won = gameState.status == GameStatus.won;
    
    final result = won ? '$guessCount/$maxGuesses' : 'X/$maxGuesses';
    final difficultyName = _getDifficultyName(gameState.difficulty);
    
    final buffer = StringBuffer();
    buffer.writeln('Guess the Player 🏈 $result');
    buffer.writeln('Difficulty: $difficultyName');
    if (playerName != null && won) {
      buffer.writeln('Player: $playerName');
    }
    buffer.writeln();
    buffer.writeln(generateEmojiGrid(gameState));
    buffer.writeln();
    buffer.writeln('Play at: tackle4loss.com');
    
    return buffer.toString();
  }

  /// Get human-readable difficulty name.
  static String _getDifficultyName(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.fan:
        return 'Fan';
      case Difficulty.rookie:
        return 'Rookie';
      case Difficulty.pro:
        return 'Pro';
      case Difficulty.allMadden:
        return 'All-Madden';
    }
  }

  /// Share the game result using native share sheet.
  static Future<void> shareResult(GameState gameState, {String? playerName}) async {
    final text = generateShareText(gameState, playerName: playerName);
    await Share.share(text, subject: 'Guess the Player Result');
  }
}
