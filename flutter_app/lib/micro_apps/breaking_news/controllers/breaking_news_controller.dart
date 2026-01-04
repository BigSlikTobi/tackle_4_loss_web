import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/breaking_news_article.dart';
import '../services/breaking_news_service.dart';

class BreakingNewsController extends ChangeNotifier {
  final BreakingNewsService _newsService;

  BreakingNewsController({BreakingNewsService? service})
    : _newsService = service ?? BreakingNewsService();
  final List<BreakingNewsArticle> _articles = []; // The Filtered Queue
  final List<BreakingNewsArticle> _allAvailableArticles =
      []; // Source for the queue (minus saved/refused/read)
  final List<BreakingNewsArticle> _savedArticles = [];
  final List<BreakingNewsArticle> _refusedArticles = [];
  final List<BreakingNewsArticle> _readHistoryArticles = [];
  final Set<String> _readArticleIds = {};

  String? _currentTeamFilter;
  bool _isNewestFirst = true;

  // Persistence Keys
  static const String _keySavedIds = 'breaking_news_saved_ids';
  static const String _keyRefusedIds = 'breaking_news_refused_ids';
  static const String _keyReadHistoryIds = 'breaking_news_read_history_ids';
  static const String _keyReadStatusIds = 'breaking_news_read_status_ids';

  bool _isLoading = false;

  List<BreakingNewsArticle> get articles => List.unmodifiable(_articles);
  List<BreakingNewsArticle> get savedArticles =>
      List.unmodifiable(_savedArticles);
  List<BreakingNewsArticle> get refusedArticles =>
      List.unmodifiable(_refusedArticles);
  List<BreakingNewsArticle> get readHistoryArticles =>
      List.unmodifiable(_readHistoryArticles);
  bool get isLoading => _isLoading;
  String? get currentTeamFilter => _currentTeamFilter;
  bool get isNewestFirst => _isNewestFirst;

  Map<String, String> get availableTeams {
    final teams = <String, String>{};
    for (var article in _allAvailableArticles) {
      if (article.teams != null) {
        for (var team in article.teams!) {
          // Changed to use Strong types
          final teamId = team.teamId;
          // Note: team.teamId is the ID, not necessarily the name. 
          // However, previous code seemingly expected 'team_name' key.
          // Based on usage in UI (logos/teams/$teamId.png), teamId seems to be the abbr/id.
          // If the previous code relied on 'team_name' for display name, but now we only have teamId,
          // we might need to rely on teamId as the key.
          // Assuming teamId is sufficient for filtering.
          
          if (teamId.isNotEmpty) {
            final logo = team.logoUrl ?? '';
            teams[teamId] = logo;
          }
        }
      }
    }
    return teams;
  }

  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  Future<void> loadNews({String languageCode = 'en'}) async {
    _isLoading = true;
    // We assume the caller (Widget) is still mounting us here, but safe to check
    if (!_isDisposed) notifyListeners();

    try {
      final fetched = await _newsService.fetchBreakingNews(
        languageCode: languageCode,
      );
      if (_isDisposed) return; // Exit early if disposed during fetch

      await _loadState(fetched);
    } catch (e, stackTrace) {
      debugPrint('Error loading breaking news: $e');
      debugPrint(stackTrace.toString());
      _articles.clear();
    }

    _isLoading = false;
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  Future<void> _loadState(List<BreakingNewsArticle> fetchedArticles) async {
    final prefs = await SharedPreferences.getInstance();
    if (_isDisposed) return;

    final savedIds = prefs.getStringList(_keySavedIds) ?? [];
    final refusedIds = prefs.getStringList(_keyRefusedIds) ?? [];
    final readHistoryIds = prefs.getStringList(_keyReadHistoryIds) ?? [];
    final readStatusIds = prefs.getStringList(_keyReadStatusIds) ?? [];

    _readArticleIds.clear();
    _readArticleIds.addAll(readStatusIds);

    // Clear and repopulate lists locally based on matching IDs from fetched content
    _savedArticles.clear();
    _refusedArticles.clear();
    _readHistoryArticles.clear();
    _allAvailableArticles.clear();

    for (var article in fetchedArticles) {
      if (savedIds.contains(article.id)) {
        _savedArticles.add(article);
      } else if (refusedIds.contains(article.id)) {
        _refusedArticles.add(article);
      } else if (readHistoryIds.contains(article.id)) {
        _readHistoryArticles.add(article);
      } else {
        _allAvailableArticles.add(article);
      }
    }

    _applyFilterAndSort();
  }

  void _applyFilterAndSort() {
    _articles.clear();

    // 1. Filter
    final filtered = _allAvailableArticles.where((article) {
      if (_currentTeamFilter == null) return true;
      if (article.teams == null) return false;
      return article.teams!.any(
        (team) => team.teamId == _currentTeamFilter,
      );
    }).toList();

    // 2. Sort
    filtered.sort((a, b) {
      if (_isNewestFirst) {
        return b.createdAt.compareTo(a.createdAt);
      } else {
        return a.createdAt.compareTo(b.createdAt);
      }
    });

    _articles.addAll(filtered);
  }

  /// Moves the article with [id] to the top of the list
  void prioritizeArticle(String id) {
    BreakingNewsArticle? targetArticle;

    // 1. Check active articles first
    final index = _articles.indexWhere((a) => a.id == id);
    if (index != -1) {
      targetArticle = _articles.removeAt(index);
    } 
    // 2. Check all available (but filtered out?)
    else {
      final availIndex = _allAvailableArticles.indexWhere((a) => a.id == id);
      if (availIndex != -1) {
        targetArticle = _allAvailableArticles.removeAt(availIndex);
      }
    }

    // 3. Check other lists if not found yet
    if (targetArticle == null) {
      if (_removeFromList(_savedArticles, id, out: (a) => targetArticle = a)) {
        // found in saved
      } else if (_removeFromList(_refusedArticles, id, out: (a) => targetArticle = a)) {
        // found in refused
      } else if (_removeFromList(_readHistoryArticles, id, out: (a) => targetArticle = a)) {
        // found in history
      }
    }

    // 4. If found anywhere, put it at top of active list
    if (targetArticle != null) {
      _articles.insert(0, targetArticle!);
      if (!_isDisposed) notifyListeners();
    }
  }

  bool _removeFromList(List<BreakingNewsArticle> list, String id, {required Function(BreakingNewsArticle) out}) {
    final index = list.indexWhere((a) => a.id == id);
    if (index != -1) {
      out(list.removeAt(index));
      return true;
    }
    return false;
  }

  void setTeamFilter(String? teamName) {
    if (_currentTeamFilter == teamName) return;
    _currentTeamFilter = teamName;
    _applyFilterAndSort();
    if (!_isDisposed) notifyListeners();
  }

  void toggleSort() {
    _isNewestFirst = !_isNewestFirst;
    _applyFilterAndSort();
    if (!_isDisposed) notifyListeners();
  }

  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    // Disposal check not strictly necessary for simple async saves but good practice
    // ensuring we don't act on stale state, though _saveState is usually atomic-ish logic.
    await prefs.setStringList(
      _keySavedIds,
      _savedArticles.map((a) => a.id).toList(),
    );
    await prefs.setStringList(
      _keyRefusedIds,
      _refusedArticles.map((a) => a.id).toList(),
    );
    await prefs.setStringList(
      _keyReadHistoryIds,
      _readHistoryArticles.map((a) => a.id).toList(),
    );
    await prefs.setStringList(_keyReadStatusIds, _readArticleIds.toList());
  }

  void markAsRead(String id) {
    if (!_readArticleIds.contains(id)) {
      _readArticleIds.add(id);
      _saveState(); // Persist read status
      // No notifyListeners to protect animation
    }
  }

  void swipeRight(BreakingNewsArticle article) {
    _savedArticles.add(article);
    _allAvailableArticles.remove(article);
    _articles.remove(article);
    _saveState();
    if (!_isDisposed) notifyListeners();
  }

  void swipeLeft(BreakingNewsArticle article) {
    if (_readArticleIds.contains(article.id)) {
      _readHistoryArticles.add(article);
    } else {
      _refusedArticles.add(article);
    }
    _allAvailableArticles.remove(article);
    _articles.remove(article);
    _saveState();
    if (!_isDisposed) notifyListeners();
  }

  void restoreArticle(BreakingNewsArticle article) {
    // Remove from whichever stack it is in
    if (_savedArticles.remove(article)) {
      // Removed from saved
    } else if (_refusedArticles.remove(article)) {
      // Removed from refused
    } else if (_readHistoryArticles.remove(article)) {
      // Removed from read history
    }

    // Add to TOP of queue (first item) so it appears immediately
    // Note: This temporarily ignores filter/sort until next refresh or manual change?
    // Actually let's add it back to _allAvailableArticles and re-apply.
    _allAvailableArticles.add(article);
    _applyFilterAndSort();

    _saveState();
    if (!_isDisposed) notifyListeners();
  }

  /// Clears storage and memory
  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keySavedIds);
    await prefs.remove(_keyRefusedIds);
    await prefs.remove(_keyReadHistoryIds);
    await prefs.remove(_keyReadStatusIds);

    _savedArticles.clear();
    _refusedArticles.clear();
    _readHistoryArticles.clear();
    _readArticleIds.clear();

    // Reload to fetch fresh
    await loadNews();
  }
}
