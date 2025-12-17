import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AudioPlayerHandler extends BaseAudioHandler {
  final _player = AudioPlayer();
  
  // Expose player events as streams if needed, or update playbackState/mediaItem directly
  Stream<Duration> get onPositionChanged => _player.onPositionChanged;
  Stream<Duration> get onDurationChanged => _player.onDurationChanged;
  Stream<void> get onPlayerComplete => _player.onPlayerComplete;

  AudioPlayerHandler() {
    _init();
  }

  // Cached position to avoid async calls during state updates
  Duration _currentPosition = Duration.zero;

  Future<void> _init() async {
    // Listen to playback events and broadcast via audio_service
    _player.onPlayerStateChanged.listen((state) {
      _broadcastState();
    });

    _player.onPositionChanged.listen((position) {
      _currentPosition = position;
      _broadcastState();
    });
    
    // Set Audio Context
    final AudioContext audioContext = AudioContext(
      iOS: AudioContextIOS(
        category: AVAudioSessionCategory.playback,
        options: const {},
      ),
      android: AudioContextAndroid(
        isSpeakerphoneOn: true,
        stayAwake: true,
        usageType: AndroidUsageType.media,
        contentType: AndroidContentType.music,
      ),
    );
    await _player.setAudioContext(audioContext);
  }

  void _broadcastState() {
     final playing = _player.state == PlayerState.playing;
     
     // Map AudioPlayer state to AudioProcessingState
     AudioProcessingState processingState;
     switch (_player.state) {
       case PlayerState.stopped:
         processingState = AudioProcessingState.idle;
         break;
       case PlayerState.playing:
         processingState = AudioProcessingState.ready;
         break;
       case PlayerState.paused:
         processingState = AudioProcessingState.ready;
         break;
       case PlayerState.completed:
         processingState = AudioProcessingState.completed;
         break;
       case PlayerState.disposed:
         processingState = AudioProcessingState.idle;
         break;
       default:
         processingState = AudioProcessingState.idle;
     }

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
       processingState: processingState,
       playing: playing,
       updatePosition: _currentPosition, // Sync position
       bufferedPosition: Duration.zero,
       speed: 1.0,
       queueIndex: 0,
     ));
  }

  Future<void> setMediaItem(MediaItem item) async {
    mediaItem.add(item);
    if (item.extras?['url'] != null) {
      await _player.setSourceUrl(item.extras!['url']);
    }
  }

  @override
  Future<void> play() => _player.resume();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() => _player.stop();
  
  @override
  Future<void> seek(Duration position) => _player.seek(position);

  Future<Duration?> getDuration() => _player.getDuration();
}
