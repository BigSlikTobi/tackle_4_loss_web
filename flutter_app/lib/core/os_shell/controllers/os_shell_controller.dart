import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../micro_app.dart';
import '../../../../micro_apps/deep_dive/models/deep_dive_article.dart';

class OSShellController extends ChangeNotifier {
  final BuildContext context;
  DeepDiveArticle? _featuredArticle;
  bool _isLoadingFeatured = false;
  bool _isPageReady = false;

  OSShellController(this.context);

  DeepDiveArticle? get featuredArticle => _featuredArticle;
  bool get isLoadingFeatured => _isLoadingFeatured;
  bool get isPageReady => _isPageReady;

  bool _mounted = true;

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  Future<void> loadFeaturedContent(String languageCode) async {
    _isLoadingFeatured = true;
    if (_mounted) notifyListeners();

    try {
      final response = await Supabase.instance.client.functions.invoke(
        'get-latest-deepdive',
        body: {'language_code': languageCode},
      );

      if (_mounted && response.data != null) {
        _featuredArticle = DeepDiveArticle.fromJson(response.data);
      }
    } catch (e) {
      debugPrint('Error loading featured content: $e');
    } finally {
      if (_mounted) {
        _isLoadingFeatured = false;
        notifyListeners();
      }
    }
  }

  /// Load all page data in parallel, notify when complete.
  /// This should be called from the view's initState or didChangeDependencies.
  Future<void> initLoadAll(String languageCode) async {
    _isPageReady = false;
    if (_mounted) notifyListeners();

    await Future.wait([
      loadFeaturedContent(languageCode),
      // Add other data sources here as needed
    ]);

    if (_mounted) {
      _isPageReady = true;
      notifyListeners();
    }
  }

  void openApp(MicroApp app) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => app.page(context)));
  }

  void openAppStore() {
    debugPrint("Navigating to App Store...");
  }

  void openHistory() {
    debugPrint("Opening History...");
  }

  void openSettings() {
    debugPrint("Opening Settings...");
  }

  void openTeamSelector() {
    debugPrint("Opening Team Selector...");
  }
}
