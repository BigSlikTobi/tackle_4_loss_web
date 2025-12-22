import 'package:flutter_test/flutter_test.dart';
import 'package:tackle4loss_mobile/micro_apps/radio/controllers/radio_controller.dart';
import 'package:tackle4loss_mobile/core/services/audio_player_service.dart';

// Simple mock since we are testing state logic primarily
class MockAudioPlayerService extends AudioPlayerService {
  MockAudioPlayerService() : super.testing();
  
  @override
  Future<void> playPlaylist(List<Map<String, String>> items) async {
    // Mock interaction
  }
}

void main() {
  group('RadioController', () {
    late RadioController controller;

    setUp(() {
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
      await Future.delayed(const Duration(seconds: 2)); 
      
      controller.selectCategory('deep_dive');
      final deepDives = controller.stations;
      expect(deepDives.every((s) => s.categoryId == 'deep_dive'), true);
      
      controller.selectCategory('news');
      final news = controller.stations;
      expect(news.every((s) => s.categoryId == 'news'), true);
    });
  });
}
