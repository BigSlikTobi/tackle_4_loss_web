import React, { useEffect, useMemo, useRef, useState } from 'react';
import BreakingNewsModal from '../BreakingNewsModal';
import {
  DeepDiveFeedItemModel,
  fetchNewsFeed,
  NewsFeedItemModel,
  NewsUpdateFeedItemModel,
} from '../../lib/microApps';
import { useTeamTheme } from '../../hooks/useTeamTheme';

interface OSShellHomeProps {
  languageCode: string;
  onOpenDeepDiveArticle: (articleId: string) => void;
  onOpenRadioApp: () => void;
}

function formatTimeAgo(rawDate: string) {
  const createdAt = new Date(rawDate);
  if (Number.isNaN(createdAt.valueOf())) return '';

  const diffMs = Date.now() - createdAt.valueOf();
  const mins = Math.floor(diffMs / (1000 * 60));
  if (mins < 60) return `${Math.max(mins, 1)}m`;
  const hours = Math.floor(mins / 60);
  if (hours < 24) return `${hours}h`;
  const days = Math.floor(hours / 24);
  if (days < 7) return `${days}d`;
  return `${createdAt.getMonth() + 1}/${createdAt.getDate()}`;
}

function normalize(value: string | undefined | null) {
  return (value ?? '').trim().toLowerCase();
}

export default function OSShellHome({ languageCode, onOpenDeepDiveArticle, onOpenRadioApp }: OSShellHomeProps) {
  const [items, setItems] = useState<NewsFeedItemModel[]>([]);
  const [hasMore, setHasMore] = useState(true);
  const [loading, setLoading] = useState(true);
  const [loadingMore, setLoadingMore] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [selectedNewsId, setSelectedNewsId] = useState<string | null>(null);
  const sentinelRef = useRef<HTMLDivElement | null>(null);

  const { currentTeam } = useTeamTheme();
  const headlineSeed = useMemo(() => {
    const latestNews = items.find((entry) => entry.type === 'newsUpdate') as NewsUpdateFeedItemModel | undefined;
    return latestNews?.headline || latestNews?.xPost || 'Deep Dive · Breaking News';
  }, [items]);

  useEffect(() => {
    let mounted = true;
    (async () => {
      setLoading(true);
      setError(null);
      try {
        const response = await fetchNewsFeed(languageCode, { limit: 20, offset: 0 });
        if (!mounted) return;
        setItems(response.items);
        setHasMore(response.hasMore);
      } catch (err) {
        if (!mounted) return;
        setError(err instanceof Error ? err.message : 'Failed to load news feed');
      } finally {
        if (!mounted) return;
        setLoading(false);
      }
    })();

    return () => {
      mounted = false;
    };
  }, [languageCode]);

  const newsItems = useMemo(
    () => items.filter((item): item is NewsUpdateFeedItemModel => item.type === 'newsUpdate'),
    [items],
  );

  const loadMore = async () => {
    if (loadingMore || loading || !hasMore) return;
    setLoadingMore(true);
    try {
      const response = await fetchNewsFeed(languageCode, { limit: 20, offset: items.length });
      setItems((prev) => [...prev, ...response.items]);
      setHasMore(response.hasMore);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to load more feed items');
    } finally {
      setLoadingMore(false);
    }
  };

  useEffect(() => {
    if (!sentinelRef.current || !hasMore) return;
    const observer = new IntersectionObserver(
      (entries) => {
        if (entries.some((entry) => entry.isIntersecting)) {
          loadMore();
        }
      },
      { rootMargin: '320px 0px 320px 0px' },
    );
    observer.observe(sentinelRef.current);
    return () => observer.disconnect();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [hasMore, loadingMore, loading, items.length, languageCode]);

  return (
    <section className="t4l-os-home">
      <article
        className="t4l-radio-home-widget"
        onClick={onOpenRadioApp}
        role="button"
        tabIndex={0}
        onKeyDown={(event) => {
          if (event.key === 'Enter' || event.key === ' ') {
            event.preventDefault();
            onOpenRadioApp();
          }
        }}
      >
        <button type="button" className="t4l-radio-home-play" aria-label="Open radio">
          ▶
        </button>
        <div className="t4l-radio-home-content">
          <p className="t4l-radio-home-title">Radio</p>
          <div className="t4l-radio-home-marquee">
            <span>{headlineSeed}</span>
            <span>{headlineSeed}</span>
          </div>
        </div>
        {currentTeam?.logo_url ? <img className="t4l-radio-home-watermark" src={currentTeam.logo_url} alt="" /> : null}
      </article>

      {error ? <p className="t4l-feed-error">{error}</p> : null}

      {loading ? (
        <div className="t4l-feed-skeleton-list">
          <div className="t4l-feed-skeleton" />
          <div className="t4l-feed-skeleton" />
          <div className="t4l-feed-skeleton" />
        </div>
      ) : (
        <>
          <div className="t4l-os-logo-watermark-slot">
            {currentTeam?.logo_url ? <img src={currentTeam.logo_url} alt="" /> : null}
          </div>

          <div className="t4l-os-feed-list">
            {items.map((item) => {
              if (item.type === 'deepDive') {
                const deepDive = item as DeepDiveFeedItemModel;
                return (
                  <article
                    key={item.id}
                    className="t4l-deepdive-feed-card"
                    onClick={() => onOpenDeepDiveArticle(deepDive.articleId)}
                  >
                    <div className="t4l-deepdive-feed-inner">
                      <div className="t4l-deepdive-feed-media">
                        {deepDive.imageUrl ? (
                          <img src={deepDive.imageUrl} alt={deepDive.title} />
                        ) : (
                          <div className="t4l-deepdive-feed-fallback" />
                        )}
                        <div className="t4l-deepdive-feed-overlay" />
                        <div className="t4l-deepdive-feed-badge">Deep Dive</div>
                        <div className="t4l-deepdive-feed-copy">
                          <h3>{deepDive.title}</h3>
                          <p>{deepDive.summary}</p>
                          <span>{deepDive.author}</span>
                        </div>
                      </div>
                    </div>
                  </article>
                );
              }

              if (item.type === 'newsUpdate') {
                const isUpdate = item.status?.toLowerCase() === 'update';
                const isTeamMatch =
                  normalize(currentTeam?.team_name) !== '' &&
                  (item.teams ?? []).some((team: any) => normalize(team?.team_name) === normalize(currentTeam?.team_name));

                return (
                  <React.Fragment key={item.id}>
                    <article
                      className={`t4l-news-feed-item ${isTeamMatch ? 'is-team-match' : ''}`}
                      onClick={() => setSelectedNewsId(item.id)}
                    >
                      {isTeamMatch ? <div className="t4l-news-chip is-team">Your Team</div> : null}
                      {isUpdate ? <div className="t4l-news-chip is-update">Update</div> : null}

                      <div className="t4l-news-head">
                        <span className="t4l-news-head-accent" />
                        <p>
                          <span className="t4l-news-headline">{(item.headline || 'News').toUpperCase()}</span>
                          <span className="t4l-news-meta">
                            {' '}
                            • {(item.source || 'Feed').toUpperCase()} • {formatTimeAgo(item.createdAt)}
                          </span>
                        </p>
                      </div>

                      {(item.teams?.length || item.players?.length) ? (
                        <div className="t4l-news-context-row">
                          {item.teams?.length ? (
                            <div className="t4l-news-team-stack">
                              {item.teams.slice(0, 3).map((team: any, index) => (
                                <span key={`${team.team_id || team.team_name || 'team'}-${index}`} className="t4l-news-team-dot">
                                  {team.logo_url ? (
                                    <img src={team.logo_url} alt={team.team_name || team.team_id || 'Team'} />
                                  ) : (
                                    <span>{(team.team_id || team.team_name || '?').toString().slice(0, 2)}</span>
                                  )}
                                </span>
                              ))}
                            </div>
                          ) : null}

                          {item.players?.length ? (
                            <div className="t4l-news-player-stack">
                              {item.players.slice(0, 8).map((player: any, index) => (
                                <span key={`${player.player_id || 'player'}-${index}`} className="t4l-news-player-dot">
                                  {player.headshot_url ? <img src={player.headshot_url} alt="" /> : null}
                                </span>
                              ))}
                            </div>
                          ) : null}
                        </div>
                      ) : null}

                      {item.imageUrl ? (
                        <div className="t4l-news-media">
                          <img src={item.imageUrl} alt={item.headline || 'News'} />
                        </div>
                      ) : null}

                      <p className="t4l-news-body">{item.xPost}</p>
                    </article>
                    <div className="t4l-news-divider" />
                  </React.Fragment>
                );
              }

              if (item.type === 'video') {
                return (
                  <article key={item.id} className="t4l-os-feed-fallback">
                    <h3>{item.title}</h3>
                  </article>
                );
              }

              return (
                <article key={item.id} className="t4l-os-feed-fallback">
                  <h3>{item.title}</h3>
                  <p>{item.subtitle}</p>
                </article>
              );
            })}
          </div>

          {hasMore ? (
            <div className="t4l-feed-load-more" ref={sentinelRef}>
              {loadingMore ? 'Loading feed...' : ''}
            </div>
          ) : null}
        </>
      )}

      {selectedNewsId ? (
        <BreakingNewsModal
          newsId={selectedNewsId}
          onClose={() => setSelectedNewsId(null)}
          previousArticle={(() => {
            const currentIndex = newsItems.findIndex((entry) => entry.id === selectedNewsId);
            if (currentIndex <= 0) return null;
            const previous = newsItems[currentIndex - 1];
            return { id: previous.id, headline: previous.headline ?? 'News', image: previous.imageUrl };
          })()}
          nextArticle={(() => {
            const currentIndex = newsItems.findIndex((entry) => entry.id === selectedNewsId);
            if (currentIndex < 0 || currentIndex >= newsItems.length - 1) return null;
            const next = newsItems[currentIndex + 1];
            return { id: next.id, headline: next.headline ?? 'News', image: next.imageUrl };
          })()}
          onNavigate={(id) => setSelectedNewsId(id)}
        />
      ) : null}
    </section>
  );
}
