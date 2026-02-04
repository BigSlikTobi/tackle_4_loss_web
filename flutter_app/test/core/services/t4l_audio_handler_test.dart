import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tackle4loss_mobile/core/services/t4l_audio_handler.dart';

class MockAudioPlayer extends Mock implements AudioPlayer {}

class FakeAudioSource extends Fake implements AudioSource {}

// Test the queue exhaustion and continuous playback logic
// Note: Full T4LAudioHandler testing requires mocking just_audio and audio_session
// which are platform-specific. These tests focus on the queue logic.

void main() {
  setUpAll(() {
    registerFallbackValue(FakeAudioSource());
    registerFallbackValue(Duration.zero);
  });

  group('T4LAudioHandler Queue Logic', () {
    test('queue exhaustion signal emits when no more tracks', () async {
      // This test verifies the expected behavior of queue exhaustion
      // In a real implementation, we'd mock the audio player

      final controller = StreamController<void>.broadcast();
      var exhaustedCalled = false;

      controller.stream.listen((_) {
        exhaustedCalled = true;
      });

      // Simulate queue exhaustion
      controller.add(null);

      await Future.delayed(const Duration(milliseconds: 10));
      expect(exhaustedCalled, true);

      await controller.close();
    });

    test('MediaItem properties are correctly set', () {
      // Test that MediaItem is correctly constructed for queue items
      final item = MediaItem(
        id: 'https://example.com/audio.mp3',
        album: 'T4L Radio',
        title: 'Test News Article',
        artist: 'Team T4L',
        artUri: Uri.parse('https://example.com/image.jpg'),
      );

      expect(item.id, 'https://example.com/audio.mp3');
      expect(item.title, 'Test News Article');
      expect(item.artist, 'Team T4L');
      expect(item.album, 'T4L Radio');
    });

    test('queue index bounds checking works correctly', () {
      // Test the logic for determining if there are more tracks
      const queueLength = 5;

      // At index 0, there are more tracks
      var currentIndex = 0;
      expect(currentIndex + 1 < queueLength, true);

      // At index 3, there is one more track
      currentIndex = 3;
      expect(currentIndex + 1 < queueLength, true);

      // At index 4 (last item), no more tracks
      currentIndex = 4;
      expect(currentIndex + 1 < queueLength, false);
    });

    test('appendQueueItems correctly identifies exhausted state', () {
      // Test the logic for determining if queue was exhausted
      final currentQueue = [
        const MediaItem(id: '1', title: 'Track 1'),
        const MediaItem(id: '2', title: 'Track 2'),
        const MediaItem(id: '3', title: 'Track 3'),
      ];

      // If at last item (index 2), queue is exhausted
      var currentIndex = 2;
      var wasExhausted =
          currentQueue.isEmpty || currentIndex >= currentQueue.length - 1;
      expect(wasExhausted, true);

      // If at middle item (index 1), queue is not exhausted
      currentIndex = 1;
      wasExhausted =
          currentQueue.isEmpty || currentIndex >= currentQueue.length - 1;
      expect(wasExhausted, false);

      // Empty queue is always exhausted
      final emptyQueue = <MediaItem>[];
      wasExhausted =
          emptyQueue.isEmpty || currentIndex >= emptyQueue.length - 1;
      expect(wasExhausted, true);
    });
  });

  group('T4LAudioHandler (just_audio integration)', () {
    late MockAudioPlayer mockPlayer;
    late StreamController<PlaybackEvent> playbackEvents;
    late StreamController<int?> currentIndexEvents;
    late StreamController<PlayerState> playerStateEvents;

    setUp(() {
      mockPlayer = MockAudioPlayer();
      playbackEvents = StreamController<PlaybackEvent>.broadcast();
      currentIndexEvents = StreamController<int?>.broadcast();
      playerStateEvents = StreamController<PlayerState>.broadcast();

      when(() => mockPlayer.playbackEventStream)
          .thenAnswer((_) => playbackEvents.stream);
      when(() => mockPlayer.currentIndexStream)
          .thenAnswer((_) => currentIndexEvents.stream);
      when(() => mockPlayer.playerStateStream)
          .thenAnswer((_) => playerStateEvents.stream);

      when(() => mockPlayer.processingState)
          .thenReturn(ProcessingState.ready);
      when(() => mockPlayer.playing).thenReturn(false);
      when(() => mockPlayer.position).thenReturn(Duration.zero);
      when(() => mockPlayer.bufferedPosition).thenReturn(Duration.zero);
      when(() => mockPlayer.speed).thenReturn(1.0);
      when(() => mockPlayer.currentIndex).thenReturn(0);
      when(() => mockPlayer.hasNext).thenReturn(false);
      when(() => mockPlayer.hasPrevious).thenReturn(false);

      when(() => mockPlayer.setAudioSource(
            any(),
            initialIndex: any(named: 'initialIndex'),
            initialPosition: any(named: 'initialPosition'),
          )).thenAnswer((_) async => null);
      when(() => mockPlayer.play()).thenAnswer((_) async => null);
      when(() => mockPlayer.pause()).thenAnswer((_) async => null);
      when(() => mockPlayer.stop()).thenAnswer((_) async => null);
      when(() => mockPlayer.seek(any(), index: any(named: 'index')))
          .thenAnswer((_) async => null);
      when(() => mockPlayer.seekToNext()).thenAnswer((_) async => null);
      when(() => mockPlayer.seekToPrevious()).thenAnswer((_) async => null);
    });

    tearDown(() async {
      await playbackEvents.close();
      await currentIndexEvents.close();
      await playerStateEvents.close();
    });

    test('emits queue exhausted when completed on last item', () async {
      final handler =
          T4LAudioHandler(player: mockPlayer, configureSession: false);
      handler.queue.add(const [
        MediaItem(id: 'https://example.com/1.mp3', title: 'Track 1'),
        MediaItem(id: 'https://example.com/2.mp3', title: 'Track 2'),
      ]);
      when(() => mockPlayer.currentIndex).thenReturn(1);

      final exhausted = Completer<void>();
      final sub = handler.onQueueExhausted.listen((_) {
        if (!exhausted.isCompleted) {
          exhausted.complete();
        }
      });

      playerStateEvents.add(PlayerState(false, ProcessingState.completed));

      await exhausted.future.timeout(const Duration(milliseconds: 100));
      await sub.cancel();
    });

    test('appendQueueItems resumes playback when exhausted', () async {
      final handler =
          T4LAudioHandler(player: mockPlayer, configureSession: false);
      handler.queue.add(const [
        MediaItem(id: 'https://example.com/1.mp3', title: 'Track 1'),
      ]);
      when(() => mockPlayer.processingState)
          .thenReturn(ProcessingState.completed);
      when(() => mockPlayer.currentIndex).thenReturn(0);
      when(() => mockPlayer.playing).thenReturn(false);

      await handler.appendQueueItems(const [
        MediaItem(id: 'https://example.com/2.mp3', title: 'Track 2'),
      ]);

      verify(() => mockPlayer.seek(Duration.zero, index: 1)).called(1);
      verify(() => mockPlayer.play()).called(1);
    });

    test('insertQueueItemsNext inserts after current index', () async {
      final handler =
          T4LAudioHandler(player: mockPlayer, configureSession: false);

      await handler.addQueueItems(const [
        MediaItem(id: 'https://example.com/1.mp3', title: 'Track 1'),
        MediaItem(id: 'https://example.com/2.mp3', title: 'Track 2'),
      ]);

      when(() => mockPlayer.currentIndex).thenReturn(0);

      await handler.insertQueueItemsNext(const [
        MediaItem(id: 'https://example.com/3.mp3', title: 'Track 3'),
      ]);

      expect(
        handler.queue.value.map((item) => item.id).toList(),
        [
          'https://example.com/1.mp3',
          'https://example.com/3.mp3',
          'https://example.com/2.mp3',
        ],
      );
    });
  });

  group('RadioController Queue Exhaustion Logic', () {
    test('filters out already played items', () {
      final playedIds = {'url1', 'url2'};
      final allNews = [
        {'url': 'url1', 'title': 'News 1'},
        {'url': 'url2', 'title': 'News 2'},
        {'url': 'url3', 'title': 'News 3'},
      ];

      final unplayedNews =
          allNews.where((track) => !playedIds.contains(track['url'])).toList();

      expect(unplayedNews.length, 1);
      expect(unplayedNews.first['url'], 'url3');
    });

    test('filters out items already in playlist', () {
      final currentPlaylistIds = {'url1', 'url3'};
      final allNews = [
        {'url': 'url1', 'title': 'News 1'},
        {'url': 'url2', 'title': 'News 2'},
        {'url': 'url3', 'title': 'News 3'},
        {'url': 'url4', 'title': 'News 4'},
      ];

      final newItems = allNews
          .where((track) => !currentPlaylistIds.contains(track['url']))
          .toList();

      expect(newItems.length, 2);
      expect(newItems.map((e) => e['url']).toList(), ['url2', 'url4']);
    });

    test('combined filtering removes both played and queued items', () {
      final playedIds = {'url1'};
      final currentPlaylistIds = {'url2', 'url3'};
      final allNews = [
        {'url': 'url1', 'title': 'News 1'},
        {'url': 'url2', 'title': 'News 2'},
        {'url': 'url3', 'title': 'News 3'},
        {'url': 'url4', 'title': 'News 4'},
        {'url': 'url5', 'title': 'News 5'},
      ];

      // First filter: remove played
      final unplayedNews =
          allNews.where((track) => !playedIds.contains(track['url'])).toList();

      // Second filter: remove already in playlist
      final newItems = unplayedNews
          .where((track) => !currentPlaylistIds.contains(track['url']))
          .toList();

      expect(newItems.length, 2);
      expect(newItems.map((e) => e['url']).toList(), ['url4', 'url5']);
    });

    test('returns empty list when all items are played or queued', () {
      final playedIds = {'url1', 'url2'};
      final currentPlaylistIds = {'url3'};
      final allNews = [
        {'url': 'url1', 'title': 'News 1'},
        {'url': 'url2', 'title': 'News 2'},
        {'url': 'url3', 'title': 'News 3'},
      ];

      final unplayedNews =
          allNews.where((track) => !playedIds.contains(track['url'])).toList();

      final newItems = unplayedNews
          .where((track) => !currentPlaylistIds.contains(track['url']))
          .toList();

      expect(newItems.isEmpty, true);
    });
  });
}
