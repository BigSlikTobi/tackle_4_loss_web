import React from 'react';

interface HeaderProps {
  selectedLanguage: 'de' | 'en';
  onChangeLanguage: (lang: 'de' | 'en') => void;
}

const Header: React.FC<HeaderProps> = ({ selectedLanguage, onChangeLanguage }) => {
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

          {/* Language Selector */}
          <div className="flex items-center gap-2 bg-white rounded-xl p-1 border border-gray-200 shadow-sm">
            {(['de', 'en'] as const).map((lang) => (
              <button
                key={lang}
                onClick={() => onChangeLanguage(lang)}
                className={`haptic-light px-4 py-2 rounded-lg text-sm font-semibold uppercase tracking-wide transition-all ${selectedLanguage === lang
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
    </header>
  );
};

export default Header;
