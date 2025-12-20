
import React from 'react';
import { SupabaseArticle } from '../types';
import { BadgeCheck } from 'lucide-react';

interface HeroProps {
    article: SupabaseArticle;
    tag?: string;
    onSelect: (article: SupabaseArticle) => void;
}

const Hero: React.FC<HeroProps> = ({ article, onSelect, tag }) => {


    return (
        <div
            onClick={() => onSelect(article)}
            className="relative w-full h-[65vh] overflow-hidden group cursor-pointer bg-primary z-0 md:rounded-2xl"
            style={{
                maskImage: 'linear-gradient(to top, transparent, black 10%)',
                WebkitMaskImage: 'linear-gradient(to top, transparent, black 10%)'
            }}
        >
            {/* Background Image & Overlay */}
            <div className="absolute inset-0">
                <img
                    alt={article.title}
                    className="w-full h-full object-cover transition-transform duration-700 group-hover:scale-105"
                    src={article.hero_image_url}
                />
                <div
                    className="absolute inset-0"
                    style={{ background: 'linear-gradient(to top, var(--brand) 0%, color-mix(in srgb, var(--brand), transparent 60%) 50%, rgba(0,0,0,0.3) 100%)' }}
                ></div>
            </div>

            {/* Content */}
            <div className="absolute bottom-16 left-0 w-full px-6 z-10">

                {/* Tag / CTA */}
                <div
                    className="inline-flex items-center space-x-2 bg-[#C9A256] backdrop-blur-sm px-3 py-1 rounded-full mb-4 shadow-lg animate-emotional-pulse cursor-pointer hover:bg-[#b08d4b] transition-colors"
                    style={{ animationDelay: '0.1s' }}
                >
                    <BadgeCheck className="text-[#0f3d2e] w-[16px] h-[16px]" fill="currentColor" size={16} />
                    <span className="text-[10px] font-bold text-[#0f3d2e] tracking-wider uppercase">{tag || 'Deep Dive'}</span>
                </div>

                {/* Title */}
                <h1
                    className="text-4xl md:text-5xl font-['Anton'] !text-white leading-[0.95] tracking-tight mb-3 uppercase italic drop-shadow-md animate-fade-in"
                    style={{ animationDelay: '0.2s' }}
                >
                    {article.title}
                </h1>

                {/* Subtitle */}
                <p
                    className="!text-gray-200 text-sm font-medium max-w-xs leading-relaxed line-clamp-2 animate-fade-in"
                    style={{ animationDelay: '0.3s' }}
                >
                    {article.subtitle}
                </p>

                {/* Buttons - Removed */}

            </div>
        </div>
    );
};


export default Hero;
