import 'package:flutter/material.dart';
import '../models/deep_dive_article.dart';

/// Stubbed in MVP slim — Deep Dive is flag-off and the underlying
/// `get-latest-deepdive` / `get-all-deepdives` edge functions are gone with
/// the new main Supabase project.
///
// TODO(restore-on-revive): wire to new edge functions when Deep Dive returns.
class DeepDiveController extends ChangeNotifier {
  final List<DeepDiveArticle> _articles = const [];
  final DeepDiveArticle? _latestArticle = null;
  final bool _isLoading = false;
  final bool _isLoadingMore = false;
  final bool _hasMore = false;
  final String? _error = null;

  List<DeepDiveArticle> get articles => _articles;
  DeepDiveArticle? get latestArticle => _latestArticle;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  String? get error => _error;

  Future<void> loadLatestArticle(String languageCode) async {}

  Future<void> loadAllArticles(String languageCode,
      {bool forceRefresh = false}) async {}

  Future<void> loadMore(String languageCode) async {}

  @visibleForTesting
  Future<DeepDivePageResult> fetchDeepDives(String languageCode,
      {int limit = 25, int offset = 0}) async {
    return const DeepDivePageResult(items: [], hasMore: false);
  }
}

class DeepDivePageResult {
  final List<DeepDiveArticle> items;
  final bool hasMore;

  const DeepDivePageResult({required this.items, required this.hasMore});
}
