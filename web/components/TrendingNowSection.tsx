import React from 'react';
import { SupabaseArticle } from '../types';

interface TrendingNowSectionProps {
  articles: SupabaseArticle[];
  onSelectArticle: (article: SupabaseArticle) => void;
}

const TrendingNowSection: React.FC<TrendingNowSectionProps> = ({ articles, onSelectArticle }) => {
  if (articles.length === 0) {
    return null;
  }

  return (
    <section className="pb-10">
      <div className="flex items-center justify-between mb-5 px-1">
        <h3 className="text-xl font-bold text-text-main-light dark:text-text-main-dark">Trending Now</h3>
        <a className="text-xs font-bold text-primary dark:text-secondary uppercase tracking-wide" href="#">View all</a>
      </div>
      <div className="flex space-x-5 overflow-x-auto no-scrollbar -mx-6 px-6 pb-6">
        {articles.map((article, index) => (
          <div key={article.id} className="flex-shrink-0 w-72 group cursor-pointer" onClick={() => onSelectArticle(article)}>
            <div className="relative h-40 rounded-2xl overflow-hidden shadow-md mb-3">
              <div className="absolute inset-0 bg-gradient-to-t from-black/80 to-transparent z-10 transition-opacity duration-300 group-hover:opacity-90"></div>
              <img alt={article.title} className="w-full h-full object-cover transform group-hover:scale-105 transition-transform duration-700" src={article.hero_image_url} />
              <span className="absolute top-3 right-3 z-20 bg-white/20 backdrop-blur-md text-white text-[10px] font-bold px-2.5 py-1 rounded-full border border-white/10">
                ANALYSIS
              </span>
              <div className="absolute bottom-3 left-3 z-20">
                <p className="text-white font-bold text-lg leading-tight group-hover:text-secondary transition-colors">{article.title}</p>
              </div>
            </div>
            <div className="flex items-center justify-between px-1">
              <span className="text-xs font-medium text-text-sub-light dark:text-text-sub-dark flex items-center">
                <span className="material-symbols-outlined text-[14px] mr-1">schedule</span> {Math.ceil(Math.random() * 5 + 2)} min read
              </span>
              <span className="text-xs font-bold text-primary dark:text-secondary">#{index + 1} Trending</span>
            </div>
          </div>
        ))}
      </div>
    </section>
  );
};

export default TrendingNowSection;
