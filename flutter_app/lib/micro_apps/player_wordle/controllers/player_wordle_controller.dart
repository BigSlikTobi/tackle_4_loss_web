/// Controller for the NFL Guessing Game.
/// Manages game state, handles user interactions, and persists statistics.
library;

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/player_model.dart';
import '../models/game_state.dart';
import '../services/player_wordle_service.dart';

/// Controller for the Player Wordle game.
/// Uses ChangeNotifier for reactive UI updates.
class PlayerWordleController extends ChangeNotifier {
  final PlayerWordleService _service;

  /// Current game state
  GameState? _gameState;
  GameState? get gameState => _gameState;

  /// Search results for autocomplete
  List<Player> _searchResults = [];
  List<Player> get searchResults => _searchResults;

  /// Mystery player details (revealed after game ends)
  Player? _mysteryPlayer;
  Player? get mysteryPlayer => _mysteryPlayer;

  /// Loading states
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSearching = false;
  bool get isSearching => _isSearching;

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  /// Error message
  String? _error;
  String? get error => _error;

  /// Statistics
  int _gamesPlayed = 0;
  int get gamesPlayed => _gamesPlayed;

  int _gamesWon = 0;
  int get gamesWon => _gamesWon;

  int _currentStreak = 0;
  int get currentStreak => _currentStreak;

  int _maxStreak = 0;
  int get maxStreak => _maxStreak;

  /// Selected difficulty level (default: fan)
  Difficulty _selectedDifficulty = Difficulty.fan;
  Difficulty get selectedDifficulty => _selectedDifficulty;

  /// Search Filters
  String? _selectedTeamFilter;
  String? get selectedTeamFilter => _selectedTeamFilter;

  String? _selectedPositionFilter;
  String? get selectedPositionFilter => _selectedPositionFilter;

  /// Last search query (for refreshing filters)
  String _lastSearchQuery = '';

  /// Pagination
  int _searchOffset = 0;
  bool _hasMoreResults = true;
  bool get hasMoreResults => _hasMoreResults;
  static const int _pageSize = 20; // Smaller pages for smooth loading

  /// Default constructor
  PlayerWordleController() : _service = PlayerWordleService();

  /// Testing constructor
  @visibleForTesting
  PlayerWordleController.withService(this._service);

  /// Initializes the controller, loading stats and starting a new game.
  Future<void> initialize() async {
    await _loadStatistics();
    await startNewGame();
  }

  /// Sets the difficulty level and restarts the game.
  Future<void> setDifficulty(Difficulty difficulty) async {
    if (_selectedDifficulty == difficulty) return;
    _selectedDifficulty = difficulty;
    notifyListeners();
    await startNewGame();
  }

  /// Starts a new game with a random mystery player.
  Future<void> startNewGame() async {
    _isLoading = true;
    _error = null;
    _mysteryPlayer = null;
    _searchResults = [];
    notifyListeners();

    try {
      final playerId = await _service.getRandomPlayerId(difficulty: _selectedDifficulty);
      _gameState = GameState.newGame(
        mysteryPlayerId: playerId,
        difficulty: _selectedDifficulty,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to start new game: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Searches for players by name.
  Future<void> searchPlayers(String query) async {
    if (query.length < 2 && _selectedTeamFilter == null && _selectedPositionFilter == null) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    _lastSearchQuery = query;
    _isSearching = true;
    notifyListeners();

    try {
      _searchOffset = 0; // Reset offset
      _hasMoreResults = true;
      
      final results = await _service.searchPlayers(
        query,
        limit: _pageSize,
        offset: _searchOffset,
        team: _selectedTeamFilter,
        position: _selectedPositionFilter,
        difficulty: _getDifficultyString(),
      );

      // Filter out already guessed players
      final guessedIds = _gameState?.guesses
          .map((g) => g.guessedPlayer.playerId)
          .toSet() ?? {};
      
      _searchResults = results
          .where((p) => !guessedIds.contains(p.playerId))
          .toList();
          
      _hasMoreResults = results.length >= _pageSize;
      _isSearching = false;
      notifyListeners();
    } catch (e) {
      _error = 'Search failed: $e';
      _isSearching = false;
      notifyListeners();
    }
  }

  /// Loads the next page of results.
  Future<void> loadMoreResults() async {
    if (_isLoading || !_hasMoreResults) return;

    try {
      _searchOffset += _pageSize;
      
      final results = await _service.searchPlayers(
        _lastSearchQuery,
        limit: _pageSize,
        offset: _searchOffset,
        team: _selectedTeamFilter,
        position: _selectedPositionFilter,
        difficulty: _getDifficultyString(),
      );

      if (results.isEmpty) {
        _hasMoreResults = false;
        notifyListeners();
        return;
      }

      // Filter out already guessed players (and existing results just in case)
      final guessedIds = _gameState?.guesses
          .map((g) => g.guessedPlayer.playerId)
          .toSet() ?? {};
      
      final existingIds = _searchResults.map((p) => p.playerId).toSet();
      
      final newResults = results
          .where((p) => !guessedIds.contains(p.playerId) && !existingIds.contains(p.playerId))
          .toList();

      _searchResults.addAll(newResults);
      _hasMoreResults = results.length >= _pageSize;
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load more results: $e');
    }
  }


  String _getDifficultyString() {
    return switch (_gameState?.difficulty ?? Difficulty.pro) {
      Difficulty.fan => 'fan',
      Difficulty.rookie => 'rookie',
      Difficulty.pro => 'pro',
      Difficulty.allMadden => 'allMadden',
    };
  }

  /// Clears search results.
  void clearSearch() {
    _searchResults = [];
    _lastSearchQuery = '';
    notifyListeners();
  }

  /// Sets team filter and refreshes search if active.
  void setTeamFilter(String? team) {
    if (_selectedTeamFilter == team) return;
    _selectedTeamFilter = team;
    notifyListeners();
    // Refresh search if we have a valid query OR a valid filter
    if (_lastSearchQuery.length >= 2 || _selectedTeamFilter != null || _selectedPositionFilter != null) {
      searchPlayers(_lastSearchQuery);
    } else {
      clearSearch();
    }
  }

  /// Sets position filter and refreshes search if active.
  void setPositionFilter(String? position) {
    if (_selectedPositionFilter == position) return;
    _selectedPositionFilter = position;
    notifyListeners();
    // Refresh search if we have a valid query OR a valid filter
    if (_lastSearchQuery.length >= 2 || _selectedTeamFilter != null || _selectedPositionFilter != null) {
      searchPlayers(_lastSearchQuery);
    } else {
      clearSearch();
    }
  }

  /// Clears all filters.
  void clearFilters() {
    _selectedTeamFilter = null;
    _selectedPositionFilter = null;
    notifyListeners();
    // Only refresh if we still have a valid query, otherwise clear results
    if (_lastSearchQuery.length >= 2) {
      searchPlayers(_lastSearchQuery);
    } else {
      clearSearch();
    }
  }

  /// Submits a guess for a player.
  Future<void> submitGuess(Player player) async {
    if (_gameState == null || !_gameState!.isPlaying) return;

    _isSubmitting = true;
    _searchResults = [];
    _error = null;
    notifyListeners();

    try {
      final result = await _service.compareGuess(
        guessedPlayerId: player.playerId,
        mysteryPlayerId: _gameState!.mysteryPlayerId,
      );

      _gameState = _gameState!.addGuess(result);
      _isSubmitting = false;

      // Handle game end
      if (_gameState!.isGameOver) {
        await _handleGameEnd();
      } else {
        // Clear filters for the next guess so user isn't stuck
        // We do this by manually resetting variables to avoid triggering a new search
        _selectedTeamFilter = null;
        _selectedPositionFilter = null;
      }

      notifyListeners();
    } catch (e) {
      _error = 'Failed to submit guess: $e';
      _isSubmitting = false;
      notifyListeners();
    }
  }

  /// Uses the hint (reveals alma mater).
  Future<void> useHint() async {
    if (_gameState == null || _gameState!.hintUsed) return;

    try {
      final player = await _service.getPlayerDetails(
        _gameState!.mysteryPlayerId,
      );

      if (player.college != null) {
        _gameState = _gameState!.useHint(player.college!);
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to get hint: $e';
      notifyListeners();
    }
  }

  /// Handles game end - loads mystery player and updates stats.
  Future<void> _handleGameEnd() async {
    try {
      _mysteryPlayer = await _service.getPlayerDetails(
        _gameState!.mysteryPlayerId,
      );
      await _updateStatistics(_gameState!.status == GameStatus.won);
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to handle game end: $e');
    }
  }

  // ===== Statistics Management =====
  
  static const _keyGamesPlayed = 'player_wordle_games_played';
  static const _keyGamesWon = 'player_wordle_games_won';
  static const _keyCurrentStreak = 'player_wordle_current_streak';
  static const _keyMaxStreak = 'player_wordle_max_streak';
  static const _keyTotalPoints = 'player_wordle_total_points';
  
  int _totalPoints = 0;
  int get totalPoints => _totalPoints;

  Future<void> _loadStatistics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _gamesPlayed = prefs.getInt(_keyGamesPlayed) ?? 0;
      _gamesWon = prefs.getInt(_keyGamesWon) ?? 0;
      _currentStreak = prefs.getInt(_keyCurrentStreak) ?? 0;
      _maxStreak = prefs.getInt(_keyMaxStreak) ?? 0;
      _totalPoints = prefs.getInt(_keyTotalPoints) ?? 0;
    } catch (e) {
      debugPrint('Failed to load statistics: $e');
    }
  }

  Future<void> _updateStatistics(bool won) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      _gamesPlayed++;
      await prefs.setInt(_keyGamesPlayed, _gamesPlayed);

      if (won) {
        _gamesWon++;
        _currentStreak++;
        if (_currentStreak > _maxStreak) {
          _maxStreak = _currentStreak;
        }
        
        // Calculate points
        final points = _calculateScore();
        _totalPoints += points;
        
        await prefs.setInt(_keyGamesWon, _gamesWon);
        await prefs.setInt(_keyCurrentStreak, _currentStreak);
        await prefs.setInt(_keyMaxStreak, _maxStreak);
        await prefs.setInt(_keyTotalPoints, _totalPoints);
      } else {
        _currentStreak = 0;
        await prefs.setInt(_keyCurrentStreak, 0);
      }
    } catch (e) {
      debugPrint('Failed to update statistics: $e');
    }
  }

  /// Calculates score based on difficulty and remaining guesses.
  int _calculateScore() {
    if (_gameState == null) return 0;
    
    final basePoints = switch (_gameState!.difficulty) {
      Difficulty.fan => 100,
      Difficulty.rookie => 250,
      Difficulty.pro => 500,
      Difficulty.allMadden => 1000,
    };

    // More remaining guesses = higher multiplier
    // 8 guesses max. 
    // Win on 1st guess (7 remaining) -> Max points?
    // Formula: Base * (Remaining + 1) / MaxGuesses (approx)
    // Or simplified: Just Flat Base? Plan said: Base * (Remaining + 1) / Max
    // Actually, simple is better. Let's do: Base + (Remaining * Bonus)
    // Plan: Score = BasePoints * (RemainingGuesses + 1) / MaxGuesses
    // Fan (100) * (7+1)/8 = 100.
    // Fan (100) * (0+1)/8 = 12.
    
    // Let's ensure it's at least integer math.
    const maxGuesses = 8;
    final remaining = _gameState!.remainingGuesses;
    // Note: remainingGuesses in GameState is decremented *before* we check win usually? 
    // Let's check GameState logic. If we just won, the last guess was added. 
    // remainingGuesses is calculated as max - guesses.length.
    // So if I win on 1st guess, guesses.length is 1, remaining is 7.
    // Formula: 100 * (7 + 1) / 8 = 100. Correct.
    
    final baseScore = (basePoints * (remaining + 1) / maxGuesses).round();
    
    // Deduct points if hint was used
    final hintPenalty = _gameState!.hintUsed ? 10 : 0;
    
    return (baseScore - hintPenalty).clamp(0, baseScore);
  }
  
  /// Checks if a difficulty level is unlocked.
  bool isDifficultyUnlocked(Difficulty difficulty) {
    if (difficulty == Difficulty.fan) return true;
    if (difficulty == Difficulty.rookie) return _totalPoints >= 500;
    if (difficulty == Difficulty.pro) return _totalPoints >= 2000;
    if (difficulty == Difficulty.allMadden) return _totalPoints >= 5000;
    return false;
  }

  /// Win percentage as a value between 0 and 1.
  double get winPercentage {
    if (_gamesPlayed == 0) return 0;
    return _gamesWon / _gamesPlayed;
  }
}
