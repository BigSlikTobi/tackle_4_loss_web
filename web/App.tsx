import React, { useState, useEffect } from 'react';
import TransparentHeader from './components/TransparentHeader';
import Hero from './components/Hero';
import ArticleViewer from './components/ArticleViewer';
import ArticleFeed from './components/ArticleFeed';
import { MOCK_SUPABASE_DATA } from './constants';
import { Article, ArticleSection, SupabaseArticle } from './types';
import { Loader2, ArrowLeft } from 'lucide-react';
import { supabase } from './lib/supabase';
import { AudioProvider } from './context/AudioContext';
import BreakingNewsOverviewModal from './components/BreakingNewsOverviewModal';
import { useBreakingNews } from './hooks/useBreakingNews';
import FloatingNavBar from './components/FloatingNavBar';
import { useTeamTheme } from './hooks/useTeamTheme';
import OSAppGrid from './components/OSAppGrid';
import AppStore from './components/AppStore';
import Settings from './components/Settings';

// --- Helper: Parse Supabase Section Format ---
function parseArticle(supabaseArticle: SupabaseArticle): Article {
  const sections: ArticleSection[] = Object.entries(supabaseArticle.sections || {})
    .sort(([keyA], [keyB]) => keyA.localeCompare(keyB, undefined, { numeric: true }))
    .map(([key, rawText]) => {
      // Raw text format: "## Headline\n### Subheader\n\nContent..."
      const lines = rawText.split('\n');

      // 1. Extract Headline (Starts with ## )
      const headlineLine = lines.find(line => line.startsWith('## '));
      const headline = headlineLine ? headlineLine.replace('## ', '').trim() : 'Section';

      // 2. Extract Content (Everything else, remove ### lines if preferred, or clean them)
      const content = lines
        .filter(line => !line.startsWith('## ')) // Remove headline line
        .map(line => line.startsWith('### ') ? line.replace('### ', '').trim() : line) // Clean subheaders to just text
        .filter(line => line.trim().length > 0); // Remove empty lines

      return {
        id: key,
        headline,
        content
      };
    });

  return {
    id: supabaseArticle.id,
    title: supabaseArticle.title,
    subtitle: supabaseArticle.subtitle,
    author: supabaseArticle.author,
    date: new Date(supabaseArticle.published_at).toLocaleDateString('de-DE', { day: 'numeric', month: 'long', year: 'numeric' }),
    heroImage: supabaseArticle.hero_image_url,
    languageCode: supabaseArticle.language_code,
    audioFile: supabaseArticle.audio_file,
    videoFile: supabaseArticle.video_file,
    sections
  };
}

export default function App() {
  const [articles, setArticles] = useState<SupabaseArticle[]>([]);
  const [loading, setLoading] = useState(true);
  const [selectedLanguage, setSelectedLanguage] = useState<'de' | 'en'>(() => {
    if (typeof window !== 'undefined' && navigator.language) {
      return navigator.language.startsWith('de') ? 'de' : 'en';
    }
    return 'de';
  });

  const [selectedArticle, setSelectedArticle] = useState<Article | null>(null);

  // Initialize Team Theme
  useTeamTheme();

  // Breaking News Logic
  const { news: breakingNews, hasUnread: hasBreakingNewsUnread, markAsRead: markBreakingNewsRead } = useBreakingNews(selectedLanguage);
  const [isBreakingNewsOpen, setIsBreakingNewsOpen] = useState(false);

  useEffect(() => {
    const fetchArticles = async () => {
      setLoading(true); // Ensure loading state is true when refetching
      try {
        const { data, error } = await supabase.functions.invoke('get-latest-deepdive', {
          body: { language_code: selectedLanguage }
        });

        if (error) {
          console.error('Supabase function error:', error);
          throw error;
        }

        if (data) {
          setArticles([data] as SupabaseArticle[]);
        }
      } catch (error) {
        console.error('Failed to fetch articles:', error);
        setArticles(MOCK_SUPABASE_DATA);
      } finally {
        setLoading(false);
      }
    };

    fetchArticles();
  }, [selectedLanguage]); // Add selectedLanguage dependency

  const [view, setView] = useState<'home' | 'app_store' | 'settings'>('home');
  const [lastAppId, setLastAppId] = useState<string>('deep_dives'); // Default to Deep Dives

  // No longer need client-side filtering since we filter on the server
  const filteredArticles = articles;

  const handleSelectArticle = async (rawArticle: SupabaseArticle) => {
    try {
      // Fetch full details including sections
      const { data, error } = await supabase.functions.invoke('get-article-viewer-data', {
        body: { article_id: rawArticle.id }
      });

      if (error) throw error;

      const fullArticle = data as SupabaseArticle;
      const parsed = parseArticle(fullArticle);
      setSelectedArticle(parsed);
      window.scrollTo({ top: 0, behavior: 'smooth' });
    } catch (e) {
      console.error("Error fetching article details", e);
    }
  };

  const handleBackToFeed = () => {
    setSelectedArticle(null);
  };

  // Navigation Handlers
  const goHome = () => {
    setSelectedArticle(null);
    setView('home');
  };

  const goAppStore = () => {
    setSelectedArticle(null);
    setView('app_store');
  };

  const goSettings = () => {
    setSelectedArticle(null);
    setView('settings');
  };

  const customOpenApp = (appId: string) => {
    setLastAppId(appId);
    if (appId === 'breaking_news') {
      setIsBreakingNewsOpen(true);
      markBreakingNewsRead();
      // Stay on current view or go Home? Let's stay.
    } else if (appId === 'radio') {
      // Logic to play radio? For now just log or basic alert
      // Or maybe just ensure audio context is active.
      // But we don't have a specific radio screen yet, so just go Home and play?
      // The prompt says "when selecting the last apps, the last app the user had open opens."
      // If it's radio, maybe it just plays.
      goHome(); // Radio is usually overlay/background.
    } else if (appId === 'deep_dives') {
      goHome(); // Deep dives is basically the home screen hero + list
    }
  };

  const goHistory = () => {
    customOpenApp(lastAppId);
  };

  // App Installation State
  const [installedApps, setInstalledApps] = useState<string[]>(['deep_dives', 'breaking_news', 'radio']);

  const toggleInstallApp = (appId: string) => {
    setInstalledApps(prev => {
      if (prev.includes(appId)) {
        return prev.filter(id => id !== appId);
      } else {
        return [...prev, appId];
      }
    });
  };


  return (
    <AudioProvider>
      <div
        className="min-h-screen flex flex-col transition-colors duration-500 ease-in-out"
        style={{ backgroundColor: 'var(--app-bg)' }}
      >
        <TransparentHeader />

        {/* Watermark - Focused on lower area */}
        <div
          className="fixed bottom-0 left-0 right-0 h-[60vh] pointer-events-none z-0 bg-no-repeat bg-center bg-contain opacity-40 transition-all duration-1000 transform translate-y-12"
          style={{ backgroundImage: 'var(--team-logo-url)' }}
        />

        <BreakingNewsOverviewModal
          isOpen={isBreakingNewsOpen}
          onClose={() => setIsBreakingNewsOpen(false)}
          news={breakingNews}
          languageCode={selectedLanguage}
        />

        {/* Route Content */}
        {/* 1. Article Viewer (Highest Priority if selected) */}
        {selectedArticle ? (
          <main className="flex-1 max-w-7xl mx-auto w-full px-4 sm:px-6 lg:px-8 py-4 z-10">
            <button
              onClick={handleBackToFeed}
              className="mb-4 inline-flex items-center gap-1 text-sm text-zinc-600 hover:text-zinc-900 haptic-light px-2 py-1 rounded-md border border-transparent mt-20"
            >
              <ArrowLeft size={14} /> Back
            </button>
            <div className="mt-4">
              <ArticleViewer
                article={selectedArticle}
                nextArticle={(() => {
                  const currentIndex = filteredArticles.findIndex(a => a.id === selectedArticle.id);
                  if (currentIndex === -1 || currentIndex === filteredArticles.length - 1) return null;
                  const next = filteredArticles[currentIndex + 1];
                  return { id: next.id, headline: next.title, image: next.hero_image_url };
                })()}
                previousArticle={(() => {
                  const currentIndex = filteredArticles.findIndex(a => a.id === selectedArticle.id);
                  if (currentIndex <= 0) return null;
                  const prev = filteredArticles[currentIndex - 1];
                  return { id: prev.id, headline: prev.title, image: prev.hero_image_url };
                })()}
                onNavigate={(id) => {
                  const article = filteredArticles.find(a => a.id === id);
                  if (article) handleSelectArticle(article);
                }}
              />
            </div>
          </main>
        ) : (
          <>
            {/* 2. App Store */}
            {view === 'app_store' && (
              <AppStore
                onOpenApp={customOpenApp}
                installedApps={installedApps}
                onToggleInstall={toggleInstallApp}
              />
            )}

            {/* 3. Settings */}
            {view === 'settings' && (
              <Settings
                selectedLanguage={selectedLanguage}
                onChangeLanguage={setSelectedLanguage}
              />
            )}

            {/* 4. Home (Hero + Grid) */}
            {view === 'home' && (
              <div className="w-full md:max-w-7xl md:mx-auto md:px-8 md:pt-24 z-0 flex flex-col items-center animate-fade-in">
                {!loading && filteredArticles[0] && (
                  <>
                    <Hero article={filteredArticles[0]} onSelect={handleSelectArticle} tag="Deep Dive" />

                    {/* iOS App Grid placed naturally below Hero */}
                    <div className="w-full max-w-md mt-1 z-10">
                      <OSAppGrid
                        onOpenNews={() => {
                          setIsBreakingNewsOpen(true);
                          markBreakingNewsRead();
                          setLastAppId('breaking_news');
                        }}
                        hasUnreadNews={hasBreakingNewsUnread}
                        installedApps={installedApps}
                      />
                    </div>
                  </>
                )}
              </div>
            )}
          </>
        )}


        <FloatingNavBar
          onOpenBreakingNews={() => {
            setIsBreakingNewsOpen(true);
            markBreakingNewsRead();
          }}
          hasUnread={hasBreakingNewsUnread}
          onHome={goHome}
          onAppStore={goAppStore}
          onHistory={goHistory}
          onSettings={goSettings}
        />
      </div>
    </AudioProvider>
  );
}

// Import new components at top (I can't edit top in this chunk, so I must rely on auto-imports or do a separate add. 
// Wait, I can't do auto imports. I must add imports at top first. 
// I will split this into two calls or ensure imports are added. 
// Actually I can just add imports at the top of this file using a replace on top lines first? 
// No, I'll assume I can edit the whole file or do top lines separately. 
// I'll do imports first.)

