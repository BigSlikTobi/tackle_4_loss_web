/// Game state model for the NFL Guessing Game.
/// Tracks current game progress, guesses, and status.
library;

import 'guess_result.dart';

/// Current status of the game.
enum GameStatus {
  /// Game is in progress, player can still guess
  playing,

  /// Player guessed correctly
  won,

  /// Player ran out of guesses
  lost,
}

/// Difficulty level for player selection.
enum Difficulty {
  /// Specific starters (QB1, RB1, WR1/2, etc.)
  fan,

  /// Top positions only (QB, RB, WR, TE, DE, CB)
  rookie,

  /// All starting positions
  pro,

  /// All players including backups
  allMadden,
}

/// Represents the current state of a game session.
class GameState {
  /// ID of the mystery player to guess
  final String mysteryPlayerId;

  /// List of guesses made so far
  final List<GuessResult> guesses;

  /// Current game status
  final GameStatus status;

  /// Difficulty level
  final Difficulty difficulty;

  /// Maximum allowed guesses (default: 8)
  final int maxGuesses;

  /// Whether the hint was used
  final bool hintUsed;

  /// College name if hint was revealed
  final String? revealedHint;

  const GameState({
    required this.mysteryPlayerId,
    this.guesses = const [],
    this.status = GameStatus.playing,
    this.difficulty = Difficulty.pro,
    this.maxGuesses = 8,
    this.hintUsed = false,
    this.revealedHint,
  });

  /// Number of guesses remaining.
  int get remainingGuesses => maxGuesses - guesses.length;

  /// Whether the game is still active.
  bool get isPlaying => status == GameStatus.playing;

  /// Whether the game has ended (won or lost).
  bool get isGameOver => status != GameStatus.playing;

  /// Silhouette reveal level (0-2 based on guesses made).
  /// 0 = Pure black silhouette (guesses 1-3)
  /// 1 = Slightly revealed (guesses 4-6)
  /// 2 = Nearly revealed (guesses 7-8)
  int get silhouetteLevel {
    if (guesses.length <= 3) return 0;
    if (guesses.length <= 6) return 1;
    return 2;
  }

  /// Creates a new state after adding a guess.
  GameState addGuess(GuessResult guess) {
    final newGuesses = [...guesses, guess];

    GameStatus newStatus = status;
    if (guess.isCorrect) {
      newStatus = GameStatus.won;
    } else if (newGuesses.length >= maxGuesses) {
      newStatus = GameStatus.lost;
    }

    return GameState(
      mysteryPlayerId: mysteryPlayerId,
      guesses: newGuesses,
      status: newStatus,
      difficulty: difficulty,
      maxGuesses: maxGuesses,
      hintUsed: hintUsed,
      revealedHint: revealedHint,
    );
  }

  /// Creates a new state after using the hint.
  GameState useHint(String collegeName) {
    return GameState(
      mysteryPlayerId: mysteryPlayerId,
      guesses: guesses,
      status: status,
      difficulty: difficulty,
      maxGuesses: maxGuesses,
      hintUsed: true,
      revealedHint: collegeName,
    );
  }

  /// Creates an initial game state for a new game.
  factory GameState.newGame({
    required String mysteryPlayerId,
    Difficulty difficulty = Difficulty.pro,
  }) {
    return GameState(
      mysteryPlayerId: mysteryPlayerId,
      difficulty: difficulty,
    );
  }
}
