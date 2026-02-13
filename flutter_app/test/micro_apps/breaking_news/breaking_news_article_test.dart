import 'package:flutter_test/flutter_test.dart';
import 'package:tackle4loss_mobile/micro_apps/breaking_news/models/breaking_news_article.dart';

void main() {
  group('BreakingNewsArticle', () {
    group('sourceName', () {
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

      test('falls back to Source when no URL provided', () {
        final article = BreakingNewsArticle(
          id: '4',
          headline: 'Test',
          createdAt: DateTime.now(),
        );

        expect(article.sourceName, 'Source');
      });
    });

    group('isUpdate', () {
      test('returns true when status is "update"', () {
        final article = BreakingNewsArticle(
          id: '1',
          headline: 'Test',
          createdAt: DateTime.now(),
          status: 'update',
        );

        expect(article.isUpdate, isTrue);
      });

      test('returns true when status is "Update" (case-insensitive)', () {
        final article = BreakingNewsArticle(
          id: '1',
          headline: 'Test',
          createdAt: DateTime.now(),
          status: 'Update',
        );

        expect(article.isUpdate, isTrue);
      });

      test('returns false when status is null', () {
        final article = BreakingNewsArticle(
          id: '1',
          headline: 'Test',
          createdAt: DateTime.now(),
        );

        expect(article.isUpdate, isFalse);
      });

      test('returns false when status is other value', () {
        final article = BreakingNewsArticle(
          id: '1',
          headline: 'Test',
          createdAt: DateTime.now(),
          status: 'published',
        );

        expect(article.isUpdate, isFalse);
      });
    });

    group('fromJson', () {
      test('parses all fields correctly', () {
        final json = {
          'id': '123',
          'headline': 'Chiefs win Super Bowl',
          'status': 'update',
          'subHeader': 'A historic victory',
          'introductionParagraph': 'The Chiefs did it again.',
          'content': 'Full story content here.',
          'imageUrl': 'https://example.com/image.jpg',
          'createdAt': '2026-02-07T12:00:00Z',
          'url': 'https://espn.com/article',
          'audioFile': 'audio.mp3',
          'sourceUrl': 'https://espn.com/article',
          'imageSource': 'Getty Images',
          'sourceName': 'ESPN',
          'teams': [
            {'team_id': 'KC'},
          ],
          'players': [
            {'player_id': 'p1', 'name': 'Mahomes', 'headshot_url': 'url'},
          ],
        };

        final article = BreakingNewsArticle.fromJson(json);

        expect(article.id, '123');
        expect(article.headline, 'Chiefs win Super Bowl');
        expect(article.status, 'update');
        expect(article.isUpdate, isTrue);
        expect(article.subHeader, 'A historic victory');
        expect(article.imageUrl, 'https://example.com/image.jpg');
        expect(article.teams, hasLength(1));
        expect(article.teams!.first.teamId, 'KC');
        expect(article.players, hasLength(1));
        expect(article.players!.first.name, 'Mahomes');
        expect(article.sourceName, 'ESPN');
      });

      test('handles missing optional fields gracefully', () {
        final json = {
          'id': 42,
          'headline': 'Minimal article',
          'createdAt': '2026-01-01T00:00:00Z',
        };

        final article = BreakingNewsArticle.fromJson(json);

        expect(article.id, '42');
        expect(article.headline, 'Minimal article');
        expect(article.status, isNull);
        expect(article.isUpdate, isFalse);
        expect(article.imageUrl, isNull);
        expect(article.teams, isNull);
        expect(article.players, isNull);
      });
    });
  });

  group('RelatedStory', () {
    group('fromJson', () {
      test('parses all fields correctly', () {
        final json = {
          'id': 'rs-1',
          'headline': 'Related headline',
          'status': 'update',
          'imageUrl': 'https://example.com/thumb.jpg',
          'createdAt': '2026-02-06T10:00:00Z',
          'subHeader': 'Sub header text',
          'introductionParagraph': 'Intro text',
          'sourceUrl': 'https://source.com/article',
          'teams': [
            {'team_id': 'SF'},
          ],
        };

        final story = RelatedStory.fromJson(json);

        expect(story.id, 'rs-1');
        expect(story.headline, 'Related headline');
        expect(story.status, 'update');
        expect(story.imageUrl, 'https://example.com/thumb.jpg');
        expect(story.createdAt, DateTime.parse('2026-02-06T10:00:00Z'));
        expect(story.teams, hasLength(1));
        expect(story.teams!.first.teamId, 'SF');
      });

      test('handles snake_case fallback keys', () {
        final json = {
          'id': 'rs-2',
          'headline': 'Snake case test',
          'image_url': 'https://example.com/image.jpg',
          'created_at': '2026-02-05T08:00:00Z',
          'source_url': 'https://source.com',
        };

        final story = RelatedStory.fromJson(json);

        expect(story.imageUrl, 'https://example.com/image.jpg');
        expect(story.createdAt, DateTime.parse('2026-02-05T08:00:00Z'));
        expect(story.sourceUrl, 'https://source.com');
      });

      test('handles numeric id', () {
        final json = {
          'id': 99,
          'headline': 'Numeric ID',
          'createdAt': '2026-01-01T00:00:00Z',
        };

        final story = RelatedStory.fromJson(json);
        expect(story.id, '99');
      });
    });

    group('toArticle', () {
      test('converts to BreakingNewsArticle with matching fields', () {
        final story = RelatedStory(
          id: 'rs-1',
          headline: 'Related headline',
          status: 'update',
          imageUrl: 'https://example.com/image.jpg',
          createdAt: DateTime(2026, 2, 6),
          subHeader: 'Sub',
          introductionParagraph: 'Intro',
          teams: [TeamReference(teamId: 'KC')],
          sourceUrl: 'https://source.com',
        );

        final article = story.toArticle();

        expect(article.id, story.id);
        expect(article.headline, story.headline);
        expect(article.status, story.status);
        expect(article.isUpdate, isTrue);
        expect(article.imageUrl, story.imageUrl);
        expect(article.createdAt, story.createdAt);
        expect(article.subHeader, story.subHeader);
        expect(article.teams, hasLength(1));
        expect(article.sourceUrl, story.sourceUrl);
      });
    });
  });

  group('TeamReference', () {
    test('fromJson parses team_id', () {
      final ref = TeamReference.fromJson({'team_id': 'DAL', 'logo_url': 'url'});
      expect(ref.teamId, 'DAL');
      expect(ref.logoUrl, 'url');
    });

    test('fromJson handles null team_id gracefully', () {
      final ref = TeamReference.fromJson({});
      expect(ref.teamId, '');
      expect(ref.logoUrl, isNull);
    });
  });

  group('PlayerReference', () {
    test('fromJson parses all fields', () {
      final ref = PlayerReference.fromJson({
        'headshot_url': 'https://img.com/player.jpg',
        'name': 'Patrick Mahomes',
        'id': 'pm15',
      });
      expect(ref.headshotUrl, 'https://img.com/player.jpg');
      expect(ref.name, 'Patrick Mahomes');
      expect(ref.id, 'pm15');
    });

    test('fromJson handles missing fields', () {
      final ref = PlayerReference.fromJson({});
      expect(ref.headshotUrl, isNull);
      expect(ref.name, isNull);
      expect(ref.id, isNull);
    });
  });
}
