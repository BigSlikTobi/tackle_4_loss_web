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
  String get radioStationDailyBriefingDesc =>
      'Alle News und aktuelle Updates in einem Stream.';

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

  @override
  String get playerWordleTitle => 'Errate den Spieler';

  @override
  String get playerWordleLevelFan => 'Fan';

  @override
  String get playerWordleLevelRookie => 'Rookie';

  @override
  String get playerWordleLevelPro => 'Pro';

  @override
  String get playerWordleLevelAllMadden => 'All-Madden';

  @override
  String get playerWordleInstructionPrimary =>
      'Errate den geheimnisvollen NFL-Spieler!';

  @override
  String get playerWordleInstructionSecondary =>
      'Tippe einen Namen, um zu beginnen.';

  @override
  String playerWordlePointsToNext(int points, String rank) {
    return '$points Pkt bis $rank';
  }

  @override
  String get playerWordleMaxLevel => 'Max Level';

  @override
  String get playerWordleSearchHint => 'Suche nach einem NFL-Spieler...';

  @override
  String get playerWordleGameOverSearchHint => 'Spiel vorbei';

  @override
  String get playerWordleYouGotIt => 'Geschafft!';

  @override
  String get playerWordleGameOver => 'Game Over!';

  @override
  String get playerWordlePlayAgain => 'Nochmal spielen';

  @override
  String get playerWordleStatAge => 'Alter';

  @override
  String get playerWordleStatHeight => 'Größe';

  @override
  String get playerWordleStatWeight => 'Gewicht';

  @override
  String get playerWordleStatCollege => 'College';

  @override
  String get playerWordleStatExperience => 'Erfahrung';

  @override
  String get playerWordleStatDraft => 'Draft';

  @override
  String get playerWordleHeaderPlayer => 'Spieler';

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
  String get playerWordleHeaderAge => 'Alter';

  @override
  String get playerWordleHeaderHt => 'Größe';

  @override
  String get playerWordleRevealSurprise => 'Überraschung!';

  @override
  String get playerWordleGiveUp => 'Aufgeben?';

  @override
  String get playerWordleHint => 'Tipp: College zeigen (-10 Pkt)';

  @override
  String get playerWordleSurpriseTitle => 'Eine Überraschung für dich!';

  @override
  String get playerWordleSurpriseUnlock => 'Freischalten';

  @override
  String get playerWordleSurpriseDismiss => 'Nicht jetzt';

  @override
  String get playerWordleModeFan => 'Fan Modus (Einfach)';

  @override
  String get playerWordleModeRookie => 'Rookie Modus (Skill Pos)';

  @override
  String get playerWordleModePro => 'Pro Modus (Alle Starter)';

  @override
  String get playerWordleModeAllMadden => 'All-Madden (Alle)';

  @override
  String get playerWordleLoading => 'Suche deinen geheimnisvollen Spieler...';

  @override
  String get playerWordleNoGameLoaded => 'Kein Spiel geladen';

  @override
  String get playerWordleFailedToLoad => 'Spiel konnte nicht geladen werden';

  @override
  String get playerWordleUnknownError => 'Unbekannter Fehler';

  @override
  String get playerWordleTryAgain => 'Erneut versuchen';

  @override
  String get playerWordleMaxLevelAchieved => 'Max Level erreicht!';

  @override
  String get playerWordleStatPts => 'PKT';

  @override
  String get playerWordleStatPlayed => 'Gespielt';

  @override
  String get playerWordleStatWon => 'Gewonnen';

  @override
  String get playerWordleStatStreak => 'Serie';

  @override
  String get playerWordleStatMax => 'Max';

  @override
  String get playerWordleStatWinLabel => 'WL';

  @override
  String get playerWordleFilterTeam => 'Team';

  @override
  String get playerWordleFilterAllTeams => 'Alle Teams';

  @override
  String get playerWordleNotAvailable => 'N/V';

  @override
  String playerWordleGuessesFormat(int count) {
    return '$count Versuche';
  }
}
