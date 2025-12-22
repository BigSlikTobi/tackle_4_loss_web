import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
  ];

  /// Navigation bar label for the Home screen
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navAppStore.
  ///
  /// In en, this message translates to:
  /// **'App Store'**
  String get navAppStore;

  /// No description provided for @navHistory.
  ///
  /// In en, this message translates to:
  /// **'Last App'**
  String get navHistory;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get settingsClose;

  /// No description provided for @historyEmpty.
  ///
  /// In en, this message translates to:
  /// **'No app history yet.'**
  String get historyEmpty;

  /// No description provided for @breakingNewsTitle.
  ///
  /// In en, this message translates to:
  /// **'Breaking News'**
  String get breakingNewsTitle;

  /// No description provided for @breakingNewsRefused.
  ///
  /// In en, this message translates to:
  /// **'REFUSED'**
  String get breakingNewsRefused;

  /// No description provided for @breakingNewsSaved.
  ///
  /// In en, this message translates to:
  /// **'SAVED'**
  String get breakingNewsSaved;

  /// No description provided for @breakingNewsReadHistory.
  ///
  /// In en, this message translates to:
  /// **'READ HISTORY'**
  String get breakingNewsReadHistory;

  /// No description provided for @breakingNewsRestore.
  ///
  /// In en, this message translates to:
  /// **'RESTORE?'**
  String get breakingNewsRestore;

  /// No description provided for @breakingNewsHistory.
  ///
  /// In en, this message translates to:
  /// **'HISTORY'**
  String get breakingNewsHistory;

  /// No description provided for @breakingNewsBackTitle.
  ///
  /// In en, this message translates to:
  /// **'Full Story'**
  String get breakingNewsBackTitle;

  /// No description provided for @breakingNewsTag.
  ///
  /// In en, this message translates to:
  /// **'BREAKING'**
  String get breakingNewsTag;

  /// No description provided for @breakingNewsSavedLabel.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get breakingNewsSavedLabel;

  /// No description provided for @deepDiveChapter.
  ///
  /// In en, this message translates to:
  /// **'CHAPTER {index}'**
  String deepDiveChapter(int index);

  /// No description provided for @deepDiveNoContent.
  ///
  /// In en, this message translates to:
  /// **'No content available'**
  String get deepDiveNoContent;

  /// No description provided for @appStoreTitle.
  ///
  /// In en, this message translates to:
  /// **'T4L Apps'**
  String get appStoreTitle;

  /// No description provided for @appStoreFeaturedTitle.
  ///
  /// In en, this message translates to:
  /// **'App of the Month'**
  String get appStoreFeaturedTitle;

  /// No description provided for @appStoreFeaturedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Deeply immersive reading.'**
  String get appStoreFeaturedSubtitle;

  /// No description provided for @appStoreAllApps.
  ///
  /// In en, this message translates to:
  /// **'All Apps'**
  String get appStoreAllApps;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
