import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tackle4loss_mobile/core/services/settings_service.dart';
import 'package:tackle4loss_mobile/core/models/team_model.dart';

void main() {
  group('SettingsService', () {
    late SettingsService service;

    setUp(() async {
      // Reset SharedPreferences for each test
      SharedPreferences.setMockInitialValues({});
      // Use the testing constructor to avoid singleton issues
      service = SettingsService.testing();
    });

    group('locale management', () {
      test('default locale is English', () {
        expect(service.locale.languageCode, 'en');
      });

      test('setLocale updates locale and notifies listeners', () {
        bool notified = false;
        service.addListener(() => notified = true);

        service.setLocale(const Locale('de'));

        expect(service.locale.languageCode, 'de');
        expect(notified, isTrue);
      });

      test('setLocale does not notify if same locale', () {
        bool notified = false;
        service.addListener(() => notified = true);

        // Set to same locale (default is 'en')
        service.setLocale(const Locale('en'));

        expect(notified, isFalse);
      });
    });

    group('theme management', () {
      test('default theme is light mode', () {
        expect(service.themeMode, ThemeMode.light);
        expect(service.isDarkMode, isFalse);
      });

      test('toggleTheme switches from light to dark', () async {
        await service.toggleTheme();

        expect(service.themeMode, ThemeMode.dark);
        expect(service.isDarkMode, isTrue);
      });

      test('toggleTheme switches from dark to light', () async {
        // First toggle to dark
        await service.toggleTheme();
        expect(service.isDarkMode, isTrue);

        // Toggle back to light
        await service.toggleTheme();
        expect(service.themeMode, ThemeMode.light);
        expect(service.isDarkMode, isFalse);
      });

      test('toggleTheme notifies listeners', () async {
        bool notified = false;
        service.addListener(() => notified = true);

        await service.toggleTheme();

        expect(notified, isTrue);
      });
    });

    group('team management', () {
      test('selectedTeam is null by default', () {
        expect(service.selectedTeam, isNull);
      });

      test('setFavoriteTeam updates selected team', () async {
        const team = Team(
          id: 'KC',
          name: 'Kansas City Chiefs',
          logoUrl: 'assets/logos/teams/kc.svg',
          primaryColor: Color(0xFFE31837),
          secondaryColor: Color(0xFFFFB81C),
        );

        await service.setFavoriteTeam(team);

        expect(service.selectedTeam, isNotNull);
        expect(service.selectedTeam!.id, 'KC');
      });

      test('setFavoriteTeam notifies listeners', () async {
        bool notified = false;
        service.addListener(() => notified = true);

        const team = Team(
          id: 'SF',
          name: 'San Francisco 49ers',
          logoUrl: 'assets/logos/teams/sf.svg',
          primaryColor: Color(0xFFAA0000),
          secondaryColor: Color(0xFFB3995D),
        );

        await service.setFavoriteTeam(team);

        expect(notified, isTrue);
      });

      test('setFavoriteTeam does not notify if same team', () async {
        const team = Team(
          id: 'KC',
          name: 'Kansas City Chiefs',
          logoUrl: 'assets/logos/teams/kc.svg',
          primaryColor: Color(0xFFE31837),
          secondaryColor: Color(0xFFFFB81C),
        );

        await service.setFavoriteTeam(team);

        bool notified = false;
        service.addListener(() => notified = true);

        // Set same team again
        await service.setFavoriteTeam(team);

        expect(notified, isFalse);
      });
    });

    group('onboarding', () {
      test('onboardingComplete defaults to false', () {
        expect(service.onboardingComplete, isFalse);
      });

      test('isLoaded defaults to false on testing constructor', () {
        expect(service.isLoaded, isFalse);
      });

      test('markOnboardingComplete flips flag and notifies', () async {
        bool notified = false;
        service.addListener(() => notified = true);

        await service.markOnboardingComplete();

        expect(service.onboardingComplete, isTrue);
        expect(notified, isTrue);
      });

      test('markOnboardingComplete is idempotent', () async {
        await service.markOnboardingComplete();

        bool notified = false;
        service.addListener(() => notified = true);
        await service.markOnboardingComplete();

        expect(notified, isFalse,
            reason: 'second call should be a no-op');
      });

      test('markOnboardingComplete persists to SharedPreferences', () async {
        await service.markOnboardingComplete();

        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getBool('onboarding_complete_v1'), isTrue);
      });
    });

    group('backgroundGradient', () {
      test('returns default gradient when no team selected (light mode)', () {
        final gradient = service.backgroundGradient;

        expect(gradient, isA<LinearGradient>());
        expect(gradient.colors.length, 2);
      });

      test('returns dark gradient when dark mode and no team', () async {
        await service.toggleTheme();
        final gradient = service.backgroundGradient;

        expect(gradient, isA<LinearGradient>());
        expect(service.isDarkMode, isTrue);
      });

      test('returns team-colored gradient when team selected (light mode)',
          () async {
        const team = Team(
          id: 'KC',
          name: 'Kansas City Chiefs',
          logoUrl: 'assets/logos/teams/kc.svg',
          primaryColor: Color(0xFFE31837),
          secondaryColor: Color(0xFFFFB81C),
        );

        await service.setFavoriteTeam(team);
        final gradient = service.backgroundGradient;

        expect(gradient, isA<LinearGradient>());
        // In light mode with team, gradient should incorporate team color
        expect(gradient.colors.length, 2);
      });

      test('returns team-colored gradient when team selected (dark mode)',
          () async {
        const team = Team(
          id: 'SF',
          name: 'San Francisco 49ers',
          logoUrl: 'assets/logos/teams/sf.svg',
          primaryColor: Color(0xFFAA0000),
          secondaryColor: Color(0xFFB3995D),
        );

        await service.setFavoriteTeam(team);
        await service.toggleTheme();

        final gradient = service.backgroundGradient;

        expect(gradient, isA<LinearGradient>());
        expect(service.isDarkMode, isTrue);
      });
    });
  });
}
