import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tackle4loss_mobile/core/models/news_feed_item.dart';
import 'package:tackle4loss_mobile/core/os_shell/controllers/news_feed_controller.dart';
import 'package:tackle4loss_mobile/core/services/articles_service.dart';

class MockArticlesService extends Mock implements ArticlesService {}

NewsFeedItem _item(String id) => NewsFeedItem(
      id: id,
      xPost: 'intro $id',
      headline: 'Headline $id',
      createdAt: DateTime.parse('2026-04-26T20:15:51.000+00:00'),
    );

void main() {
  late MockArticlesService mockArticles;
  late NewsFeedController controller;

  setUp(() {
    mockArticles = MockArticlesService();
    controller = NewsFeedController(
      languageCode: 'en',
      articlesService: mockArticles,
    );
  });

  group('NewsFeedController', () {
    test('loadInitial fetches first page from ArticlesService', () async {
      when(() => mockArticles.fetchArticles(
            language: 'en',
            limit: any(named: 'limit'),
            cursor: any(named: 'cursor'),
          )).thenAnswer((_) async => ArticlesPage(items: [_item('1')]));

      await controller.loadInitial();

      verify(() => mockArticles.fetchArticles(
            language: 'en',
            limit: 20,
            cursor: null,
          )).called(1);
      expect(controller.items.length, 1);
      expect(controller.hasMore, isFalse);
    });

    test('loadMore advances by next_cursor and de-duplicates ids', () async {
      const cursor1 = ArticlesCursor(createdAt: 't1', id: 1);
      when(() => mockArticles.fetchArticles(
            language: 'en',
            limit: 20,
            cursor: null,
          )).thenAnswer((_) async => ArticlesPage(
            items: [_item('1')],
            nextCursor: cursor1,
          ));
      when(() => mockArticles.fetchArticles(
            language: 'en',
            limit: 20,
            cursor: cursor1,
          )).thenAnswer((_) async => ArticlesPage(
            items: [_item('2'), _item('1')], // duplicate '1' from page 1
          ));

      await controller.loadInitial();
      expect(controller.items.length, 1);
      expect(controller.hasMore, isTrue);

      await controller.loadMore();

      expect(controller.items.map((e) => e.id), containsAll(['1', '2']));
      expect(controller.items.length, 2);
      expect(controller.hasMore, isFalse);
    });

    test('records error when fetchArticles throws', () async {
      when(() => mockArticles.fetchArticles(
            language: any(named: 'language'),
            limit: any(named: 'limit'),
            cursor: any(named: 'cursor'),
          )).thenThrow(Exception('boom'));

      await controller.loadInitial();

      expect(controller.items, isEmpty);
      expect(controller.error, contains('boom'));
    });
  });
}
