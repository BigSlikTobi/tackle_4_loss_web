import React, { useMemo, useState } from 'react';
import { fetchLatestStandingsGames, GameModel } from '../../lib/microApps';

type ReportStyle = 'casual' | 'detailed' | 'stats';

interface GeneratedReport {
  headline: string;
  body: string;
  highlights: string[];
}

function generateHeadline(game: GameModel): string {
  const awayScore = game.awayScore ?? 0;
  const homeScore = game.homeScore ?? 0;
  const winner = awayScore > homeScore ? game.awayTeam : homeScore > awayScore ? game.homeTeam : null;
  const scoreDiff = Math.abs(awayScore - homeScore);

  if (!winner) return `${game.awayTeam} and ${game.homeTeam} Battle to a Draw`;
  if (scoreDiff >= 20) return `${winner} Dominate in ${awayScore}-${homeScore} Blowout`;
  if (scoreDiff <= 3) return `${winner} Edge Out a Nail-Biter, ${awayScore}-${homeScore}`;
  if ((game.overtime ?? 0) > 0) return `${winner} Prevail in Overtime`;
  return `${winner} Secure ${awayScore}-${homeScore} Win`;
}

function generateBody(game: GameModel, style: ReportStyle): string {
  const awayScore = game.awayScore ?? 0;
  const homeScore = game.homeScore ?? 0;
  const totalPoints = awayScore + homeScore;
  const margin = Math.abs(awayScore - homeScore);

  if (style === 'stats') {
    const lines = [
      `Final Score: ${game.awayTeam} ${awayScore} - ${homeScore} ${game.homeTeam}`,
      `Week ${game.week}, Season ${game.season}`,
      `Point Differential: ${margin}`,
      `Total Points: ${totalPoints}`,
    ];
    if (game.stadium) lines.push(`Stadium: ${game.stadium}`);
    if (game.temp != null) lines.push(`Temperature: ${game.temp}F`);
    if (game.wind != null) lines.push(`Wind: ${game.wind} mph`);
    if ((game.overtime ?? 0) > 0) lines.push('Overtime: Yes');
    return lines.join('\n');
  }

  if (style === 'detailed') {
    const narrative = [
      `${game.awayTeam} and ${game.homeTeam} met in Week ${game.week} at ${game.stadium ?? 'their venue'}.`,
      `The game finished ${awayScore}-${homeScore}, with a ${margin}-point margin.`,
      totalPoints >= 50
        ? `Both offenses were productive, combining for ${totalPoints} total points.`
        : `Defense had a major impact, limiting total production to ${totalPoints} points.`,
    ];
    if ((game.overtime ?? 0) > 0) narrative.push('The result required overtime to settle the game.');
    return narrative.join(' ');
  }

  return `Week ${game.week} recap: ${game.awayTeam} ${awayScore}, ${game.homeTeam} ${homeScore}. ` +
    (margin <= 7 ? 'It came down to the final possessions.' : 'The winner kept control through most of the game.');
}

function generateHighlights(game: GameModel): string[] {
  const awayScore = game.awayScore ?? 0;
  const homeScore = game.homeScore ?? 0;
  const total = awayScore + homeScore;
  const diff = Math.abs(awayScore - homeScore);
  const winner = awayScore > homeScore ? game.awayTeam : homeScore > awayScore ? game.homeTeam : null;
  const pointsLeader = awayScore > homeScore ? game.awayTeam : game.homeTeam;

  const highlights: string[] = [];
  if ((game.overtime ?? 0) > 0) highlights.push('Game went to overtime.');
  if (winner && diff >= 20) highlights.push(`${winner} won by ${diff} points.`);
  if (winner && diff <= 3) highlights.push(`${winner} survived a one-score finish.`);
  if (total >= 55) highlights.push(`Combined scoring reached ${total} points.`);
  highlights.push(`${pointsLeader} posted the higher point total.`);
  return highlights;
}

export default function GameReportsApp() {
  const [games, setGames] = useState<GameModel[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [selectedGameId, setSelectedGameId] = useState<string>('');
  const [style, setStyle] = useState<ReportStyle>('casual');
  const [report, setReport] = useState<GeneratedReport | null>(null);

  React.useEffect(() => {
    let mounted = true;
    (async () => {
      setLoading(true);
      setError(null);
      try {
        const rows = await fetchLatestStandingsGames();
        if (!mounted) return;
        const completed = rows
          .filter((game) => game.awayScore != null && game.homeScore != null)
          .sort((a, b) => new Date(b.gameday).valueOf() - new Date(a.gameday).valueOf());
        setGames(completed);
        setSelectedGameId(completed[0]?.gameId ?? '');
      } catch (err) {
        if (!mounted) return;
        setError(err instanceof Error ? err.message : 'Failed to load completed games');
      } finally {
        if (!mounted) return;
        setLoading(false);
      }
    })();
    return () => {
      mounted = false;
    };
  }, []);

  const selectedGame = useMemo(
    () => games.find((game) => game.gameId === selectedGameId) ?? null,
    [games, selectedGameId],
  );

  const generateReport = () => {
    if (!selectedGame) return;
    setReport({
      headline: generateHeadline(selectedGame),
      body: generateBody(selectedGame, style),
      highlights: generateHighlights(selectedGame),
    });
  };

  return (
    <section className="t4l-page t4l-page-narrow">
      <header className="t4l-page-header">
        <p className="t4l-page-eyebrow">Game Reports</p>
        <h2>AI Recap Studio</h2>
        <p>Uses completed games from `get-latest-standings`, same as Flutter flow.</p>
      </header>

      {loading ? (
        <div className="t4l-feed-skeleton-list">
          <div className="t4l-feed-skeleton" />
          <div className="t4l-feed-skeleton" />
        </div>
      ) : (
        <>
          {error ? <p className="text-sm text-red-700">{error}</p> : null}
          <div className="rounded-2xl border border-[var(--neutral-border)] bg-white/85 p-4 space-y-3">
            <label className="block text-xs font-bold uppercase tracking-wide text-[var(--text-secondary)]">
              Select Game
            </label>
            <select
              className="w-full rounded-xl border border-[var(--neutral-border)] bg-white px-3 py-2 text-sm"
              value={selectedGameId}
              onChange={(event) => setSelectedGameId(event.target.value)}
            >
              {games.map((game) => (
                <option key={game.gameId} value={game.gameId}>
                  Week {game.week}: {game.awayTeam} {game.awayScore} - {game.homeScore} {game.homeTeam}
                </option>
              ))}
            </select>

            <label className="block text-xs font-bold uppercase tracking-wide text-[var(--text-secondary)]">
              Style
            </label>
            <div className="t4l-segmented">
              <button type="button" className={style === 'casual' ? 'is-active' : ''} onClick={() => setStyle('casual')}>
                Casual
              </button>
              <button
                type="button"
                className={style === 'detailed' ? 'is-active' : ''}
                onClick={() => setStyle('detailed')}
              >
                Detailed
              </button>
              <button type="button" className={style === 'stats' ? 'is-active' : ''} onClick={() => setStyle('stats')}>
                Stats
              </button>
            </div>

            <button type="button" className="t4l-install-button" onClick={generateReport} disabled={!selectedGame}>
              Generate Report
            </button>
          </div>

          {report ? (
            <article className="rounded-2xl border border-[var(--neutral-border)] bg-white/90 p-5 space-y-4">
              <h3 className="font-['Russo_One'] text-lg leading-tight">{report.headline}</h3>
              <pre className="text-sm whitespace-pre-wrap font-body m-0 text-[var(--text-strong)]">{report.body}</pre>
              <div>
                <p className="text-xs font-bold uppercase tracking-wide text-[var(--text-secondary)]">Highlights</p>
                <ul className="mt-2 space-y-1 text-sm">
                  {report.highlights.map((highlight, index) => (
                    <li key={`${highlight}-${index}`}>• {highlight}</li>
                  ))}
                </ul>
              </div>
            </article>
          ) : null}
        </>
      )}
    </section>
  );
}
