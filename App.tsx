import React, { useState, useEffect } from 'react';
import Header from './components/Header';
import ArticleViewer from './components/ArticleViewer';
import ArticleFeed from './components/ArticleFeed';
import { MOCK_SUPABASE_DATA } from './constants';
import { Article, ArticleSection, SupabaseArticle } from './types';
import { Loader2, ArrowLeft } from 'lucide-react';

// --- Helper: Parse Supabase Section Format ---
function parseArticle(supabaseArticle: SupabaseArticle): Article {
  const sections: ArticleSection[] = Object.entries(supabaseArticle.sections)
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
    audioFile: supabaseArticle.audio_file,
    sections
  };
}

export default function App() {
  const [isDarkMode, setIsDarkMode] = useState(true);
  const [articles, setArticles] = useState<SupabaseArticle[]>([]);
  const [loading, setLoading] = useState(true);
  const [selectedLanguage, setSelectedLanguage] = useState<string>('de');
  const [selectedArticle, setSelectedArticle] = useState<Article | null>(null);

  useEffect(() => {
    if (isDarkMode) {
      document.documentElement.classList.add('dark');
    } else {
      document.documentElement.classList.remove('dark');
    }
  }, [isDarkMode]);

  const toggleTheme = () => setIsDarkMode(!isDarkMode);

  // --- Fetch Logic ---
  useEffect(() => {
    const fetchArticles = async () => {
      setLoading(true);
      try {
        const apiKey = process.env.SUPABASE_KEY; // Use Anon Key
        
        if (!apiKey) {
           console.warn("No Supabase Key provided. Using Mock Data.");
           setArticles(MOCK_SUPABASE_DATA);
           setLoading(false);
           return;
        }

        // Note: Table name from prompt is 'deepdive_artilce' (sic)
        // Added mode: 'cors' as per best practices, though fetch defaults to it usually
        const response = await fetch('https://yqtiuzhedkfacwgormhn.supabase.co/rest/v1/deepdive_artilce?select=*&order=created_at.desc', {
          mode: 'cors',
          headers: {
            'apikey': apiKey,
            'Authorization': `Bearer ${apiKey}`,
            'Accept-Profile': 'content'
          }
        });

        if (!response.ok) {
          throw new Error('Network response was not ok');
        }

        const data: SupabaseArticle[] = await response.json();
        setArticles(data);
      } catch (error) {
        console.error("Failed to fetch articles:", error);
        // Fallback to mock data on error so the app is viewable
        setArticles(MOCK_SUPABASE_DATA);
      } finally {
        setLoading(false);
      }
    };

    fetchArticles();
  }, []);

  // Filter articles based on language
  const filteredArticles = articles.filter(a => a.language_code === selectedLanguage);

  const handleSelectArticle = (rawArticle: SupabaseArticle) => {
    const parsed = parseArticle(rawArticle);
    setSelectedArticle(parsed);
    window.scrollTo({ top: 0, behavior: 'smooth' });
  };

  const handleBackToFeed = () => {
    setSelectedArticle(null);
  };

  return (
    <div className={`min-h-screen transition-colors duration-500 ${isDarkMode ? 'bg-gradient-to-b from-tfl-green-950 via-gray-950 to-black text-slate-100' : 'bg-gradient-to-b from-gray-100 to-gray-200 text-slate-900'}`}>
      <Header isDarkMode={isDarkMode} toggleTheme={toggleTheme} />
      
      <main className="container mx-auto px-4 py-8 max-w-5xl">
        
        {/* Navigation / Language Bar */}
        {!selectedArticle && (
          <div className="flex justify-end mb-8">
            <div className={`flex items-center gap-1 p-1 rounded-full border ${isDarkMode ? 'bg-black/30 border-tfl-green-800' : 'bg-white border-gray-300'}`}>
              {['de', 'en'].map((lang) => (
                <button
                  key={lang}
                  onClick={() => setSelectedLanguage(lang)}
                  className={`px-4 py-1 rounded-full text-xs font-bold uppercase transition-all duration-300 ${
                    selectedLanguage === lang
                      ? 'bg-tfl-green-600 text-white shadow-lg'
                      : isDarkMode ? 'text-gray-400 hover:text-white' : 'text-gray-500 hover:text-black'
                  }`}
                >
                  {lang.toUpperCase()}
                </button>
              ))}
            </div>
          </div>
        )}

        {/* Back Button (If Reading) */}
        {selectedArticle && (
           <button 
             onClick={handleBackToFeed}
             className={`mb-6 flex items-center gap-2 text-sm font-bold uppercase tracking-wider transition-colors ${
               isDarkMode ? 'text-tfl-green-400 hover:text-tfl-green-300' : 'text-tfl-green-700 hover:text-tfl-green-900'
             }`}
           >
             <ArrowLeft size={16} /> Back to Feed
           </button>
        )}

        {/* Content Area */}
        {loading ? (
          <div className="h-[50vh] flex flex-col items-center justify-center gap-4">
             <Loader2 className="w-8 h-8 animate-spin text-tfl-green-500" />
             <p className="text-sm uppercase tracking-widest opacity-60">Loading DeepDives...</p>
          </div>
        ) : selectedArticle ? (
          <ArticleViewer article={selectedArticle} isDarkMode={isDarkMode} />
        ) : (
          <>
            {filteredArticles.length === 0 ? (
               <div className="text-center py-20 opacity-50">
                 <p>No articles found for the selected language.</p>
               </div>
            ) : (
               <ArticleFeed 
                  articles={filteredArticles} 
                  onSelect={handleSelectArticle} 
                  isDarkMode={isDarkMode} 
               />
            )}
          </>
        )}
      </main>

      <footer className="py-8 text-center text-sm opacity-60">
        <p>&copy; {new Date().getFullYear()} Tackle4Loss DeepDives. All Rights Reserved.</p>
      </footer>
    </div>
  );
}