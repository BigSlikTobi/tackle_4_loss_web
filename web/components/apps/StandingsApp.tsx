import React, { useEffect, useMemo, useState } from 'react';
import {
  ConferenceStandingModel,
  fetchGroupedStandings,
  fetchLatestStandingsGames,
  GameModel,
} from '../../lib/microApps';

type StandingsTab = 'schedule' | 'standings';

function gameLabel(game: GameModel) {
  return `${game.awayTeam} @ ${game.homeTeam}`;
}

function formatDateLabel(date: string) {
  const dt = new Date(date);
  return Number.isNaN(dt.valueOf()) ? date : dt.toLocaleDateString();
}

export default function StandingsApp() {
  const [tab, setTab] = useState<StandingsTab>('schedule');
  const [games, setGames] = useState<GameModel[]>([]);
  const [standings, setStandings] = useState<ConferenceStandingModel[]>([]);
  const [selectedWeek, setSelectedWeek] = useState<number | null>(null);
  const [loadingGames, setLoadingGames] = useState(true);
  const [loadingStandings, setLoadingStandings] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let mounted = true;
    (async () => {
      try {
        const [gamesPayload, standingsPayload] = await Promise.all([
          fetchLatestStandingsGames(),
          fetchGroupedStandings(),
        ]);

        if (!mounted) return;
        setGames(gamesPayload);
        setStandings(standingsPayload);

        const weeks = Array.from(new Set(gamesPayload.map((game) => game.week))).sort((a, b) => a - b);
        setSelectedWeek(weeks.length > 0 ? weeks[0] : null);
      } catch (err) {
        if (!mounted) return;
        setError(err instanceof Error ? err.message : 'Failed to load standings');
      } finally {
        if (!mounted) return;
        setLoadingGames(false);
        setLoadingStandings(false);
      }
    })();

    return () => {
      mounted = false;
    };
  }, []);

  const weeks = useMemo(
    () => Array.from(new Set(games.map((game) => game.week))).sort((a, b) => a - b),
    [games],
  );
  const filteredWeekGames = useMemo(
    () => games.filter((game) => (selectedWeek == null ? true : game.week === selectedWeek)),
    [games, selectedWeek],
  );

  return (
    <section className="t4l-page t4l-page-narrow">
      <header className="t4l-page-header">
        <p className="t4l-page-eyebrow">Standings</p>
        <h2>Schedule & Rankings</h2>
        <p>Live data from `get-latest-standings` and `get-standings`.</p>
      </header>

      <div className="t4l-segmented">
        <button type="button" className={tab === 'schedule' ? 'is-active' : ''} onClick={() => setTab('schedule')}>
          Schedule
        </button>
        <button
          type="button"
          className={tab === 'standings' ? 'is-active' : ''}
          onClick={() => setTab('standings')}
        >
          Standings
        </button>
      </div>

      {error ? <p className="text-sm text-red-700">{error}</p> : null}

      {tab === 'schedule' ? (
        <div className="space-y-4">
          {loadingGames ? (
            <div className="t4l-feed-skeleton-list">
              <div className="t4l-feed-skeleton" />
              <div className="t4l-feed-skeleton" />
            </div>
          ) : (
            <>
              <div className="flex gap-2 overflow-x-auto pb-1">
                {weeks.map((week) => (
                  <button
                    key={week}
                    type="button"
                    onClick={() => setSelectedWeek(week)}
                    className={`px-3 py-1.5 rounded-full text-xs font-bold border ${
                      selectedWeek === week
                        ? 'bg-[var(--brand)] text-white border-[var(--brand)]'
                        : 'bg-white text-[var(--text-secondary)] border-[var(--neutral-border)]'
                    }`}
                  >
                    Week {week}
                  </button>
                ))}
              </div>

              <div className="space-y-2">
                {filteredWeekGames.map((game) => {
                  const isPlayed = game.awayScore != null && game.homeScore != null;
                  return (
                    <article
                      key={`${game.id}-${game.week}`}
                      className="rounded-2xl border border-[var(--neutral-border)] bg-white/80 px-4 py-3"
                    >
                      <div className="flex items-center justify-between gap-3">
                        <div className="min-w-0">
                          <p className="font-bold text-sm">{gameLabel(game)}</p>
                          <p className="text-xs text-[var(--text-secondary)]">
                            {formatDateLabel(game.gameday)} {game.gametime ? `• ${game.gametime}` : ''}
                          </p>
                        </div>
                        <div className="text-right">
                          {isPlayed ? (
                            <p className="font-bold text-sm">
                              {game.awayScore} - {game.homeScore}
                            </p>
                          ) : (
                            <p className="text-xs text-[var(--text-secondary)]">Upcoming</p>
                          )}
                          {game.stadium ? (
                            <p className="text-[11px] text-[var(--text-secondary)] truncate max-w-[140px]">
                              {game.stadium}
                            </p>
                          ) : null}
                        </div>
                      </div>
                    </article>
                  );
                })}
              </div>
            </>
          )}
        </div>
      ) : (
        <div className="space-y-4">
          {loadingStandings ? (
            <div className="t4l-feed-skeleton-list">
              <div className="t4l-feed-skeleton" />
              <div className="t4l-feed-skeleton" />
            </div>
          ) : (
            standings.map((conference) => (
              <section key={conference.conference} className="space-y-3">
                <h3 className="text-sm font-bold uppercase tracking-wide text-[var(--text-secondary)]">
                  {conference.conference}
                </h3>
                {conference.divisions.map((division) => (
                  <article
                    key={`${conference.conference}-${division.division}`}
                    className="rounded-2xl border border-[var(--neutral-border)] bg-white/85 overflow-hidden"
                  >
                    <div className="px-4 py-2 border-b border-[var(--neutral-border)] bg-[var(--neutral-1)]/50">
                      <p className="text-xs font-bold uppercase tracking-wide">{division.division}</p>
                    </div>
                    <div className="divide-y divide-[var(--neutral-border)]">
                      {division.teams.map((team, index) => (
                        <div key={team.teamId} className="px-4 py-2.5 flex items-center justify-between gap-3">
                          <div className="min-w-0 flex items-center gap-2">
                            <span className="text-xs text-[var(--text-secondary)] w-5">{index + 1}</span>
                            {team.logoUrl ? (
                              <img src={team.logoUrl} alt="" className="w-6 h-6 object-contain" />
                            ) : null}
                            <p className="text-sm font-semibold truncate">{team.teamName}</p>
                          </div>
                          <div className="text-right">
                            <p className="text-xs font-bold">
                              {team.wins}-{team.losses}
                              {team.ties ? `-${team.ties}` : ''}
                            </p>
                            <p className="text-[11px] text-[var(--text-secondary)]">
                              {team.winPercentage.toFixed(3)}
                            </p>
                          </div>
                        </div>
                      ))}
                    </div>
                  </article>
                ))}
              </section>
            ))
          )}
        </div>
      )}
    </section>
  );
}
