import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 't4l_audio_handler.dart';

class AudioPlayerService {
  static AudioPlayerService _instance = AudioPlayerService._internal();
  factory AudioPlayerService() => _instance;

  @visibleForTesting
  static void setInstanceForTesting(AudioPlayerService mock) {
    _instance = mock;
  }

  T4LAudioHandler? _audioHandler;
  Future<void>? _initializationFuture;

  AudioPlayerService._internal();

  @visibleForTesting
  AudioPlayerService.testing();

  /// Lazily initialize the audio service on first use.
  /// This avoids activating the native audio session at app startup,
  /// which would interrupt other apps' audio (e.g. music, podcasts on iOS)
  /// and waste resources if the user never plays audio.
  ///
  /// Prevents race conditions by ensuring only one initialization attempt
  /// runs at a time. If initialization fails, subsequent calls will retry.
  Future<void> _ensureInitialized() async {
    // Already initialized successfully
    if (_audioHandler != null) return;

    // Initialization in progress - wait for it to complete
    if (_initializationFuture != null) {
      await _initializationFuture;
      return;
    }

    // Start new initialization
    _initializationFuture = _initializeAudioService();
    await _initializationFuture;
    _initializationFuture = null;
  }

  Future<void> _initializeAudioService() async {
    try {
      _audioHandler = await AudioService.init(
        builder: () => T4LAudioHandler(),
        config: const AudioServiceConfig(
          androidNotificationChannelId: 'com.tackle4loss.channel.audio',
          androidNotificationChannelName: 'T4L Audio',
          androidNotificationOngoing: true,
        ),
      );
      debugPrint('AudioPlayerService: Successfully initialized audio service');
    } catch (e, stackTrace) {
      debugPrint('AudioPlayerService: Failed to initialize audio service: $e');
      debugPrint('Stack trace: $stackTrace');
      // _audioHandler remains null, allowing retry on next playback request
      rethrow;
    }
  }

  /// Initialize the audio service.
  /// Kept for backward compatibility / testing. In production the service
  /// is lazily initialized on first playback request.
  Future<void> init() async => await _ensureInitialized();

  /// Stream of the current playback state (playing, paused, buffering, etc.)
  Stream<PlaybackState> get playbackStateStream =>
      _audioHandler?.playbackState ?? Stream.value(PlaybackState());

  /// Stream of the current media item (title, album, art, etc.)
  Stream<MediaItem?> get mediaItemStream =>
      _audioHandler?.mediaItem ?? Stream.value(null);

  /// Current value helpers
  bool get isPlaying => _audioHandler?.playbackState.value.playing ?? false;
  MediaItem? get currentMediaItem => _audioHandler?.mediaItem.value;

  /// Play a specific URL with metadata
  Future<void> play(
      String url, String title, String author, String imageUrl) async {
    await _ensureInitialized();

    // Check if initialization succeeded
    if (_audioHandler == null) {
      debugPrint(
          'AudioPlayerService: Cannot play - audio service initialization failed');
      return;
    }

    final mediaItem = MediaItem(
      id: url,
      album: "Deep Dive",
      title: title,
      artist: author,
      artUri: Uri.parse(imageUrl),
    );

    try {
      await _audioHandler!.playMediaItem(mediaItem);
    } catch (e, stackTrace) {
      debugPrint('AudioPlayerService: Failed to play media item: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Play a list of items (Playlist)
  Future<void> playPlaylist(List<Map<String, String>> items,
      {int initialIndex = 0}) async {
    await _ensureInitialized();

    // Check if initialization succeeded
    if (_audioHandler == null) {
      debugPrint(
          'AudioPlayerService: Cannot play playlist - audio service initialization failed');
      return;
    }

    final mediaItems = items
        .map((item) => MediaItem(
              id: item['url']!,
              album: "T4L Radio",
              title: item['title']!,
              artist: item['author'] ?? "Team T4L",
              artUri: Uri.parse(item['imageUrl']!),
            ))
        .toList();

    try {
      await _audioHandler!
          .addQueueItems(mediaItems, initialIndex: initialIndex);
    } catch (e, stackTrace) {
      debugPrint('AudioPlayerService: Failed to add queue items: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<void> resume() async => await _audioHandler?.play();
  Future<void> pause() async => await _audioHandler?.pause();
  Future<void> stop() async => await _audioHandler?.stop();
  Future<void> seek(Duration position) async =>
      await _audioHandler?.seek(position);
  Future<void> skipToNext() async => await _audioHandler?.skipToNext();
  Future<void> skipToPrevious() async => await _audioHandler?.skipToPrevious();

  /// Insert items into the queue to be played next
  Future<void> insertNext(List<Map<String, String>> items) async {
    if (_audioHandler == null) return;

    final mediaItems = items
        .map((item) => MediaItem(
              id: item['url']!,
              album: "T4L Radio",
              title: item['title']!,
              artist: item['author'] ?? "Team T4L",
              artUri: Uri.parse(item['imageUrl']!),
            ))
        .toList();

    await _audioHandler!.insertQueueItemsNext(mediaItems);
  }

  /// Stream that emits when the queue is exhausted (all items played)
  /// Listen to this to fetch and append more content for continuous playback
  Stream<void> get onQueueExhausted =>
      _audioHandler?.onQueueExhausted ?? const Stream.empty();

  /// Append items to the end of the queue (for continuous streaming)
  /// If queue was exhausted, this will resume playback with the new content
  Future<void> appendToQueue(List<Map<String, String>> items) async {
    if (_audioHandler == null) return;

    final mediaItems = items
        .map((item) => MediaItem(
              id: item['url']!,
              album: "T4L Radio",
              title: item['title']!,
              artist: item['author'] ?? "Team T4L",
              artUri: Uri.parse(item['imageUrl']!),
            ))
        .toList();

    await _audioHandler!.appendQueueItems(mediaItems);
  }
}
