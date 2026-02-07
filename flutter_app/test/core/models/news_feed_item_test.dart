import 'package:flutter_test/flutter_test.dart';
import 'package:tackle4loss_mobile/core/models/news_feed_item.dart';

void main() {
  group('NewsFeedItem', () {
    group('isUpdate', () {
      test('returns true when status is "update"', () {
        final item = NewsFeedItem(
          id: '1',
          xPost: 'Post text',
          status: 'update',
          createdAt: DateTime.now(),
        );
        expect(item.isUpdate, isTrue);
      });

      test('returns true when status is "UPDATE" (case-insensitive)', () {
        final item = NewsFeedItem(
          id: '1',
          xPost: 'Post text',
          status: 'UPDATE',
          createdAt: DateTime.now(),
        );
        expect(item.isUpdate, isTrue);
      });

      test('returns false when status is null', () {
        final item = NewsFeedItem(
          id: '1',
          xPost: 'Post text',
          createdAt: DateTime.now(),
        );
        expect(item.isUpdate, isFalse);
      });

      test('returns false when status is other value', () {
        final item = NewsFeedItem(
          id: '1',
          xPost: 'Post text',
          status: 'published',
          createdAt: DateTime.now(),
        );
        expect(item.isUpdate, isFalse);
      });
    });

    group('fromJson', () {
      test('parses all fields correctly', () {
        final json = {
          'id': 'news-1',
          'xPost': 'Breaking: Big trade!',
          'imageUrl': 'https://example.com/img.jpg',
          'source': 'ESPN',
          'headline': 'Chiefs trade for star WR',
          'status': 'update',
          'createdAt': '2026-02-07T12:00:00Z',
          'players': [
            {'player_id': 'p1', 'headshot_url': 'url'},
          ],
          'teams': [
            {'team_id': 'KC'},
          ],
        };

        final item = NewsFeedItem.fromJson(json);

        expect(item.id, 'news-1');
        expect(item.xPost, 'Breaking: Big trade!');
        expect(item.imageUrl, 'https://example.com/img.jpg');
        expect(item.source, 'ESPN');
        expect(item.headline, 'Chiefs trade for star WR');
        expect(item.status, 'update');
        expect(item.isUpdate, isTrue);
        expect(item.type, FeedItemType.newsUpdate);
        expect(item.players, hasLength(1));
        expect(item.teams, hasLength(1));
      });

      test('handles missing optional fields', () {
        final json = {
          'id': 'news-2',
          'createdAt': '2026-01-01T00:00:00Z',
        };

        final item = NewsFeedItem.fromJson(json);

        expect(item.id, 'news-2');
        expect(item.xPost, '');
        expect(item.imageUrl, isNull);
        expect(item.source, isNull);
        expect(item.headline, isNull);
        expect(item.status, isNull);
        expect(item.isUpdate, isFalse);
      });
    });
  });

  group('FeedItem.fromJson', () {
    test('creates NewsFeedItem for type "newsUpdate"', () {
      final json = {
        'type': 'newsUpdate',
        'id': 'n1',
        'xPost': 'Post',
        'createdAt': '2026-01-01T00:00:00Z',
      };

      final item = FeedItem.fromJson(json);
      expect(item, isA<NewsFeedItem>());
    });

    test('creates DeepDiveFeedItem for type "deepDive"', () {
      final json = {
        'type': 'deepDive',
        'id': 'dd1',
        'articleId': 'art1',
        'title': 'Deep Dive',
        'summary': 'Summary',
        'author': 'Author',
        'createdAt': '2026-01-01T00:00:00Z',
      };

      final item = FeedItem.fromJson(json);
      expect(item, isA<DeepDiveFeedItem>());
    });

    test('defaults to NewsFeedItem when type is missing', () {
      final json = {
        'id': 'n2',
        'xPost': 'Post',
        'createdAt': '2026-01-01T00:00:00Z',
      };

      final item = FeedItem.fromJson(json);
      expect(item, isA<NewsFeedItem>());
    });
  });
}
