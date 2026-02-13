import { supabase } from './supabase';

export interface GameModel {
  id: string;
  gameId: string;
  season: number;
  gameType: string;
  week: number;
  gameday: string;
  weekday: string;
  gametime: string;
  awayTeam: string;
  awayScore: number | null;
  homeTeam: string;
  homeScore: number | null;
  location?: string | null;
  result?: number | null;
  total?: number | null;
  overtime: number;
  stadium?: string | null;
  temp?: number | null;
  wind?: number | null;
  referee?: string | null;
}

export interface TeamStandingModel {
  teamId: string;
  teamName: string;
  conference: string;
  division: string;
  logoUrl: string;
  season: number;
  wins: number;
  losses: number;
  ties: number;
  pointsFor: number;
  pointsAgainst: number;
  conferenceWins: number;
  conferenceLosses: number;
  divisionWins: number;
  divisionLosses: number;
  winPercentage: number;
  netPoints: number;
}

export interface DivisionStandingModel {
  division: string;
  teams: TeamStandingModel[];
}

export interface ConferenceStandingModel {
  conference: string;
  divisions: DivisionStandingModel[];
}

export interface RadioTrackModel {
  id: string;
  url: string;
  title: string;
  createdAt: string;
  author: string;
  imageUrl: string;
  teamName?: string;
  teamLogoUrl?: string;
}

export interface RadioDeepDiveModel {
  id: string;
  title: string;
  subtitle: string;
  hero_image_url: string;
  audio_file?: string;
  published_at?: string;
}

export interface NewsUpdateFeedItemModel {
  type: 'newsUpdate';
  id: string;
  xPost: string;
  imageUrl?: string;
  source?: string | null;
  status?: string | null;
  createdAt: string;
  headline?: string;
  players?: Array<{
    player_id?: string;
    headshot_url?: string;
  }>;
  teams?: Array<{
    team_id?: string;
    team_name?: string;
    logo_url?: string;
  }>;
}

export interface DeepDiveFeedItemModel {
  type: 'deepDive';
  id: string;
  articleId: string;
  title: string;
  summary: string;
  imageUrl?: string;
  author: string;
  createdAt: string;
}

export interface VideoFeedItemModel {
  type: 'video';
  id: string;
  createdAt: string;
  title: string;
  thumbnailUrl?: string;
  videoUrl: string;
  durationSeconds?: number;
}

export interface PersonalizedFeedItemModel {
  type: 'personalized';
  id: string;
  createdAt: string;
  title: string;
  subtitle: string;
  imageUrl?: string;
  actionUrl?: string;
}

export type NewsFeedItemModel =
  | NewsUpdateFeedItemModel
  | DeepDiveFeedItemModel
  | VideoFeedItemModel
  | PersonalizedFeedItemModel;

export type WordleDifficulty = 'fan' | 'rookie' | 'pro' | 'allMadden';

export interface WordleSearchPlayer {
  playerId: string;
  displayName: string;
  team?: string;
  position?: string;
  headshot?: string;
  rank?: number;
}

export interface WordleNumericComparison {
  match: boolean;
  direction: 'up' | 'down' | 'exact';
  isClose: boolean;
}

export interface WordleGuessResult {
  guessedPlayer: {
    playerId: string;
    displayName: string;
    team?: string;
    conference?: string;
    division?: string;
    position?: string;
    jerseyNumber?: number;
    age?: number;
    height?: number;
    headshot?: string;
  };
  comparison: {
    conference: 'match' | 'miss';
    division: 'match' | 'miss';
    team: 'match' | 'miss';
    position: 'match' | 'side' | 'miss';
    jerseyNumber: WordleNumericComparison;
    age: WordleNumericComparison;
    height: WordleNumericComparison;
  };
  isCorrect: boolean;
}

export interface WordlePlayerDetails {
  playerId: string;
  displayName: string;
  team?: string;
  teamName?: string;
  teamLogo?: string;
  conference?: string;
  division?: string;
  position?: string;
  jerseyNumber?: number;
  age?: number;
  height?: number;
  weight?: number;
  college?: string;
  headshot?: string;
  yearsExperience?: number;
  draftYear?: number;
  draftRound?: number;
  draftPick?: number;
}

export interface DailyPlayerResponse {
  playerId: string;
  date: string;
  difficulty: WordleDifficulty;
  poolSize: number;
  teamsInvolved: string[];
}

async function invokeOrThrow<T>(fn: string, body?: Record<string, unknown>): Promise<T> {
  const { data, error } = await supabase.functions.invoke(fn, body ? { body } : undefined);
  if (error) {
    throw error;
  }
  return data as T;
}

export async function fetchLatestStandingsGames(): Promise<GameModel[]> {
  return invokeOrThrow<GameModel[]>('get-latest-standings');
}

export async function fetchGroupedStandings(season?: number): Promise<ConferenceStandingModel[]> {
  if (season != null) {
    return invokeOrThrow<ConferenceStandingModel[]>('get-standings', { season });
  }
  return invokeOrThrow<ConferenceStandingModel[]>('get-standings');
}

export async function fetchRadioNewsTracks(
  languageCode: string,
  opts?: { sinceCreatedAt?: string; limit?: number },
): Promise<RadioTrackModel[]> {
  const payload: Record<string, unknown> = { language_code: languageCode };
  if (opts?.sinceCreatedAt) payload.since_created_at = opts.sinceCreatedAt;
  if (opts?.limit != null) payload.limit = opts.limit;

  const rows = await invokeOrThrow<
    Array<{
      id?: string;
      audioUrl?: string;
      title?: string;
      createdAt?: string;
      imageUrl?: string;
      primaryTeam?: { team_name?: string; logo_url?: string } | null;
    }>
  >('get-radio-news', payload);

  return rows
    .map((item) => ({
      id: item.id ?? '',
      url: item.audioUrl ?? '',
      title: item.title ?? 'News Update',
      createdAt: item.createdAt ?? '',
      imageUrl: item.imageUrl ?? '',
      author: item.primaryTeam?.team_name ?? 'T4L News',
      teamName: item.primaryTeam?.team_name,
      teamLogoUrl: item.primaryTeam?.logo_url,
    }))
    .filter((row) => row.url.length > 0);
}

export async function fetchRadioDeepDiveTracks(languageCode: string): Promise<RadioDeepDiveModel[]> {
  return invokeOrThrow<RadioDeepDiveModel[]>('get-radio-deepdives', {
    language_code: languageCode,
  });
}

export async function fetchAllDeepDives(
  languageCode: string,
  opts?: { limit?: number; offset?: number },
): Promise<{ data: any[]; count: number | null }> {
  const payload = {
    language_code: languageCode,
    limit: opts?.limit ?? 25,
    offset: opts?.offset ?? 0,
  };

  const response = await invokeOrThrow<{ data?: any[]; count?: number } | any[]>('get-all-deepdives', payload);
  if (Array.isArray(response)) {
    return { data: response, count: null };
  }

  return {
    data: Array.isArray(response.data) ? response.data : [],
    count: typeof response.count === 'number' ? response.count : null,
  };
}

export async function fetchNewsFeed(
  languageCode: string,
  opts?: { limit?: number; offset?: number },
): Promise<{ items: NewsFeedItemModel[]; hasMore: boolean }> {
  const response = await invokeOrThrow<{ items?: NewsFeedItemModel[]; hasMore?: boolean }>('get-news-feed', {
    language_code: languageCode,
    limit: opts?.limit ?? 20,
    offset: opts?.offset ?? 0,
  });

  return {
    items: Array.isArray(response.items) ? response.items : [],
    hasMore: Boolean(response.hasMore),
  };
}

export async function getRandomWordlePlayerId(difficulty: WordleDifficulty): Promise<string> {
  const result = await invokeOrThrow<{ playerId: string }>('get-random-player', { difficulty });
  return result.playerId;
}

export async function getDailyWordlePlayerId(difficulty: WordleDifficulty): Promise<DailyPlayerResponse> {
  return invokeOrThrow<DailyPlayerResponse>('get-daily-player', { difficulty });
}

export async function searchWordlePlayers(
  query: string,
  opts?: {
    difficulty?: WordleDifficulty;
    limit?: number;
    offset?: number;
    team?: string;
    position?: string;
  },
): Promise<WordleSearchPlayer[]> {
  return invokeOrThrow<WordleSearchPlayer[]>('search-players', {
    query,
    difficulty: opts?.difficulty ?? 'pro',
    limit: opts?.limit ?? 10,
    offset: opts?.offset ?? 0,
    team: opts?.team,
    position: opts?.position,
  });
}

export async function compareWordleGuess(
  guessedPlayerId: string,
  mysteryPlayerId: string,
): Promise<WordleGuessResult> {
  return invokeOrThrow<WordleGuessResult>('compare-player-guess', {
    guessedPlayerId,
    mysteryPlayerId,
  });
}

export async function getWordlePlayerDetails(playerId: string): Promise<WordlePlayerDetails> {
  return invokeOrThrow<WordlePlayerDetails>('get-player-details', {
    playerId,
  });
}
