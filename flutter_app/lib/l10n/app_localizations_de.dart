// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get navHome => 'Startseite';

  @override
  String get navAppStore => 'App Store';

  @override
  String get navHistory => 'Letzte App';

  @override
  String get navSettings => 'Einstellungen';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get settingsLanguage => 'Sprache';

  @override
  String get settingsClose => 'Schließen';

  @override
  String get historyEmpty => 'Noch kein App-Verlauf.';

  @override
  String get breakingNewsTitle => 'Breaking News';

  @override
  String get breakingNewsRefused => 'ABGELEHNT';

  @override
  String get breakingNewsSaved => 'GESPEICHERT';

  @override
  String get breakingNewsReadHistory => 'GELESEN';

  @override
  String get breakingNewsRestore => 'WIEDERHERSTELLEN?';

  @override
  String get breakingNewsHistory => 'VERLAUF';

  @override
  String get breakingNewsBackTitle => 'Hintergrund';

  @override
  String get breakingNewsTag => 'AKTUELL';

  @override
  String get breakingNewsSavedLabel => 'Saved';

  @override
  String deepDiveChapter(int index) {
    return 'KAPITEL $index';
  }

  @override
  String get deepDiveNoContent => 'Kein Inhalt verfügbar';

  @override
  String get appStoreTitle => 'T4L Apps';

  @override
  String get appStoreFeaturedTitle => 'App des Monats';

  @override
  String get appStoreFeaturedSubtitle => 'Tiefes, immersives Lesen.';

  @override
  String get appStoreAllApps => 'Alle Apps';

  @override
  String get radioTitle => 'Radio';

  @override
  String get radioCategoryAll => 'Alle';

  @override
  String get radioCategoryDeepDive => 'Deep Dives';

  @override
  String get radioCategoryNews => 'News';

  @override
  String get radioStationLatestDeepDivesTitle => 'Neueste Deep Dives';

  @override
  String get radioStationLatestDeepDivesDesc =>
      'Die aktuellste Analyse vom Team.';

  @override
  String get radioStationDailyBriefingTitle => 'Tägliches Briefing';

  @override
  String get radioStationDailyBriefingDesc => 'In 5 Minuten auf dem Laufenden.';

  @override
  String get radioStationDeepDiveClassicsTitle => 'Deep Dive Klassiker';

  @override
  String get radioStationDeepDiveClassicsDesc => 'Zeitlose Fußballphilosophie.';

  @override
  String get radioStationNewsTitle => 'Nachrichten';

  @override
  String get radioStationNewsDesc => 'Tägliches Briefing und aktuelle Updates.';

  @override
  String get radioStationNewsCollectionTitle => 'Nachrichten-Sammlung';

  @override
  String get radioStationNewsCollectionDesc =>
      'Einzelne Nachrichten durchsuchen und abspielen.';

  @override
  String get radioCollectionLatestUpdates => 'Aktuelle Updates';

  @override
  String get radioCollectionTeamNews => 'Team-Nachrichten';

  @override
  String get radioCollectionAllTeams => 'Alle Teams';

  @override
  String radioPlaying(String title) {
    return 'Spielt: $title';
  }
}
