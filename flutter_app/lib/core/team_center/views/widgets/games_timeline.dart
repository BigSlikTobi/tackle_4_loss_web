import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../micro_apps/standings/models/game_model.dart';

class GamesTimeline extends StatelessWidget {
  final Game? pastGame;
  final Game? lastGame;
  final Game? nextGame;
  final Color? teamColor;
  final String teamId;

  const GamesTimeline({
    super.key,
    this.pastGame,
    this.lastGame,
    this.nextGame,
    this.teamColor,
    required this.teamId,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140, // Height constraint for the timeline row
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Visual Connection Line
          Positioned(
            top: 60,
            left: 40,
            right: 40,
            child: Container(
              height: 2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.0),
                    Colors.white.withValues(alpha: 0.2),
                    Colors.white.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),

          Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Past Game (Left)
                  if (pastGame != null)
                    _buildSideCard(context, pastGame!, 'PAST GAME', isLeft: true)
                  else
                    const SizedBox(width: 70), // Spacer placeholder

                  const SizedBox(width: 8),

                  // Last / Main Game (Center)
                  if (lastGame != null)
                    _buildCenterCard(context, lastGame!)
                  else
                    _buildEmptyCenterCard(context),

                  const SizedBox(width: 8),

                  // Next Game (Right)
                  if (nextGame != null)
                    _buildSideCard(
                        context, nextGame!, 'NEXT GAME', isLeft: false)
                  else
                    const SizedBox(width: 70),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Helper to determine display info relative to the selected team
  ({
    bool isWin,
    bool isTie,
    String resultString,
    String opponent,
    String scoreString,
    bool isHomeGame,
    bool isPlayed
  }) _getGameDisplayInfo(Game game) {
    final normalizedTeamId = teamId.toUpperCase();
    final homeTeam = game.homeTeam.toUpperCase();
    final awayTeam = game.awayTeam.toUpperCase();

    final isHomeGame = homeTeam == normalizedTeamId;
    final opponent = isHomeGame ? game.awayTeam : game.homeTeam;

    if (!game.isPlayed) {
      return (
        isWin: false,
        isTie: false,
        resultString: '',
        opponent: opponent,
        scoreString: '', // No score yet
        isHomeGame: isHomeGame,
        isPlayed: false,
      );
    }

    final homeScore = game.homeScore ?? 0;
    final awayScore = game.awayScore ?? 0;

    final myScore = isHomeGame ? homeScore : awayScore;
    final opponentScore = isHomeGame ? awayScore : homeScore;

    final isWin = myScore > opponentScore;
    final isTie = myScore == opponentScore;
    
    // Result String: W, L, T
    String resultString = 'L';
    if (isWin) {
      resultString = 'W';
    } else if (isTie) {
      resultString = 'T';
    }

    // Score String: Always "Winner-Loser" convention or "MyScore-OpponentScore" logic?
    // User requested "NYJ 8-35 vs Buffalo". 
    // Conventionally, American sports show "WinnerScore-LoserScore" (35-8) OR "AwayScore-HomeScore" final.
    // The previous code had `${game.awayScore}-${game.homeScore}`.
    // Let's stick to a standard display. 
    // Ideally: "W 17-10" or "L 10-17". Usually "W [MyScore]-[OppScore]" or "L [MyScore]-[OppScore]".
    // Let's use "MyScore - OpponentScore" to be clear on the outcome.
    
    // Actually, looking at the screenshot "W 8-35 vs NYJ" (which was wrong).
    // Let's show "MyScore - OpponentScore" so "L 8-35" makes sense (if I lost 8 to 35).
    
    final scoreString = '$myScore-$opponentScore';

    return (
      isWin: isWin,
      isTie: isTie,
      resultString: resultString,
      opponent: opponent,
      scoreString: scoreString,
      isHomeGame: isHomeGame,
      isPlayed: true
    );
  }

  Widget _buildCenterCard(BuildContext context, Game game) {
    final info = _getGameDisplayInfo(game);
    final cardColor = teamColor ?? const Color(0xFF1F222B);

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: 150,
          height: 120,
          decoration: BoxDecoration(
            color: cardColor.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'LAST GAME',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 10,
                    letterSpacing: 1.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),

                // Score Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      info.resultString,
                      style: TextStyle(
                        color: info.isWin
                            ? Colors.greenAccent
                            : (info.isTie ? Colors.orangeAccent : Colors.redAccent),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      info.scoreString,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 2),

                // Opponent
                Text(
                  'vs ${info.opponent}', 
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 6),

                // Status Badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'FINAL',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyCenterCard(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: 150,
          height: 120,
          decoration: BoxDecoration(
            color: (teamColor ?? Colors.white).withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white10),
          ),
          child: const Center(
              child: Text("No Data", style: TextStyle(color: Colors.white54))),
        ),
      ),
    );
  }

  Widget _buildSideCard(BuildContext context, Game game, String label,
      {required bool isLeft}) {
    
    final info = _getGameDisplayInfo(game);

    // Past/Next games are smaller and transparent
    return Opacity(
      opacity: 0.4,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            width: 80,
            height: 100,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (teamColor ?? Colors.white).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  
                  // Content dependent on Past vs Next (Played vs Not Played)
                  if (info.isPlayed) ...[
                     Text(
                      '${info.resultString} ${info.scoreString}', // e.g. "W 21-17"
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                     const SizedBox(height: 1),
                     Text(
                      'vs ${info.opponent}',
                      style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                  ] else ...[
                    // Upcoming game
                    Text(
                      info.isHomeGame ? 'vs' : '@',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                     Text(
                      info.opponent,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],

                  const SizedBox(height: 2),
                  // ignore: deprecated_member_use_from_same_package
                  Text(
                    DateFormat('EEE h:mm a').format(game.gameday), // "SAT 9:00 PM"
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 9,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
