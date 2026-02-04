import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

/// A [BaseAudioHandler] implementation that uses [just_audio] to play audio.
class T4LAudioHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  final AudioPlayer _player;

  ConcatenatingAudioSource _playlist =
      ConcatenatingAudioSource(children: []);

  /// Stream controller to signal when queue is exhausted
  /// This allows the RadioController to fetch and append more content
  final StreamController<void> _queueExhaustedController =
      StreamController<void>.broadcast();

  /// Stream that emits when the queue is exhausted (all items played)
  Stream<void> get onQueueExhausted => _queueExhaustedController.stream;

  bool _queueExhaustedNotified = false;

  /// Initialise our audio handler.
  T4LAudioHandler({AudioPlayer? player, bool configureSession = true})
      : _player = player ?? AudioPlayer() {
    _init(configureSession: configureSession);
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

    _player.playbackEventStream.listen(
      _broadcastState,
      onError: (Object error, StackTrace stackTrace) {
        debugPrint("T4LAudioHandler: Playback error: $error");
      },
    );

    _player.currentIndexStream.listen((index) {
      if (index == null) return;
      final currentQueue = queue.value;
      if (index >= 0 && index < currentQueue.length) {
        mediaItem.add(currentQueue[index]);
      }
    });

    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _notifyQueueExhaustedIfNeeded();
      } else {
        _queueExhaustedNotified = false;
      }
    });
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

  AudioSource _sourceForMediaItem(MediaItem item) {
    return AudioSource.uri(
      Uri.parse(item.id),
      tag: item,
    );
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
    _queueExhaustedNotified = false;
    queue.add(items);

    if (items.isEmpty) {
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

    mediaItem.add(items[initialIndex]);
    _playlist = ConcatenatingAudioSource(
      children: items.map(_sourceForMediaItem).toList(),
    );

    await _player.setAudioSource(
      _playlist,
      initialIndex: initialIndex,
      initialPosition: Duration.zero,
    );

    if (autoplay) {
      await _player.play();
    }
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() async {
    await _player.stop();
    mediaItem.add(null);
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToNext() async {
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
    if (items.isEmpty) return;

    final currentQueue = queue.value;
    if (currentQueue.isEmpty) {
      await addQueueItems(items);
      return;
    }

    final insertIndex = (_player.currentIndex ?? 0) + 1;
    final newQueue = List<MediaItem>.from(currentQueue);
    newQueue.insertAll(insertIndex, items);
    queue.add(newQueue);

    await _playlist.insertAll(
      insertIndex,
      items.map(_sourceForMediaItem).toList(),
    );
  }

  /// Append items to the end of the queue (for continuous streaming)
  /// If the queue was exhausted, this will start playing the first appended item
  Future<void> appendQueueItems(List<MediaItem> items) async {
    if (items.isEmpty) return;

    final currentQueue = queue.value;
    if (currentQueue.isEmpty) {
      await addQueueItems(items);
      return;
    }

    final wasExhausted =
        _player.processingState == ProcessingState.completed ||
            ((_player.currentIndex ?? 0) >= currentQueue.length - 1 &&
                !_player.playing);

    final newQueue = List<MediaItem>.from(currentQueue)..addAll(items);
    queue.add(newQueue);

    await _playlist.addAll(items.map(_sourceForMediaItem).toList());
    _queueExhaustedNotified = false;

    if (wasExhausted) {
      await _player.seek(Duration.zero, index: currentQueue.length);
      await _player.play();
    }
  }
}
