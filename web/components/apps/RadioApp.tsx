import React, { useEffect, useMemo, useState } from 'react';
import { fetchRadioDeepDiveTracks, fetchRadioNewsTracks, RadioDeepDiveModel, RadioTrackModel } from '../../lib/microApps';
import { useAudio } from '../../context/AudioContext';

type RadioCategory = 'all' | 'news' | 'deep_dive';

interface RadioAppProps {
  languageCode: string;
}

function formatTime(time: string) {
  const dt = new Date(time);
  return Number.isNaN(dt.valueOf()) ? '' : dt.toLocaleString();
}

export default function RadioApp({ languageCode }: RadioAppProps) {
  const [category, setCategory] = useState<RadioCategory>('all');
  const [newsTracks, setNewsTracks] = useState<RadioTrackModel[]>([]);
  const [deepDiveTracks, setDeepDiveTracks] = useState<RadioDeepDiveModel[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const { play, pause, currentUrl, isPlaying } = useAudio();

  useEffect(() => {
    let mounted = true;
    (async () => {
      setLoading(true);
      setError(null);
      try {
        const [news, deepDives] = await Promise.all([
          fetchRadioNewsTracks(languageCode),
          fetchRadioDeepDiveTracks(languageCode),
        ]);
        if (!mounted) return;
        setNewsTracks(news);
        setDeepDiveTracks(deepDives);
      } catch (err) {
        if (!mounted) return;
        setError(err instanceof Error ? err.message : 'Failed to load radio feeds');
      } finally {
        if (!mounted) return;
        setLoading(false);
      }
    })();

    return () => {
      mounted = false;
    };
  }, [languageCode]);

  const visibleNews = useMemo(() => (category === 'deep_dive' ? [] : newsTracks), [category, newsTracks]);
  const visibleDeepDives = useMemo(
    () => (category === 'news' ? [] : deepDiveTracks.filter((track) => Boolean(track.audio_file))),
    [category, deepDiveTracks],
  );

  const playDailyBriefing = () => {
    const firstTrack = newsTracks[0];
    if (!firstTrack) return;
    if (currentUrl === firstTrack.url && isPlaying) {
      pause();
      return;
    }
    play(firstTrack.url, `Daily Briefing: ${firstTrack.title}`);
  };

  return (
    <section className="t4l-page t4l-page-narrow">
      <header className="t4l-page-header">
        <p className="t4l-page-eyebrow">Radio</p>
        <h2>Daily Briefing</h2>
        <p>Content from `get-radio-news` and `get-radio-deepdives`.</p>
      </header>

      <article className="t4l-radio-card">
        <div>
          <p className="t4l-page-eyebrow">Now</p>
          <h2>{newsTracks[0]?.title ?? 'No briefing available'}</h2>
          <p>{newsTracks[0] ? formatTime(newsTracks[0].createdAt) : 'No recent news in this language.'}</p>
        </div>
        <button type="button" className="t4l-install-button" onClick={playDailyBriefing} disabled={!newsTracks[0]}>
          {currentUrl === newsTracks[0]?.url && isPlaying ? 'Pause' : 'Play'}
        </button>
      </article>

      <div className="t4l-segmented">
        <button type="button" className={category === 'all' ? 'is-active' : ''} onClick={() => setCategory('all')}>
          All
        </button>
        <button
          type="button"
          className={category === 'news' ? 'is-active' : ''}
          onClick={() => setCategory('news')}
        >
          News
        </button>
        <button
          type="button"
          className={category === 'deep_dive' ? 'is-active' : ''}
          onClick={() => setCategory('deep_dive')}
        >
          Deep Dives
        </button>
      </div>

      {error ? <p className="text-sm text-red-700">{error}</p> : null}

      {loading ? (
        <div className="t4l-feed-skeleton-list">
          <div className="t4l-feed-skeleton" />
          <div className="t4l-feed-skeleton" />
        </div>
      ) : (
        <div className="space-y-4">
          {visibleNews.length > 0 ? (
            <section className="space-y-2">
              <h3 className="text-xs font-bold uppercase tracking-wide text-[var(--text-secondary)]">News Tracks</h3>
              {visibleNews.map((track) => (
                <article
                  key={`news-${track.id}`}
                  className="rounded-2xl border border-[var(--neutral-border)] bg-white/85 px-4 py-3 flex items-center justify-between gap-3"
                >
                  <div className="min-w-0">
                    <p className="text-sm font-semibold truncate">{track.title}</p>
                    <p className="text-xs text-[var(--text-secondary)] truncate">
                      {track.author} {track.createdAt ? `• ${formatTime(track.createdAt)}` : ''}
                    </p>
                  </div>
                  <button
                    type="button"
                    className={`t4l-install-button ${currentUrl === track.url ? 'is-installed' : ''}`}
                    onClick={() => {
                      if (currentUrl === track.url && isPlaying) {
                        pause();
                      } else {
                        play(track.url, track.title);
                      }
                    }}
                  >
                    {currentUrl === track.url && isPlaying ? 'Pause' : 'Play'}
                  </button>
                </article>
              ))}
            </section>
          ) : null}

          {visibleDeepDives.length > 0 ? (
            <section className="space-y-2">
              <h3 className="text-xs font-bold uppercase tracking-wide text-[var(--text-secondary)]">
                Deep Dive Audio
              </h3>
              {visibleDeepDives.map((track) => (
                <article
                  key={`dd-${track.id}`}
                  className="rounded-2xl border border-[var(--neutral-border)] bg-white/85 px-4 py-3 flex items-center justify-between gap-3"
                >
                  <div className="min-w-0">
                    <p className="text-sm font-semibold truncate">{track.title}</p>
                    <p className="text-xs text-[var(--text-secondary)] line-clamp-2">{track.subtitle}</p>
                  </div>
                  <button
                    type="button"
                    className={`t4l-install-button ${currentUrl === track.audio_file ? 'is-installed' : ''}`}
                    onClick={() => {
                      if (!track.audio_file) return;
                      if (currentUrl === track.audio_file && isPlaying) {
                        pause();
                      } else {
                        play(track.audio_file, track.title);
                      }
                    }}
                  >
                    {currentUrl === track.audio_file && isPlaying ? 'Pause' : 'Play'}
                  </button>
                </article>
              ))}
            </section>
          ) : null}
        </div>
      )}
    </section>
  );
}
