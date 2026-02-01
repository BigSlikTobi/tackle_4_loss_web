import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tackle4loss_mobile/core/team_center/views/widgets/games_timeline.dart';
import 'package:tackle4loss_mobile/micro_apps/standings/models/game_model.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// IMPORTANT: We need to bypass the _getGameDisplayInfo private method access limitation by testing the Widget output OR extracting logic.
// Since `_getGameDisplayInfo` is private, we will test the WIDGET output directly (finding text).

void main() {
  group('GamesTimeline Logic Tests', () {
    const teamId = 'NYJ';
    final now = DateTime.now();

    // Scenario 1: NYJ Home Game vs BUF, NYJ Lost 8-35 (User Scenario)
    // Home: NYJ, Away: BUF. HomeScore: 8, AwayScore: 35. -> NYJ Lost. Score: 8-35. Opp: BUF.
    testWidgets('Displays Loss and correct score for Home Loss (User Scenario)',
        (WidgetTester tester) async {
      final lastGame = Game(
        id: '1',
        gameId: '2024_01_BUF_NYJ',
        season: 2024,
        gameType: 'REG',
        week: 1,
        weekday: 'Sunday',
        gametime: '13:00',
        homeTeam: 'NYJ',
        awayTeam: 'BUF',
        homeScore: 8,
        awayScore: 35,
        overtime: 0,
        gameday: now.subtract(const Duration(days: 7)),
      );

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Scaffold(
            body: GamesTimeline(
              teamId: teamId,
              lastGame: lastGame,
            ),
          ),
        ),
      );

      // Expect "L" for Loss
      expect(find.text('L'), findsOneWidget);

      // Expect "8-35" (MyScore - OpponentScore)
      expect(find.text('8-35'), findsOneWidget);

      // Expect "vs BUF" (Home game implies 'vs', but text is explicitly 'vs Opponent')
      expect(find.text('vs BUF'), findsOneWidget);
    });

    // Scenario 2: NYJ Away Game vs MIA, NYJ Won 24-17
    // Home: MIA, Away: NYJ. HomeScore: 17, AwayScore: 24. -> NYJ Won. Score: 24-17. Opp: MIA.
    testWidgets('Displays Win and correct score for Away Win',
        (WidgetTester tester) async {
      final lastGame = Game(
        id: '2',
        gameId: '2024_02_NYJ_MIA',
        season: 2024,
        gameType: 'REG',
        week: 2,
        weekday: 'Sunday',
        gametime: '13:00',
        homeTeam: 'MIA',
        awayTeam: 'NYJ',
        homeScore: 17,
        awayScore: 24,
        overtime: 0,
        gameday: now.subtract(const Duration(days: 7)),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GamesTimeline(
              teamId: teamId,
              lastGame: lastGame,
            ),
          ),
        ),
      );

      // Expect "W" for Win
      expect(find.text('W'), findsOneWidget);

      // Expect "24-17" (MyScore - OpponentScore)
      expect(find.text('24-17'), findsOneWidget);

      // Expect "vs MIA"
      expect(find.text('vs MIA'), findsOneWidget);
    });

    // Scenario 3: Upcoming Game (Next Game) - Away at NE
    testWidgets('Displays Upcoming Game correctly',
        (WidgetTester tester) async {
      final nextGame = Game(
        id: '3',
        gameId: '2024_03_NYJ_NE',
        season: 2024,
        gameType: 'REG',
        week: 3,
        weekday: 'Sunday',
        gametime: '13:00',
        homeTeam: 'NE',
        awayTeam: 'NYJ',
        overtime: 0,
        gameday: now.add(const Duration(days: 7)),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GamesTimeline(
              teamId: teamId,
              nextGame: nextGame, // Pass as nextGame logic
            ),
          ),
        ),
      );

      // Should find side card for 'NEXT GAME'
      expect(find.text('NEXT GAME'), findsOneWidget);

      // Should show '@' for Away game
      expect(find.text('@'), findsOneWidget);

      // Should show opponent 'NE'
      expect(find.text('NE'), findsOneWidget);
    });
  });
}
