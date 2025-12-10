import React, { useState, useEffect } from 'react';
import Header from './components/Header';
import ArticleViewer from './components/ArticleViewer';
import ArticleFeed from './components/ArticleFeed';
import { MOCK_SUPABASE_DATA } from './constants';
import { Article, ArticleSection, SupabaseArticle } from './types';
import { Loader2, ArrowLeft } from 'lucide-react';
import { supabase } from './lib/supabase';

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
  const [selectedLanguage, setSelectedLanguage] = useState<'de' | 'en'>('de');
  const [selectedArticle, setSelectedArticle] = useState<Article | null>(null);

  useEffect(() => {
    const fetchArticles = async () => {
      setLoading(true); // Ensure loading state is true when refetching
      try {
        const { data, error } = await supabase.functions.invoke('get-all-deepdives', {
          body: { language_code: selectedLanguage }
        });

        if (error) {
          console.error('Supabase function error:', error);
          throw error;
        }

        if (data) {
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
  }, [selectedLanguage]); // Add selectedLanguage dependency

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
      // Fallback or show error? For now, try to parse what we have if possible, or do nothing.
      // If sections are missing, parseArticle might fail if not updated to handle optional sections.
    }
  };

  const handleBackToFeed = () => {
    setSelectedArticle(null);
  };

  return (
    <div className="min-h-screen flex flex-col bg-gray-50">
      <Header
        selectedLanguage={selectedLanguage}
        onChangeLanguage={(lang) => setSelectedLanguage(lang)}
      />

      <main className="flex-1 max-w-7xl mx-auto w-full px-4 sm:px-6 lg:px-8 py-4">

        {/* Back Button (If Reading) */}
        {selectedArticle && (
          <button
            onClick={handleBackToFeed}
            className="mb-4 inline-flex items-center gap-1 text-sm text-zinc-600 hover:text-zinc-900 haptic-light px-2 py-1 rounded-md border border-transparent"
          >
            <ArrowLeft size={14} /> Back
          </button>
        )}

        {/* Content Area */}
        {loading ? (
          <div className="h-[50vh] flex flex-col items-center justify-center gap-4 fade-in">
            <Loader2 className="w-12 h-12 animate-spin text-[var(--brand)]" />
            <p className="text-sm font-medium text-zinc-500">Loading</p>
          </div>
        ) : selectedArticle ? (
          <ArticleViewer
            article={selectedArticle}
          />
        ) : (
          <>
            {filteredArticles.length === 0 ? (
              <div className="text-center py-20 fade-in">
                <div className="w-16 h-16 bg-gray-100 rounded-2xl flex items-center justify-center mx-auto mb-4">
                  <span className="text-3xl">🔍</span>
                </div>
                <p className="text-lg font-semibold text-zinc-900 mb-2">No articles</p>
                <p className="text-sm text-zinc-500">Check later</p>
              </div>
            ) : (
              <ArticleFeed
                articles={filteredArticles}
                onSelect={handleSelectArticle}
                selectedLanguage={selectedLanguage}
              />
            )}
          </>
        )}
      </main>

      {/* Transitional video overlay removed; inline hero handles video playback */}

      <footer className="py-8 border-t border-gray-200">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
          <p className="text-sm text-zinc-500">
            &copy; {new Date().getFullYear()} Tackle4Loss. All rights reserved.
          </p>
        </div>
      </footer>
    </div>
  );
}
