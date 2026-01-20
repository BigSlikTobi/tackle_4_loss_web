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
  String get navAppHub => 'App Hub';

  @override
  String get navGameCenter => 'Game Center';

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
  String get deepDiveNotebookDisclaimer =>
      'Our researches are done with NotebookLM, if you want to dig deeper and explore more content, feel free to access the notebook here!';

  @override
  String get appHubTitle => 'App Hub';

  @override
  String get appHubFeaturedTitle => 'Featured App';

  @override
  String get appHubFeaturedGames => 'Game of the Month';

  @override
  String get appHubFeaturedContent => 'Article of the Month';

  @override
  String get appHubFeaturedGameData => 'Stat of the Month';

  @override
  String get appHubFeaturedNews => 'Topic of the Month';

  @override
  String get appHubAllApps => 'All Apps';

  @override
  String get appHubOpen => 'Open';

  @override
  String get categoryGames => 'Games';

  @override
  String get categoryGameData => 'Game Data';

  @override
  String get categoryContent => 'Content';

  @override
  String get categoryNews => 'News';

  @override
  String get radioTitle => 'Radio';

  @override
  String get radioCategoryAll => 'All';

  @override
  String get radioCategoryDeepDive => 'Deep Dives';

  @override
  String get radioCategoryNews => 'News';

  @override
  String get radioStationLatestDeepDivesTitle => 'Latest Deep Dives';

  @override
  String get radioStationLatestDeepDivesDesc =>
      'The freshest analysis from the team.';

  @override
  String get radioStationDailyBriefingTitle => 'Daily Briefing';

  @override
  String get radioStationDailyBriefingDesc =>
      'All News and latest updates in one stream.';

  @override
  String get radioStationDeepDiveClassicsTitle => 'Deep Dive Classics';

  @override
  String get radioStationDeepDiveClassicsDesc =>
      'Timeless football philosophy.';

  @override
  String get radioStationNewsTitle => 'News';

  @override
  String get radioStationNewsDesc => 'Daily briefing and latest updates.';

  @override
  String get radioStationNewsCollectionTitle => 'News Collection';

  @override
  String get radioStationNewsCollectionDesc =>
      'Browse and play individual news updates.';

  @override
  String get radioCollectionLatestUpdates => 'Latest Updates';

  @override
  String get radioCollectionTeamNews => 'Team News';

  @override
  String get radioCollectionAllTeams => 'All Teams';

  @override
  String radioPlaying(String title) {
    return 'Playing: $title';
  }

  @override
  String get playerWordleTitle => 'Guess the Player';

  @override
  String get playerWordleLevelFan => 'Fan';

  @override
  String get playerWordleLevelRookie => 'Rookie';

  @override
  String get playerWordleLevelPro => 'Pro';

  @override
  String get playerWordleLevelAllMadden => 'All-Madden';

  @override
  String get playerWordleInstructionPrimary => 'Guess the mystery NFL player!';

  @override
  String get playerWordleInstructionSecondary =>
      '1. Select Team  2. Position  3. Player';

  @override
  String playerWordlePointsToNext(int points, String rank) {
    return '$points pts to $rank';
  }

  @override
  String get playerWordleMaxLevel => 'Max Level';

  @override
  String get playerWordleSearchHint => 'Search for an NFL player...';

  @override
  String get playerWordleGameOverSearchHint => 'Game Over';

  @override
  String get playerWordleYouGotIt => 'You Got It!';

  @override
  String get playerWordleGameOver => 'Game Over!';

  @override
  String get playerWordlePlayAgain => 'Play Again';

  @override
  String get playerWordleStatAge => 'Age';

  @override
  String get playerWordleStatHeight => 'Height';

  @override
  String get playerWordleStatWeight => 'Weight';

  @override
  String get playerWordleStatCollege => 'College';

  @override
  String get playerWordleStatExperience => 'Experience';

  @override
  String get playerWordleStatDraft => 'Draft';

  @override
  String get playerWordleHeaderPlayer => 'Player';

  @override
  String get playerWordleHeaderConf => 'Conf';

  @override
  String get playerWordleHeaderDiv => 'Div';

  @override
  String get playerWordleHeaderTeam => 'Team';

  @override
  String get playerWordleHeaderPos => 'Pos';

  @override
  String get playerWordleHeaderNum => '#';

  @override
  String get playerWordleHeaderAge => 'Age';

  @override
  String get playerWordleHeaderHt => 'Ht';

  @override
  String get playerWordleRevealSurprise => 'Reveal Surprise';

  @override
  String get playerWordleGiveUp => 'Give Up?';

  @override
  String get playerWordleHint => 'Hint: Reveal College (-10pts)';

  @override
  String get playerWordleSurpriseTitle => 'A Surprise for you!';

  @override
  String get playerWordleSurpriseUnlock => 'Unlock';

  @override
  String get playerWordleSurpriseDismiss => 'Not now';

  @override
  String get playerWordleModeFan => 'Fan Mode (Easy)';

  @override
  String get playerWordleModeRookie => 'Rookie Mode (Skill Pos)';

  @override
  String get playerWordleModePro => 'Pro Mode (All Starters)';

  @override
  String get playerWordleModeAllMadden => 'All-Madden (Everyone)';

  @override
  String get playerWordleLoading => 'Finding your mystery player...';

  @override
  String get playerWordleNoGameLoaded => 'No game loaded';

  @override
  String get playerWordleFailedToLoad => 'Failed to load game';

  @override
  String get playerWordleUnknownError => 'Unknown error';

  @override
  String get playerWordleTryAgain => 'Try Again';

  @override
  String get playerWordleMaxLevelAchieved => 'Max Level Achieved!';

  @override
  String get playerWordleStatPts => 'PTS';

  @override
  String get playerWordleStatPlayed => 'Played';

  @override
  String get playerWordleStatWon => 'Won';

  @override
  String get playerWordleStatStreak => 'Streak';

  @override
  String get playerWordleStatMax => 'Max';

  @override
  String get playerWordleStatWinLabel => 'WL';

  @override
  String get playerWordleFilterTeam => 'Team';

  @override
  String get playerWordleFilterAllTeams => 'All Teams';

  @override
  String get playerWordleNotAvailable => 'N/A';

  @override
  String playerWordleGuessesFormat(int count) {
    return '$count guesses';
  }

  @override
  String get playerWordleInstructionStep2 => '🟩 = Match  🟨 = Close  ⬜ = Miss';

  @override
  String get playerWordleInstructionStep3 => 'Win in 8 guesses to earn points!';

  @override
  String get playerWordleStatYearsUnit => 'yrs';

  @override
  String get playerWordleStatLbsUnit => 'lbs';

  @override
  String playerWordleStatDraftFormat(int year, int round, int pick) {
    return '$year Rd $round Pick $pick';
  }

  @override
  String get playerWordleStartGuessing => 'Start guessing below!';
}
