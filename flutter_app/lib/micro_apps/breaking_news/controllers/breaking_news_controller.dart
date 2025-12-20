import 'package:flutter/material.dart';
import '../models/breaking_news_article.dart';
import '../../../core/services/mock_news_service.dart';

class BreakingNewsController extends ChangeNotifier {
  final MockNewsService _newsService = MockNewsService();
  List<BreakingNewsArticle> _articles = [];
  bool _isLoading = false;

  List<BreakingNewsArticle> get articles => _articles;
  bool get isLoading => _isLoading;

  Future<void> loadNews() async {
    _isLoading = true;
    notifyListeners();

    try {
      _articles = await _newsService.fetchBreakingNews();
    } catch (e) {
      debugPrint('Error loading news: $e');
      _articles = [];
    }
    
    _isLoading = false;
    notifyListeners();
  }
}
