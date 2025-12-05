import React, { useState, useRef, useEffect } from 'react';
import { Article } from '../types';
import { ChevronDown, ChevronUp, Clock, Calendar, Hash, ArrowDown, Loader2, Volume2, Square } from 'lucide-react';

interface ArticleViewerProps {
  article: Article;
  isDarkMode: boolean;
}

const ArticleViewer: React.FC<ArticleViewerProps> = ({ article, isDarkMode }) => {
  const [currentSectionIndex, setCurrentSectionIndex] = useState(0);
  const [isTransitioning, setIsTransitioning] = useState(false);

  // Audio State
  const [isPlaying, setIsPlaying] = useState(false);
  const [isAudioReady, setIsAudioReady] = useState(false);
  const audioRef = useRef<HTMLAudioElement | null>(null);

  const contentRef = useRef<HTMLDivElement>(null);

  const currentSection = article.sections[currentSectionIndex];
  const nextSection = article.sections[currentSectionIndex + 1];

  // Preload Audio on Mount
  useEffect(() => {
    if (article.audioFile) {
      console.log("Preloading audio:", article.audioFile);
      const audio = new Audio(article.audioFile);
      // Essential for loading from different origins without "supported sources" error
      audio.crossOrigin = "anonymous";
      audio.preload = "auto";
      
      // Setup listeners
      audio.addEventListener('canplaythrough', () => {
        console.log("Audio ready to play");
        setIsAudioReady(true);
      });
      
      audio.addEventListener('ended', () => {
        setIsPlaying(false);
      });
      
      audio.addEventListener('error', (e) => {
        const error = (e.target as HTMLAudioElement).error;
        console.error("Audio error event:", e);
        console.error("Audio error code:", error?.code);
        console.error("Audio error message:", error?.message);
        setIsAudioReady(false);
        setIsPlaying(false);
      });

      // Start loading
      audio.load();
      audioRef.current = audio;
    }

    // Cleanup on unmount or article change
    return () => {
      if (audioRef.current) {
        audioRef.current.pause();
        audioRef.current = null;
      }
    };
  }, [article.audioFile]);

  const handleToggleAudio = () => {
    if (!audioRef.current || !article.audioFile) {
      console.error("No audio reference or file available");
      return;
    }

    if (isPlaying) {
      audioRef.current.pause();
      setIsPlaying(false);
    } else {
      audioRef.current.play()
        .then(() => setIsPlaying(true))
        .catch(e => {
           console.error("Play execution error:", e);
           // Handle NotAllowedError (Autoplay) specific logic if needed
           alert("Could not play audio. The browser might be blocking it or the source is invalid.");
        });
    }
  };

  const handleNextSection = () => {
    // Optional: Pause audio on navigation if desired. 
    // Currently leaving it playing as requested for "Read Article" mode.
    
    setIsTransitioning(true);
    setTimeout(() => {
      setCurrentSectionIndex((prev) => prev + 1);
      setIsTransitioning(false);
      if (contentRef.current) {
        contentRef.current.scrollIntoView({ behavior: 'smooth', block: 'start' });
      }
    }, 300);
  };

  const handlePrevSection = () => {
    if (currentSectionIndex === 0) return;
    setIsTransitioning(true);
    setTimeout(() => {
      setCurrentSectionIndex((prev) => prev - 1);
      setIsTransitioning(false);
      if (contentRef.current) {
        contentRef.current.scrollIntoView({ behavior: 'smooth', block: 'start' });
      }
    }, 300);
  };

  return (
    <div className="flex flex-col gap-8">
      
      {/* Article Header Card (Static Background) */}
      <div 
        className={`p-6 md:p-8 rounded-2xl transition-all duration-500 relative overflow-hidden group border min-h-[300px] flex flex-col justify-between ${
        isDarkMode ? 'metallic-panel border-tfl-green-600/30' : 'metallic-panel-light border-white'
      }`}>
        
        {/* Static Background Image Layer */}
        <div className="absolute inset-0 z-0">
            {/* Base Image */}
            <img 
                src={article.heroImage} 
                alt={article.title}
                className="absolute inset-0 w-full h-full object-cover transition-transform duration-[20s] ease-linear group-hover:scale-105"
            />
            {/* Overlays for readability - adjusted for better image visibility */}
            <div className={`absolute inset-0 ${
              isDarkMode 
                ? 'bg-gradient-to-t from-tfl-green-950 via-tfl-green-950/70 to-transparent' 
                : 'bg-gradient-to-t from-white via-white/80 to-white/20'
            }`}></div>
            <div className="absolute inset-0 bg-black/10 mix-blend-overlay"></div>
        </div>

        {/* Top Content (Metadata) */}
        <div className="relative z-10 w-full flex flex-wrap items-start justify-between gap-4">
          <span className={`px-2 py-1 text-xs font-bold tracking-widest uppercase rounded border backdrop-blur-sm ${isDarkMode ? 'bg-black/40 border-tfl-green-500 text-tfl-green-300' : 'bg-white/60 border-tfl-green-600 text-tfl-green-900'}`}>
               DeepDive
          </span>
          
          <div className="flex items-center gap-4 text-xs font-bold tracking-widest uppercase opacity-90 backdrop-blur-sm rounded-full px-3 py-1 bg-black/20">
            <span className={`flex items-center gap-1 ${isDarkMode ? 'text-white' : 'text-slate-100'}`}><Calendar size={12} /> {article.date}</span>
            <span className="w-1 h-1 rounded-full bg-white opacity-50 hidden sm:block"></span>
            <span className={`flex items-center gap-1 ${isDarkMode ? 'text-white' : 'text-slate-100'}`}><Clock size={12} /> 15 min read</span>
          </div>
        </div>

        {/* Bottom Content (Title, Subtitle, Author) */}
        <div className="relative z-10 mt-8">
          <h1 className={`text-3xl md:text-5xl font-black mb-2 font-sans leading-tight tracking-tight drop-shadow-lg ${
            isDarkMode ? 'metallic-text' : 'text-slate-900'
          }`}>
            {article.title}
          </h1>
          
          <h2 className={`text-xl md:text-2xl font-serif italic mb-6 leading-relaxed drop-shadow-md ${
            isDarkMode ? 'text-tfl-green-100' : 'text-tfl-green-900'
          }`}>
            {article.subtitle}
          </h2>

          <div className="flex items-center gap-4 pt-4 border-t border-dashed border-current border-opacity-30">
            <div className={`w-10 h-10 rounded-full p-[2px] ${isDarkMode ? 'bg-gradient-to-tr from-tfl-green-500 to-yellow-500' : 'bg-gradient-to-tr from-tfl-green-400 to-tfl-green-600'}`}>
              <div className="w-full h-full rounded-full bg-slate-900 overflow-hidden">
                <img src={`https://api.dicebear.com/7.x/initials/svg?seed=${article.author}`} alt="author" className="w-full h-full" />
              </div>
            </div>
            <div>
              <p className={`text-sm font-bold ${isDarkMode ? 'text-white' : 'text-black'}`}>{article.author}</p>
              <p className={`text-[10px] opacity-80 uppercase tracking-wide font-medium ${isDarkMode ? 'text-gray-300' : 'text-gray-600'}`}>Analysis Team</p>
            </div>
          </div>
        </div>
      </div>

      {/* Main Content Area */}
      <div 
        ref={contentRef}
        className={`transition-all duration-500 min-h-[400px] ${isTransitioning ? 'opacity-0 translate-y-4' : 'opacity-100 translate-y-0'}`}
      >
        <div className="mb-4 flex items-center justify-between">
          <div className="flex items-center gap-3">
            {/* Previous Button */}
            {currentSectionIndex > 0 && (
              <button
                onClick={handlePrevSection}
                className={`mr-2 p-2 rounded-full border shadow-sm transition-all duration-300 group ${
                  isDarkMode 
                    ? 'bg-tfl-green-950 border-tfl-green-800 text-tfl-green-400 hover:border-tfl-green-500 hover:shadow-[0_0_10px_rgba(34,197,94,0.2)]' 
                    : 'bg-white border-tfl-green-200 text-tfl-green-700 hover:border-tfl-green-400'
                }`}
                title="Go back to previous section"
              >
                <ChevronUp size={18} className="transition-transform group-hover:-translate-y-0.5" />
              </button>
            )}

            <div className={`h-8 w-8 rounded-full flex items-center justify-center font-bold text-sm border ${
               isDarkMode ? 'bg-tfl-green-900 border-tfl-green-600 text-tfl-green-300' : 'bg-tfl-green-100 border-tfl-green-300 text-tfl-green-800'
            }`}>
              {currentSectionIndex + 1}
            </div>
            <span className={`text-xs font-bold uppercase tracking-widest ${isDarkMode ? 'text-tfl-green-400' : 'text-tfl-green-700'}`}>
              Section {currentSectionIndex + 1} of {article.sections.length}
            </span>
            <div className={`h-[1px] w-12 ${isDarkMode ? 'bg-tfl-green-900' : 'bg-tfl-green-200'}`}></div>
          </div>

          {/* Audio Controls */}
          {article.audioFile && (
            <button
              onClick={handleToggleAudio}
              className={`flex items-center gap-2 px-3 py-1.5 rounded-full text-xs font-bold uppercase tracking-wider border transition-all ${
                isDarkMode 
                  ? isPlaying 
                    ? 'bg-red-900/30 border-red-800 text-red-400 hover:bg-red-900/50'
                    : 'bg-tfl-green-900/30 border-tfl-green-700 text-tfl-green-400 hover:bg-tfl-green-900/50'
                  : isPlaying
                    ? 'bg-red-100 border-red-200 text-red-600'
                    : 'bg-tfl-green-50 border-tfl-green-200 text-tfl-green-700 hover:bg-tfl-green-100'
              }`}
            >
              {!isAudioReady && isPlaying && <Loader2 size={14} className="animate-spin" />}
              {isPlaying ? (
                <Square size={14} fill="currentColor" />
              ) : (
                <Volume2 size={14} />
              )}
              {isPlaying ? 'Stop Audio' : 'Read Article'}
            </button>
          )}
        </div>

        <h3 className={`text-2xl md:text-4xl font-bold mb-8 font-sans ${
           isDarkMode ? 'text-white drop-shadow-lg' : 'text-slate-900'
        }`}>
           {currentSection.headline}
        </h3>

        <div className={`prose prose-lg md:prose-xl max-w-none ${isDarkMode ? 'prose-invert prose-p:text-gray-300 prose-headings:text-white' : 'prose-p:text-slate-700'}`}>
          {currentSection.content.map((paragraph, idx) => (
            <p key={idx} className="mb-6 leading-relaxed font-serif text-justify md:text-left">
              {paragraph}
            </p>
          ))}
        </div>
      </div>

      {/* Next Section Teaser (Interactive) */}
      {nextSection ? (
        <button
          onClick={handleNextSection}
          className={`group relative w-full text-left p-6 md:p-8 rounded-xl transition-all duration-300 hover:-translate-y-1 hover:shadow-[0_20px_40px_-15px_rgba(0,0,0,0.5)] metallic-button overflow-hidden`}
        >
          {/* Shine effect */}
          <div className="absolute inset-0 bg-gradient-to-r from-transparent via-white/5 to-transparent -translate-x-full group-hover:animate-[shimmer_1.5s_infinite]"></div>
          
          <div className="flex items-center justify-between relative z-10">
            <div className="flex-1 pr-6">
              <span className="flex items-center gap-2 text-xs font-bold uppercase tracking-widest mb-3 text-tfl-green-300 group-hover:text-white transition-colors">
                <ArrowDown size={14} className="animate-bounce" /> Read Next
              </span>
              <h4 className="text-xl md:text-2xl font-bold font-sans text-white group-hover:text-tfl-green-100 transition-colors">
                {nextSection.headline}
              </h4>
            </div>
            <div className="h-12 w-12 rounded-full border-2 border-tfl-green-400/30 flex items-center justify-center text-tfl-green-300 group-hover:bg-tfl-green-400 group-hover:text-black group-hover:border-transparent transition-all duration-300">
              <ChevronDown className="w-6 h-6" />
            </div>
          </div>
        </button>
      ) : (
         <div className={`p-10 rounded-xl text-center border ${
            isDarkMode 
              ? 'bg-tfl-green-950/40 border-tfl-green-900' 
              : 'bg-tfl-green-50 border-tfl-green-200'
         }`}>
           <div className="inline-block p-4 rounded-full bg-tfl-green-500/10 mb-4">
             <Hash className={`w-8 h-8 ${isDarkMode ? 'text-tfl-green-400' : 'text-tfl-green-600'}`} />
           </div>
           <h4 className="text-xl font-bold mb-2">End of DeepDive</h4>
           <p className="opacity-70 max-w-md mx-auto">You've reached the end of this analysis. We hope you enjoyed the read.</p>
           <button 
             onClick={() => {
                setCurrentSectionIndex(0);
                if (contentRef.current) {
                  contentRef.current.scrollIntoView({ behavior: 'smooth', block: 'start' });
                }
             }}
             className="mt-6 px-6 py-2 rounded-full font-bold uppercase tracking-wide text-xs border border-current hover:bg-current hover:text-black transition-colors"
           >
             Read Again
           </button>
         </div>
      )}

      {/* Progress Bar fixed at bottom */}
      <div className={`fixed bottom-0 left-0 w-full h-1 ${isDarkMode ? 'bg-gray-800' : 'bg-gray-200'}`}>
        <div 
           className="h-full bg-tfl-green-500 transition-all duration-500 ease-out"
           style={{ width: `${((currentSectionIndex + 1) / article.sections.length) * 100}%` }}
        />
      </div>
    </div>
  );
};

export default ArticleViewer;