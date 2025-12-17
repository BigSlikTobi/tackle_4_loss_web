import React, { useState, useEffect } from 'react';
import Header from './components/Header';
import HeroSection from './components/HeroSection';
import LiveOnAirBanner from './components/LiveOnAirBanner';
import PickedForYouSection from './components/PickedForYouSection';
import TrendingNowSection from './components/TrendingNowSection';
import BottomNavigation from './components/BottomNavigation';
import ArticleViewer from './components/ArticleViewer';
import { supabase } from './lib/supabase';
import { Article, ArticleSection, SupabaseArticle } from './types';
import { Loader2 } from 'lucide-react';
import { MOCK_SUPABASE_DATA } from './constants';

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
  const [selectedArticle, setSelectedArticle] = useState<Article | null>(null);

  useEffect(() => {
    const fetchArticles = async () => {
      setLoading(true);
      try {
        const { data, error } = await supabase.functions.invoke('get-latest-deepdive');

        if (error || !data) {
          console.error('Supabase function error:', error);
          setArticles(MOCK_SUPABASE_DATA);
        } else {
          setArticles(data as SupabaseArticle[]);
        }
      } catch (error) {
        console.error('Failed to fetch articles:', error);
        setArticles(MOCK_SUPABASE_DATA);
      } finally {
        setLoading(false);
      }
    };

    fetchArticles();
  }, []);

  const handleSelectArticle = async (rawArticle: SupabaseArticle) => {
    try {
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
      const parsed = parseArticle(rawArticle);
      setSelectedArticle(parsed);
    }
  };

  const handleBackToFeed = () => {
    setSelectedArticle(null);
  };

  if (loading) {
    return (
      <div className="bg-background-light dark:bg-background-dark min-h-screen flex items-center justify-center">
        <Loader2 className="w-12 h-12 animate-spin text-primary" />
      </div>
    );
  }

  if (selectedArticle) {
    return <ArticleViewer article={selectedArticle} onBack={handleBackToFeed} />;
  }

  return (
    <div className="bg-background-light dark:bg-background-dark font-sans antialiased text-text-main-light dark:text-text-main-dark min-h-screen pb-24 selection:bg-secondary selection:text-primary">
      <Header />
      <HeroSection article={articles[0]} onReadMore={() => articles[0] && handleSelectArticle(articles[0])} />
      <main className="relative z-20 -mt-10 bg-background-light dark:bg-background-dark rounded-t-3xl min-h-[500px] shadow-[0_-10px_40px_-10px_rgba(0,0,0,0.3)] border-t border-white/50 dark:border-white/5">
        <div className="w-full flex justify-center pt-3 pb-1">
          <div className="w-12 h-1.5 bg-gray-300 dark:bg-gray-700 rounded-full opacity-50"></div>
        </div>
        <div className="px-6 py-6 space-y-10">
          <LiveOnAirBanner />
          <PickedForYouSection />
          <TrendingNowSection articles={articles.slice(1)} onSelectArticle={handleSelectArticle} />
        </div>
      </main>
      <BottomNavigation />
    </div>
  );
}
