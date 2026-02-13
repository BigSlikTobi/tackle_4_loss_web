import React, { useEffect, useMemo, useState } from 'react';
import {
  compareWordleGuess,
  getDailyWordlePlayerId,
  getRandomWordlePlayerId,
  getWordlePlayerDetails,
  searchWordlePlayers,
  WordleDifficulty,
  WordleGuessResult,
  WordlePlayerDetails,
  WordleSearchPlayer,
} from '../../lib/microApps';

type GameStatus = 'playing' | 'won' | 'lost';
type GameMode = 'random' | 'daily';

const MAX_GUESSES = 8;

function matchClass(status: 'match' | 'miss' | 'side') {
  if (status === 'match') return 'bg-emerald-100 text-emerald-800 border-emerald-300';
  if (status === 'side') return 'bg-amber-100 text-amber-800 border-amber-300';
  return 'bg-zinc-100 text-zinc-600 border-zinc-300';
}

function numericClass(match: boolean, isClose: boolean) {
  if (match) return 'bg-emerald-100 text-emerald-800 border-emerald-300';
  if (isClose) return 'bg-amber-100 text-amber-800 border-amber-300';
  return 'bg-zinc-100 text-zinc-600 border-zinc-300';
}

function formatArrow(direction: 'up' | 'down' | 'exact') {
  if (direction === 'up') return '↑';
  if (direction === 'down') return '↓';
  return '✓';
}

export default function PlayerWordleApp() {
  const [difficulty, setDifficulty] = useState<WordleDifficulty>('pro');
  const [mode, setMode] = useState<GameMode>('random');
  const [mysteryPlayerId, setMysteryPlayerId] = useState<string | null>(null);
  const [dailyInfo, setDailyInfo] = useState<{ date: string; teamsInvolved: string[] } | null>(null);
  const [guesses, setGuesses] = useState<WordleGuessResult[]>([]);
  const [status, setStatus] = useState<GameStatus>('playing');
  const [revealPlayer, setRevealPlayer] = useState<WordlePlayerDetails | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [loadingGame, setLoadingGame] = useState(false);

  const [query, setQuery] = useState('');
  const [searchResults, setSearchResults] = useState<WordleSearchPlayer[]>([]);
  const [searching, setSearching] = useState(false);
  const [submittingGuessId, setSubmittingGuessId] = useState<string | null>(null);

  const remainingGuesses = MAX_GUESSES - guesses.length;
  const canGuess = status === 'playing' && Boolean(mysteryPlayerId);
  const guessedIds = useMemo(() => new Set(guesses.map((guess) => guess.guessedPlayer.playerId)), [guesses]);

  const startNewGame = async (targetMode: GameMode) => {
    setLoadingGame(true);
    setError(null);
    setMode(targetMode);
    setGuesses([]);
    setStatus('playing');
    setRevealPlayer(null);
    setQuery('');
    setSearchResults([]);
    setDailyInfo(null);

    try {
      if (targetMode === 'daily') {
        const daily = await getDailyWordlePlayerId(difficulty);
        setMysteryPlayerId(daily.playerId);
        setDailyInfo({ date: daily.date, teamsInvolved: daily.teamsInvolved });
      } else {
        const randomId = await getRandomWordlePlayerId(difficulty);
        setMysteryPlayerId(randomId);
      }
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to start game');
      setMysteryPlayerId(null);
    } finally {
      setLoadingGame(false);
    }
  };

  useEffect(() => {
    startNewGame('random');
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [difficulty]);

  useEffect(() => {
    if (!canGuess || query.trim().length < 2) {
      setSearchResults([]);
      return;
    }

    const timeout = window.setTimeout(async () => {
      setSearching(true);
      try {
        const results = await searchWordlePlayers(query.trim(), {
          difficulty,
          limit: 8,
          offset: 0,
        });
        setSearchResults(results.filter((player) => !guessedIds.has(player.playerId)));
      } catch {
        setSearchResults([]);
      } finally {
        setSearching(false);
      }
    }, 220);

    return () => window.clearTimeout(timeout);
  }, [query, difficulty, canGuess, guessedIds]);

  const finalizeGame = async (isWin: boolean, playerId: string) => {
    setStatus(isWin ? 'won' : 'lost');
    try {
      const details = await getWordlePlayerDetails(playerId);
      setRevealPlayer(details);
    } catch {
      // Best effort
    }
  };

  const submitGuess = async (player: WordleSearchPlayer) => {
    if (!mysteryPlayerId || !canGuess || guessedIds.has(player.playerId)) return;

    setSubmittingGuessId(player.playerId);
    setError(null);
    setQuery('');
    setSearchResults([]);

    try {
      const result = await compareWordleGuess(player.playerId, mysteryPlayerId);
      setGuesses((previous) => [...previous, result]);

      if (result.isCorrect) {
        await finalizeGame(true, mysteryPlayerId);
        return;
      }

      if (guesses.length + 1 >= MAX_GUESSES) {
        await finalizeGame(false, mysteryPlayerId);
      }
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to submit guess');
    } finally {
      setSubmittingGuessId(null);
    }
  };

  return (
    <section className="t4l-page t4l-page-narrow">
      <header className="t4l-page-header">
        <p className="t4l-page-eyebrow">Player Wordle</p>
        <h2>Guess The Player</h2>
        <p>
          Uses `get-random-player`, `get-daily-player`, `search-players`, `compare-player-guess`, and
          `get-player-details`.
        </p>
      </header>

      <div className="rounded-2xl border border-[var(--neutral-border)] bg-white/85 p-4 space-y-3">
        <div className="flex flex-wrap gap-2 items-center justify-between">
          <div className="text-sm text-[var(--text-secondary)]">
            Status: <span className="font-bold text-[var(--text-strong)]">{status.toUpperCase()}</span> • Remaining:{' '}
            <span className="font-bold text-[var(--text-strong)]">{remainingGuesses}</span>
          </div>
          {dailyInfo ? (
            <div className="text-xs text-[var(--text-secondary)]">
              Daily: {dailyInfo.date} {dailyInfo.teamsInvolved.length ? `• ${dailyInfo.teamsInvolved.join(', ')}` : ''}
            </div>
          ) : null}
        </div>

        <label className="block text-xs font-bold uppercase tracking-wide text-[var(--text-secondary)]">Difficulty</label>
        <div className="t4l-segmented">
          {(['fan', 'rookie', 'pro', 'allMadden'] as WordleDifficulty[]).map((level) => (
            <button
              key={level}
              type="button"
              className={difficulty === level ? 'is-active' : ''}
              onClick={() => setDifficulty(level)}
            >
              {level}
            </button>
          ))}
        </div>

        <div className="flex flex-wrap gap-2">
          <button type="button" className="t4l-install-button" onClick={() => startNewGame('random')} disabled={loadingGame}>
            Random Game
          </button>
          <button type="button" className="t4l-install-button is-installed" onClick={() => startNewGame('daily')} disabled={loadingGame}>
            Daily Challenge
          </button>
        </div>
      </div>

      {canGuess ? (
        <div className="rounded-2xl border border-[var(--neutral-border)] bg-white/90 p-4 space-y-2 relative">
          <label className="block text-xs font-bold uppercase tracking-wide text-[var(--text-secondary)]">
            Search Player
          </label>
          <input
            value={query}
            onChange={(event) => setQuery(event.target.value)}
            placeholder="Type at least 2 letters..."
            className="w-full rounded-xl border border-[var(--neutral-border)] px-3 py-2 text-sm"
          />
          {searching ? <p className="text-xs text-[var(--text-secondary)]">Searching...</p> : null}

          {searchResults.length > 0 ? (
            <div className="absolute left-4 right-4 top-[5.8rem] rounded-xl border border-[var(--neutral-border)] bg-white shadow-lg max-h-64 overflow-y-auto z-20">
              {searchResults.map((player) => (
                <button
                  key={player.playerId}
                  type="button"
                  onClick={() => submitGuess(player)}
                  disabled={submittingGuessId != null}
                  className="w-full px-3 py-2 text-left border-b border-[var(--neutral-border)] last:border-b-0 hover:bg-[var(--neutral-1)]/60"
                >
                  <p className="text-sm font-semibold">{player.displayName}</p>
                  <p className="text-xs text-[var(--text-secondary)]">
                    {player.team ?? 'N/A'} • {player.position ?? 'N/A'}
                  </p>
                </button>
              ))}
            </div>
          ) : null}
        </div>
      ) : null}

      {error ? <p className="text-sm text-red-700">{error}</p> : null}

      <div className="space-y-2">
        {guesses.map((guess) => (
          <article
            key={guess.guessedPlayer.playerId}
            className="rounded-2xl border border-[var(--neutral-border)] bg-white/90 p-3"
          >
            <div className="flex items-center justify-between gap-3 mb-2">
              <p className="font-semibold text-sm">{guess.guessedPlayer.displayName}</p>
              <p className="text-xs text-[var(--text-secondary)]">{guess.guessedPlayer.position ?? 'N/A'}</p>
            </div>
            <div className="grid grid-cols-2 sm:grid-cols-3 gap-2">
              <span className={`px-2 py-1 rounded-lg border text-xs ${matchClass(guess.comparison.conference)}`}>
                Conference
              </span>
              <span className={`px-2 py-1 rounded-lg border text-xs ${matchClass(guess.comparison.division)}`}>
                Division
              </span>
              <span className={`px-2 py-1 rounded-lg border text-xs ${matchClass(guess.comparison.team)}`}>Team</span>
              <span className={`px-2 py-1 rounded-lg border text-xs ${matchClass(guess.comparison.position)}`}>
                Position
              </span>
              <span
                className={`px-2 py-1 rounded-lg border text-xs ${numericClass(
                  guess.comparison.jerseyNumber.match,
                  guess.comparison.jerseyNumber.isClose,
                )}`}
              >
                Jersey {formatArrow(guess.comparison.jerseyNumber.direction)}
              </span>
              <span
                className={`px-2 py-1 rounded-lg border text-xs ${numericClass(
                  guess.comparison.age.match,
                  guess.comparison.age.isClose,
                )}`}
              >
                Age {formatArrow(guess.comparison.age.direction)}
              </span>
              <span
                className={`px-2 py-1 rounded-lg border text-xs ${numericClass(
                  guess.comparison.height.match,
                  guess.comparison.height.isClose,
                )}`}
              >
                Height {formatArrow(guess.comparison.height.direction)}
              </span>
            </div>
          </article>
        ))}
      </div>

      {revealPlayer ? (
        <article className="rounded-2xl border border-[var(--neutral-border)] bg-white/90 p-4 space-y-2">
          <p className="text-xs font-bold uppercase tracking-wide text-[var(--text-secondary)]">Reveal</p>
          <div className="flex gap-3 items-start">
            {revealPlayer.headshot ? (
              <img src={revealPlayer.headshot} alt={revealPlayer.displayName} className="w-20 h-20 rounded-xl object-cover" />
            ) : null}
            <div>
              <p className="font-semibold">{revealPlayer.displayName}</p>
              <p className="text-sm text-[var(--text-secondary)]">
                {revealPlayer.position ?? 'N/A'} • {revealPlayer.teamName ?? revealPlayer.team ?? 'N/A'}
              </p>
              <p className="text-sm text-[var(--text-secondary)]">
                #{revealPlayer.jerseyNumber ?? 'N/A'} • {revealPlayer.college ?? 'Unknown College'}
              </p>
            </div>
          </div>
        </article>
      ) : null}
    </section>
  );
}
