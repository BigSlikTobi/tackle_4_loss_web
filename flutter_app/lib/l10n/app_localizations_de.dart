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
}
