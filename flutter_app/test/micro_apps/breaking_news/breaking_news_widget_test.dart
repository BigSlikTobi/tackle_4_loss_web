// ignore_for_file: deprecated_member_use_from_same_package
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
class MockBreakingNewsController extends ChangeNotifier
    implements BreakingNewsController {
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
  Future<void> loadNews(
      {String languageCode = 'en', String? userTeamId}) async {}

  @override
  void updateUserTeam(String? teamId) {}

  @override
  BreakingNewsArticle? get heroArticle =>
      _articles.isNotEmpty ? _articles.first : null;

  @override
  List<BreakingNewsArticle> get listArticles =>
      _articles.length > 1 ? _articles.sublist(1) : [];

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

  @override
  Map<String, String> get availableTeams => {};

  @override
  String? get currentTeamFilter => null;

  @override
  bool get isNewestFirst => true;

  @override
  void prioritizeArticle(String id) {}

  @override
  void setTeamFilter(String? teamName) {}

  @override
  void toggleSort() {}
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
      theme: T4LTheme.light(), // Use app theme
      home: Scaffold(body: BreakingNewsWidget(controller: controller)),
    );
  }

  testWidgets('BreakingNewsWidget displays loading state when empty', (
    WidgetTester tester,
  ) async {
    // Setup controller with no articles (and isLoading false defaults to empty icon)
    final controller = MockBreakingNewsController();

    await tester.pumpWidget(createWidgetUnderTest(controller));

    // Check for Flash Icon (Empty State)
    expect(find.byIcon(Icons.flash_on_rounded), findsOneWidget);
  });

  testWidgets('BreakingNewsWidget displays article content', (
    WidgetTester tester,
  ) async {
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

  test('BreakingNewsArticle parses dynamic generic maps correctly', () {
    final dynamicMap = <dynamic, dynamic>{
      'id': '123',
      'headline': 'Test',
      'createdAt': DateTime.now().toIso8601String(),
      'teams': [
        <dynamic, dynamic>{'team_id': 'PIT', 'logo_url': 'http://logo'},
      ],
      'players': [
        <dynamic, dynamic>{'name': 'Player', 'headshot_url': 'http://head'},
      ],
    };

    final article = BreakingNewsArticle.fromJson(
      Map<String, dynamic>.from(dynamicMap),
    );
    expect(article.teams!.first.teamId, 'PIT');
    expect(article.players!.first.name, 'Player');
  });

  test('BreakingNewsArticle handles int IDs gracefully', () {
    final intIdMap = <String, dynamic>{
      'id': 12345, // int ID
      'headline': 'Int ID Test',
      'createdAt': DateTime.now().toIso8601String(),
      'teams': [
        {'team_id': 101, 'logo_url': 'http://logo'}, // int team_id
      ],
      'players': [
        {
          'id': 99,
          'name': 'Player',
          'headshot_url': 'http://head',
        }, // int player id
      ],
    };

    final article = BreakingNewsArticle.fromJson(intIdMap);
    expect(article.id, '12345');
    expect(article.teams!.first.teamId, '101');
    expect(article.players!.first.id, '99');
  });
}
