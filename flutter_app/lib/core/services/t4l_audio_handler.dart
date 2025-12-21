import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// A [BaseAudioHandler] implementation that uses [audioplayers] to play audio.
class T4LAudioHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  final _player = AudioPlayer();

  /// Initialise our audio handler.
  T4LAudioHandler() {
    _init();
  }

  Future<void> _init() async {
    // Listen to playback events from the player.
    _player.onPlayerStateChanged.listen((state) {
      _broadcastState(state);
    });

    _player.onPositionChanged.listen((position) {
      final oldState = playbackState.value;
      playbackState.add(oldState.copyWith(
        updatePosition: position,
      ));
    });

    _player.onDurationChanged.listen((duration) {
      final item = mediaItem.value;
      if (item != null && duration != null) {
        mediaItem.add(item.copyWith(duration: duration));
      }
    });
    
    // For iOS to continue playing in background
    // The audio_service package handles the AudioSession configuration internally
    // but sometimes explicit configuration helps if things break. 
    // Usually BaseAudioHandler + AndroidManifest/Info.plist setup is enough.
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
      },
      androidCompactActionIndices: const [0, 1],
      processingState: const {
        PlayerState.stopped: AudioProcessingState.idle,
        PlayerState.playing: AudioProcessingState.ready,
        PlayerState.paused: AudioProcessingState.ready,
        PlayerState.completed: AudioProcessingState.completed,
      }[state]!,
      playing: playing,
      updatePosition: playbackState.value.updatePosition, // Use last known position derived from onPositionChanged
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

  /// Custom action to play a specific URL with metadata
  @override
  Future<void> playMediaItem(MediaItem item) async {
    mediaItem.add(item);
    try {
        await _player.setSourceUrl(item.id);
        await _player.resume();
    } catch (e) {
        debugPrint("Error playing audio: $e");
    }
  }
}
