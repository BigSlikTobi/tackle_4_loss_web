import '../../micro_apps/breaking_news/models/breaking_news_article.dart';

class MockNewsService {
  // Singleton
  static final MockNewsService _instance = MockNewsService._internal();
  factory MockNewsService() => _instance;
  MockNewsService._internal();

  Future<List<BreakingNewsArticle>> fetchBreakingNews() async {
    // Simulate Network Delay
    await Future.delayed(const Duration(milliseconds: 1000));
    
    // Return Mock Data
    return List.generate(5, (index) => BreakingNewsArticle.mock(index));
  }
}
