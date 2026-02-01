import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:audioplayers/audioplayers.dart' hide AVAudioSessionCategory;
import 'package:flutter/foundation.dart';
import 'package:audio_session/audio_session.dart';

/// A [BaseAudioHandler] implementation that uses [audioplayers] to play audio.
class T4LAudioHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  final _player = AudioPlayer();

  /// Stream controller to signal when queue is exhausted
  /// This allows the RadioController to fetch and append more content
  final StreamController<void> _queueExhaustedController =
      StreamController<void>.broadcast();

  /// Stream that emits when the queue is exhausted (all items played)
  Stream<void> get onQueueExhausted => _queueExhaustedController.stream;

  /// Initialise our audio handler.
  T4LAudioHandler() {
    _init();
  }

  int _currentIndex = 0;

  Future<void> _init() async {
    // Configure audio session for background playback
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

    // Activate the audio session
    await session.setActive(true);

    // Configure audioplayers for background playback
    await _player.setReleaseMode(ReleaseMode.stop);

    // Listen to playback events from the player.
    _player.onPlayerStateChanged.listen((state) {
      // Don't broadcast 'completed' state here - we handle it in onPlayerComplete
      // Broadcasting 'completed' causes the lock screen controls to disappear
      if (state != PlayerState.completed) {
        _broadcastState(state);
      }
    });

    _player.onPlayerComplete.listen((_) {
      _skipToNext();
    });

    _player.onPositionChanged.listen((position) {
      final oldState = playbackState.value;
      playbackState.add(oldState.copyWith(
        updatePosition: position,
      ));
    });

    _player.onDurationChanged.listen((duration) {
      final item = mediaItem.value;
      if (item != null) {
        mediaItem.add(item.copyWith(duration: duration));
      }
    });
  }

  Future<void> _skipToNext() async {
    final queue = this.queue.value;
    if (_currentIndex + 1 < queue.length) {
      _currentIndex++;
      await _playCurrent();
    } else {
      // Signal that queue is exhausted - RadioController can fetch more content
      _queueExhaustedController.add(null);
    }
  }

  Future<void> _playCurrent() async {
    final queue = this.queue.value;
    if (queue.isNotEmpty && _currentIndex < queue.length) {
      final item = queue[_currentIndex];
      mediaItem.add(item);
      try {
        // Ensure audio session is still active for background playback
        final session = await AudioSession.instance;
        await session.setActive(true);

        // Don't call stop() - it briefly releases audio focus which allows other apps to steal it
        await _player.play(UrlSource(item.id));

        // Explicitly broadcast playing state to update lock screen controls
        _broadcastState(PlayerState.playing);
      } catch (e) {
        debugPrint("T4LAudioHandler: Error playing audio: $e");
        // Attempt to skip to next item if the current one is unplayable
        if (_currentIndex < queue.length - 1) {
          _skipToNext();
        }
      }
    }
  }

  /// Broadcasts the current state to all clients.
  void _broadcastState(PlayerState state) {
    final playing = state == PlayerState.playing;

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
        PlayerState.stopped: AudioProcessingState.idle,
        PlayerState.playing: AudioProcessingState.ready,
        PlayerState.paused: AudioProcessingState.ready,
        PlayerState.completed: AudioProcessingState.completed,
      }[state]!,
      playing: playing,
      updatePosition: playbackState.value
          .updatePosition, // Use last known position derived from onPositionChanged
      bufferedPosition: Duration.zero,
      speed: _player.playbackRate,
    ));
  }

  @override
  Future<void> play() => _player.resume();

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
  Future<void> skipToNext() => _skipToNext();

  @override
  Future<void> skipToPrevious() async {
    if (_currentIndex > 0) {
      _currentIndex--;
      await _playCurrent();
    } else {
      await seek(Duration.zero);
    }
  }

  @override
  Future<void> updateQueue(List<MediaItem> queue) async {
    await super.updateQueue(queue);
    // If not playing anything, start playing the first item?
    // Or just update. Let's just update.
  }

  /// Custom action to play a specific URL with metadata
  /// Keeps legacy behavior but resets queue to just this item
  @override
  Future<void> playMediaItem(MediaItem item) async {
    queue.add([item]);
    _currentIndex = 0;
    await _playCurrent();
  }

  /// Custom action to play a list of items
  @override
  Future<void> addQueueItems(List<MediaItem> mediaItems,
      {int initialIndex = 0}) async {
    queue.add(mediaItems);
    _currentIndex = initialIndex;
    if (_currentIndex < 0) {
      _currentIndex = 0;
    }
    if (_currentIndex >= mediaItems.length) {
      _currentIndex = mediaItems.length - 1;
    }

    await _playCurrent();
  }

  /// Insert items into the queue immediately after the current item
  Future<void> insertQueueItemsNext(List<MediaItem> items) async {
    final currentQueue = queue.value;
    if (currentQueue.isEmpty) {
      await addQueueItems(items);
      return;
    }

    final newQueue = List<MediaItem>.from(currentQueue);
    // Insert after current index
    newQueue.insertAll(_currentIndex + 1, items);

    // Update the queue
    queue.add(newQueue);
    // _currentIndex remains the same as we inserted AFTER it
  }

  /// Append items to the end of the queue (for continuous streaming)
  /// If the queue was exhausted, this will start playing the first appended item
  Future<void> appendQueueItems(List<MediaItem> items) async {
    if (items.isEmpty) return;

    final currentQueue = queue.value;
    final wasExhausted =
        currentQueue.isEmpty || _currentIndex >= currentQueue.length - 1;

    if (currentQueue.isEmpty) {
      // No queue yet, just start playing
      await addQueueItems(items);
      return;
    }

    final newQueue = List<MediaItem>.from(currentQueue);
    newQueue.addAll(items);
    queue.add(newQueue);

    // If queue was exhausted (we signaled for more content), start playing the new content
    if (wasExhausted && _currentIndex >= currentQueue.length - 1) {
      _currentIndex++;
      await _playCurrent();
    }
  }
}
