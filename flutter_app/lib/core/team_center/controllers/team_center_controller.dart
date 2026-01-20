import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../micro_apps/standings/services/standings_service.dart';
import '../../../micro_apps/standings/models/game_model.dart';
import '../../models/team_model.dart';
import '../../services/audio_player_service.dart';

import '../models/team_article.dart';
import '../models/roster_player.dart';
import '../models/depth_chart_player.dart';
import '../models/injury_player.dart';

/// Controller for the Team Center overlay.
/// Manages fetching games for a specific team.
class TeamCenterController extends ChangeNotifier {
  final StandingsService _standingsService = StandingsService();
  final AudioPlayerService _audioService = AudioPlayerService();
  
  bool _isLoading = false;
  String? _error;
  Game? _lastGame;
  Game? _nextGame;
  TeamArticle? _todaysArticle;

  /// All games for the team in chronological order
  List<Game> _allTeamGames = [];
  
  /// Index to start the carousel at (first upcoming game)
  int _startIndex = 0;

  bool get isLoading => _isLoading;
  String? get error => _error;
  Game? get lastGame => _lastGame;
  Game? get nextGame => _nextGame;
  TeamArticle? get todaysArticle => _todaysArticle;
  List<Game> get allTeamGames => _allTeamGames;
  int get startIndex => _startIndex;

  /// Plays the audio for today's article if available.
  Future<void> playArticleAudio() async {
    final audioUrl = _todaysArticle?.audioUrl;
    if (audioUrl == null || audioUrl.isEmpty) return;
    
    await _audioService.play(
      audioUrl,
      _todaysArticle!.title,
      "T4L Daily Update", // Author
      _todaysArticle!.imageUrl.isNotEmpty ? _todaysArticle!.imageUrl : 'https://images.unsplash.com/photo-1566577739112-5180d4bf9390',
    );
  }

  /// Loads data for the specified team.
  Future<void> loadTeamData(Team team, {String? languageCode}) async {
    _isLoading = true;
    _error = null;
    _todaysArticle = null;
    notifyListeners();

    try {
      final allGames = await _standingsService.fetchGames();
      final normalizedId = team.id.toUpperCase();

      // Get all games for this team
      final teamGames = allGames.where((g) =>
        g.homeTeam.toUpperCase() == normalizedId || 
        g.awayTeam.toUpperCase() == normalizedId
      ).toList();
      
      // Sort chronologically (oldest first)
      teamGames.sort((a, b) => a.gameday.compareTo(b.gameday));
      _allTeamGames = teamGames;
      
      // Find index of first upcoming game (or last game if all played)
      _startIndex = 0;
      for (int i = 0; i < _allTeamGames.length; i++) {
        if (!_allTeamGames[i].isPlayed) {
          _startIndex = i > 0 ? i - 1 : 0; // Start at last played game
          break;
        }
        _startIndex = i; // If no upcoming games, stay at last
      }

      // Find Last Game (Played) - for backward compatibility
      final playedGames = teamGames.where((g) => g.isPlayed).toList();
      playedGames.sort((a, b) => b.gameday.compareTo(a.gameday));
      _lastGame = playedGames.isNotEmpty ? playedGames.first : null;

      // Find Next Game (Upcoming) - for backward compatibility
      final upcomingGames = teamGames.where((g) => !g.isPlayed).toList();
      upcomingGames.sort((a, b) => a.gameday.compareTo(b.gameday));
      _nextGame = upcomingGames.isNotEmpty ? upcomingGames.first : null;

      // Load Daily Update
      await _loadDailyUpdate(team.id, languageCode ?? 'en');

    } catch (e) {
      _error = 'Failed to load team data: $e';
      debugPrint('TeamCenterController error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadDailyUpdate(String teamId, String languageCode) async {
    try {
      final response = await Supabase.instance.client.functions.invoke(
        'get-team-daily-update',
        // Ensure team_id is uppercase to match team_abbr (e.g., DEN, BUF)
        body: {'team_id': teamId.toUpperCase(), 'language_code': languageCode},
      );

      final data = response.data;
      if (data != null && data['article'] != null) {
        _todaysArticle = TeamArticle.fromJson(data['article']);
      }
    } catch (e) {
      debugPrint('Failed to load daily update: $e');
      // Set fallback even on error to stop spinner
      _todaysArticle = TeamArticle(
        id: 'placeholder_error',
        title: 'Stay tuned for updates!',
        summary: 'We are currently preparing the latest news for your team.',
        imageUrl: '',
        publishedAt: DateTime.now(),
      );
    }
  }
  List<RosterPlayer> _offenseRoster = [];
  List<RosterPlayer> _defenseRoster = [];
  List<RosterPlayer> _specialTeamsRoster = [];
  bool _isRosterLoading = false;
  String? _rosterError;

  List<RosterPlayer> get offenseRoster => _offenseRoster;
  List<RosterPlayer> get defenseRoster => _defenseRoster;
  List<RosterPlayer> get specialTeamsRoster => _specialTeamsRoster;
  bool get isRosterLoading => _isRosterLoading;
  String? get rosterError => _rosterError;

  /// Loads the team roster.
  Future<void> loadTeamRoster(String teamId) async {
    // If we already have data, don't reload
    if (_offenseRoster.isNotEmpty || _defenseRoster.isNotEmpty || _specialTeamsRoster.isNotEmpty) {
      return;
    }

    _isRosterLoading = true;
    _rosterError = null;
    notifyListeners();

    try {
      debugPrint('Loading roster for team: ${teamId.toUpperCase()}'); // Debug log
      final response = await Supabase.instance.client.functions.invoke(
        'get-team-roster',
        body: {'team_id': teamId.toUpperCase()},
      );

      final data = response.data;
      if (data != null) {
        _offenseRoster = (data['offense'] as List?)
                ?.map((e) => RosterPlayer.fromJson(e))
                .toList() ??
            [];
        _defenseRoster = (data['defense'] as List?)
                ?.map((e) => RosterPlayer.fromJson(e))
                .toList() ??
            [];
        _specialTeamsRoster = (data['specialTeams'] as List?)
                ?.map((e) => RosterPlayer.fromJson(e))
                .toList() ??
            [];
      }
    } catch (e) {
      _rosterError = 'Failed to load roster: $e';
      debugPrint('TeamCenterController roster error: $e');
    } finally {
      _isRosterLoading = false;
      notifyListeners();
    }
  }

  // ---- Depth Chart State ----
  Map<String, List<DepthChartPlayer>> _offenseDepthChart = {};
  Map<String, List<DepthChartPlayer>> _defenseDepthChart = {};
  Map<String, List<DepthChartPlayer>> _specialTeamsDepthChart = {};
  bool _isDepthChartLoading = false;
  String? _depthChartError;

  Map<String, List<DepthChartPlayer>> get offenseDepthChart => _offenseDepthChart;
  Map<String, List<DepthChartPlayer>> get defenseDepthChart => _defenseDepthChart;
  Map<String, List<DepthChartPlayer>> get specialTeamsDepthChart => _specialTeamsDepthChart;
  bool get isDepthChartLoading => _isDepthChartLoading;
  String? get depthChartError => _depthChartError;

  /// Loads the team depth chart.
  Future<void> loadDepthChart(String teamId) async {
    // If we already have data, don't reload
    if (_offenseDepthChart.isNotEmpty || _defenseDepthChart.isNotEmpty || _specialTeamsDepthChart.isNotEmpty) {
      return;
    }

    _isDepthChartLoading = true;
    _depthChartError = null;
    notifyListeners();

    try {
      debugPrint('Loading depth chart for team: ${teamId.toUpperCase()}');
      final response = await Supabase.instance.client.functions.invoke(
        'get-team-depth-chart',
        body: {'team_id': teamId.toUpperCase()},
      );

      final data = response.data;
      if (data != null) {
        _offenseDepthChart = _parseDepthChartGroup(data['offense']);
        _defenseDepthChart = _parseDepthChartGroup(data['defense']);
        _specialTeamsDepthChart = _parseDepthChartGroup(data['specialTeams']);
      }
    } catch (e) {
      _depthChartError = 'Failed to load depth chart: $e';
      debugPrint('TeamCenterController depth chart error: $e');
    } finally {
      _isDepthChartLoading = false;
      notifyListeners();
    }
  }

  /// Parses a depth chart group from JSON.
  Map<String, List<DepthChartPlayer>> _parseDepthChartGroup(dynamic group) {
    if (group == null) return {};
    
    final Map<String, List<DepthChartPlayer>> result = {};
    final Map<String, dynamic> groupMap = group as Map<String, dynamic>;
    
    for (final entry in groupMap.entries) {
      final players = (entry.value as List?)
          ?.map((e) => DepthChartPlayer.fromJson(e as Map<String, dynamic>))
          .toList() ?? [];
      result[entry.key] = players;
    }
    
    return result;
  }

  // ---- Injuries State ----
  List<InjuryPlayer> _outInjuries = [];
  List<InjuryPlayer> _doubtfulInjuries = [];
  List<InjuryPlayer> _questionableInjuries = [];
  bool _isInjuriesLoading = false;
  String? _injuriesError;

  List<InjuryPlayer> get outInjuries => _outInjuries;
  List<InjuryPlayer> get doubtfulInjuries => _doubtfulInjuries;
  List<InjuryPlayer> get questionableInjuries => _questionableInjuries;
  bool get isInjuriesLoading => _isInjuriesLoading;
  String? get injuriesError => _injuriesError;

  /// Loads the team injury report.
  Future<void> loadInjuries(String teamId) async {
    // If we already have data, don't reload
    if (_outInjuries.isNotEmpty || _doubtfulInjuries.isNotEmpty || _questionableInjuries.isNotEmpty) {
      return;
    }

    _isInjuriesLoading = true;
    _injuriesError = null;
    notifyListeners();

    try {
      debugPrint('Loading injuries for team: ${teamId.toUpperCase()}');
      final response = await Supabase.instance.client.functions.invoke(
        'get-team-injuries',
        body: {'team_id': teamId.toUpperCase()},
      );

      final data = response.data;
      if (data != null) {
        _outInjuries = (data['out'] as List?)
                ?.map((e) => InjuryPlayer.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [];
        _doubtfulInjuries = (data['doubtful'] as List?)
                ?.map((e) => InjuryPlayer.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [];
        _questionableInjuries = (data['questionable'] as List?)
                ?.map((e) => InjuryPlayer.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [];
      }
    } catch (e) {
      _injuriesError = 'Failed to load injuries: $e';
      debugPrint('TeamCenterController injuries error: $e');
    } finally {
      _isInjuriesLoading = false;
      notifyListeners();
    }
  }
}
