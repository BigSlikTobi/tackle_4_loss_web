import React from 'react';
import { SupabaseArticle } from '../types';

interface HeroSectionProps {
  article: SupabaseArticle | undefined;
  onReadMore: () => void;
}

const HeroSection: React.FC<HeroSectionProps> = ({ article, onReadMore }) => {
  if (!article) {
    return (
      <div className="relative w-full h-[65vh] overflow-hidden bg-primary animate-pulse"></div>
    );
  }

  return (
    <div className="relative w-full h-[65vh] overflow-hidden">
      <div className="absolute inset-0 bg-primary">
        <img
          alt={article.title}
          className="w-full h-full object-cover opacity-90 mix-blend-overlay"
          src={article.hero_image_url}
        />
        <div className="absolute inset-0 bg-gradient-to-t from-primary via-primary/40 to-black/30"></div>
      </div>
      <div className="absolute bottom-16 left-0 w-full px-6 z-10">
        <div className="inline-flex items-center space-x-2 bg-secondary/90 backdrop-blur-sm px-3 py-1 rounded-full mb-4 shadow-lg animate-fade-in" style={{ animationDelay: '0.1s' }}>
          <span className="material-symbols-outlined text-primary text-[16px]">verified</span>
          <span className="text-[10px] font-bold text-primary tracking-wider uppercase">Deep Dive</span>
        </div>
        <h1 className="text-4xl md:text-5xl font-black text-white leading-[0.95] tracking-tight mb-3 uppercase italic text-shadow animate-fade-in" style={{ animationDelay: '0.2s' }}>
          {article.title}
        </h1>
        <p className="text-gray-200 text-sm font-medium max-w-xs leading-relaxed mb-6 line-clamp-2 animate-fade-in" style={{ animationDelay: '0.3s' }}>
          {article.subtitle}
        </p>
        <div className="flex items-center space-x-4 animate-fade-in" style={{ animationDelay: '0.4s' }}>
          <button onClick={onReadMore} className="bg-white text-primary px-6 py-3 rounded-xl font-bold text-sm shadow-xl flex items-center group active:scale-95 transition-transform">
            <span className="material-symbols-outlined text-[20px] mr-2 group-hover:rotate-12 transition-transform">play_circle</span>
            Listen Now
          </button>
          <button className="h-11 w-11 bg-white/10 backdrop-blur-md rounded-xl flex items-center justify-center text-white border border-white/20 active:scale-95 transition-transform">
            <span className="material-symbols-outlined text-[20px]">bookmark_border</span>
          </button>
        </div>
      </div>
    </div>
  );
};

export default HeroSection;
