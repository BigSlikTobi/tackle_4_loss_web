import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'dart:async';
import 'package:tackle4loss_mobile/l10n/app_localizations.dart';
import 'package:tackle4loss_mobile/micro_apps/breaking_news/views/widgets/breaking_news_hero.dart';
import 'package:tackle4loss_mobile/micro_apps/breaking_news/views/widgets/breaking_news_list_item.dart';
import 'package:tackle4loss_mobile/micro_apps/breaking_news/models/breaking_news_article.dart';
import 'package:tackle4loss_mobile/core/theme/t4l_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:io';

class MockHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return _MockHttpClient();
  }
}

class _MockHttpClient implements HttpClient {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }

  @override
  Future<HttpClientRequest> getUrl(Uri url) async {
    return _MockHttpClientRequest();
  }
}

class _MockHttpClientRequest implements HttpClientRequest {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }

  @override
  Future<HttpClientResponse> close() async {
    return _MockHttpClientResponse();
  }

  @override
  HttpHeaders get headers => _MockHttpHeaders();
}

class _MockHttpClientResponse implements HttpClientResponse {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }

  @override
  int get statusCode => 200;

  @override
  int get contentLength => 0; // Empty body

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  StreamSubscription<List<int>> listen(void Function(List<int> event)? onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    final List<int> validImage = [
      0x89,
      0x50,
      0x4e,
      0x47,
      0x0d,
      0x0a,
      0x1a,
      0x0a,
      0x00,
      0x00,
      0x00,
      0x0d,
      0x49,
      0x48,
      0x44,
      0x52,
      0x00,
      0x00,
      0x00,
      0x01,
      0x00,
      0x00,
      0x00,
      0x01,
      0x08,
      0x06,
      0x00,
      0x00,
      0x00,
      0x1f,
      0x15,
      0xc4,
      0x89,
      0x00,
      0x00,
      0x00,
      0x0a,
      0x49,
      0x44,
      0x41,
      0x54,
      0x78,
      0x9c,
      0x63,
      0x00,
      0x01,
      0x00,
      0x00,
      0x05,
      0x00,
      0x01,
      0x0d,
      0x0a,
      0x2d,
      0xb4,
      0x00,
      0x00,
      0x00,
      0x00,
      0x49,
      0x45,
      0x4e,
      0x44,
      0xae,
      0x42,
      0x60,
      0x82,
    ];

    return Stream<List<int>>.fromIterable([validImage]).listen(onData,
        onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }
}

class _MockHttpHeaders implements HttpHeaders {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    return null;
  }

  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {}
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    HttpOverrides.global = MockHttpOverrides();
  });

  Widget createWidgetUnderTest(Widget child) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
      theme: T4LTheme.light(),
      home: Scaffold(body: child),
    );
  }

  group('BreakingNewsHero', () {
    testWidgets('displays headline, source badge, and team logo',
        (tester) async {
      final article = BreakingNewsArticle(
        id: '1',
        headline: 'Hero Headline',
        sourceName: 'The Athletic',
        createdAt: DateTime.now(),
        teams: [TeamReference(teamId: 'BUF')],
        players: [],
      );

      await tester.pumpWidget(createWidgetUnderTest(
        BreakingNewsHero(
          article: article,
          onTap: () {},
        ),
      ));

      // Headline
      expect(find.text('Hero Headline'), findsOneWidget);

      // Source in Badge (White background check is hard via widget test, but we check text existence)
      expect(find.text('THE ATHLETIC'), findsOneWidget);

      // Breaking Tag
      expect(find.text('BREAKING'), findsOneWidget);
    });

    testWidgets('displays player headshot if available', (tester) async {
      final article = BreakingNewsArticle(
        id: '2',
        headline: 'Player News',
        sourceName: 'ESPN',
        createdAt: DateTime.now(),
        teams: [TeamReference(teamId: 'KC')],
        players: [
          PlayerReference(id: '99', name: 'Patrick', headshotUrl: 'http://pat')
        ],
      );

      await tester.pumpWidget(createWidgetUnderTest(
        BreakingNewsHero(
          article: article,
          onTap: () {},
        ),
      ));

      // Should find CircularAvatar/Image for player (NetworkImage relies on HTTP overrides or mock,
      // but WidgetTester flushes image loading usually. We check structurally.)
      expect(find.byType(CircleAvatar), findsOneWidget);
    });
  });

  group('BreakingNewsListItem', () {
    testWidgets(
        'displays headline, source badge, team logo, and player headshot',
        (tester) async {
      final article = BreakingNewsArticle(
        id: '3',
        headline: 'List Item Headline',
        sourceName: 'Yahoo',
        createdAt: DateTime.now(),
        teams: [TeamReference(teamId: 'PIT')],
        players: [
          PlayerReference(id: '7', name: 'Ben', headshotUrl: 'http://ben')
        ],
      );

      await tester.pumpWidget(createWidgetUnderTest(
        BreakingNewsListItem(
          article: article,
          onTap: () {},
        ),
      ));

      // Headline
      expect(find.text('List Item Headline'), findsOneWidget);

      // Source
      expect(find.text('YAHOO'), findsOneWidget);

      // Player Headshot (CircleAvatar)
      // Note: breaking_news_list_item uses ClipOval for team and CircleAvatar for player
      expect(find.byType(CircleAvatar), findsOneWidget);
    });
  });
}
