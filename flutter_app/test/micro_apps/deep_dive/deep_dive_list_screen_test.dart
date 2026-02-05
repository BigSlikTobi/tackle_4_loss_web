import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tackle4loss_mobile/core/services/settings_service.dart';
import 'package:tackle4loss_mobile/micro_apps/deep_dive/controllers/deep_dive_controller.dart';
import 'package:tackle4loss_mobile/micro_apps/deep_dive/models/deep_dive_article.dart';
import 'package:tackle4loss_mobile/core/theme/t4l_theme.dart';
import 'package:tackle4loss_mobile/l10n/app_localizations.dart';

// ---------------------------------------------------------------------------
// Test helpers
// ---------------------------------------------------------------------------

List<DeepDiveArticle> _makeArticles(int count, {int startAt = 1}) =>
    List.generate(
        count,
        (i) => DeepDiveArticle(
              id: '${startAt + i}',
              title: 'Article ${startAt + i}',
              summary: 'Summary ${startAt + i}',
              content: 'Content',
              imageUrl: 'https://example.com/${startAt + i}.png',
              publishedAt: DateTime(2026, 1, 1),
              author: 'Author',
              languageCode: 'en',
            ));

/// A testable controller that produces pages of articles without network calls.
class _PaginatingTestController extends DeepDiveController {
  final int pageSize;
  final int totalItems;

  _PaginatingTestController({
    this.pageSize = 5,
    this.totalItems = 12,
  });

  @override
  Future<DeepDivePageResult> fetchDeepDives(String languageCode,
      {int limit = 25, int offset = 0}) async {
    await Future.delayed(const Duration(milliseconds: 5));
    final remaining = totalItems - offset;
    final count = remaining.clamp(0, limit.clamp(0, pageSize));
    final articles = _makeArticles(count, startAt: offset + 1);
    return DeepDivePageResult(
      items: articles,
      hasMore: (offset + count) < totalItems,
    );
  }
}

/// A controller that always fails.
class _FailingTestController extends DeepDiveController {
  @override
  Future<DeepDivePageResult> fetchDeepDives(String languageCode,
      {int limit = 25, int offset = 0}) async {
    throw Exception('Network error');
  }
}

/// A controller that returns an empty list.
class _EmptyTestController extends DeepDiveController {
  @override
  Future<DeepDivePageResult> fetchDeepDives(String languageCode,
      {int limit = 25, int offset = 0}) async {
    return const DeepDivePageResult(items: [], hasMore: false);
  }
}

// We can't easily swap the controller into the real DeepDiveListScreen because
// _DeepDiveListScreenState creates its own. Instead, test the controller
// integration from a widget perspective using Consumer pattern.

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('DeepDiveController widget integration', () {
    testWidgets('shows loading indicator initially',
        (WidgetTester tester) async {
      final controller = _PaginatingTestController(
        pageSize: 5,
        totalItems: 12,
      );

      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          MaterialApp(
            theme: T4LTheme.light(),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: ChangeNotifierProvider<DeepDiveController>.value(
                value: controller,
                child: Consumer<DeepDiveController>(
                  builder: (context, ctrl, _) {
                    if (ctrl.isLoading && ctrl.articles.isEmpty) {
                      return const Center(
                          child: CircularProgressIndicator(
                        key: Key('loading'),
                      ));
                    }
                    return const Text('Loaded');
                  },
                ),
              ),
            ),
          ),
        );

        // Loading state before loadAllArticles is called
        controller.loadAllArticles('en');
        await tester.pump();
        expect(find.byKey(const Key('loading')), findsOneWidget);

        // After completing
        await tester.pumpAndSettle();
        expect(find.text('Loaded'), findsOneWidget);
      });
    });

    testWidgets('shows error state with retry', (WidgetTester tester) async {
      final controller = _FailingTestController();

      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          MaterialApp(
            theme: T4LTheme.light(),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: ChangeNotifierProvider<DeepDiveController>.value(
                value: controller,
                child: Consumer<DeepDiveController>(
                  builder: (context, ctrl, _) {
                    if (ctrl.isLoading) {
                      return const CircularProgressIndicator();
                    }
                    if (ctrl.error != null && ctrl.articles.isEmpty) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Error'),
                          TextButton(
                            key: const Key('retry'),
                            onPressed: () =>
                                ctrl.loadAllArticles('en', forceRefresh: true),
                            child: const Text('Retry'),
                          ),
                        ],
                      );
                    }
                    return const Text('Loaded');
                  },
                ),
              ),
            ),
          ),
        );

        controller.loadAllArticles('en');
        await tester.pumpAndSettle();

        expect(controller.error, isNotNull);
        expect(find.text('Error'), findsOneWidget);
        expect(find.byKey(const Key('retry')), findsOneWidget);
      });
    });

    testWidgets('shows empty state when no articles',
        (WidgetTester tester) async {
      final controller = _EmptyTestController();

      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          MaterialApp(
            theme: T4LTheme.light(),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: ChangeNotifierProvider<DeepDiveController>.value(
                value: controller,
                child: Consumer<DeepDiveController>(
                  builder: (context, ctrl, _) {
                    if (ctrl.isLoading) {
                      return const CircularProgressIndicator();
                    }
                    if (ctrl.articles.isEmpty) {
                      return const Text('No deep dives found.');
                    }
                    return const Text('Has articles');
                  },
                ),
              ),
            ),
          ),
        );

        controller.loadAllArticles('en');
        await tester.pumpAndSettle();

        expect(find.text('No deep dives found.'), findsOneWidget);
      });
    });

    testWidgets('loadMore appends articles and updates UI',
        (WidgetTester tester) async {
      final controller = _PaginatingTestController(
        pageSize: 3,
        totalItems: 7,
      );

      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          MaterialApp(
            theme: T4LTheme.light(),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: ChangeNotifierProvider<DeepDiveController>.value(
              value: controller,
              child: Scaffold(
                body: Consumer<DeepDiveController>(
                  builder: (context, ctrl, _) {
                    if (ctrl.isLoading && ctrl.articles.isEmpty) {
                      return const CircularProgressIndicator();
                    }
                    return Column(
                      children: [
                        Text('Count: ${ctrl.articles.length}'),
                        Text('HasMore: ${ctrl.hasMore}'),
                        if (ctrl.isLoadingMore) const Text('Loading more...'),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        );

        // Load first page
        controller.loadAllArticles('en');
        await tester.pumpAndSettle();
        expect(find.text('Count: 3'), findsOneWidget);
        expect(find.text('HasMore: true'), findsOneWidget);

        // Load second page
        controller.loadMore('en');
        await tester.pumpAndSettle();
        expect(find.text('Count: 6'), findsOneWidget);
        expect(find.text('HasMore: true'), findsOneWidget);

        // Load third page (partial - only 1 item left)
        controller.loadMore('en');
        await tester.pumpAndSettle();
        expect(find.text('Count: 7'), findsOneWidget);
        expect(find.text('HasMore: false'), findsOneWidget);

        // Another loadMore should be a no-op
        final oldCount = controller.articles.length;
        controller.loadMore('en');
        await tester.pumpAndSettle();
        expect(controller.articles.length, oldCount);
      });
    });
  });
}
