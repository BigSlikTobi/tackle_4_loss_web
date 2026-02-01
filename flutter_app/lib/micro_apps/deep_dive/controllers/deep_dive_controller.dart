import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/deep_dive_article.dart';

class DeepDiveController extends ChangeNotifier {
  List<DeepDiveArticle> _articles = [];
  DeepDiveArticle? _latestArticle;
  bool _isLoading = false;

  List<DeepDiveArticle> get articles => _articles;
  DeepDiveArticle? get latestArticle => _latestArticle;
  bool get isLoading => _isLoading;

  Future<void> loadLatestArticle(String languageCode) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await Supabase.instance.client.functions.invoke(
        'get-latest-deepdive',
        body: {'language_code': languageCode},
      );

      final data = response.data as Map<String, dynamic>;
      _latestArticle = DeepDiveArticle.fromJson(data);
    } catch (e) {
      debugPrint('Error fetching latest deep dive: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAllArticles(String languageCode,
      {bool forceRefresh = false}) async {
    if (_articles.isNotEmpty && !forceRefresh) return;

    _isLoading = true;
    notifyListeners();

    try {
      _articles = await fetchDeepDives(languageCode);
    } catch (e) {
      debugPrint('Error fetching deep dives: $e');
      // In a real app, handle error state
      _articles = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @visibleForTesting
  Future<List<DeepDiveArticle>> fetchDeepDives(String languageCode) async {
    final response = await Supabase.instance.client.functions.invoke(
      'get-all-deepdives',
      body: {'language_code': languageCode},
    );

    final data = response.data as List<dynamic>;
    return data.map((json) => DeepDiveArticle.fromJson(json)).toList();
  }
}
