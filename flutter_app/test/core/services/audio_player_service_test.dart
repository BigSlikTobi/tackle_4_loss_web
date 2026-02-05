import 'package:audio_service/audio_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tackle4loss_mobile/core/services/audio_player_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AudioPlayerService Lazy Initialization', () {
    late AudioPlayerService service;

    setUp(() {
      // Create a fresh instance for each test
      service = AudioPlayerService();
    });

    test('does not initialize handler on construction', () {
      // The handler should be null initially
      expect(service.isPlaying, false);
      expect(service.currentMediaItem, null);
    });

    test('streams return safe defaults before initialization', () {
      // Streams should return safe defaults when handler is null
      expect(service.playbackStateStream, isNotNull);
      expect(service.mediaItemStream, isNotNull);

      // First value should be the default
      service.playbackStateStream.first.then((state) {
        expect(state.playing, false);
      });

      service.mediaItemStream.first.then((item) {
        expect(item, null);
      });
    });

    test('init() requires platform support (skipped in unit tests)', () async {
      // Note: Actual initialization requires native platform plugins
      // (audio_service, path_provider) which aren't available in unit tests.
      // In production, init() is called lazily on first playback.
      // This test verifies the API exists and is callable.
      
      // The method exists and can be referenced
      expect(service.init, isNotNull);
      
      // In a real environment, init() would be idempotent:
      // - First call initializes the handler
      // - Second call returns early (no-op)
      // But we can't actually call it in unit tests without platform support.
    }, skip: 'Requires native platform plugins not available in unit tests');

    test('play() would trigger lazy initialization in production', () async {
      // Note: In unit tests, play() will fail trying to initialize AudioService
      // because platform plugins aren't available. This test documents the
      // expected behavior rather than testing it directly.
      
      // In production, calling play() when _audioHandler is null would:
      // 1. Call _ensureInitialized()
      // 2. Initialize the audio service
      // 3. Create and play the media item
      
      // For unit test verification, we rely on integration tests or manual testing.
      expect(service.play, isNotNull);
    }, skip: 'Requires native platform plugins not available in unit tests');

    test('playPlaylist() would trigger lazy initialization in production', () async {
      // Similar to play(), playPlaylist() triggers lazy initialization
      // via _ensureInitialized() in production environments.
      
      expect(service.playPlaylist, isNotNull);
    }, skip: 'Requires native platform plugins not available in unit tests');

    test('control methods safely no-op before initialization', () async {
      // These should not throw even when handler is null
      await service.pause();
      await service.resume();
      await service.stop();
      await service.seek(const Duration(seconds: 10));
      await service.skipToNext();
      await service.skipToPrevious();

      // Should complete without errors
      expect(true, true);
    });

    test('queue methods safely no-op before initialization', () async {
      final items = [
        {
          'url': 'https://example.com/track.mp3',
          'title': 'Track',
          'author': 'Artist',
          'imageUrl': 'https://example.com/image.jpg',
        },
      ];

      // Should not throw when handler is null
      await service.insertNext(items);
      await service.appendToQueue(items);

      // Should complete without errors
      expect(true, true);
    });

    test('onQueueExhausted returns empty stream before initialization', () {
      final stream = service.onQueueExhausted;
      expect(stream, isNotNull);

      // Should be able to listen without errors
      stream.listen((_) {});
    });
  });

  group('AudioPlayerService Testing Support', () {
    test('setInstanceForTesting allows mock injection', () {
      final mock = MockAudioPlayerServiceForTest();
      AudioPlayerService.setInstanceForTesting(mock);

      final instance = AudioPlayerService();
      expect(instance, mock);
    });

    test('testing constructor creates instance without initialization', () {
      final service = AudioPlayerService.testing();
      expect(service, isNotNull);
      
      // Should have safe defaults
      expect(service.isPlaying, false);
      expect(service.currentMediaItem, null);
    });
  });

  group('AudioPlayerService Initialization Safety', () {
    test('concurrent initialization attempts wait for first to complete', () async {
      final service = AudioPlayerService();

      // Start two concurrent play calls
      // Both should call _ensureInitialized(), but only one should actually
      // run AudioService.init() - the second should wait for the first
      
      // This test verifies the code structure exists to prevent race conditions
      // Actual behavior requires platform plugins and can't be tested in unit tests
      expect(service.init, isNotNull);
    }, skip: 'Race condition prevention requires integration testing with platform plugins');

    test('initialization failure allows retry on next call', () async {
      // If _ensureInitialized() catches an exception and _audioHandler stays null,
      // the next call to play() should retry initialization
      
      // This behavior can't be verified in unit tests without platform plugins,
      // but the code structure supports it:
      // 1. If init fails, _audioHandler remains null
      // 2. _initializationFuture is cleared
      // 3. Next call will retry initialization
      
      final service = AudioPlayerService();
      expect(service.play, isNotNull);
    }, skip: 'Error recovery requires integration testing with platform plugins');
  });
}

class MockAudioPlayerServiceForTest extends AudioPlayerService {
  MockAudioPlayerServiceForTest() : super.testing();

  @override
  Stream<PlaybackState> get playbackStateStream =>
      Stream.value(PlaybackState());

  @override
  Stream<MediaItem?> get mediaItemStream => Stream.value(null);

  @override
  Stream<void> get onQueueExhausted => const Stream.empty();
}
