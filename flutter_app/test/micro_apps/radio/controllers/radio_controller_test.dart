import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tackle4loss_mobile/micro_apps/radio/controllers/radio_controller.dart';
import 'package:tackle4loss_mobile/core/services/audio_player_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

// Simple mock since we are testing state logic primarily
class MockAudioPlayerService extends AudioPlayerService {
  MockAudioPlayerService() : super.testing();

  @override
  Future<void> playPlaylist(List<Map<String, String>> items,
      {int initialIndex = 0}) async {
    // Mock interaction
  }
}

class MockHttpClient extends Mock implements http.Client {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // Register fallback values if needed
    registerFallbackValue(Uri());
    SharedPreferences.setMockInitialValues({});

    final mockHttpClient = MockHttpClient();

    // Mock success response for Supabase Edge Functions (POST)
    when(() => mockHttpClient.post(any(),
            headers: any(named: 'headers'), body: any(named: 'body')))
        .thenAnswer((_) async => http.Response('[]', 200));

    // Initialize Supabase with mock client
    // Check if already initialized to avoid errors
    try {
      Supabase.instance;
    } catch (_) {
      await Supabase.initialize(
        url: 'https://example.com',
        anonKey: 'dummy',
        httpClient: mockHttpClient,
      );
    }
  });

  group('RadioController', () {
    late RadioController controller;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      AudioPlayerService.setInstanceForTesting(MockAudioPlayerService());
      controller = RadioController();
    });

    test('initial state is correct', () {
      expect(controller.selectedCategoryId, 'all');
      expect(controller.categories.length, 3);
      // Stations load async, so initially empty or default
      // mocked load happens in constructor but is async
    });

    test('selectCategory updates state', () {
      controller.selectCategory('deep_dive');
      expect(controller.selectedCategoryId, 'deep_dive');
    });

    test('stations filter by category', () async {
      // wait for load
      await Future.delayed(const Duration(milliseconds: 100));

      controller.selectCategory('deep_dive');
      final deepDives = controller.stations;
      expect(deepDives.every((s) => s.categoryId == 'deep_dive'), true);

      controller.selectCategory('news');
      final news = controller.stations;
      expect(news.every((s) => s.categoryId == 'news'), true);
    });
  });
}
