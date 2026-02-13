import React, { useEffect, useMemo, useState } from 'react';
import { ArrowLeft } from 'lucide-react';
import TransparentHeader from './components/TransparentHeader';
import Hero from './components/Hero';
import ArticleViewer from './components/ArticleViewer';
import ArticleFeed from './components/ArticleFeed';
import BreakingNewsOverviewModal from './components/BreakingNewsOverviewModal';
import FloatingNavBar from './components/FloatingNavBar';
import AppStrip from './components/AppStrip';
import AppStore from './components/AppStore';
import Settings from './components/Settings';
import MiniPlayerBar from './components/MiniPlayerBar';
import BreakingNewsApp from './components/apps/BreakingNewsApp';
import RadioApp from './components/apps/RadioApp';
import StandingsApp from './components/apps/StandingsApp';
import GameReportsApp from './components/apps/GameReportsApp';
import PlayerWordleApp from './components/apps/PlayerWordleApp';
import OSShellHome from './components/apps/OSShellHome';
import { MOCK_SUPABASE_DATA } from './constants';
import { Article, ArticleSection, SupabaseArticle } from './types';
import { supabase } from './lib/supabase';
import { AudioProvider, useAudio } from './context/AudioContext';
import { useBreakingNews } from './hooks/useBreakingNews';
import { HOME_STRIP_DEFAULT_APPS, ShellAppId } from './constants/apps';
import { fetchAllDeepDives } from './lib/microApps';

type ShellView =
  | 'home'
  | 'deep_dive'
  | 'app_store'
  | 'settings'
  | 'breaking_news'
  | 'radio'
  | 'standings'
  | 'game_reports'
  | 'player_wordle';

const RADIO_STREAM_URL =
  (typeof process !== 'undefined' &&
    process.env &&
    (process.env.REACT_APP_T4L_RADIO_STREAM_URL ||
      process.env.NEXT_PUBLIC_T4L_RADIO_STREAM_URL ||
      process.env.VITE_T4L_RADIO_STREAM_URL)) ||
  'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3';

function parseArticle(supabaseArticle: SupabaseArticle): Article {
  const sections: ArticleSection[] = Object.entries(supabaseArticle.sections || {})
    .sort(([keyA], [keyB]) => keyA.localeCompare(keyB, undefined, { numeric: true }))
    .map(([key, rawText]) => {
      const lines = rawText.split('\n');
      const headlineLine = lines.find((line) => line.startsWith('## '));
      const headline = headlineLine ? headlineLine.replace('## ', '').trim() : 'Section';

      const content = lines
        .filter((line) => !line.startsWith('## '))
        .map((line) => (line.startsWith('### ') ? line.replace('### ', '').trim() : line))
        .filter((line) => line.trim().length > 0);

      return {
        id: key,
        headline,
        content,
      };
    });

  return {
    id: supabaseArticle.id,
    title: supabaseArticle.title,
    subtitle: supabaseArticle.subtitle,
    author: supabaseArticle.author,
    date: new Date(supabaseArticle.published_at).toLocaleDateString('de-DE', {
      day: 'numeric',
      month: 'long',
      year: 'numeric',
    }),
    heroImage: supabaseArticle.hero_image_url,
    languageCode: supabaseArticle.language_code,
    audioFile: supabaseArticle.audio_file,
    videoFile: supabaseArticle.video_file,
    sections,
  };
}

function AppShell() {
  const [articles, setArticles] = useState<SupabaseArticle[]>([]);
  const [loading, setLoading] = useState(true);
  const [selectedArticle, setSelectedArticle] = useState<Article | null>(null);
  const [selectedLanguage, setSelectedLanguage] = useState<'de' | 'en'>(() => {
    if (typeof window !== 'undefined' && navigator.language) {
      return navigator.language.startsWith('de') ? 'de' : 'en';
    }
    return 'de';
  });

  const [view, setView] = useState<ShellView>('home');
  const [lastAppId, setLastAppId] = useState<ShellAppId>('deep_dive');
  const [installedApps, setInstalledApps] = useState<ShellAppId[]>([...HOME_STRIP_DEFAULT_APPS]);
  const [isBreakingNewsOpen, setIsBreakingNewsOpen] = useState(false);

  const { play } = useAudio();
  const { news: breakingNews, markAsRead: markBreakingNewsRead } = useBreakingNews(selectedLanguage);

  useEffect(() => {
    const fetchArticles = async () => {
      setLoading(true);
      try {
        const deepDives = await fetchAllDeepDives(selectedLanguage, {
          limit: 25,
          offset: 0,
        });
        if (deepDives.data.length > 0) {
          setArticles(deepDives.data as SupabaseArticle[]);
        } else {
          setArticles(MOCK_SUPABASE_DATA.filter((article) => article.language_code === selectedLanguage));
        }
      } catch {
        setArticles(MOCK_SUPABASE_DATA.filter((article) => article.language_code === selectedLanguage));
      } finally {
        setLoading(false);
      }
    };

    fetchArticles();
  }, [selectedLanguage]);

  const filteredArticles = useMemo(() => articles, [articles]);

  const handleSelectArticle = async (rawArticle: SupabaseArticle) => {
    try {
      const { data, error } = await supabase.functions.invoke('get-article-viewer-data', {
        body: { article_id: rawArticle.id },
      });

      if (error) {
        throw error;
      }

      const fullArticle = data as SupabaseArticle;
      setSelectedArticle(parseArticle(fullArticle));
      window.scrollTo({ top: 0, behavior: 'smooth' });
    } catch {
      setSelectedArticle(parseArticle(rawArticle));
      window.scrollTo({ top: 0, behavior: 'smooth' });
    }
  };

  const handleSelectArticleById = async (articleId: string) => {
    try {
      const { data, error } = await supabase.functions.invoke('get-article-viewer-data', {
        body: { article_id: articleId },
      });

      if (error) {
        throw error;
      }

      const fullArticle = data as SupabaseArticle;
      setSelectedArticle(parseArticle(fullArticle));
      window.scrollTo({ top: 0, behavior: 'smooth' });
    } catch {
      const fallback = filteredArticles.find((article) => article.id === articleId);
      if (fallback) {
        setSelectedArticle(parseArticle(fallback));
        window.scrollTo({ top: 0, behavior: 'smooth' });
      }
    }
  };

  const openApp = (appId: ShellAppId) => {
    if (appId !== 'deep_dive' && !installedApps.includes(appId)) {
      setView('app_store');
      return;
    }

    setLastAppId(appId);
    setSelectedArticle(null);

    switch (appId) {
      case 'deep_dive':
        setView('deep_dive');
        return;
      case 'breaking_news':
        setView('breaking_news');
        markBreakingNewsRead();
        return;
      case 'radio':
        setView('radio');
        play(RADIO_STREAM_URL, 'T4L Radio');
        return;
      case 'standings':
        setView('standings');
        return;
      case 'game_reports':
        setView('game_reports');
        return;
      case 'player_wordle':
        setView('player_wordle');
        return;
    }
  };

  const goHistory = () => {
    if (lastAppId !== 'deep_dive' && !installedApps.includes(lastAppId)) {
      setView('app_store');
      return;
    }
    openApp(lastAppId);
  };

  const toggleInstallApp = (appId: ShellAppId) => {
    setInstalledApps((prev) => {
      if (prev.includes(appId)) {
        const nextApps = prev.filter((id) => id !== appId);
        if (nextApps.length === 0) {
          return ['deep_dive'];
        }
        return nextApps;
      }
      return [...prev, appId];
    });
  };

  const headerTitle = selectedArticle
    ? selectedArticle.title
    : view === 'app_store'
    ? 'App Hub'
    : view === 'settings'
    ? 'Settings'
    : view === 'deep_dive'
    ? 'Deep Dive'
    : view === 'breaking_news'
    ? 'Breaking News'
    : view === 'radio'
    ? 'Radio'
    : view === 'standings'
    ? 'Standings'
    : view === 'game_reports'
    ? 'Game Reports'
    : view === 'player_wordle'
    ? 'Player Wordle'
    : undefined;

  return (
    <div className="t4l-shell">
      <TransparentHeader
        title={headerTitle}
      />

      <BreakingNewsOverviewModal
        isOpen={isBreakingNewsOpen}
        onClose={() => setIsBreakingNewsOpen(false)}
        news={breakingNews}
        languageCode={selectedLanguage}
      />

      <main className="t4l-main">
        {selectedArticle ? (
          <section className="t4l-page t4l-page-article">
            <button type="button" className="t4l-back-button" onClick={() => setSelectedArticle(null)}>
              <ArrowLeft size={15} /> Back
            </button>
            <ArticleViewer
              article={selectedArticle}
              nextArticle={(() => {
                const currentIndex = filteredArticles.findIndex((article) => article.id === selectedArticle.id);
                if (currentIndex === -1 || currentIndex === filteredArticles.length - 1) {
                  return null;
                }
                const next = filteredArticles[currentIndex + 1];
                return { id: next.id, headline: next.title, image: next.hero_image_url };
              })()}
              previousArticle={(() => {
                const currentIndex = filteredArticles.findIndex((article) => article.id === selectedArticle.id);
                if (currentIndex <= 0) {
                  return null;
                }
                const previous = filteredArticles[currentIndex - 1];
                return { id: previous.id, headline: previous.title, image: previous.hero_image_url };
              })()}
              onNavigate={(id) => {
                const nextArticle = filteredArticles.find((article) => article.id === id);
                if (nextArticle) {
                  handleSelectArticle(nextArticle);
                }
              }}
            />
          </section>
        ) : null}

        {!selectedArticle && view === 'app_store' ? (
          <AppStore onOpenApp={openApp} installedApps={installedApps} onToggleInstall={toggleInstallApp} />
        ) : null}

        {!selectedArticle && view === 'settings' ? (
          <Settings selectedLanguage={selectedLanguage} onChangeLanguage={setSelectedLanguage} />
        ) : null}

        {!selectedArticle && view === 'home' ? (
          <OSShellHome
            languageCode={selectedLanguage}
            onOpenDeepDiveArticle={handleSelectArticleById}
            onOpenRadioApp={() => openApp('radio')}
          />
        ) : null}

        {!selectedArticle && view === 'deep_dive' ? (
          <section className="t4l-page">
            <article className="t4l-radio-card">
              <div>
                <p className="t4l-page-eyebrow">Radio</p>
                <h2>Live Team Audio</h2>
                <p>Tap to start T4L Radio stream.</p>
              </div>
              <button type="button" className="t4l-install-button" onClick={() => openApp('radio')}>
                Play
              </button>
            </article>

            {!loading && filteredArticles[0] ? (
              <>
                <Hero article={filteredArticles[0]} onSelect={handleSelectArticle} tag="Deep Dive" />
                <ArticleFeed
                  articles={filteredArticles.length > 1 ? filteredArticles.slice(1) : []}
                  onSelect={handleSelectArticle}
                  selectedLanguage={selectedLanguage}
                />
              </>
            ) : (
              <div className="t4l-feed-skeleton-list" aria-hidden="true">
                <div className="t4l-feed-skeleton" />
                <div className="t4l-feed-skeleton" />
              </div>
            )}
          </section>
        ) : null}

        {!selectedArticle && view === 'breaking_news' ? (
          <BreakingNewsApp languageCode={selectedLanguage} />
        ) : null}

        {!selectedArticle && view === 'radio' ? <RadioApp languageCode={selectedLanguage} /> : null}

        {!selectedArticle && view === 'standings' ? <StandingsApp /> : null}

        {!selectedArticle && view === 'game_reports' ? <GameReportsApp /> : null}

        {!selectedArticle && view === 'player_wordle' ? <PlayerWordleApp /> : null}
      </main>

      <div className="t4l-bottom-stack">
        <MiniPlayerBar />
        <AppStrip
          installedApps={HOME_STRIP_DEFAULT_APPS.filter((appId) => installedApps.includes(appId))}
          onOpenApp={openApp}
        />
        <FloatingNavBar
          onHome={() => {
            setSelectedArticle(null);
            setView('home');
          }}
          onGameCenter={() => {
            setSelectedArticle(null);
            if (installedApps.includes('standings')) {
              openApp('standings');
            } else {
              setView('app_store');
            }
          }}
          onHistory={goHistory}
          onSettings={() => {
            setSelectedArticle(null);
            setView('settings');
          }}
        />
      </div>
    </div>
  );
}

export default function App() {
  return (
    <AudioProvider>
      <AppShell />
    </AudioProvider>
  );
}
