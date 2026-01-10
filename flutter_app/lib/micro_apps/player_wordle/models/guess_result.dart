/// Models for guess results in the NFL Guessing Game.
/// Contains comparison status types and result structures.
library;

import 'player_model.dart';

/// Match status for categorical comparisons.
enum MatchStatus {
  /// Exact match (green)
  match,
  /// No match (grey/red)
  miss,
  /// Partial match - e.g., same side of ball (yellow)
  partial,
}

/// Direction for numeric comparisons.
enum NumericDirection {
  /// Target is higher than guess (↑)
  up,
  /// Target is lower than guess (↓)
  down,
  /// Exact match
  exact,
}

/// Result of comparing a numeric attribute.
class NumericComparison {
  /// Whether it's an exact match
  final bool match;
  /// Direction to the target (up/down/exact)
  final NumericDirection direction;
  /// Whether the guess is "close" (within 2)
  final bool isClose;

  const NumericComparison({
    required this.match,
    required this.direction,
    required this.isClose,
  });

  factory NumericComparison.fromJson(Map<String, dynamic> json) {
    return NumericComparison(
      match: json['match'] ?? false,
      direction: _parseDirection(json['direction']),
      isClose: json['isClose'] ?? false,
    );
  }

  static NumericDirection _parseDirection(String? dir) {
    switch (dir) {
      case 'up':
        return NumericDirection.up;
      case 'down':
        return NumericDirection.down;
      default:
        return NumericDirection.exact;
    }
  }

  /// Returns the display arrow character.
  String get arrowDisplay {
    switch (direction) {
      case NumericDirection.up:
        return '↑';
      case NumericDirection.down:
        return '↓';
      case NumericDirection.exact:
        return '✓';
    }
  }
}

/// Complete result of a guess comparing all attributes.
class GuessResult {
  /// The player that was guessed
  final Player guessedPlayer;
  /// Conference match status
  final MatchStatus conferenceMatch;
  /// Division match status
  final MatchStatus divisionMatch;
  /// Team match status
  final MatchStatus teamMatch;
  /// Position match status (partial = same side of ball)
  final MatchStatus positionMatch;
  /// Jersey number comparison
  final NumericComparison jerseyComparison;
  /// Age comparison
  final NumericComparison ageComparison;
  /// Height comparison
  final NumericComparison heightComparison;
  /// Whether this guess is correct (guessed player is the mystery player)
  final bool isCorrect;

  const GuessResult({
    required this.guessedPlayer,
    required this.conferenceMatch,
    required this.divisionMatch,
    required this.teamMatch,
    required this.positionMatch,
    required this.jerseyComparison,
    required this.ageComparison,
    required this.heightComparison,
    required this.isCorrect,
  });

  factory GuessResult.fromJson(Map<String, dynamic> json) {
    final comparison = json['comparison'] as Map<String, dynamic>? ?? {};
    
    return GuessResult(
      guessedPlayer: Player.fromJson(json['guessedPlayer'] ?? {}),
      conferenceMatch: _parseMatchStatus(comparison['conference']),
      divisionMatch: _parseMatchStatus(comparison['division']),
      teamMatch: _parseMatchStatus(comparison['team']),
      positionMatch: _parsePositionMatch(comparison['position']),
      jerseyComparison: NumericComparison.fromJson(
        comparison['jerseyNumber'] ?? {},
      ),
      ageComparison: NumericComparison.fromJson(
        comparison['age'] ?? {},
      ),
      heightComparison: NumericComparison.fromJson(
        comparison['height'] ?? {},
      ),
      isCorrect: json['isCorrect'] ?? false,
    );
  }

  static MatchStatus _parseMatchStatus(String? status) {
    switch (status) {
      case 'match':
        return MatchStatus.match;
      case 'partial':
      case 'side':
        return MatchStatus.partial;
      default:
        return MatchStatus.miss;
    }
  }

  static MatchStatus _parsePositionMatch(String? status) {
    switch (status) {
      case 'match':
        return MatchStatus.match;
      case 'side':
        return MatchStatus.partial;
      default:
        return MatchStatus.miss;
    }
  }
}
