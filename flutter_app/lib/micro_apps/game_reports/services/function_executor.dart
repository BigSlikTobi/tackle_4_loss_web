import '../../standings/models/game_model.dart';
import '../models/report_request.dart';
import '../models/report_response.dart';

/// Executes function calls and generates template-based reports.
/// This handles local report generation based on game data.
class FunctionExecutor {
  /// Generate a post-game recap for a completed game.
  ReportResponse generateGameRecap(Game game, ReportRequest request) {
    if (!game.isPlayed) {
      throw Exception('Cannot generate recap for unplayed game');
    }

    final headline = _generateHeadline(game, request.focusTeam);
    final body = _generateBody(game, request);
    final highlights = _generateHighlights(game);

    return ReportResponse(
      gameId: game.gameId,
      awayTeam: game.awayTeam,
      homeTeam: game.homeTeam,
      awayScore: game.awayScore!,
      homeScore: game.homeScore!,
      headline: headline,
      body: body,
      highlights: highlights,
      isCloudEnhanced: false,
      generatedAt: DateTime.now(),
    );
  }

  String _generateHeadline(Game game, String? focusTeam) {
    final winner = game.winner;
    final awayScore = game.awayScore!;
    final homeScore = game.homeScore!;
    final scoreDiff = (awayScore - homeScore).abs();

    // Handle tie
    if (winner == null) {
      return '${game.awayTeam} and ${game.homeTeam} Battle to $awayScore-$homeScore Tie';
    }

    // Focus team perspective
    if (focusTeam != null) {
      final focusNorm = focusTeam.toUpperCase();
      final isWinner = winner.toUpperCase() == focusNorm;
      if (isWinner) {
        if (scoreDiff >= 20) {
          return '$focusTeam Dominates with Commanding $awayScore-$homeScore Victory';
        } else if (scoreDiff <= 3) {
          return '$focusTeam Squeaks Out Thrilling $awayScore-$homeScore Win';
        } else {
          return '$focusTeam Secures $awayScore-$homeScore Victory';
        }
      } else {
        if (scoreDiff >= 20) {
          return '$focusTeam Falls in Tough $awayScore-$homeScore Loss';
        } else if (scoreDiff <= 3) {
          return '$focusTeam Drops Heartbreaker, $awayScore-$homeScore';
        } else {
          return '$focusTeam Falls Short, $awayScore-$homeScore';
        }
      }
    }

    // Generic headline
    if (scoreDiff >= 20) {
      return '$winner Crushes Opponent in $awayScore-$homeScore Blowout';
    } else if (scoreDiff <= 3) {
      return '$winner Edges Out $awayScore-$homeScore Thriller';
    } else if (game.isOvertime) {
      return '$winner Prevails $awayScore-$homeScore in Overtime Classic';
    } else {
      return '$winner Takes Down Opponent $awayScore-$homeScore';
    }
  }

  String _generateBody(Game game, ReportRequest request) {
    final buffer = StringBuffer();
    final awayScore = game.awayScore!;
    final homeScore = game.homeScore!;
    final total = awayScore + homeScore;
    final scoreDiff = (awayScore - homeScore).abs();

    // Opening paragraph
    buffer.writeln(_generateOpening(game));
    buffer.writeln();

    // Style-specific content
    switch (request.style) {
      case ReportStyle.casual:
        buffer.writeln(_generateCasualBody(game, total, scoreDiff));
        break;
      case ReportStyle.detailed:
        buffer.writeln(_generateDetailedBody(game, total, scoreDiff));
        break;
      case ReportStyle.stats:
        buffer.writeln(_generateStatsBody(game, total, scoreDiff));
        break;
    }

    return buffer.toString().trim();
  }

  String _generateOpening(Game game) {
    final winner = game.winner;
    final venue = game.stadium ?? 'the stadium';

    if (winner == null) {
      return 'In a hard-fought Week ${game.week} matchup at $venue, '
          'the ${game.awayTeam} and ${game.homeTeam} played to a '
          '${game.awayScore}-${game.homeScore} tie.';
    }

    final isHomeWinner = winner == game.homeTeam;
    final winnerText =
        isHomeWinner ? 'The home team' : 'The visiting ${game.awayTeam}';

    return '$winnerText emerged victorious in Week ${game.week} action at $venue, '
        'defeating the opponent ${game.awayScore}-${game.homeScore}.';
  }

  String _generateCasualBody(Game game, int total, int scoreDiff) {
    final buffer = StringBuffer();

    if (scoreDiff >= 20) {
      buffer.writeln('This one was never really close, as ${game.winner} '
          'controlled the game from start to finish.');
    } else if (scoreDiff <= 7) {
      buffer.writeln(
          'It was a back-and-forth battle that came down to the wire.');
    } else {
      buffer.writeln('The game featured solid performances from both sides.');
    }

    if (game.isOvertime) {
      buffer.writeln();
      buffer.writeln('The game required extra time to determine a winner, '
          'adding to the drama of an already exciting matchup.');
    }

    return buffer.toString();
  }

  String _generateDetailedBody(Game game, int total, int scoreDiff) {
    final buffer = StringBuffer();

    // Game conditions
    if (game.temp != null || game.wind != null) {
      buffer.write('Playing in ');
      if (game.temp != null) buffer.write('${game.temp}°F temperatures');
      if (game.temp != null && game.wind != null) buffer.write(' with ');
      if (game.wind != null) buffer.write('${game.wind} mph winds');
      buffer.writeln(', conditions played a factor in the game.');
      buffer.writeln();
    }

    // Score analysis
    if (total >= 50) {
      buffer.writeln('This high-scoring affair saw both offenses find success, '
          'combining for $total total points.');
    } else if (total <= 30) {
      buffer.writeln('Defense ruled the day in this low-scoring contest, '
          'with only $total total points scored.');
    } else {
      buffer.writeln('The final score reflected a balanced contest between '
          'offense and defense.');
    }

    if (game.isOvertime) {
      buffer.writeln();
      buffer.writeln('After regulation ended in a tie, ${game.winner} '
          'found a way to secure the win in overtime.');
    }

    return buffer.toString();
  }

  String _generateStatsBody(Game game, int total, int scoreDiff) {
    final buffer = StringBuffer();

    buffer.writeln('**Game Statistics:**');
    buffer.writeln(
        '- Final Score: ${game.awayTeam} ${game.awayScore} @ ${game.homeTeam} ${game.homeScore}');
    buffer.writeln('- Total Points: $total');
    buffer.writeln('- Point Differential: $scoreDiff');
    buffer.writeln('- Week ${game.week} | ${game.gameType} Game');

    if (game.isOvertime) {
      buffer.writeln('- Overtime: Yes');
    }

    if (game.stadium != null) {
      buffer.writeln('- Venue: ${game.stadium}');
    }

    if (game.temp != null) {
      buffer.writeln('- Temperature: ${game.temp}°F');
    }

    if (game.wind != null) {
      buffer.writeln('- Wind: ${game.wind} mph');
    }

    if (game.referee != null) {
      buffer.writeln('- Referee: ${game.referee}');
    }

    return buffer.toString();
  }

  List<String> _generateHighlights(Game game) {
    final highlights = <String>[];
    final scoreDiff = (game.awayScore! - game.homeScore!).abs();
    final total = game.awayScore! + game.homeScore!;

    if (game.isOvertime) {
      highlights.add('🏈 Game went to overtime');
    }

    if (scoreDiff >= 20) {
      highlights.add('💪 ${game.winner} won by $scoreDiff points');
    } else if (scoreDiff <= 3) {
      highlights.add('🔥 Decided by just $scoreDiff points');
    }

    if (total >= 60) {
      highlights.add('📈 High-scoring shootout with $total total points');
    } else if (total <= 20) {
      highlights.add('🛡️ Defensive battle with only $total total points');
    }

    if (game.winner != game.homeTeam) {
      highlights.add('✈️ Road victory for ${game.winner}');
    }

    return highlights;
  }
}
