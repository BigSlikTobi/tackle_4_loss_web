import 'package:flutter/material.dart';
import '../models/deep_dive_article.dart';

/// Stubbed in MVP slim — Deep Dive is flag-off and the underlying
/// `get-article-viewer-data` edge function is gone with the new main
/// Supabase project.
///
// TODO(restore-on-revive): wire to a new edge function when Deep Dive returns.
class DeepDiveDetailController extends ChangeNotifier {
  final DeepDiveArticle? _article = null;
  bool _isLoading = false;

  DeepDiveArticle? get article => _article;
  bool get isLoading => _isLoading;

  Future<void> loadArticleDetails(String articleId) async {
    _isLoading = false;
    notifyListeners();
  }
}
