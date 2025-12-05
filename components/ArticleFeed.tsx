import React from 'react';
import { SupabaseArticle } from '../types';
import { Calendar, Clock, ArrowRight } from 'lucide-react';

interface ArticleFeedProps {
  articles: SupabaseArticle[];
  onSelect: (article: SupabaseArticle) => void;
  isDarkMode: boolean;
}

const ArticleFeed: React.FC<ArticleFeedProps> = ({ articles, onSelect, isDarkMode }) => {
  return (
    <div className="grid grid-cols-1 md:grid-cols-2 gap-8 animate-in fade-in duration-700">
      {articles.map((article) => (
        <button
          key={article.id}
          onClick={() => onSelect(article)}
          className={`group relative flex flex-col justify-between text-left rounded-2xl overflow-hidden transition-all duration-300 hover:-translate-y-2 min-h-[320px] ${
            isDarkMode 
              ? 'metallic-panel border border-tfl-green-600/30 hover:shadow-[0_0_30px_rgba(34,197,94,0.15)]' 
              : 'metallic-panel-light border border-white hover:shadow-xl'
          }`}
        >
          {/* Background Image with Overlay */}
          <div className="absolute inset-0 z-0">
             <img 
                src={article.hero_image_url} 
                alt={article.title}
                className="absolute inset-0 w-full h-full object-cover transition-transform duration-[10s] ease-linear group-hover:scale-110"
             />
             <div className={`absolute inset-0 ${
               isDarkMode 
                 ? 'bg-gradient-to-t from-tfl-green-950 via-tfl-green-950/80 to-transparent' 
                 : 'bg-gradient-to-t from-white via-white/90 to-transparent'
             }`}></div>
          </div>

          {/* Content */}
          <div className="relative z-10 p-6 md:p-8 flex flex-col h-full justify-between">
            
            {/* Top Meta */}
            <div className="flex justify-between items-start">
               <span className={`px-2 py-1 text-[10px] font-bold tracking-widest uppercase rounded border backdrop-blur-sm ${
                 isDarkMode ? 'bg-black/40 border-tfl-green-500 text-tfl-green-300' : 'bg-white/60 border-tfl-green-600 text-tfl-green-900'
               }`}>
                 DeepDive
               </span>
               <span className={`flex items-center gap-1 text-[10px] font-bold tracking-widest uppercase opacity-80 ${isDarkMode ? 'text-gray-300' : 'text-gray-600'}`}>
                 <Calendar size={10} /> {new Date(article.published_at).toLocaleDateString()}
               </span>
            </div>

            {/* Title Area */}
            <div className="mt-auto">
              <h3 className={`text-2xl font-black mb-2 font-sans leading-tight ${
                 isDarkMode ? 'metallic-text' : 'text-slate-900'
              }`}>
                {article.title}
              </h3>
              <p className={`text-sm font-serif italic mb-6 line-clamp-2 ${
                 isDarkMode ? 'text-gray-300' : 'text-gray-600'
              }`}>
                {article.subtitle}
              </p>

              <div className="flex items-center justify-between pt-4 border-t border-dashed border-current border-opacity-20">
                 <span className={`text-xs font-bold uppercase tracking-wider ${isDarkMode ? 'text-tfl-green-400' : 'text-tfl-green-700'}`}>
                   {article.author}
                 </span>
                 <div className={`p-2 rounded-full transition-colors ${
                   isDarkMode ? 'bg-tfl-green-900/50 group-hover:bg-tfl-green-500 text-white' : 'bg-tfl-green-100 group-hover:bg-tfl-green-500 group-hover:text-white'
                 }`}>
                   <ArrowRight size={16} />
                 </div>
              </div>
            </div>
          </div>
        </button>
      ))}
    </div>
  );
};

export default ArticleFeed;