import React from 'react';

interface HeaderProps {
  selectedLanguage: 'de' | 'en';
  onChangeLanguage: (lang: 'de' | 'en') => void;
  onOpenBreakingNews: () => void;
  hasUnread: boolean;
}

const Header: React.FC<HeaderProps> = ({ selectedLanguage, onChangeLanguage, onOpenBreakingNews, hasUnread }) => {
  return (
    <header className="sticky top-0 z-50 bg-white/90 backdrop-blur-xl border-b border-gray-200 py-2">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex items-center justify-between h-16">
          {/* Logo */}
          <div className="flex items-center gap-3">
            <div className="w-11 h-11 rounded-xl overflow-hidden shadow-sm bg-[#0d2119] flex items-center justify-center">
              <img
                src="/T4L_app_logo.png"
                alt="Tackle4Loss logo"
                className="w-full h-full object-cover"
              />
            </div>
          </div>

          {/* Controls */}
          <div className="flex items-center gap-3">
            {/* Breaking News Button - DD Style */}
            <button
              onClick={onOpenBreakingNews}
              className="relative w-11 h-11 flex items-center justify-center rounded-xl bg-white border-[1.5px] border-[#0f3d2e]/35 shadow-[0_10px_24px_rgba(15,61,46,0.12),0_2px_6px_rgba(0,0,0,0.05)] text-[#0f3d2e] font-extrabold text-lg tracking-wider hover:-translate-y-0.5 hover:shadow-[0_14px_30px_rgba(15,61,46,0.16),0_3px_8px_rgba(0,0,0,0.06)] active:scale-95 transition-all duration-200"
              aria-label="Breaking News"
            >
              B
              {hasUnread && (
                <span className="absolute -top-1 -right-1 flex h-3 w-3">
                  <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-red-400 opacity-75"></span>
                  <span className="relative inline-flex rounded-full h-3 w-3 bg-red-500 border border-white"></span>
                </span>
              )}
            </button>

            {/* Language Selector */}
            <div className="flex items-center gap-2 bg-white rounded-xl p-1 border border-gray-200 shadow-sm h-11">
              {(['de', 'en'] as const).map((lang) => (
                <button
                  key={lang}
                  onClick={() => onChangeLanguage(lang)}
                  className={`haptic-light px-4 h-full rounded-lg text-sm font-semibold uppercase tracking-wide transition-all flex items-center justify-center ${selectedLanguage === lang
                    ? 'bg-[var(--brand)] text-white shadow-sm'
                    : 'text-zinc-600 hover:text-zinc-900 hover:bg-gray-100'
                    }`}
                >
                  {lang}
                </button>
              ))}
            </div>
          </div>
        </div>
      </div>
    </header>
  );
};

export default Header;
