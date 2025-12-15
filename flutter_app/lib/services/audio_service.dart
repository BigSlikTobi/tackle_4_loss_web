import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  
  factory AudioService() => _instance;
  
  AudioService._internal() {
    _player.onPlayerStateChanged.listen((state) {
      _playerStateController.add(state);
    });
    
    _player.onPlayerComplete.listen((event) {
       _currentUrl = null;
       _currentTitle = null;
       _playerStateController.add(PlayerState.completed);
    });
  }

  final AudioPlayer _player = AudioPlayer();
  final _playerStateController = StreamController<PlayerState>.broadcast();
  
  String? _currentUrl;
  String? _currentTitle;

  Stream<PlayerState> get playerStateStream => _playerStateController.stream;
  String? get currentUrl => _currentUrl;
  String? get currentTitle => _currentTitle;
  
  bool get isPlaying => _player.state == PlayerState.playing;

  Future<void> play(String url, {String? title}) async {
    if (_currentUrl == url && isPlaying) {
      return; 
    }
    
    try {
      await _player.stop();
      _currentUrl = url;
      _currentTitle = title;
      await _player.play(UrlSource(url));
    } catch (e) {
      debugPrint("Error playing audio: $e");
    }
  }

  Future<void> pause() async {
    await _player.pause();
  }

  Future<void> resume() async {
    if (_currentUrl != null) {
      await _player.resume();
    }
  }

  Future<void> stop() async {
    await _player.stop();
    _currentUrl = null;
    _currentTitle = null;
  }
}
