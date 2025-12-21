import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tackle4loss_mobile/core/adk/widgets/t4l_hero_header.dart';
import 'package:tackle4loss_mobile/core/os_shell/widgets/t4l_scaffold.dart';
import 'package:tackle4loss_mobile/core/services/audio_player_service.dart';
import 'package:tackle4loss_mobile/core/services/settings_service.dart';
import 'package:tackle4loss_mobile/l10n/app_localizations.dart'; // Added
import 'package:tackle4loss_mobile/micro_apps/deep_dive/controllers/deep_dive_detail_controller.dart';
import 'package:tackle4loss_mobile/micro_apps/deep_dive/models/deep_dive_article.dart';
import 'package:tackle4loss_mobile/micro_apps/deep_dive/views/deep_dive_screen.dart';
import 'package:tackle4loss_mobile/core/theme/t4l_theme.dart'; // Added

class MockAudioPlayerService extends AudioPlayerService {
  MockAudioPlayerService() : super.testing();

  @override
  Stream<PlaybackState> get playbackStateStream => Stream.value(PlaybackState());
  
  @override
  Stream<MediaItem?> get mediaItemStream => Stream.value(null);
}

class MockDeepDiveDetailController extends DeepDiveDetailController {
  @override
  bool get isLoading => false;

  @override
  Future<void> loadArticleDetails(String articleId) async {
    // No-op
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    AudioPlayerService.setInstanceForTesting(MockAudioPlayerService());
  });

  testWidgets('DeepDiveScreen renders ADK components and content', (WidgetTester tester) async {
    final mockArticle = DeepDiveArticle(
      id: 'test-1',
      title: 'Test Title',
      summary: 'Test Summary',
      content: 'Test Content',
      imageUrl: 'https://example.com/image.png',
      videoUrl: null, 
      audioUrl: null,
      publishedAt: DateTime.now(),
      author: 'Test Author',
      languageCode: 'en',
    );
    
    final mockController = MockDeepDiveDetailController();

    // Wrap in mock network image because screen uses Image.network
    await mockNetworkImagesFor(() async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
             ChangeNotifierProvider.value(value: SettingsService()),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates, 
            supportedLocales: AppLocalizations.supportedLocales, 
            theme: T4LTheme.light, // Added to provide T4LThemeColors extension
            home: DeepDiveScreen(article: mockArticle, controller: mockController),
          ),
        ),
      );
 // ... rest of test ...

      // 1. Initial Loading State (Might be skipped if data is present immediately from widget)
      // We expect the Hero to be visible because it's in the header, outside the body spinner
      
      // Let's settle to allow any async inits to complete (even if they fail silently)
      // Let's settle to allow any async inits to complete (even if they fail silently)
      await tester.pump();
      await tester.pump();

      // 2. Verify ADK Components
      expect(find.byType(T4LScaffold), findsOneWidget);
      expect(find.byType(T4LHeroHeader), findsOneWidget);

      // 3. Verify Content from Mock
      expect(find.text(mockArticle.title.toUpperCase()), findsOneWidget);
    });
  });
}
