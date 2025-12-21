import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/deep_dive_article.dart';

class DeepDiveDetailController extends ChangeNotifier {
  DeepDiveArticle? _article;
  bool _isLoading = true;

  DeepDiveArticle? get article => _article;
  bool get isLoading => _isLoading;

  Future<void> loadArticleDetails(String articleId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await Supabase.instance.client.functions.invoke(
        'get-article-viewer-data',
        body: {'article_id': articleId},
      );

      final data = response.data as Map<String, dynamic>;
      _article = DeepDiveArticle.fromJson(data);
    } catch (e) {
      debugPrint('Error fetching article details: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
