import 'package:flutter/material.dart';
import '../../../micro_apps/standings/services/standings_service.dart';
import '../../../micro_apps/standings/models/game_model.dart';
import '../../models/team_model.dart';

/// Controller for the Team Center overlay.
/// Manages fetching games for a specific team.
class TeamCenterController extends ChangeNotifier {
  final StandingsService _standingsService = StandingsService();
  
  bool _isLoading = false;
  String? _error;
  Game? _lastGame;
  Game? _nextGame;
  
  /// All games for the team in chronological order
  List<Game> _allTeamGames = [];
  
  /// Index to start the carousel at (first upcoming game)
  int _startIndex = 0;

  bool get isLoading => _isLoading;
  String? get error => _error;
  Game? get lastGame => _lastGame;
  Game? get nextGame => _nextGame;
  List<Game> get allTeamGames => _allTeamGames;
  int get startIndex => _startIndex;

  /// Loads data for the specified team.
  Future<void> loadTeamData(Team team) async {
    _isLoading = true;
    _error = null;
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

    } catch (e) {
      _error = 'Failed to load team data: $e';
      debugPrint('TeamCenterController error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
