import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:tackle4loss_mobile/core/os_shell/widgets/news_feed/news_feed_widget.dart';
import 'package:tackle4loss_mobile/core/services/articles_service.dart';
import 'package:tackle4loss_mobile/core/services/settings_service.dart';

class MockSettingsService extends Mock implements SettingsService {}

class MockArticlesService extends Mock implements ArticlesService {}

void main() {
  late MockSettingsService mockSettings;
  late MockArticlesService mockArticles;

  setUp(() {
    mockSettings = MockSettingsService();
    mockArticles = MockArticlesService();
    when(() => mockSettings.locale).thenReturn(const Locale('en'));
    when(() => mockSettings.selectedTeam).thenReturn(null);
    when(() => mockArticles.fetchArticles(
          language: any(named: 'language'),
          limit: any(named: 'limit'),
          cursor: any(named: 'cursor'),
        )).thenAnswer((_) async => const ArticlesPage(items: []));
  });

  Widget createTestWidget({
    ScrollController? scrollController,
    SettingsService? settingsService,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: ChangeNotifierProvider<SettingsService>.value(
          value: settingsService ?? mockSettings,
          child: CustomScrollView(
            controller: scrollController,
            slivers: [
              NewsFeedWidget(articlesService: mockArticles),
            ],
          ),
        ),
      ),
    );
  }

  group('NewsFeedWidget Initialization', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.byType(NewsFeedWidget), findsOneWidget);
    });

    testWidgets('initializes controller on first build', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      verify(() => mockArticles.fetchArticles(
            language: 'en',
            limit: 20,
            cursor: null,
          )).called(1);
    });
  });

  group('NewsFeedWidget Scroll Behavior', () {
    testWidgets('attaches to primary scroll controller', (tester) async {
      final scrollController = ScrollController();
      await tester
          .pumpWidget(createTestWidget(scrollController: scrollController));
      await tester.pumpAndSettle();
      expect(scrollController.hasClients, isTrue);
    });

    testWidgets('removes scroll listener on dispose', (tester) async {
      final scrollController = ScrollController();
      await tester
          .pumpWidget(createTestWidget(scrollController: scrollController));
      await tester.pumpAndSettle();
      final hadClients = scrollController.hasClients;

      await tester.pumpWidget(Container());
      await tester.pumpAndSettle();

      expect(hadClients, isTrue);
      expect(scrollController.hasClients, isFalse);
    });
  });

  group('NewsFeedWidget Lifecycle', () {
    testWidgets('reinitializes on language change', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      clearInteractions(mockArticles);

      final newSettings = MockSettingsService();
      when(() => newSettings.locale).thenReturn(const Locale('de'));
      when(() => newSettings.selectedTeam).thenReturn(null);

      await tester.pumpWidget(createTestWidget(settingsService: newSettings));
      await tester.pumpAndSettle();

      verify(() => mockArticles.fetchArticles(
            language: 'de',
            limit: 20,
            cursor: null,
          )).called(1);
    });

    testWidgets('does not reinitialize if language unchanged', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      clearInteractions(mockArticles);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      verifyNever(() => mockArticles.fetchArticles(
            language: any(named: 'language'),
            limit: any(named: 'limit'),
            cursor: any(named: 'cursor'),
          ));
    });
  });

  group('NewsFeedWidget Error Handling', () {
    testWidgets('displays error state on load failure', (tester) async {
      when(() => mockArticles.fetchArticles(
            language: any(named: 'language'),
            limit: any(named: 'limit'),
            cursor: any(named: 'cursor'),
          )).thenThrow(Exception('boom'));

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Failed to load news feed'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });
  });
}
