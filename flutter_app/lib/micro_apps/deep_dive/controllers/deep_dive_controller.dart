import 'package:flutter/material.dart';
import '../models/deep_dive_article.dart';

class DeepDiveController extends ChangeNotifier {
  DeepDiveArticle? _article;
  bool _isLoading = false;
  bool _isPlayingAudio = false;

  DeepDiveArticle? get article => _article;
  bool get isLoading => _isLoading;
  bool get isPlayingAudio => _isPlayingAudio;

  Future<void> loadLatestArticle() async {
    _isLoading = true;
    notifyListeners();

    // Simulate Network Delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Load Mock Data
    _article = DeepDiveArticle.mock();
    _isLoading = false;
    notifyListeners();
  }

  void toggleAudio() {
    // Basic state toggle for now. 
    // Real implementation will use AudioService later.
    _isPlayingAudio = !_isPlayingAudio;
    notifyListeners();
  }
}
