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
    Locale('en')
  ];

  /// Navigation bar label for the Home screen
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navAppHub.
  ///
  /// In en, this message translates to:
  /// **'App Hub'**
  String get navAppHub;

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

  /// No description provided for @deepDiveNotebookDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Our researches are done with NotebookLM, if you want to dig deeper and explore more content, feel free to access the notebook here!'**
  String get deepDiveNotebookDisclaimer;

  /// No description provided for @appHubTitle.
  ///
  /// In en, this message translates to:
  /// **'App Hub'**
  String get appHubTitle;

  /// No description provided for @appHubFeaturedTitle.
  ///
  /// In en, this message translates to:
  /// **'Featured App'**
  String get appHubFeaturedTitle;

  /// No description provided for @appHubFeaturedGames.
  ///
  /// In en, this message translates to:
  /// **'Game of the Month'**
  String get appHubFeaturedGames;

  /// No description provided for @appHubFeaturedContent.
  ///
  /// In en, this message translates to:
  /// **'Article of the Month'**
  String get appHubFeaturedContent;

  /// No description provided for @appHubFeaturedGameData.
  ///
  /// In en, this message translates to:
  /// **'Stat of the Month'**
  String get appHubFeaturedGameData;

  /// No description provided for @appHubFeaturedNews.
  ///
  /// In en, this message translates to:
  /// **'Topic of the Month'**
  String get appHubFeaturedNews;

  /// No description provided for @appHubAllApps.
  ///
  /// In en, this message translates to:
  /// **'All Apps'**
  String get appHubAllApps;

  /// No description provided for @appHubOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get appHubOpen;

  /// No description provided for @categoryGames.
  ///
  /// In en, this message translates to:
  /// **'Games'**
  String get categoryGames;

  /// No description provided for @categoryGameData.
  ///
  /// In en, this message translates to:
  /// **'Game Data'**
  String get categoryGameData;

  /// No description provided for @categoryContent.
  ///
  /// In en, this message translates to:
  /// **'Content'**
  String get categoryContent;

  /// No description provided for @categoryNews.
  ///
  /// In en, this message translates to:
  /// **'News'**
  String get categoryNews;

  /// No description provided for @radioTitle.
  ///
  /// In en, this message translates to:
  /// **'Radio'**
  String get radioTitle;

  /// No description provided for @radioCategoryAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get radioCategoryAll;

  /// No description provided for @radioCategoryDeepDive.
  ///
  /// In en, this message translates to:
  /// **'Deep Dives'**
  String get radioCategoryDeepDive;

  /// No description provided for @radioCategoryNews.
  ///
  /// In en, this message translates to:
  /// **'News'**
  String get radioCategoryNews;

  /// No description provided for @radioStationLatestDeepDivesTitle.
  ///
  /// In en, this message translates to:
  /// **'Latest Deep Dives'**
  String get radioStationLatestDeepDivesTitle;

  /// No description provided for @radioStationLatestDeepDivesDesc.
  ///
  /// In en, this message translates to:
  /// **'The freshest analysis from the team.'**
  String get radioStationLatestDeepDivesDesc;

  /// No description provided for @radioStationDailyBriefingTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Briefing'**
  String get radioStationDailyBriefingTitle;

  /// No description provided for @radioStationDailyBriefingDesc.
  ///
  /// In en, this message translates to:
  /// **'All News and latest updates in one stream.'**
  String get radioStationDailyBriefingDesc;

  /// No description provided for @radioStationDeepDiveClassicsTitle.
  ///
  /// In en, this message translates to:
  /// **'Deep Dive Classics'**
  String get radioStationDeepDiveClassicsTitle;

  /// No description provided for @radioStationDeepDiveClassicsDesc.
  ///
  /// In en, this message translates to:
  /// **'Timeless football philosophy.'**
  String get radioStationDeepDiveClassicsDesc;

  /// No description provided for @radioStationNewsTitle.
  ///
  /// In en, this message translates to:
  /// **'News'**
  String get radioStationNewsTitle;

  /// No description provided for @radioStationNewsDesc.
  ///
  /// In en, this message translates to:
  /// **'Daily briefing and latest updates.'**
  String get radioStationNewsDesc;

  /// No description provided for @radioStationNewsCollectionTitle.
  ///
  /// In en, this message translates to:
  /// **'News Collection'**
  String get radioStationNewsCollectionTitle;

  /// No description provided for @radioStationNewsCollectionDesc.
  ///
  /// In en, this message translates to:
  /// **'Browse and play individual news updates.'**
  String get radioStationNewsCollectionDesc;

  /// No description provided for @radioCollectionLatestUpdates.
  ///
  /// In en, this message translates to:
  /// **'Latest Updates'**
  String get radioCollectionLatestUpdates;

  /// No description provided for @radioCollectionTeamNews.
  ///
  /// In en, this message translates to:
  /// **'Team News'**
  String get radioCollectionTeamNews;

  /// No description provided for @radioCollectionAllTeams.
  ///
  /// In en, this message translates to:
  /// **'All Teams'**
  String get radioCollectionAllTeams;

  /// No description provided for @radioPlaying.
  ///
  /// In en, this message translates to:
  /// **'Playing: {title}'**
  String radioPlaying(String title);

  /// No description provided for @playerWordleTitle.
  ///
  /// In en, this message translates to:
  /// **'Guess the Player'**
  String get playerWordleTitle;

  /// No description provided for @playerWordleLevelFan.
  ///
  /// In en, this message translates to:
  /// **'Fan'**
  String get playerWordleLevelFan;

  /// No description provided for @playerWordleLevelRookie.
  ///
  /// In en, this message translates to:
  /// **'Rookie'**
  String get playerWordleLevelRookie;

  /// No description provided for @playerWordleLevelPro.
  ///
  /// In en, this message translates to:
  /// **'Pro'**
  String get playerWordleLevelPro;

  /// No description provided for @playerWordleLevelAllMadden.
  ///
  /// In en, this message translates to:
  /// **'All-Madden'**
  String get playerWordleLevelAllMadden;

  /// No description provided for @playerWordleInstructionPrimary.
  ///
  /// In en, this message translates to:
  /// **'Guess the mystery NFL player!'**
  String get playerWordleInstructionPrimary;

  /// No description provided for @playerWordleInstructionSecondary.
  ///
  /// In en, this message translates to:
  /// **'Start typing a name below to begin.'**
  String get playerWordleInstructionSecondary;

  /// No description provided for @playerWordlePointsToNext.
  ///
  /// In en, this message translates to:
  /// **'{points} pts to {rank}'**
  String playerWordlePointsToNext(int points, String rank);

  /// No description provided for @playerWordleMaxLevel.
  ///
  /// In en, this message translates to:
  /// **'Max Level'**
  String get playerWordleMaxLevel;

  /// No description provided for @playerWordleSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search for an NFL player...'**
  String get playerWordleSearchHint;

  /// No description provided for @playerWordleGameOverSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Game Over'**
  String get playerWordleGameOverSearchHint;

  /// No description provided for @playerWordleYouGotIt.
  ///
  /// In en, this message translates to:
  /// **'You Got It!'**
  String get playerWordleYouGotIt;

  /// No description provided for @playerWordleGameOver.
  ///
  /// In en, this message translates to:
  /// **'Game Over!'**
  String get playerWordleGameOver;

  /// No description provided for @playerWordlePlayAgain.
  ///
  /// In en, this message translates to:
  /// **'Play Again'**
  String get playerWordlePlayAgain;

  /// No description provided for @playerWordleStatAge.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get playerWordleStatAge;

  /// No description provided for @playerWordleStatHeight.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get playerWordleStatHeight;

  /// No description provided for @playerWordleStatWeight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get playerWordleStatWeight;

  /// No description provided for @playerWordleStatCollege.
  ///
  /// In en, this message translates to:
  /// **'College'**
  String get playerWordleStatCollege;

  /// No description provided for @playerWordleStatExperience.
  ///
  /// In en, this message translates to:
  /// **'Experience'**
  String get playerWordleStatExperience;

  /// No description provided for @playerWordleStatDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get playerWordleStatDraft;

  /// No description provided for @playerWordleHeaderPlayer.
  ///
  /// In en, this message translates to:
  /// **'Player'**
  String get playerWordleHeaderPlayer;

  /// No description provided for @playerWordleHeaderConf.
  ///
  /// In en, this message translates to:
  /// **'Conf'**
  String get playerWordleHeaderConf;

  /// No description provided for @playerWordleHeaderDiv.
  ///
  /// In en, this message translates to:
  /// **'Div'**
  String get playerWordleHeaderDiv;

  /// No description provided for @playerWordleHeaderTeam.
  ///
  /// In en, this message translates to:
  /// **'Team'**
  String get playerWordleHeaderTeam;

  /// No description provided for @playerWordleHeaderPos.
  ///
  /// In en, this message translates to:
  /// **'Pos'**
  String get playerWordleHeaderPos;

  /// No description provided for @playerWordleHeaderNum.
  ///
  /// In en, this message translates to:
  /// **'#'**
  String get playerWordleHeaderNum;

  /// No description provided for @playerWordleHeaderAge.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get playerWordleHeaderAge;

  /// No description provided for @playerWordleHeaderHt.
  ///
  /// In en, this message translates to:
  /// **'Ht'**
  String get playerWordleHeaderHt;

  /// No description provided for @playerWordleRevealSurprise.
  ///
  /// In en, this message translates to:
  /// **'Reveal Surprise'**
  String get playerWordleRevealSurprise;

  /// No description provided for @playerWordleGiveUp.
  ///
  /// In en, this message translates to:
  /// **'Give Up?'**
  String get playerWordleGiveUp;

  /// No description provided for @playerWordleHint.
  ///
  /// In en, this message translates to:
  /// **'Hint: Reveal College (-10pts)'**
  String get playerWordleHint;

  /// No description provided for @playerWordleSurpriseTitle.
  ///
  /// In en, this message translates to:
  /// **'A Surprise for you!'**
  String get playerWordleSurpriseTitle;

  /// No description provided for @playerWordleSurpriseUnlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get playerWordleSurpriseUnlock;

  /// No description provided for @playerWordleSurpriseDismiss.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get playerWordleSurpriseDismiss;

  /// No description provided for @playerWordleModeFan.
  ///
  /// In en, this message translates to:
  /// **'Fan Mode (Easy)'**
  String get playerWordleModeFan;

  /// No description provided for @playerWordleModeRookie.
  ///
  /// In en, this message translates to:
  /// **'Rookie Mode (Skill Pos)'**
  String get playerWordleModeRookie;

  /// No description provided for @playerWordleModePro.
  ///
  /// In en, this message translates to:
  /// **'Pro Mode (All Starters)'**
  String get playerWordleModePro;

  /// No description provided for @playerWordleModeAllMadden.
  ///
  /// In en, this message translates to:
  /// **'All-Madden (Everyone)'**
  String get playerWordleModeAllMadden;

  /// No description provided for @playerWordleLoading.
  ///
  /// In en, this message translates to:
  /// **'Finding your mystery player...'**
  String get playerWordleLoading;

  /// No description provided for @playerWordleNoGameLoaded.
  ///
  /// In en, this message translates to:
  /// **'No game loaded'**
  String get playerWordleNoGameLoaded;

  /// No description provided for @playerWordleFailedToLoad.
  ///
  /// In en, this message translates to:
  /// **'Failed to load game'**
  String get playerWordleFailedToLoad;

  /// No description provided for @playerWordleUnknownError.
  ///
  /// In en, this message translates to:
  /// **'Unknown error'**
  String get playerWordleUnknownError;

  /// No description provided for @playerWordleTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get playerWordleTryAgain;

  /// No description provided for @playerWordleMaxLevelAchieved.
  ///
  /// In en, this message translates to:
  /// **'Max Level Achieved!'**
  String get playerWordleMaxLevelAchieved;

  /// No description provided for @playerWordleStatPts.
  ///
  /// In en, this message translates to:
  /// **'PTS'**
  String get playerWordleStatPts;

  /// No description provided for @playerWordleStatPlayed.
  ///
  /// In en, this message translates to:
  /// **'Played'**
  String get playerWordleStatPlayed;

  /// No description provided for @playerWordleStatWon.
  ///
  /// In en, this message translates to:
  /// **'Won'**
  String get playerWordleStatWon;

  /// No description provided for @playerWordleStatStreak.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get playerWordleStatStreak;

  /// No description provided for @playerWordleStatMax.
  ///
  /// In en, this message translates to:
  /// **'Max'**
  String get playerWordleStatMax;

  /// No description provided for @playerWordleStatWinLabel.
  ///
  /// In en, this message translates to:
  /// **'WL'**
  String get playerWordleStatWinLabel;

  /// No description provided for @playerWordleFilterTeam.
  ///
  /// In en, this message translates to:
  /// **'Team'**
  String get playerWordleFilterTeam;

  /// No description provided for @playerWordleFilterAllTeams.
  ///
  /// In en, this message translates to:
  /// **'All Teams'**
  String get playerWordleFilterAllTeams;

  /// No description provided for @playerWordleNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get playerWordleNotAvailable;

  /// No description provided for @playerWordleGuessesFormat.
  ///
  /// In en, this message translates to:
  /// **'{count} guesses'**
  String playerWordleGuessesFormat(int count);
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
      'that was used.');
}
