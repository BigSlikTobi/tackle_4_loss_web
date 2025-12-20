import React from 'react';

import { SupabaseArticle } from '../types';
import { Calendar, ChevronRight, Headphones } from 'lucide-react';
import { useAudio } from '../context/AudioContext';

interface ArticleFeedProps {
  articles: SupabaseArticle[];
  onSelect: (article: SupabaseArticle) => void;
  selectedLanguage: string;
}

const DeepDiveGlyph = () => (
  <div className="deep-dive-glyph" aria-hidden="true">
    <span className="deep-dive-glyph-text">DD</span>
  </div>
);

const ArticleFeed: React.FC<ArticleFeedProps> = ({ articles, onSelect, selectedLanguage }) => {
  const { play } = useAudio();

  return (
    <div className="space-y-6">


      {/* Grid of Articles */}
      <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-4">
        {articles.map((article, index) => (
          <article
            key={article.id}
            onClick={() => onSelect(article)}
            className="card-minimal deep-dive-card cursor-pointer group fade-in overflow-hidden relative micro-press"
            style={{ animationDelay: `${index * 50}ms` }}
          >
            <DeepDiveGlyph />
            {/* Image */}
            <div className="deep-dive-media relative h-44 overflow-hidden rounded-xl mb-2">
              <img
                src={article.hero_image_url}
                alt={article.title}
                className="deep-dive-image w-full h-full object-cover transition-transform duration-500 group-hover:scale-105"
              />
            </div>

            {/* Content */}
            <div className="space-y-1">
              <div className="deep-dive-meta flex items-center gap-2 text-zinc-500">
                <Calendar className="w-3.5 h-3.5" />
                <span>{new Date(article.published_at).toLocaleDateString('en-US', { month: 'short', day: 'numeric' })}</span>
              </div>

              <h3 className="deep-dive-title-sm text-zinc-900 group-hover:text-[var(--brand)] transition-colors">
                {article.title}
              </h3>

              <p className="deep-dive-subtitle-sm text-zinc-700 line-clamp-2">
                {article.subtitle}
              </p>

              <div className="flex items-center justify-between pt-3 border-t border-current border-opacity-10">
                <span className="text-xs font-subheadline font-bold uppercase">
                  {article.author}
                </span>
                <ChevronRight size={16} className="opacity-50" />
              </div>
            </div>
          </article>
        ))}
      </div>

      {/* Breaking News Section - MOVED TO GLOBAL CHIP */}
    </div>
  );
};

export default ArticleFeed;
