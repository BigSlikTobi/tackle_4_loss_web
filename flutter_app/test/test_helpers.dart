// Test utilities and helpers for Flutter app testing
// Provides mock factories, common test widgets, and setup utilities

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tackle4loss_mobile/core/models/team_model.dart';
import 'package:tackle4loss_mobile/micro_apps/standings/models/game_model.dart';

// ============================================================================
// Mock Classes
// ============================================================================

/// Mock SharedPreferences for testing persistence
class MockSharedPreferences extends Mock implements SharedPreferences {}

// ============================================================================
// Test Data Factories
// ============================================================================

/// Factory for creating test Team instances
class TeamFactory {
  static Team create({
    String id = 'KC',
    String name = 'Kansas City Chiefs',
    String logoUrl = 'assets/logos/teams/kc.svg',
    Color primaryColor = const Color(0xFFE31837),
    Color secondaryColor = const Color(0xFFFFB81C),
  }) {
    return Team(
      id: id,
      name: name,
      logoUrl: logoUrl,
      primaryColor: primaryColor,
      secondaryColor: secondaryColor,
    );
  }

  static List<Team> createList([int count = 3]) {
    final teams = <Team>[
      create(id: 'KC', name: 'Kansas City Chiefs'),
      create(id: 'SF', name: 'San Francisco 49ers', primaryColor: const Color(0xFFAA0000)),
      create(id: 'DAL', name: 'Dallas Cowboys', primaryColor: const Color(0xFF002244)),
      create(id: 'PHI', name: 'Philadelphia Eagles', primaryColor: const Color(0xFF004C54)),
      create(id: 'BUF', name: 'Buffalo Bills', primaryColor: const Color(0xFF00338D)),
    ];
    return teams.take(count).toList();
  }
}

/// Factory for creating test Game instances
class GameFactory {
  static Game create({
    String id = 'game_1',
    String gameId = 'game_1_id',
    int season = 2024,
    String gameType = 'REG',
    int week = 1,
    DateTime? gameday,
    String weekday = 'Sunday',
    String gametime = '13:00',
    String homeTeam = 'KC',
    String awayTeam = 'SF',
    int? homeScore = 24,
    int? awayScore = 21,
    int overtime = 0,
  }) {
    return Game(
      id: id,
      gameId: gameId,
      season: season,
      gameType: gameType,
      week: week,
      gameday: gameday ?? DateTime.now(),
      weekday: weekday,
      gametime: gametime,
      homeTeam: homeTeam,
      awayTeam: awayTeam,
      homeScore: homeScore,
      awayScore: awayScore,
      overtime: overtime,
    );
  }

  static List<Game> createWeekSchedule(int week, [int count = 4]) {
    return List.generate(count, (i) => create(
      id: 'game_w${week}_$i',
      week: week,
    ));
  }
}

// ============================================================================
// Test Setup Utilities
// ============================================================================

/// Sets up mock SharedPreferences for testing
/// Call this in setUp() of tests that use SharedPreferences
Future<void> setupMockSharedPreferences([Map<String, Object>? values]) async {
  SharedPreferences.setMockInitialValues(values ?? {});
}

/// Creates a test widget wrapped in MaterialApp for widget testing
Widget createTestWidget({
  required Widget child,
  ThemeData? theme,
  NavigatorObserver? navigatorObserver,
}) {
  return MaterialApp(
    theme: theme ?? ThemeData.light(),
    home: child,
    navigatorObservers: navigatorObserver != null ? [navigatorObserver] : [],
  );
}

/// Creates a test widget with Scaffold wrapper
Widget createTestWidgetWithScaffold({
  required Widget child,
  ThemeData? theme,
}) {
  return createTestWidget(
    theme: theme,
    child: Scaffold(body: child),
  );
}

// ============================================================================
// Test Matchers
// ============================================================================

/// Matcher for verifying ChangeNotifier notifications
class NotifiesMatcher extends Matcher {
  final ChangeNotifier notifier;
  final int expectedCount;

  NotifiesMatcher(this.notifier, {this.expectedCount = 1});

  @override
  bool matches(dynamic item, Map matchState) {
    int notifyCount = 0;
    void listener() => notifyCount++;
    
    notifier.addListener(listener);
    if (item is Function()) {
      item();
    }
    notifier.removeListener(listener);
    
    matchState['actualCount'] = notifyCount;
    return notifyCount >= expectedCount;
  }

  @override
  Description describe(Description description) {
    return description.add('notifies listeners at least $expectedCount time(s)');
  }

  @override
  Description describeMismatch(
    dynamic item,
    Description mismatchDescription,
    Map matchState,
    bool verbose,
  ) {
    return mismatchDescription.add(
      'only notified ${matchState['actualCount']} time(s)',
    );
  }
}

// ============================================================================
// Grid Constants (mirror InstalledAppsService constants)
// ============================================================================

class TestGridConstants {
  static const int gridCols = 4;
  static const int gridRows = 5;
  static const int gridSize = gridCols * gridRows;
  static const String emptySlot = '__EMPTY__';
  static const String occupiedSlot = '__OCCUPIED__';
}
