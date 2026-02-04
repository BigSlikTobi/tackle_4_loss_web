import 'package:flutter_test/flutter_test.dart';
import 'package:tackle4loss_mobile/micro_apps/breaking_news/models/breaking_news_article.dart';

void main() {
  group('BreakingNewsArticle.sourceName', () {
    test('uses explicit source name when provided', () {
      final article = BreakingNewsArticle(
        id: '1',
        headline: 'Test',
        createdAt: DateTime.now(),
        sourceName: 'The Athletic',
      );

      expect(article.sourceName, 'The Athletic');
    });

    test('parses host from sourceUrl when name missing', () {
      final article = BreakingNewsArticle(
        id: '2',
        headline: 'Test',
        createdAt: DateTime.now(),
        sourceUrl: 'https://www.espn.com/nfl',
      );

      expect(article.sourceName, 'espn.com');
    });

    test('falls back to Source on invalid url', () {
      final article = BreakingNewsArticle(
        id: '3',
        headline: 'Test',
        createdAt: DateTime.now(),
        sourceUrl: 'not a url',
      );

      expect(article.sourceName, 'Source');
    });
  });
}
