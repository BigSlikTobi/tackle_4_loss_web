import 'package:flutter/material.dart';

/// Mixin to add page-level loading pattern to StatefulWidgets.
/// 
/// Usage:
/// ```dart
/// class _MyScreenState extends State<MyScreen> with PageLoadingMixin {
///   @override
///   void initState() {
///     super.initState();
///     initPageLoad();
///   }
///   
///   @override
///   Future<void> loadPageData() async {
///     await myController.loadAllData();
///   }
///   
///   @override
///   Widget build(BuildContext context) {
///     return buildWithLoading(
///       skeleton: const MyScreenSkeleton(),
///       content: MyScreenContent(),
///     );
///   }
/// }
/// ```
mixin PageLoadingMixin<T extends StatefulWidget> on State<T> {
  bool _isPageReady = false;
  
  /// Whether all page data has loaded and content is ready to display
  bool get isPageReady => _isPageReady;
  
  /// Override this to load all data required for the page.
  /// Called by [initPageLoad].
  @protected
  Future<void> loadPageData();
  
  /// Call this in initState to begin loading data.
  /// Shows skeleton until [loadPageData] completes.
  void initPageLoad() async {
    await loadPageData();
    if (mounted) {
      setState(() => _isPageReady = true);
    }
  }
  
  /// Helper to build content with loading state.
  /// Shows [skeleton] while loading, then fades in [content].
  Widget buildWithLoading({
    required Widget skeleton,
    required Widget content,
    Duration fadeDuration = const Duration(milliseconds: 300),
  }) {
    if (!_isPageReady) {
      return skeleton;
    }
    
    return AnimatedOpacity(
      opacity: 1.0,
      duration: fadeDuration,
      child: content,
    );
  }
}
