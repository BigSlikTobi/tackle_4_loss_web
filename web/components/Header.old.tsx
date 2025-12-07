import React from 'react';
import { Menu, Sun, Moon } from 'lucide-react';

interface HeaderProps {
  isDarkMode: boolean;
  toggleTheme: () => void;
}

const Header: React.FC<HeaderProps> = ({ isDarkMode, toggleTheme }) => {
  return (
    <header className={`sticky top-0 z-50 backdrop-blur-md border-b transition-colors duration-500 ${
      isDarkMode 
        ? 'bg-tfl-green-950/80 border-tfl-green-800/50' 
        : 'bg-white/90 border-gray-200'
    }`}>
      <div className="container mx-auto px-4 h-16 flex items-center justify-between">
        
        {/* Logo Area */}
        <div className="flex items-center gap-3 group cursor-pointer">
          {/* Custom T4L Logo */}
          <div className="relative w-10 h-10 rounded-xl overflow-hidden shadow-lg transition-transform duration-300 group-hover:scale-105 group-hover:shadow-tfl-green-500/30">
            <div className={`absolute inset-0 ${isDarkMode ? 'bg-[#14532d]' : 'bg-[#14532d]'}`}></div>
            <div className="absolute inset-0 bg-gradient-to-br from-white/20 to-transparent pointer-events-none"></div>
            <div className="absolute inset-0 flex items-center justify-center">
               <span className="font-sans font-[900] italic text-white text-xl tracking-tighter leading-none select-none pt-1 pr-0.5" style={{ textShadow: '0 2px 4px rgba(0,0,0,0.3)' }}>
                 T4L
               </span>
            </div>
          </div>

          <div className="flex flex-col">
            <h1 className={`text-xl font-black uppercase tracking-wider font-sans leading-none ${isDarkMode ? 'metallic-text' : 'text-slate-800'}`}>
              Tackle4Loss
            </h1>
            <span className={`text-[0.65rem] tracking-[0.3em] font-bold ${isDarkMode ? 'metallic-text-gold' : 'text-tfl-green-600'}`}>
              DEEPDIVES
            </span>
          </div>
        </div>

        {/* Controls */}
        <div className="flex items-center gap-4">
          <button 
            onClick={toggleTheme}
            className={`p-2 rounded-full transition-all duration-300 ${
              isDarkMode 
                ? 'bg-tfl-green-900/50 text-yellow-400 hover:bg-tfl-green-800' 
                : 'bg-gray-100 text-slate-600 hover:bg-gray-200'
            }`}
            aria-label="Toggle Theme"
          >
            {isDarkMode ? <Sun size={20} /> : <Moon size={20} />}
          </button>
          
          <button className={`md:hidden p-2 ${isDarkMode ? 'text-white' : 'text-slate-900'}`}>
            <Menu size={24} />
          </button>
        </div>
      </div>
    </header>
  );
};

export default Header;