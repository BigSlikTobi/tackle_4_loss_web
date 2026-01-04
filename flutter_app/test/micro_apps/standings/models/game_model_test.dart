import 'package:flutter_test/flutter_test.dart';
import 'package:tackle4loss_mobile/micro_apps/standings/models/game_model.dart';

void main() {
  group('Game Model', () {
    group('fromJson', () {
      test('parses complete game JSON correctly', () {
        final json = {
          'id': '1',
          'gameId': '2024_01_KC_DET',
          'season': 2024,
          'gameType': 'REG',
          'week': 1,
          'gameday': '2024-09-05',
          'weekday': 'Thursday',
          'gametime': '20:20',
          'awayTeam': 'KC',
          'awayScore': 24,
          'homeTeam': 'DET',
          'homeScore': 21,
          'location': 'Ford Field',
          'result': 3,
          'total': 45,
          'overtime': 0,
          'pfr': 'abc123',
          'pff': 'def456',
          'ftn': 'ghi789',
          'roof': 'dome',
          'surface': 'fieldturf',
          'temp': 72,
          'wind': 0,
          'referee': 'John Hussey',
          'stadium': 'Ford Field',
        };

        final game = Game.fromJson(json);

        expect(game.id, '1');
        expect(game.gameId, '2024_01_KC_DET');
        expect(game.season, 2024);
        expect(game.gameType, 'REG');
        expect(game.week, 1);
        expect(game.weekday, 'Thursday');
        expect(game.gametime, '20:20');
        expect(game.awayTeam, 'KC');
        expect(game.awayScore, 24);
        expect(game.homeTeam, 'DET');
        expect(game.homeScore, 21);
        expect(game.overtime, 0);
        expect(game.location, 'Ford Field');
      });

      test('handles null scores for unplayed games', () {
        final json = {
          'id': '2',
          'gameId': '2024_02_SF_MIN',
          'season': 2024,
          'gameType': 'REG',
          'week': 2,
          'gameday': '2024-09-15',
          'weekday': 'Sunday',
          'gametime': '13:00',
          'awayTeam': 'SF',
          'awayScore': null,
          'homeTeam': 'MIN',
          'homeScore': null,
          'overtime': 0,
        };

        final game = Game.fromJson(json);

        expect(game.awayScore, isNull);
        expect(game.homeScore, isNull);
        expect(game.isPlayed, isFalse);
      });
    });

    group('isPlayed', () {
      test('returns true when both scores are present', () {
        final game = _createGame(awayScore: 24, homeScore: 21);
        expect(game.isPlayed, isTrue);
      });

      test('returns false when awayScore is null', () {
        final game = _createGame(awayScore: null, homeScore: 21);
        expect(game.isPlayed, isFalse);
      });

      test('returns false when homeScore is null', () {
        final game = _createGame(awayScore: 24, homeScore: null);
        expect(game.isPlayed, isFalse);
      });

      test('returns false when both scores are null', () {
        final game = _createGame(awayScore: null, homeScore: null);
        expect(game.isPlayed, isFalse);
      });
    });

    group('isOvertime', () {
      test('returns true when overtime > 0', () {
        final game = _createGame(overtime: 1);
        expect(game.isOvertime, isTrue);
      });

      test('returns false when overtime is 0', () {
        final game = _createGame(overtime: 0);
        expect(game.isOvertime, isFalse);
      });
    });

    group('winner', () {
      test('returns away team when away score is higher', () {
        final game = _createGame(awayScore: 28, homeScore: 21);
        expect(game.winner, 'KC');
      });

      test('returns home team when home score is higher', () {
        final game = _createGame(awayScore: 21, homeScore: 28);
        expect(game.winner, 'SF');
      });

      test('returns null on tie', () {
        final game = _createGame(awayScore: 21, homeScore: 21);
        expect(game.winner, isNull);
      });

      test('returns null when game not played', () {
        final game = _createGame(awayScore: null, homeScore: null);
        expect(game.winner, isNull);
      });
    });

    group('toJson', () {
      test('serializes all fields correctly', () {
        final game = _createGame(awayScore: 24, homeScore: 21);
        final json = game.toJson();

        expect(json['id'], '1');
        expect(json['gameId'], '2024_01_KC_SF');
        expect(json['awayTeam'], 'KC');
        expect(json['homeTeam'], 'SF');
        expect(json['awayScore'], 24);
        expect(json['homeScore'], 21);
        expect(json['week'], 1);
      });
    });

    group('toString', () {
      test('returns formatted string representation', () {
        final game = _createGame();
        expect(game.toString(), 'Game(2024_01_KC_SF: KC @ SF, Week 1)');
      });
    });
  });
}

/// Helper function to create test Game instances
Game _createGame({
  String id = '1',
  String gameId = '2024_01_KC_SF',
  int season = 2024,
  String gameType = 'REG',
  int week = 1,
  DateTime? gameday,
  String weekday = 'Sunday',
  String gametime = '13:00',
  String awayTeam = 'KC',
  int? awayScore = 24,
  String homeTeam = 'SF',
  int? homeScore = 21,
  int overtime = 0,
}) {
  return Game(
    id: id,
    gameId: gameId,
    season: season,
    gameType: gameType,
    week: week,
    gameday: gameday ?? DateTime(2024, 9, 8),
    weekday: weekday,
    gametime: gametime,
    awayTeam: awayTeam,
    awayScore: awayScore,
    homeTeam: homeTeam,
    homeScore: homeScore,
    overtime: overtime,
  );
}
