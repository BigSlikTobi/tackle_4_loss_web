import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/breaking_news_article.dart';
import '../services/breaking_news_service.dart';

class BreakingNewsController extends ChangeNotifier {
  final BreakingNewsService _newsService;
  
  BreakingNewsController({BreakingNewsService? service}) 
      : _newsService = service ?? BreakingNewsService();
  final List<BreakingNewsArticle> _articles = []; // The Queue
  final List<BreakingNewsArticle> _savedArticles = [];
  final List<BreakingNewsArticle> _refusedArticles = [];
  final List<BreakingNewsArticle> _readHistoryArticles = [];
  final Set<String> _readArticleIds = {};
  
  // Persistence Keys
  static const String _keySavedIds = 'breaking_news_saved_ids';
  static const String _keyRefusedIds = 'breaking_news_refused_ids';
  static const String _keyReadHistoryIds = 'breaking_news_read_history_ids';
  static const String _keyReadStatusIds = 'breaking_news_read_status_ids';

  bool _isLoading = false;

  List<BreakingNewsArticle> get articles => List.unmodifiable(_articles);
  List<BreakingNewsArticle> get savedArticles => List.unmodifiable(_savedArticles);
  List<BreakingNewsArticle> get refusedArticles => List.unmodifiable(_refusedArticles);
  List<BreakingNewsArticle> get readHistoryArticles => List.unmodifiable(_readHistoryArticles);
  bool get isLoading => _isLoading;

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
      final fetched = await _newsService.fetchBreakingNews(languageCode: languageCode);
      if (_isDisposed) return; // Exit early if disposed during fetch
      
      await _loadState(fetched); 
    } catch (e) {
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
    // Note: If an article is no longer in the fetched list (older than 48h), 
    // it effectively disappears from our stacks, which is desired behavior.
    _savedArticles.clear();
    _refusedArticles.clear();
    _readHistoryArticles.clear();
    _articles.clear();

    for (var article in fetchedArticles) {
      if (savedIds.contains(article.id)) {
        _savedArticles.add(article);
      } else if (refusedIds.contains(article.id)) {
        _refusedArticles.add(article);
      } else if (readHistoryIds.contains(article.id)) {
        _readHistoryArticles.add(article);
      } else {
        // Not in any stack -> It's new (or skipped) -> Queue
        _articles.add(article);
      }
    }
    
    // Sort side stacks if needed? For now default fetch order (Time Desc) is fine.
    // Actually side stacks usually stack LIFO visual, but data list is chronological.
  }

  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    // Disposal check not strictly necessary for simple async saves but good practice
    // ensuring we don't act on stale state, though _saveState is usually atomic-ish logic.
    await prefs.setStringList(_keySavedIds, _savedArticles.map((a) => a.id).toList());
    await prefs.setStringList(_keyRefusedIds, _refusedArticles.map((a) => a.id).toList());
    await prefs.setStringList(_keyReadHistoryIds, _readHistoryArticles.map((a) => a.id).toList());
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
    _articles.insert(0, article);
    
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
