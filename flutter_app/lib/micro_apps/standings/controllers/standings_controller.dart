import 'dart:async';
import 'package:flutter/material.dart';
import '../models/game_model.dart';
import '../models/team_standing.dart';
import '../services/standings_service.dart';
import '../services/standings_data_service.dart';

/// Enum representing the active tab in the Game Center.
enum GameCenterTab { schedule, standings }

/// Enum for Standings View Mode
enum StandingsViewMode { conference, division, league }

/// Controller for the Game Center micro app.
/// Manages game schedule, standings data, tab selection, and loading states.
class StandingsController extends ChangeNotifier {
  final StandingsService _scheduleService;
  final StandingsDataService _standingsService;

  /// Creates a StandingsController with optional injected services for testing.
  StandingsController({
    StandingsService? scheduleService,
    StandingsDataService? standingsService,
  }) : _scheduleService = scheduleService ?? StandingsService(),
       _standingsService = standingsService ?? StandingsDataService();

  // Tab State
  GameCenterTab _activeTab = GameCenterTab.schedule;
  GameCenterTab get activeTab => _activeTab;

  // Schedule State
  List<Game> _allGames = [];
  Map<int, List<Game>> _gamesByWeek = {};
  List<int> _weeks = [];
  int _currentWeek = 1;
  int _selectedWeek = 1;
  bool _isLoadingSchedule = false;
  String? _scheduleError;

  // Standings State
  List<ConferenceStandings> _standings = [];
  bool _isLoadingStandings = false;
  String? _standingsError;
  bool _standingsFetched = false;

  // UI State for Redesign
  StandingsViewMode _viewMode = StandingsViewMode.division;
  ScrollController? _scrollController;
  String? _selectedConference; // 'AFC', 'NFC', or null

  // Scroll Request Stream
  final _scrollRequestController = StreamController<String>.broadcast();
  Stream<String> get scrollRequests => _scrollRequestController.stream;

  // Getters for UI
  StandingsViewMode get viewMode => _viewMode;
  ScrollController? get scrollController => _scrollController;
  String? get selectedConference => _selectedConference;

  @override
  void dispose() {
    _scrollRequestController.close();
    super.dispose();
  }

  /// Sets the ScrollController
  void setScrollController(ScrollController controller) {
    _scrollController = controller;
  }

  /// Sets the active view mode
  void setViewMode(StandingsViewMode mode) {
    if (_viewMode != mode) {
      _viewMode = mode;
      _selectedConference = null; // Reset filters on mode change
      notifyListeners();
    }
  }

  /// Filters by Conference (toggle behavior)
  void filterConference(String conf) {
    if (_selectedConference == conf) {
      _selectedConference = null; // Toggle off
    } else {
      _selectedConference = conf;
    }
    notifyListeners();
  }

  /// Helper to scroll to a specific index
  void scrollToSection(String sectionKey) {
    _scrollRequestController.add(sectionKey);
  }

  // Schedule Getters
  List<Game> get allGames => _allGames;
  Map<int, List<Game>> get gamesByWeek => _gamesByWeek;
  List<int> get weeks => _weeks;
  int get currentWeek => _currentWeek;
  int get selectedWeek => _selectedWeek;
  bool get isLoading => _activeTab == GameCenterTab.schedule
      ? _isLoadingSchedule
      : _isLoadingStandings;
  String? get error =>
      _activeTab == GameCenterTab.schedule ? _scheduleError : _standingsError;

  // Standings Getters
  List<ConferenceStandings> get standings => _standings;
  bool get isLoadingStandings => _isLoadingStandings;
  String? get standingsError => _standingsError;

  /// Gets games for the currently selected week, sorted by date and time.
  List<Game> get selectedWeekGames {
    final games = List<Game>.from(_gamesByWeek[_selectedWeek] ?? []);
    games.sort((a, b) {
      final dateComp = a.gameday.compareTo(b.gameday);
      if (dateComp != 0) return dateComp;
      return a.gametime.compareTo(b.gametime);
    });
    return games;
  }

  /// Finds the game involving the specific team for the selected week.
  Game? getFeaturedGame(String? teamId) {
    if (teamId == null) return null;
    final normalizedId = teamId.toUpperCase();
    try {
      return selectedWeekGames.firstWhere(
        (g) =>
            g.homeTeam.toUpperCase() == normalizedId ||
            g.awayTeam.toUpperCase() == normalizedId,
      );
    } catch (_) {
      return null;
    }
  }

  /// Gets the most recent completed game for a team (across all weeks).
  /// Returns null if no completed games found.
  Game? getLastGame(String? teamId) {
    if (teamId == null || _allGames.isEmpty) return null;
    final normalizedId = teamId.toUpperCase();

    // Filter games involving this team that have been played
    final teamGames = _allGames
        .where(
          (g) =>
              g.isPlayed &&
              (g.homeTeam.toUpperCase() == normalizedId ||
                  g.awayTeam.toUpperCase() == normalizedId),
        )
        .toList();

    debugPrint(
      'getLastGame for $teamId: found ${teamGames.length} played games out of ${_allGames.length} total',
    );

    if (teamGames.isEmpty) return null;

    // Sort by gameday descending to get most recent first
    teamGames.sort((a, b) => b.gameday.compareTo(a.gameday));
    return teamGames.first;
  }

  /// Gets the next upcoming game for a team (across all weeks).
  /// Returns null if no upcoming games found.
  Game? getNextGame(String? teamId) {
    if (teamId == null || _allGames.isEmpty) return null;
    final normalizedId = teamId.toUpperCase();

    // Filter games involving this team that haven't been played yet
    final teamGames = _allGames
        .where(
          (g) =>
              !g.isPlayed &&
              (g.homeTeam.toUpperCase() == normalizedId ||
                  g.awayTeam.toUpperCase() == normalizedId),
        )
        .toList();

    debugPrint(
      'getNextGame for $teamId: found ${teamGames.length} upcoming games',
    );

    if (teamGames.isEmpty) return null;

    // Sort by gameday ascending to get nearest upcoming first
    teamGames.sort((a, b) => a.gameday.compareTo(b.gameday));
    return teamGames.first;
  }

  /// Switches between Schedule and Standings tabs.
  void switchTab(GameCenterTab tab) {
    if (_activeTab != tab) {
      _activeTab = tab;
      notifyListeners();

      // Lazy load standings when first switching to that tab
      if (tab == GameCenterTab.standings && !_standingsFetched) {
        fetchStandings();
      }
    }
  }

  /// Fetches all games and determines the current week.
  Future<void> fetchGames() async {
    _isLoadingSchedule = true;
    _scheduleError = null;
    notifyListeners();

    try {
      _allGames = await _scheduleService.fetchGames();
      _gamesByWeek = _scheduleService.groupGamesByWeek(_allGames);
      _weeks = _scheduleService.getWeeks(_allGames);

      // Determine current week based on today's date
      _currentWeek = _scheduleService.findCurrentWeek(
        _allGames,
        DateTime.now(),
      );
      _selectedWeek = _currentWeek;

      _isLoadingSchedule = false;
      _scheduleError = null;
    } catch (e) {
      _isLoadingSchedule = false;
      _scheduleError = 'Failed to load schedule: $e';
      debugPrint('StandingsController.fetchGames error: $e');
    }

    notifyListeners();
  }

  /// Fetches standings data grouped by conference and division.
  Future<void> fetchStandings() async {
    _isLoadingStandings = true;
    _standingsError = null;
    notifyListeners();

    try {
      _standings = await _standingsService.fetchStandings();
      _isLoadingStandings = false;
      _standingsError = null;
      _standingsFetched = true;
    } catch (e) {
      _isLoadingStandings = false;
      _standingsError = 'Failed to load standings: $e';
      debugPrint('StandingsController.fetchStandings error: $e');
    }

    notifyListeners();
  }

  /// Selects a specific week to display.
  void selectWeek(int week) {
    if (_weeks.contains(week) && week != _selectedWeek) {
      _selectedWeek = week;
      notifyListeners();
    }
  }

  /// Navigates to the previous week.
  void previousWeek() {
    final currentIndex = _weeks.indexOf(_selectedWeek);
    if (currentIndex > 0) {
      _selectedWeek = _weeks[currentIndex - 1];
      notifyListeners();
    }
  }

  /// Navigates to the next week.
  void nextWeek() {
    final currentIndex = _weeks.indexOf(_selectedWeek);
    if (currentIndex < _weeks.length - 1) {
      _selectedWeek = _weeks[currentIndex + 1];
      notifyListeners();
    }
  }

  /// Resets to the current week.
  void goToCurrentWeek() {
    if (_selectedWeek != _currentWeek) {
      _selectedWeek = _currentWeek;
      notifyListeners();
    }
  }

  /// Whether we can navigate to the previous week.
  bool get canGoPrevious => _weeks.indexOf(_selectedWeek) > 0;

  /// Whether we can navigate to the next week.
  bool get canGoNext => _weeks.indexOf(_selectedWeek) < _weeks.length - 1;

  /// Returns a human-readable label for the given week number.
  /// Handles NFL post-season naming (Wild Card, Divisional, etc.).
  /// Returns a Record with (label, subLabel).
  static (String, String) getWeekLabels(int week) {
    if (week <= 18) {
      return ('Week', week.toString());
    }
    return switch (week) {
      19 => ('Wild', 'Card'),
      20 => ('Divis-', 'ional'),
      21 => ('Conf.', 'Champ'),
      22 => ('Super', 'Bowl'),
      _ => ('Week', week.toString()),
    };
  }

  /// Returns a single line label for a week.
  static String getWeekLabel(int week) {
    final (label, sub) = getWeekLabels(week);
    if (week <= 18) return '$label $sub';
    return switch (week) {
      19 => 'Wild Card',
      20 => 'Divisional',
      21 => 'Conf. Champ',
      22 => 'Super Bowl',
      _ => 'Week $week',
    };
  }
}
