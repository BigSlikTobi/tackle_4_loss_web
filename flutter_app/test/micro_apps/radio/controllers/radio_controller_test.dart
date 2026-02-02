import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tackle4loss_mobile/micro_apps/radio/controllers/radio_controller.dart';
import 'package:tackle4loss_mobile/core/services/audio_player_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

// Simple mock since we are testing state logic primarily
class MockAudioPlayerService extends AudioPlayerService {
  MockAudioPlayerService() : super.testing();

  final StreamController<void> queueExhaustedController =
      StreamController<void>.broadcast();
  final StreamController<MediaItem?> mediaItemController =
      StreamController<MediaItem?>.broadcast();

  final List<List<Map<String, String>>> appendedQueues = [];
  final List<List<Map<String, String>>> insertedQueues = [];
  List<Map<String, String>>? lastPlaylist;
  int? lastInitialIndex;

  @override
  Stream<void> get onQueueExhausted => queueExhaustedController.stream;

  @override
  Stream<MediaItem?> get mediaItemStream => mediaItemController.stream;

  @override
  Future<void> playPlaylist(List<Map<String, String>> items,
      {int initialIndex = 0}) async {
    lastPlaylist = items;
    lastInitialIndex = initialIndex;
  }

  @override
  Future<void> appendToQueue(List<Map<String, String>> items) async {
    appendedQueues.add(items);
  }

  @override
  Future<void> insertNext(List<Map<String, String>> items) async {
    insertedQueues.add(items);
  }

  void emitQueueExhausted() {
    queueExhaustedController.add(null);
  }

  Future<void> close() async {
    await queueExhaustedController.close();
    await mediaItemController.close();
  }
}

class MockHttpClient extends Mock implements http.Client {}

class TestRadioController extends RadioController {
  TestRadioController({required this.responses, String? languageCode})
      : super(languageCode: languageCode);

  final List<List<Map<String, String>>> responses;
  int _callIndex = 0;

  @override
  Future<List<Map<String, String>>> fetchNewsTracks(
      String languageCode) async {
    if (_callIndex >= responses.length) {
      return responses.isNotEmpty ? responses.last : [];
    }
    return responses[_callIndex++];
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // Register fallback values if needed
    registerFallbackValue(Uri());
    SharedPreferences.setMockInitialValues({});

    final mockHttpClient = MockHttpClient();

    // Mock success response for Supabase Edge Functions (POST)
    when(() => mockHttpClient.post(any(),
            headers: any(named: 'headers'), body: any(named: 'body')))
        .thenAnswer((_) async => http.Response('[]', 200));

    // Initialize Supabase with mock client
    // Check if already initialized to avoid errors
    try {
      Supabase.instance;
    } catch (_) {
      await Supabase.initialize(
        url: 'https://example.com',
        anonKey: 'dummy',
        httpClient: mockHttpClient,
      );
    }
  });

  group('RadioController', () {
    late RadioController controller;
    late MockAudioPlayerService mockAudio;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      mockAudio = MockAudioPlayerService();
      AudioPlayerService.setInstanceForTesting(mockAudio);
      controller = RadioController();
    });

    tearDown(() async {
      controller.dispose();
      await mockAudio.close();
    });

    test('initial state is correct', () {
      expect(controller.selectedCategoryId, 'all');
      expect(controller.categories.length, 3);
      // Stations load async, so initially empty or default
      // mocked load happens in constructor but is async
    });

    test('selectCategory updates state', () {
      controller.selectCategory('deep_dive');
      expect(controller.selectedCategoryId, 'deep_dive');
    });

    test('stations filter by category', () async {
      // wait for load
      await Future.delayed(const Duration(milliseconds: 100));

      controller.selectCategory('deep_dive');
      final deepDives = controller.stations;
      expect(deepDives.every((s) => s.categoryId == 'deep_dive'), true);

      controller.selectCategory('news');
      final news = controller.stations;
      expect(news.every((s) => s.categoryId == 'news'), true);
    });
  });

  group('RadioController playback logic', () {
    late MockAudioPlayerService mockAudio;

    tearDown(() async {
      await mockAudio.close();
    });

    test('daily briefing starts at first unplayed item', () async {
      SharedPreferences.setMockInitialValues({
        'played_news_ids': ['played1']
      });
      mockAudio = MockAudioPlayerService();
      AudioPlayerService.setInstanceForTesting(mockAudio);

      final controller = TestRadioController(responses: [
        [
          {
            'url': 'img1',
            'title': 'News 1',
            'imageUrl': 'img1',
          }
        ],
        [
          {
            'url': 'played1',
            'title': 'Played',
            'imageUrl': 'img1',
          },
          {
            'url': 'unplayed1',
            'title': 'Unplayed',
            'imageUrl': 'img1',
          },
          {
            'url': 'unplayed2',
            'title': 'Unplayed 2',
            'imageUrl': 'img1',
          },
        ],
      ]);

      await Future.delayed(const Duration(milliseconds: 20));
      await controller.playStation(controller.dailyBriefingStation,
          languageCode: 'en');

      expect(mockAudio.lastInitialIndex, 1);
      controller.dispose();
    });

    test('queue exhaustion appends only new unplayed items', () async {
      SharedPreferences.setMockInitialValues({
        'played_news_ids': ['played1']
      });
      mockAudio = MockAudioPlayerService();
      AudioPlayerService.setInstanceForTesting(mockAudio);

      final controller = TestRadioController(responses: [
        [
          {
            'url': 'img1',
            'title': 'News 1',
            'imageUrl': 'img1',
          }
        ],
        [
          {
            'url': 'played1',
            'title': 'Played',
            'imageUrl': 'img1',
          },
          {
            'url': 'queued1',
            'title': 'Queued',
            'imageUrl': 'img1',
          },
          {
            'url': 'new1',
            'title': 'New 1',
            'imageUrl': 'img1',
          },
        ],
        [
          {
            'url': 'played1',
            'title': 'Played',
            'imageUrl': 'img1',
          },
          {
            'url': 'queued1',
            'title': 'Queued',
            'imageUrl': 'img1',
          },
          {
            'url': 'new1',
            'title': 'New 1',
            'imageUrl': 'img1',
          },
          {
            'url': 'new2',
            'title': 'New 2',
            'imageUrl': 'img1',
          },
        ],
      ]);

      await Future.delayed(const Duration(milliseconds: 20));
      await controller.playStation(controller.dailyBriefingStation,
          languageCode: 'en');
      mockAudio.emitQueueExhausted();
      await Future.delayed(const Duration(milliseconds: 20));

      expect(mockAudio.appendedQueues.length, 1);
      expect(mockAudio.appendedQueues.first.map((e) => e['url']).toList(),
          ['new2']);

      controller.dispose();
    });
  });
}
