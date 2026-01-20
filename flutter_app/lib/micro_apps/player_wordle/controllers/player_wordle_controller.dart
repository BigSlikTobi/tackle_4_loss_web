/// Controller for the NFL Guessing Game.
/// Manages game state, handles user interactions, and persists statistics.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/player_model.dart';
import '../models/game_state.dart';
import '../models/guess_result.dart';
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

  /// Daily Challenge State
  bool _isDailyChallenge = false;
  bool get isDailyChallenge => _isDailyChallenge;

  String? _dailyChallengeDate;
  String? get dailyChallengeDate => _dailyChallengeDate;

  bool _dailyChallengeCompleted = false;
  bool get dailyChallengeCompleted => _dailyChallengeCompleted;

  int _dailyStreak = 0;
  int get dailyStreak => _dailyStreak;

  List<String> _dailyTeamsInvolved = [];
  List<String> get dailyTeamsInvolved => _dailyTeamsInvolved;

  /// Team Hint State (available after 3 guesses without team match)
  bool _canUseTeamHint = false;
  bool get canUseTeamHint => _canUseTeamHint;

  String? _revealedTeamHint;
  String? get revealedTeamHint => _revealedTeamHint;

  static const int _teamHintCost = 50;

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
      _isDailyChallenge = false; // Reset daily mode
      _canUseTeamHint = false;
      _revealedTeamHint = null;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to start new game: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Starts the daily challenge.
  /// Same player for all users on the same day.
  Future<void> startDailyChallenge() async {
    _isLoading = true;
    _error = null;
    _mysteryPlayer = null;
    _searchResults = [];
    _isDailyChallenge = true;
    _canUseTeamHint = false;
    _revealedTeamHint = null;
    notifyListeners();

    try {
      final result = await _service.getDailyPlayerId(difficulty: _selectedDifficulty);
      
      // Check if already completed today
      final prefs = await SharedPreferences.getInstance();
      final completedDate = prefs.getString(_keyDailyCompletedDate);
      
      if (completedDate == result.date) {
        _dailyChallengeCompleted = true;
        // Load result and show "Already Played" state
        final resultStatus = prefs.getString(_keyDailyResult) ?? 'lost';
        _mysteryPlayer = await _service.getPlayerDetails(result.playerId);
        
        _gameState = GameState(
          mysteryPlayerId: result.playerId,
          status: resultStatus == 'won' ? GameStatus.won : GameStatus.lost,
          difficulty: _selectedDifficulty,
        );
      } else {
        _dailyChallengeCompleted = false;
        _gameState = GameState.newGame(
          mysteryPlayerId: result.playerId,
          difficulty: _selectedDifficulty,
        );
      }
      
      _dailyChallengeDate = result.date;
      _dailyTeamsInvolved = result.teamsInvolved;
      _dailyStreak = prefs.getInt(_keyDailyStreak) ?? 0;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to start daily challenge: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Uses the team hint (50 points cost).
  /// Only available after 3 guesses without guessing the correct team.
  Future<void> useTeamHint() async {
    if (!_canUseTeamHint || _revealedTeamHint != null) return;
    if (_totalPoints < _teamHintCost) return;
    
    try {
      // Fetch mystery player to get team
      final player = await _service.getPlayerDetails(_gameState!.mysteryPlayerId);
      _revealedTeamHint = player.teamName ?? player.team;
      _totalPoints -= _teamHintCost;
      
      // Save updated points
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keyTotalPoints, _totalPoints);
      
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to use team hint: $e');
    }
  }

  /// Checks if team hint should be enabled (after 3 wrong team guesses)
  void _checkTeamHintAvailability() {
    if (_gameState == null || _gameState!.guesses.length < 3) {
      _canUseTeamHint = false;
      return;
    }
    
    // Check if any guess has correct team
    final hasCorrectTeam = _gameState!.guesses.any((g) => g.teamMatch == MatchStatus.match);
    _canUseTeamHint = !hasCorrectTeam && _revealedTeamHint == null;
  }

  // SharedPreferences keys for daily challenge
  static const String _keyDailyCompletedDate = 'player_wordle_daily_completed_date';
  static const String _keyDailyResult = 'player_wordle_daily_result';
  static const String _keyDailyStreak = 'player_wordle_daily_streak';

  /// Searches for players by name.
  /// Allows browsing with filters even without text input.
  Future<void> searchPlayers(String query) async {
    // Allow search with empty query if filters are active (browse mode)
    final hasFilters = _selectedTeamFilter != null || _selectedPositionFilter != null;
    if (query.isEmpty && !hasFilters) {
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
    // Reset position when team changes
    _selectedPositionFilter = null;
    notifyListeners();
    // Auto-load players when both filters are set
    if (_selectedTeamFilter != null && _selectedPositionFilter != null) {
      searchPlayers('');
    } else if (_selectedTeamFilter != null || _selectedPositionFilter != null) {
      // Load with current filters
      searchPlayers('');
    } else {
      clearSearch();
    }
  }

  /// Sets position filter and refreshes search if active.
  void setPositionFilter(String? position) {
    if (_selectedPositionFilter == position) return;
    _selectedPositionFilter = position;
    notifyListeners();
    // Auto-load players when both filters are set
    if (_selectedTeamFilter != null && _selectedPositionFilter != null) {
      searchPlayers('');
    } else if (_selectedTeamFilter != null || _selectedPositionFilter != null) {
      searchPlayers('');
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

      // Haptic feedback based on result
      if (result.isCorrect) {
        HapticFeedback.heavyImpact();
      } else {
        HapticFeedback.lightImpact();
      }

      // Check if team hint should be available (after 3 guesses)
      _checkTeamHintAvailability();

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
      
      final won = _gameState!.status == GameStatus.won;
      await _updateStatistics(won);
      
      // Handle daily challenge completion
      if (_isDailyChallenge && _dailyChallengeDate != null) {
        final prefs = await SharedPreferences.getInstance();
        final previousDate = prefs.getString(_keyDailyCompletedDate);
        
        // Mark as completed
        await prefs.setString(_keyDailyCompletedDate, _dailyChallengeDate!);
        await prefs.setString(_keyDailyResult, won ? 'won' : 'lost');
        _dailyChallengeCompleted = true;
        
        // Update streak if won
        if (won) {
          // Check if this continues a streak (previous completion was yesterday)
          final today = DateTime.now();
          final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
          final yesterday = today.subtract(const Duration(days: 1));
          final yesterdayStr = '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}';
          
          if (previousDate == yesterdayStr) {
            _dailyStreak++;
          } else if (previousDate != todayStr) {
            // Reset streak if missed a day
            _dailyStreak = 1;
          }
          await prefs.setInt(_keyDailyStreak, _dailyStreak);
        } else {
          // Lost - reset streak
          _dailyStreak = 0;
          await prefs.setInt(_keyDailyStreak, 0);
        }
      }
      
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
  static const _keyHasSeenOnboarding = 'player_wordle_has_seen_onboarding';
  
  int _totalPoints = 0;
  int get totalPoints => _totalPoints;

  bool _hasSeenOnboarding = false;
  bool get hasSeenOnboarding => _hasSeenOnboarding;

  Future<void> _loadStatistics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _gamesPlayed = prefs.getInt(_keyGamesPlayed) ?? 0;
      _gamesWon = prefs.getInt(_keyGamesWon) ?? 0;
      _currentStreak = prefs.getInt(_keyCurrentStreak) ?? 0;
      _maxStreak = prefs.getInt(_keyMaxStreak) ?? 0;
      _totalPoints = prefs.getInt(_keyTotalPoints) ?? 0;
      _hasSeenOnboarding = prefs.getBool(_keyHasSeenOnboarding) ?? false;
      
      // Set default difficulty based on user level
      _selectedDifficulty = getHighestUnlockedDifficulty();
    } catch (e) {
      debugPrint('Failed to load statistics: $e');
    }
  }

  Future<void> markOnboardingSeen() async {
    _hasSeenOnboarding = true;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyHasSeenOnboarding, true);
    } catch (e) {
      debugPrint('Failed to save onboarding state: $e');
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
  
  /// Gets the highest difficulty level unlocked by the current points.
  Difficulty getHighestUnlockedDifficulty() {
    if (_totalPoints >= 5000) return Difficulty.allMadden;
    if (_totalPoints >= 2000) return Difficulty.pro;
    if (_totalPoints >= 500) return Difficulty.rookie;
    return Difficulty.fan;
  }

  /// Win percentage as a value between 0 and 1.
  double get winPercentage {
    if (_gamesPlayed == 0) return 0;
    return _gamesWon / _gamesPlayed;
  }
}
