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
      {/* Featured Article */}
      {articles[0] && (
        <article
          onClick={() => onSelect(articles[0])}
          className="card-elevated deep-dive-card cursor-pointer group overflow-hidden fade-in relative micro-press"
        >
          <DeepDiveGlyph />
          <div className="grid md:grid-cols-5 gap-6">
            {/* Image */}
            <div className="md:col-span-2">
              <div className="deep-dive-media relative h-60 md:h-72 rounded-xl">
                <img
                  src={articles[0].hero_image_url}
                  alt={articles[0].title}
                  className="deep-dive-image w-full h-full object-cover transition-transform duration-500 group-hover:scale-105"
                />
              </div>
            </div>

            {/* Content */}
            <div className="md:col-span-3 flex flex-col justify-between py-2 space-y-4">
              <div className="space-y-1">
                <div className="deep-dive-meta flex items-center gap-3 text-zinc-500">
                  <Calendar className="w-4 h-4" />
                  <span>{new Date(articles[0].published_at).toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' })}</span>
                  <span className="text-zinc-300">•</span>
                  <span>{articles[0].author}</span>
                </div>

                <h2 className="deep-dive-title text-zinc-900">
                  {articles[0].title}
                </h2>

                <p className="deep-dive-subtitle text-zinc-700">
                  {articles[0].subtitle}
                </p>
              </div>

              <div className="flex items-center gap-4 pt-2">
                <div className="read-link micro-press">
                  <span>Read</span>
                  <ChevronRight className="w-4 h-4" />
                </div>

                {articles[0].audio_file && (
                  <button
                    onClick={(e) => {
                      e.stopPropagation();
                      if (articles[0].audio_file) {
                        play(articles[0].audio_file, articles[0].title);
                      }
                    }}
                    className="flex items-center gap-2 bg-zinc-100 hover:bg-zinc-200 text-zinc-700 px-3 py-1.5 rounded-full text-sm font-medium transition-colors"
                  >
                    <Headphones className="w-4 h-4" />
                    <span>Listen</span>
                  </button>
                )}
              </div>
            </div>
          </div>
        </article>
      )}

      {/* Grid of Articles */}
      <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-4">
        {articles.slice(1).map((article, index) => (
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
