import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

/// A [BaseAudioHandler] implementation that uses [just_audio] to play audio.
class T4LAudioHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  final AudioPlayer _player;

  ConcatenatingAudioSource _playlist = ConcatenatingAudioSource(children: []);

  /// Stream controller to signal when queue is exhausted
  /// This allows the RadioController to fetch and append more content
  final StreamController<void> _queueExhaustedController =
      StreamController<void>.broadcast();

  /// Stream that emits when the queue is exhausted (all items played)
  Stream<void> get onQueueExhausted => _queueExhaustedController.stream;

  bool _queueExhaustedNotified = false;
  bool _disposed = false;
  late final Future<void> _initFuture;
  Future<void> _queueOperation = Future.value();
  StreamSubscription<PlaybackEvent>? _playbackEventSub;
  StreamSubscription<int?>? _currentIndexSub;
  StreamSubscription<PlayerState>? _playerStateSub;

  /// Initialise our audio handler.
  T4LAudioHandler({AudioPlayer? player, bool configureSession = true})
      : _player = player ?? AudioPlayer() {
    _initFuture = _init(configureSession: configureSession);
  }

  Future<void> _init({required bool configureSession}) async {
    // Configure audio session for background playback
    if (configureSession) {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playback,
        avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.none,
        avAudioSessionMode: AVAudioSessionMode.spokenAudio,
        avAudioSessionRouteSharingPolicy:
            AVAudioSessionRouteSharingPolicy.defaultPolicy,
        avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
        androidAudioAttributes: AndroidAudioAttributes(
          contentType: AndroidAudioContentType.speech,
          usage: AndroidAudioUsage.media,
        ),
        androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
        androidWillPauseWhenDucked: true,
      ));

      await session.setActive(true);
    }

    _playbackEventSub = _player.playbackEventStream.listen(
      _broadcastState,
      onError: (Object error, StackTrace stackTrace) {
        debugPrint("T4LAudioHandler: Playback error: $error");
      },
    );

    _currentIndexSub = _player.currentIndexStream.listen((index) {
      if (index == null) return;
      final currentQueue = queue.value;
      if (index >= 0 && index < currentQueue.length) {
        mediaItem.add(currentQueue[index]);
      }
    });

    _playerStateSub = _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _notifyQueueExhaustedIfNeeded();
      } else {
        _queueExhaustedNotified = false;
      }
    });
  }

  Future<void> _ensureInitialized() async {
    await _initFuture;
  }

  Future<T> _runQueueOperation<T>(Future<T> Function() action) {
    final completer = Completer<T>();
    _queueOperation = _queueOperation.then((_) async {
      if (_disposed) {
        completer.completeError(StateError('Audio handler disposed'));
        return;
      }
      try {
        final result = await action();
        completer.complete(result);
      } catch (e, st) {
        completer.completeError(e, st);
      }
    });
    return completer.future;
  }

  void _notifyQueueExhaustedIfNeeded() {
    final currentQueue = queue.value;
    if (currentQueue.isEmpty) return;

    final currentIndex = _player.currentIndex ?? 0;
    if (currentIndex >= currentQueue.length - 1 && !_queueExhaustedNotified) {
      _queueExhaustedNotified = true;
      _queueExhaustedController.add(null);
    }
  }

  Uri? _safeUri(String raw) {
    final uri = Uri.tryParse(raw);
    if (uri == null || !uri.hasScheme) {
      return null;
    }
    return uri;
  }

  List<MediaItem> _validateItems(List<MediaItem> items, List<Uri> urisOut) {
    final validItems = <MediaItem>[];
    for (final item in items) {
      final uri = _safeUri(item.id);
      if (uri == null) {
        debugPrint(
            'T4LAudioHandler: Skipping invalid media item id: ${item.id}');
        continue;
      }
      validItems.add(item);
      urisOut.add(uri);
    }
    return validItems;
  }

  /// Broadcasts the current state to all clients.
  void _broadcastState(PlaybackEvent event) {
    final playing = _player.playing;
    final processingState = _player.processingState;

    playbackState.add(playbackState.value.copyWith(
      controls: [
        if (playing) MediaControl.pause else MediaControl.play,
        MediaControl.stop,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
        MediaAction.skipToNext,
        MediaAction.skipToPrevious,
      },
      androidCompactActionIndices: const [0, 1],
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        // Keep controls visible when completed.
        ProcessingState.completed: AudioProcessingState.ready,
      }[processingState]!,
      playing: playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: event.currentIndex,
    ));
  }

  Future<void> _setQueue(
    List<MediaItem> items, {
    int initialIndex = 0,
    bool autoplay = true,
  }) async {
    await _ensureInitialized();
    await _runQueueOperation(
        () => _setQueueInternal(items, initialIndex, autoplay));
  }

  Future<void> _setQueueInternal(
    List<MediaItem> items,
    int initialIndex,
    bool autoplay,
  ) async {
    _queueExhaustedNotified = false;

    final uris = <Uri>[];
    final validItems = _validateItems(items, uris);

    queue.add(validItems);

    if (validItems.isEmpty) {
      await _player.stop();
      mediaItem.add(null);
      return;
    }

    if (initialIndex < 0) {
      initialIndex = 0;
    }
    if (initialIndex >= items.length) {
      initialIndex = items.length - 1;
    }

    final validOriginalIndices = <int>[];
    for (var i = 0; i < items.length; i++) {
      final uri = _safeUri(items[i].id);
      if (uri != null) {
        validOriginalIndices.add(i);
      }
    }

    var resolvedIndex = 0;
    final nextValid =
        validOriginalIndices.indexWhere((index) => index >= initialIndex);
    if (nextValid != -1) {
      resolvedIndex = nextValid;
    } else {
      resolvedIndex = validItems.length - 1;
    }

    mediaItem.add(validItems[resolvedIndex]);
    _playlist = ConcatenatingAudioSource(
      children: List<AudioSource>.generate(
        validItems.length,
        (index) => AudioSource.uri(uris[index], tag: validItems[index]),
      ),
    );

    await _player.setAudioSource(
      _playlist,
      initialIndex: resolvedIndex,
      initialPosition: Duration.zero,
    );

    if (autoplay) {
      await _player.play();
    }
  }

  @override
  Future<void> play() async {
    await _ensureInitialized();
    await _player.play();
  }

  @override
  Future<void> pause() async {
    await _ensureInitialized();
    await _player.pause();
  }

  @override
  Future<void> stop() async {
    await _ensureInitialized();
    await _player.stop();
    mediaItem.add(null);
  }

  @override
  Future<void> seek(Duration position) async {
    await _ensureInitialized();
    await _player.seek(position);
  }

  @override
  Future<void> skipToNext() async {
    await _ensureInitialized();
    if (_player.hasNext) {
      await _player.seekToNext();
      if (!_player.playing) {
        await _player.play();
      }
      return;
    }
    _notifyQueueExhaustedIfNeeded();
  }

  @override
  Future<void> skipToPrevious() async {
    await _ensureInitialized();
    if (_player.hasPrevious) {
      await _player.seekToPrevious();
      if (!_player.playing) {
        await _player.play();
      }
      return;
    }
    await seek(Duration.zero);
  }

  @override
  Future<void> updateQueue(List<MediaItem> newQueue) async {
    await _setQueue(newQueue, initialIndex: 0, autoplay: false);
  }

  /// Custom action to play a specific URL with metadata
  /// Keeps legacy behavior but resets queue to just this item
  @override
  Future<void> playMediaItem(MediaItem item) async {
    await _setQueue([item], initialIndex: 0, autoplay: true);
  }

  /// Custom action to play a list of items
  @override
  Future<void> addQueueItems(List<MediaItem> mediaItems,
      {int initialIndex = 0}) async {
    await _setQueue(mediaItems, initialIndex: initialIndex, autoplay: true);
  }

  /// Insert items into the queue immediately after the current item
  Future<void> insertQueueItemsNext(List<MediaItem> items) async {
    await _ensureInitialized();
    await _runQueueOperation(() async {
      if (items.isEmpty) return;

      final currentQueue = queue.value;
      if (currentQueue.isEmpty) {
        await _setQueueInternal(items, 0, true);
        return;
      }

      final currentIndex = _player.currentIndex ?? 0;
      final insertIndex = (currentIndex + 1).clamp(0, currentQueue.length);

      final uris = <Uri>[];
      final validItems = _validateItems(items, uris);
      if (validItems.isEmpty) return;

      final newQueue = List<MediaItem>.from(currentQueue);
      newQueue.insertAll(insertIndex, validItems);
      queue.add(newQueue);

      await _playlist.insertAll(
        insertIndex,
        List<AudioSource>.generate(
          validItems.length,
          (index) => AudioSource.uri(uris[index], tag: validItems[index]),
        ),
      );
    });
  }

  /// Append items to the end of the queue (for continuous streaming)
  /// If the queue was exhausted, this will start playing the first appended item
  Future<void> appendQueueItems(List<MediaItem> items) async {
    await _ensureInitialized();
    await _runQueueOperation(() async {
      if (items.isEmpty) return;

      final currentQueue = queue.value;
      if (currentQueue.isEmpty) {
        await _setQueueInternal(items, 0, true);
        return;
      }

      final baseLength = currentQueue.length;
      final currentIndex = _player.currentIndex ?? 0;
      final processingState = _player.processingState;
      final isPlaying = _player.playing;
      final wasExhausted = processingState == ProcessingState.completed ||
          (currentIndex >= baseLength - 1 && !isPlaying);

      final uris = <Uri>[];
      final validItems = _validateItems(items, uris);
      if (validItems.isEmpty) return;

      final newQueue = List<MediaItem>.from(currentQueue)..addAll(validItems);
      queue.add(newQueue);

      await _playlist.addAll(
        List<AudioSource>.generate(
          validItems.length,
          (index) => AudioSource.uri(uris[index], tag: validItems[index]),
        ),
      );
      _queueExhaustedNotified = false;

      if (wasExhausted) {
        await _player.seek(Duration.zero, index: baseLength);
        await _player.play();
      }
    });
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    await _initFuture;
    await _playbackEventSub?.cancel();
    await _currentIndexSub?.cancel();
    await _playerStateSub?.cancel();
    await _queueExhaustedController.close();
    await _player.dispose();
  }
}
