import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tackle4loss_mobile/micro_apps/player_wordle/controllers/player_wordle_controller.dart';
import 'package:tackle4loss_mobile/micro_apps/player_wordle/models/game_state.dart';
import 'package:tackle4loss_mobile/micro_apps/player_wordle/models/guess_result.dart';
import 'package:tackle4loss_mobile/micro_apps/player_wordle/models/player_model.dart';
import 'package:tackle4loss_mobile/micro_apps/player_wordle/services/player_wordle_service.dart';

// Mock Classes
class MockPlayerWordleService extends Mock implements PlayerWordleService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  setUpAll(() {
    registerFallbackValue(Difficulty.fan);
  });

  group('PlayerWordleController', () {
    late PlayerWordleController controller;
    late MockPlayerWordleService mockService;

    final dummyPlayer = Player(
      playerId: '123',
      displayName: 'Test Player',
      team: 'ARI',
      position: 'QB',
      college: 'Test U',
      headshot: 'http://test.com/img.png',
      jerseyNumber: 1,
      height: 72,
      weight: 200,
      age: 25,
      yearsExperience: 2,
    );

    final exactNumeric = NumericComparison(
      match: true,
      direction: NumericDirection.exact,
      isClose: false,
    );

    final correctGuessResult = GuessResult(
      guessedPlayer: dummyPlayer,
      conferenceMatch: MatchStatus.match,
      divisionMatch: MatchStatus.match,
      teamMatch: MatchStatus.match,
      positionMatch: MatchStatus.match,
      jerseyComparison: exactNumeric,
      heightComparison: exactNumeric,
      ageComparison: exactNumeric,
      isCorrect: true,
    );

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      mockService = MockPlayerWordleService();
      
      // Default mock behaviors
      when(() => mockService.getRandomPlayerId(difficulty: any(named: 'difficulty')))
          .thenAnswer((_) async => 'mystery_123');
      
      when(() => mockService.getPlayerDetails(any()))
          .thenAnswer((_) async => dummyPlayer);

      controller = PlayerWordleController.withService(mockService);
    });

    test('initialize loads statistics and starts new game', () async {
      await controller.initialize();

      expect(controller.gamesPlayed, 0);
      expect(controller.gamesWon, 0);
      expect(controller.gameState, isNotNull);
      expect(controller.gameState!.mysteryPlayerId, 'mystery_123');
      expect(controller.selectedDifficulty, Difficulty.fan);
    });

    test('startNewGame resets state and gets new mystery player', () async {
      when(() => mockService.getRandomPlayerId(difficulty: any(named: 'difficulty')))
          .thenAnswer((_) async => 'new_mystery_456');

      await controller.startNewGame();

      expect(controller.gameState!.mysteryPlayerId, 'new_mystery_456');
      expect(controller.gameState!.guesses, isEmpty);
      expect(controller.gameState!.status, GameStatus.playing);
      expect(controller.error, isNull);
    });

    test('setDifficulty changes difficulty and restarts game', () async {
      await controller.setDifficulty(Difficulty.pro);
      
      expect(controller.selectedDifficulty, Difficulty.pro);
      verify(() => mockService.getRandomPlayerId(difficulty: Difficulty.pro)).called(1);
    });

    test('searchPlayers updates searchResults', () async {
      final searchResults = [dummyPlayer];
      when(() => mockService.searchPlayers(any(), limit: any(named: 'limit'), offset: any(named: 'offset'), difficulty: any(named: 'difficulty')))
          .thenAnswer((_) async => searchResults);

      await controller.searchPlayers('Test');

      expect(controller.searchResults, searchResults);
      expect(controller.isSearching, false);
    });

    test('submitGuess updates game state correctly (Correct Guess)', () async {
      await controller.startNewGame();
      
      when(() => mockService.compareGuess(
            guessedPlayerId: dummyPlayer.playerId,
            mysteryPlayerId: any(named: 'mysteryPlayerId'),
          )).thenAnswer((_) async => correctGuessResult);

      await controller.submitGuess(dummyPlayer);

      expect(controller.gameState!.guesses.length, 1);
      expect(controller.gameState!.status, GameStatus.won);
      expect(controller.gamesWon, 1);
      expect(controller.currentStreak, 1);
      expect(controller.mysteryPlayer, isNotNull); // Should be loaded on end
    });

    test('submitGuess updates game state correctly (Incorrect Guess)', () async {
      await controller.startNewGame();
      
      final incorrectResult = GuessResult(
        guessedPlayer: dummyPlayer,
        conferenceMatch: MatchStatus.miss,
        divisionMatch: MatchStatus.miss,
        teamMatch: MatchStatus.miss,
        positionMatch: MatchStatus.miss,
        jerseyComparison: NumericComparison(match: false, direction: NumericDirection.up, isClose: false),
        heightComparison: exactNumeric,
        ageComparison: exactNumeric,
        isCorrect: false,
      );

      when(() => mockService.compareGuess(
            guessedPlayerId: dummyPlayer.playerId,
            mysteryPlayerId: any(named: 'mysteryPlayerId'),
          )).thenAnswer((_) async => incorrectResult);

      await controller.submitGuess(dummyPlayer);

      expect(controller.gameState!.guesses.length, 1);
      expect(controller.gameState!.status, GameStatus.playing);
      expect(controller.gamesWon, 0);
    });

    test('Daily challenge loads correctly', () async {
      final today = DateTime.now().toIso8601String().split('T')[0];
      
      when(() => mockService.getDailyPlayerId(difficulty: any(named: 'difficulty')))
          .thenAnswer((_) async => DailyPlayerResult(
            playerId: 'daily_1',
            date: today,
            teamsInvolved: ['ARI'],
          ));

      await controller.startDailyChallenge();

      expect(controller.isDailyChallenge, true);
      expect(controller.gameState!.mysteryPlayerId, 'daily_1');
      expect(controller.dailyChallengeDate, today);
    });

    test('useHint calls service and updates state', () async {
      await controller.startNewGame();
      
      // Need a player with college to use hint
      final playerWithCollege = Player(
        playerId: dummyPlayer.playerId,
        displayName: dummyPlayer.displayName,
        team: dummyPlayer.team,
        position: dummyPlayer.position,
        college: 'State U',
        headshot: dummyPlayer.headshot,
        jerseyNumber: dummyPlayer.jerseyNumber,
        height: dummyPlayer.height,
        weight: dummyPlayer.weight,
        age: dummyPlayer.age,
        yearsExperience: dummyPlayer.yearsExperience,
      );
      
      when(() => mockService.getPlayerDetails(any()))
          .thenAnswer((_) async => playerWithCollege);

      await controller.useHint();

      expect(controller.gameState!.hintUsed, true);
      expect(controller.gameState!.revealedHint, 'State U');
    });

    test('Statistics are persisted', () async {
      await controller.initialize();
      
      // Win a game
      when(() => mockService.compareGuess(
            guessedPlayerId: any(named: 'guessedPlayerId'),
            mysteryPlayerId: any(named: 'mysteryPlayerId'),
          )).thenAnswer((_) async => correctGuessResult);

      await controller.submitGuess(dummyPlayer);
      
      // Verify prefs updated
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('player_wordle_games_won'), 1);
      expect(prefs.getInt('player_wordle_current_streak'), 1);
    });
  });
}
