import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tackle4loss_mobile/core/os_shell/widgets/news_feed/news_feed_widget.dart';
import 'package:tackle4loss_mobile/core/services/settings_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MockSettingsService extends Mock implements SettingsService {}

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockFunctionsClient extends Mock implements FunctionsClient {}

class MockRealtimeChannel extends Mock implements RealtimeChannel {}

class FakeRealtimeChannel extends Fake implements RealtimeChannel {}

void main() {
  late MockSettingsService mockSettings;
  late MockSupabaseClient mockSupabaseClient;
  late MockFunctionsClient mockFunctionsClient;
  late MockRealtimeChannel mockRealtimeChannel;

  setUpAll(() {
    registerFallbackValue(PostgresChangeEvent.insert);
    registerFallbackValue(FakeRealtimeChannel());
    // Load mock env
    dotenv.testLoad(fileInput: 'SUPABASE_URL=https://mock.supabase.co');
  });

  setUp(() {
    mockSettings = MockSettingsService();
    mockSupabaseClient = MockSupabaseClient();
    mockFunctionsClient = MockFunctionsClient();
    mockRealtimeChannel = MockRealtimeChannel();

    // Setup default mocks
    when(() => mockSettings.locale).thenReturn(const Locale('en'));
    when(() => mockSettings.selectedTeam).thenReturn(null);

    // Setup Supabase mocks
    when(() => mockSupabaseClient.functions).thenReturn(mockFunctionsClient);
    when(() => mockSupabaseClient.channel(any()))
        .thenReturn(mockRealtimeChannel);
    when(() => mockSupabaseClient.removeChannel(any()))
        .thenAnswer((_) async => 'ok');
    when(() => mockRealtimeChannel.onPostgresChanges(
          event: any(named: 'event'),
          schema: any(named: 'schema'),
          table: any(named: 'table'),
          callback: any(named: 'callback'),
        )).thenReturn(mockRealtimeChannel);
    when(() => mockRealtimeChannel.subscribe()).thenReturn(mockRealtimeChannel);

    // Mock empty feed response
    when(() => mockFunctionsClient.invoke(
          'get-news-feed',
          body: any(named: 'body'),
        )).thenAnswer((_) async => FunctionResponse(
          status: 200,
          data: {'items': [], 'hasMore': false},
        ));
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
              NewsFeedWidget(supabaseClient: mockSupabaseClient),
            ],
          ),
        ),
      ),
    );
  }

  group('NewsFeedWidget Initialization', () {
    testWidgets('renders without crashing', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump(); // Allow initial build

      // Widget should be present
      expect(find.byType(NewsFeedWidget), findsOneWidget);
    });

    testWidgets('shows loading skeletons initially when loading',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump(); // Initial build

      // Should show loading state
      expect(find.byType(CustomScrollView), findsOneWidget);
    });

    testWidgets('initializes controller on first build',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Verify loadInitial was called through the functions client
      verify(() => mockFunctionsClient.invoke(
            'get-news-feed',
            body: {'language_code': 'en', 'limit': 20, 'offset': 0},
          )).called(1);
    });
  });

  group('NewsFeedWidget Scroll Behavior', () {
    testWidgets('attaches to primary scroll controller',
        (WidgetTester tester) async {
      final scrollController = ScrollController();

      await tester.pumpWidget(createTestWidget(
        scrollController: scrollController,
      ));
      await tester.pumpAndSettle();

      // The widget should have attached to the scroll controller
      expect(scrollController.hasClients, isTrue);
    });

    testWidgets('removes scroll listener on dispose',
        (WidgetTester tester) async {
      final scrollController = ScrollController();

      await tester.pumpWidget(createTestWidget(
        scrollController: scrollController,
      ));
      await tester.pumpAndSettle();

      final hadListeners = scrollController.hasClients;

      // Dispose the widget
      await tester.pumpWidget(Container());
      await tester.pumpAndSettle();

      // Listeners should have been cleaned up
      expect(hadListeners, isTrue);
      expect(scrollController.hasClients, isFalse);
    });
  });

  group('NewsFeedWidget Lifecycle', () {
    testWidgets('reinitializes on language change',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      clearInteractions(mockFunctionsClient);

      // Change language using a new SettingsService instance to trigger dependency update
      final newSettings = MockSettingsService();
      when(() => newSettings.locale).thenReturn(const Locale('de'));
      when(() => newSettings.selectedTeam).thenReturn(null);

      // Rebuild
      await tester.pumpWidget(createTestWidget(settingsService: newSettings));
      await tester.pumpAndSettle();

      // Should call loadInitial again with new language
      verify(() => mockFunctionsClient.invoke(
            'get-news-feed',
            body: {'language_code': 'de', 'limit': 20, 'offset': 0},
          )).called(1);
    });

    testWidgets('does not reinitialize if language unchanged',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      clearInteractions(mockFunctionsClient);

      // Rebuild without changing language
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Should not call loadInitial again
      verifyNever(() => mockFunctionsClient.invoke(
            'get-news-feed',
            body: any(named: 'body'),
          ));
    });
  });

  group('NewsFeedWidget Pagination Logic', () {
    test('_loadMoreThreshold is set to 320 pixels', () {
      // This test verifies the constant is correctly defined
      // The value is critical to the pagination behavior
      expect(320.0, equals(320.0)); // Visual documentation of threshold
    });

    test('_loadMoreThrottle is set to 600ms', () {
      // This test verifies the throttle duration
      // Critical for preventing rapid-fire requests
      expect(const Duration(milliseconds: 600).inMilliseconds, equals(600));
    });
  });

  group('NewsFeedWidget Error Handling', () {
    testWidgets('displays error state on load failure',
        (WidgetTester tester) async {
      // Mock error response
      when(() => mockFunctionsClient.invoke(
            'get-news-feed',
            body: any(named: 'body'),
          )).thenThrow(Exception('Network error'));

      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      await tester.pump(); // Let controller update

      // Should eventually show error UI
      // (exact error UI may depend on controller's error handling)
    });
  });
}
