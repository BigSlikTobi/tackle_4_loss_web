import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:tackle4loss_mobile/l10n/app_localizations.dart';
import 'package:tackle4loss_mobile/micro_apps/breaking_news/views/widgets/breaking_news_widget.dart';
import 'package:tackle4loss_mobile/micro_apps/breaking_news/controllers/breaking_news_controller.dart';
import 'package:tackle4loss_mobile/micro_apps/breaking_news/models/breaking_news_article.dart';
import 'package:tackle4loss_mobile/core/theme/t4l_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Create a Mock Controller
class MockBreakingNewsController extends ChangeNotifier implements BreakingNewsController {
  @override
  List<BreakingNewsArticle> get articles => _articles;
  final List<BreakingNewsArticle> _articles = [];
  
  @override
  List<BreakingNewsArticle> get savedArticles => []; 
  @override
  List<BreakingNewsArticle> get refusedArticles => [];
  @override
  List<BreakingNewsArticle> get readHistoryArticles => [];

  @override
  bool get isLoading => false;

  void setArticles(List<BreakingNewsArticle> list) {
    _articles.addAll(list);
    notifyListeners();
  }
  
  @override
  Future<void> loadNews({String languageCode = 'en'}) async {}
  
  @override 
  void dispose() {} // No-op

  @override
  void markAsRead(String id) {}

  @override
  Future<void> reset() async {}

  @override
  void restoreArticle(BreakingNewsArticle article) {}

  @override
  void swipeLeft(BreakingNewsArticle article) {}

  @override
  void swipeRight(BreakingNewsArticle article) {}
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget createWidgetUnderTest(BreakingNewsController controller) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')], // Force English
      theme: T4LTheme.light, // Use app theme
      home: Scaffold(
        body: BreakingNewsWidget(controller: controller),
      ),
    );
  }

  testWidgets('BreakingNewsWidget displays loading state when empty', (WidgetTester tester) async {
    // Setup controller with no articles (and isLoading false defaults to empty icon)
    final controller = MockBreakingNewsController();
    
    await tester.pumpWidget(createWidgetUnderTest(controller));
    
    // Check for Flash Icon (Empty State)
    expect(find.byIcon(Icons.flash_on_rounded), findsOneWidget);
  });

  testWidgets('BreakingNewsWidget displays article content', (WidgetTester tester) async {
    final controller = MockBreakingNewsController();
    
    final article = BreakingNewsArticle(
      id: '1',
      headline: 'Super Bowl LIX',
      subHeader: 'Subtitle',
      introductionParagraph: 'Intro',
      imageUrl: null, 
      teams: [],
      createdAt: DateTime.now(),
    );
    
    controller.setArticles([article]);
    
    await tester.pumpWidget(createWidgetUnderTest(controller));
    await tester.pump(); // Rebuild after notifyListeners
    
    // Check Headline
    expect(find.text('Super Bowl LIX'), findsOneWidget);
    
    // Check Localized Tag
    // The arb file has "breakingNewsTag": "BREAKING"
    expect(find.text('BREAKING'), findsOneWidget);
  });
}
