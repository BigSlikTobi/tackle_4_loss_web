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

  AudioPlayerService._internal();

  @visibleForTesting
  AudioPlayerService.testing();

  /// Initialize the audio service. 
  /// This should be called once at app startup.
  Future<void> init() async {
    if (_audioHandler != null) return;
    
    _audioHandler = await AudioService.init(
      builder: () => T4LAudioHandler(),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.tackle4loss.channel.audio',
        androidNotificationChannelName: 'T4L Audio',
        androidNotificationOngoing: true,
      ),
    );
  }
  
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
  Future<void> play(String url, String title, String author, String imageUrl) async {
    if (_audioHandler == null) return;

    final mediaItem = MediaItem(
      id: url,
      album: "Deep Dive",
      title: title,
      artist: author,
      artUri: Uri.parse(imageUrl),
    );

    await _audioHandler!.playMediaItem(mediaItem);
  }

  Future<void> resume() async => await _audioHandler?.play();
  Future<void> pause() async => await _audioHandler?.pause();
  Future<void> stop() async => await _audioHandler?.stop();
  Future<void> seek(Duration position) async => await _audioHandler?.seek(position);
}
