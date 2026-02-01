import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tackle4loss_mobile/micro_apps/standings/controllers/standings_controller.dart';
import 'package:tackle4loss_mobile/micro_apps/standings/models/game_model.dart';
import 'package:tackle4loss_mobile/micro_apps/standings/models/team_standing.dart';
import 'package:tackle4loss_mobile/micro_apps/standings/services/standings_service.dart';
import 'package:tackle4loss_mobile/micro_apps/standings/services/standings_data_service.dart';

/// Mock StandingsService that returns test data without Supabase
class MockStandingsService extends StandingsService {
  MockStandingsService() : super.testing();

  List<Game> mockGames = [];

  @override
  Future<List<Game>> fetchGames() async {
    return mockGames;
  }

  @override
  Map<int, List<Game>> groupGamesByWeek(List<Game> games) {
    final Map<int, List<Game>> grouped = {};
    for (final game in games) {
      grouped.putIfAbsent(game.week, () => []).add(game);
    }
    return grouped;
  }

  @override
  int findCurrentWeek(List<Game> games, DateTime today) {
    if (games.isEmpty) return 1;
    return games.first.week;
  }

  @override
  List<int> getWeeks(List<Game> games) {
    final weeks = games.map((g) => g.week).toSet().toList();
    weeks.sort();
    return weeks.isEmpty ? [1] : weeks;
  }
}

/// Mock StandingsDataService that returns test data without Supabase
class MockStandingsDataService extends StandingsDataService {
  MockStandingsDataService() : super.testing();

  List<ConferenceStandings> mockStandings = [];

  @override
  Future<List<ConferenceStandings>> fetchStandings({int? season}) async {
    return mockStandings;
  }
}

void main() {
  group('StandingsController', () {
    late StandingsController controller;
    late MockStandingsService mockScheduleService;
    late MockStandingsDataService mockStandingsService;

    setUp(() {
      mockScheduleService = MockStandingsService();
      mockStandingsService = MockStandingsDataService();
      controller = StandingsController(
        scheduleService: mockScheduleService,
        standingsService: mockStandingsService,
      );
    });

    tearDown(() {
      controller.dispose();
    });

    group('initial state', () {
      test('starts with schedule tab active', () {
        expect(controller.activeTab, GameCenterTab.schedule);
      });

      test('starts with division view mode', () {
        expect(controller.viewMode, StandingsViewMode.division);
      });

      test('starts with no conference filter', () {
        expect(controller.selectedConference, isNull);
      });

      test('starts with empty games list', () {
        expect(controller.allGames, isEmpty);
      });

      test('starts with empty standings data', () {
        expect(controller.standings, isEmpty);
      });

      test('starts not loading', () {
        expect(controller.isLoading, isFalse);
      });

      test('starts with selected week equal to current week', () {
        expect(controller.selectedWeek, controller.currentWeek);
      });
    });

    group('view mode management', () {
      test('setViewMode updates view mode', () {
        controller.setViewMode(StandingsViewMode.conference);
        expect(controller.viewMode, StandingsViewMode.conference);

        controller.setViewMode(StandingsViewMode.league);
        expect(controller.viewMode, StandingsViewMode.league);
      });

      test('setViewMode notifies listeners', () {
        bool notified = false;
        controller.addListener(() => notified = true);

        controller.setViewMode(StandingsViewMode.conference);

        expect(notified, isTrue);
      });

      test('setViewMode resets conference filter', () {
        controller.filterConference('AFC');
        expect(controller.selectedConference, 'AFC');

        controller.setViewMode(StandingsViewMode.league);
        expect(controller.selectedConference, isNull);
      });

      test('setViewMode does not notify if same mode', () {
        bool notified = false;
        controller.addListener(() => notified = true);

        controller.setViewMode(StandingsViewMode.division); // Already default

        expect(notified, isFalse);
      });
    });

    group('conference filtering', () {
      test('filterConference sets conference filter', () {
        controller.filterConference('AFC');
        expect(controller.selectedConference, 'AFC');

        controller.filterConference('NFC');
        expect(controller.selectedConference, 'NFC');
      });

      test('filterConference toggles off when same value', () {
        controller.filterConference('AFC');
        expect(controller.selectedConference, 'AFC');

        controller.filterConference('AFC');
        expect(controller.selectedConference, isNull);
      });

      test('filterConference notifies listeners', () {
        bool notified = false;
        controller.addListener(() => notified = true);

        controller.filterConference('NFC');

        expect(notified, isTrue);
      });
    });

    group('tab switching', () {
      test('switchTab changes active tab', () {
        controller.switchTab(GameCenterTab.standings);
        expect(controller.activeTab, GameCenterTab.standings);

        controller.switchTab(GameCenterTab.schedule);
        expect(controller.activeTab, GameCenterTab.schedule);
      });

      test('switchTab notifies listeners', () {
        bool notified = false;
        controller.addListener(() => notified = true);

        controller.switchTab(GameCenterTab.standings);

        expect(notified, isTrue);
      });

      test('switchTab does not notify if same tab', () {
        bool notified = false;
        controller.addListener(() => notified = true);

        controller.switchTab(GameCenterTab.schedule); // Already on schedule

        expect(notified, isFalse);
      });
    });

    group('week selection', () {
      test('selectedWeek returns current week initially', () {
        expect(controller.selectedWeek, controller.currentWeek);
      });

      test('goToCurrentWeek does not notify if already at current week', () {
        bool notified = false;
        controller.addListener(() => notified = true);

        controller.goToCurrentWeek(); // Already at current week

        expect(notified, isFalse);
      });
    });

    group('scroll controller management', () {
      test('setScrollController stores controller', () {
        final scrollController = ScrollController();

        controller.setScrollController(scrollController);

        expect(controller.scrollController, equals(scrollController));

        scrollController.dispose();
      });

      test('scrollController is null initially', () {
        expect(controller.scrollController, isNull);
      });
    });

    group('game queries', () {
      test('selectedWeekGames returns empty list when no games', () {
        expect(controller.selectedWeekGames, isEmpty);
      });

      test('getFeaturedGame returns null when no games loaded', () {
        expect(controller.getFeaturedGame('KC'), isNull);
      });

      test('getFeaturedGame returns null for null team id', () {
        expect(controller.getFeaturedGame(null), isNull);
      });

      test('getLastGame returns null when no games loaded', () {
        expect(controller.getLastGame('KC'), isNull);
      });

      test('getNextGame returns null when no games loaded', () {
        expect(controller.getNextGame('KC'), isNull);
      });
    });

    group('navigation state', () {
      test('canGoPrevious is false with no weeks', () {
        expect(controller.canGoPrevious, isFalse);
      });

      test('canGoNext is false with no weeks', () {
        expect(controller.canGoNext, isFalse);
      });
    });

    group('dispose', () {
      test('dispose can be called without error', () {
        final c = StandingsController(
          scheduleService: MockStandingsService(),
          standingsService: MockStandingsDataService(),
        );

        expect(() => c.dispose(), returnsNormally);
      });
    });

    group('fetchGames', () {
      test('fetchGames populates allGames from service', () async {
        mockScheduleService.mockGames = [
          _createGame(id: '1', week: 1),
          _createGame(id: '2', week: 2),
        ];

        await controller.fetchGames();

        expect(controller.allGames.length, 2);
        expect(controller.isLoading, isFalse);
      });

      test('fetchGames sets loading state', () async {
        mockScheduleService.mockGames = [];

        final future = controller.fetchGames();
        expect(controller.isLoading, isTrue);

        await future;
        expect(controller.isLoading, isFalse);
      });
    });

    group('fetchStandings', () {
      test('fetchStandings populates standings from service', () async {
        mockStandingsService.mockStandings = [
          const ConferenceStandings(
            conference: 'AFC',
            divisions: [],
          ),
        ];

        await controller.fetchStandings();

        expect(controller.standings.length, 1);
        expect(controller.isLoadingStandings, isFalse);
      });
    });

    group('week labeling', () {
      test('getWeekLabels returns Week X for regular season (1-18)', () {
        final (label, sub) = StandingsController.getWeekLabels(1);
        expect(label, 'Week');
        expect(sub, '1');

        final (label18, sub18) = StandingsController.getWeekLabels(18);
        expect(label18, 'Week');
        expect(sub18, '18');
      });

      test('getWeekLabels returns proper names for post-season (19-22)', () {
        final (l19, s19) = StandingsController.getWeekLabels(19);
        expect(l19, 'Wild');
        expect(s19, 'Card');

        final (l20, s20) = StandingsController.getWeekLabels(20);
        expect(l20, 'Divis-');
        expect(s20, 'ional');

        final (l21, s21) = StandingsController.getWeekLabels(21);
        expect(l21, 'Conf.');
        expect(s21, 'Champ');

        final (l22, s22) = StandingsController.getWeekLabels(22);
        expect(l22, 'Super');
        expect(s22, 'Bowl');
      });

      test('getWeekLabel returns single line strings', () {
        expect(StandingsController.getWeekLabel(1), 'Week 1');
        expect(StandingsController.getWeekLabel(19), 'Wild Card');
        expect(StandingsController.getWeekLabel(20), 'Divisional');
        expect(StandingsController.getWeekLabel(21), 'Conf. Champ');
        expect(StandingsController.getWeekLabel(22), 'Super Bowl');
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
