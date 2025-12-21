// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get navHome => 'Home';

  @override
  String get navAppStore => 'App Store';

  @override
  String get navHistory => 'Last App';

  @override
  String get navSettings => 'Settings';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsClose => 'Close';

  @override
  String get historyEmpty => 'No app history yet.';

  @override
  String get breakingNewsTitle => 'Breaking News';

  @override
  String get breakingNewsRefused => 'REFUSED';

  @override
  String get breakingNewsSaved => 'SAVED';

  @override
  String get breakingNewsReadHistory => 'READ HISTORY';

  @override
  String get breakingNewsRestore => 'RESTORE?';

  @override
  String get breakingNewsHistory => 'HISTORY';

  @override
  String get breakingNewsBackTitle => 'Full Story';

  @override
  String get breakingNewsTag => 'BREAKING';

  @override
  String get breakingNewsSavedLabel => 'Saved';

  @override
  String deepDiveChapter(int index) {
    return 'CHAPTER $index';
  }

  @override
  String get deepDiveNoContent => 'No content available';

  @override
  String get appStoreTitle => 'T4L Apps';

  @override
  String get appStoreFeaturedTitle => 'App of the Month';

  @override
  String get appStoreFeaturedSubtitle => 'Deeply immersive reading.';

  @override
  String get appStoreAllApps => 'All Apps';
}
