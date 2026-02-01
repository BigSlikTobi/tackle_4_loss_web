import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tackle4loss_mobile/core/os_shell/controllers/news_feed_controller.dart';
import 'package:tackle4loss_mobile/core/models/news_feed_item.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockFunctionsClient extends Mock implements FunctionsClient {}

class MockRealtimeChannel extends Mock implements RealtimeChannel {}

void main() {
  late NewsFeedController controller;
  late MockSupabaseClient mockSupabaseClient;
  late MockFunctionsClient mockFunctionsClient;
  late MockRealtimeChannel mockRealtimeChannel;

  setUpAll(() {
    registerFallbackValue(PostgresChangeEvent.insert);
  });

  setUp(() async {
    // Load mock env
    dotenv.testLoad(fileInput: 'SUPABASE_URL=https://mock.supabase.co');

    mockSupabaseClient = MockSupabaseClient();
    mockFunctionsClient = MockFunctionsClient();
    mockRealtimeChannel = MockRealtimeChannel();

    // Setup mocks
    when(() => mockSupabaseClient.functions).thenReturn(mockFunctionsClient);

    // Mock channel subscription
    when(() => mockSupabaseClient.channel(any()))
        .thenReturn(mockRealtimeChannel);
    when(() => mockRealtimeChannel.onPostgresChanges(
          event: any(named: 'event'),
          schema: any(named: 'schema'),
          table: any(named: 'table'),
          callback: any(named: 'callback'),
        )).thenReturn(mockRealtimeChannel);
    when(() => mockRealtimeChannel.subscribe()).thenReturn(mockRealtimeChannel);

    // Mock functions invoke for loadInitial
    when(() => mockFunctionsClient.invoke(
              'get-news-feed',
              body: any(named: 'body'),
            ))
        .thenAnswer((_) async => FunctionResponse(
            status: 200, data: {'items': [], 'hasMore': false}));

    controller = NewsFeedController(
      languageCode: 'en',
      client: mockSupabaseClient,
    );
  });

  group('NewsFeedController', () {
    test('loadInitial subscribes to realtime channel and fetches data',
        () async {
      await controller.loadInitial();

      // Verify subscription
      verify(() => mockSupabaseClient.channel('news-feed-updates')).called(1);
      verify(() => mockRealtimeChannel.onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'content',
            table: 'news_updates',
            callback: any(named: 'callback'),
          )).called(1);
      verify(() => mockRealtimeChannel.subscribe()).called(1);

      // Verify initial fetch
      verify(() => mockFunctionsClient.invoke(
            'get-news-feed',
            body: {'language_code': 'en', 'limit': 20, 'offset': 0},
          )).called(1);
    });

    test('handles realtime insert correctly', () async {
      // Initialize to trigger the subscription
      await controller.loadInitial();

      // Capture the callback
      final capturedCalls = verify(() => mockRealtimeChannel.onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'content',
            table: 'news_updates',
            callback: captureAny(named: 'callback'),
          )).captured;

      final callback =
          capturedCalls.last as void Function(PostgresChangePayload);

      // Create a dummy payload
      final payload = PostgresChangePayload(
        eventType: PostgresChangeEvent.insert,
        newRecord: {
          'id': 'new-item-123',
          'created_at': DateTime.now().toIso8601String(),
          'headline': 'Realtime Headline',
          'language_code': 'en',
          'image_file': 'test.jpg',
        },
        oldRecord: {},
        schema: 'content',
        table: 'news_updates',
        commitTimestamp: DateTime.now(),
        errors: null,
      );

      // Invoke callback
      callback(payload);

      // Wait for UI to update (microtask)
      await Future.delayed(Duration.zero);

      // Verify item was added
      expect(controller.items.length, 1);
      final item = controller.items.first as NewsFeedItem;
      expect(item.id, 'new-item-123');
      expect(item.headline, 'Realtime Headline');
    });

    test('ignores realtime insert with different language', () async {
      await controller.loadInitial();

      final capturedCalls = verify(() => mockRealtimeChannel.onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'content',
            table: 'news_updates',
            callback: captureAny(named: 'callback'),
          )).captured;

      final callback =
          capturedCalls.last as void Function(PostgresChangePayload);

      final payload = PostgresChangePayload(
        eventType: PostgresChangeEvent.insert,
        newRecord: {
          'id': 'de-item-123',
          'created_at': DateTime.now().toIso8601String(),
          'headline': 'German Headline',
          'language_code': 'de', // Different language
        },
        oldRecord: {},
        schema: 'content',
        table: 'news_updates',
        commitTimestamp: DateTime.now(),
        errors: null,
      );

      callback(payload);

      expect(controller.items, isEmpty);
    });

    test('loadMore fetches next page and handles duplicates', () async {
      // Setup initial fetch response
      when(() => mockFunctionsClient.invoke('get-news-feed',
          body: any(named: 'body'))).thenAnswer((invocation) async {
        final body = invocation.namedArguments[#body] as Map;
        final offset = body['offset'] as int;

        if (offset == 0) {
          return FunctionResponse(status: 200, data: {
            'items': [
              {
                'id': '1',
                'headline': 'Item 1',
                'createdAt': DateTime.now().toIso8601String()
              }
            ],
            'hasMore': true
          });
        } else {
          // Second page returns item 2 AND item 1 (duplicate to test logic)
          return FunctionResponse(status: 200, data: {
            'items': [
              {
                'id': '2',
                'headline': 'Item 2',
                'createdAt': DateTime.now().toIso8601String()
              },
              {
                'id': '1',
                'headline': 'Item 1',
                'createdAt': DateTime.now().toIso8601String()
              } // Duplicate
            ],
            'hasMore': false
          });
        }
      });

      await controller.loadInitial();
      expect(controller.items.length, 1);

      await controller.loadMore();

      // Should have 2 items: 1 and 2. The duplicate 1 should be ignored.
      expect(controller.items.length, 2);
      expect(controller.items.map((e) => e.id), containsAll(['1', '2']));
    });
  });
}
