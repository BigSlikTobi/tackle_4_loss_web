import React, { useState, useRef, useEffect } from 'react';
import { Article } from '../types';
import { Check, Volume2, Square, Loader2, ChevronLeft, ChevronRight } from 'lucide-react';

interface ArticleViewerProps {
  article: Article;
  onHeroReady?: (el: HTMLDivElement | null) => void;
}

const ArticleViewer: React.FC<ArticleViewerProps> = ({ article, onHeroReady }) => {
  const [currentSectionIndex, setCurrentSectionIndex] = useState(0);
  const [sectionScrollProgress, setSectionScrollProgress] = useState(0);
  const [showCheckmark, setShowCheckmark] = useState(false);
  const [showVideo, setShowVideo] = useState(!!article.videoFile);
  const [videoReady, setVideoReady] = useState(false);
  const [isAudioReady, setIsAudioReady] = useState(false);
  const [isPlaying, setIsPlaying] = useState(false);
  const heroRef = useRef<HTMLDivElement>(null);
  const contentRef = useRef<HTMLDivElement>(null);
  const sectionRef = useRef<HTMLDivElement>(null);
  const videoRef = useRef<HTMLVideoElement | null>(null);
  const audioRef = useRef<HTMLAudioElement | null>(null);

  // Track scroll progress within current section
  useEffect(() => {
    const handleScroll = () => {
      if (!sectionRef.current) return;

      const rect = sectionRef.current.getBoundingClientRect();
      const sectionTop = rect.top;
      const sectionHeight = rect.height;
      const windowHeight = window.innerHeight;

      // Calculate how much of the section has been scrolled through
      const scrolled = Math.max(0, windowHeight - sectionTop);
      const progress = Math.min((scrolled / sectionHeight) * 100, 100);
      setSectionScrollProgress(progress);
    };

    window.addEventListener('scroll', handleScroll);
    handleScroll(); // Initial calculation
    return () => window.removeEventListener('scroll', handleScroll);
  }, [currentSectionIndex]);

  // Expose hero media element to parent for transitions
  useEffect(() => {
    if (onHeroReady) onHeroReady(heroRef.current);
    return () => {
      if (onHeroReady) onHeroReady(null);
    };
  }, [onHeroReady]);

  // Preload audio for read-aloud
  useEffect(() => {
    if (article.audioFile) {
      const audio = new Audio(article.audioFile);
      audio.crossOrigin = 'anonymous';
      audio.preload = 'auto';

      const handleReady = () => setIsAudioReady(true);
      const handleEnded = () => setIsPlaying(false);
      const handleError = () => {
        setIsAudioReady(false);
        setIsPlaying(false);
      };

      audio.addEventListener('canplaythrough', handleReady);
      audio.addEventListener('ended', handleEnded);
      audio.addEventListener('error', handleError);
      audio.load();

      audioRef.current = audio;

      return () => {
        audio.pause();
        audio.removeEventListener('canplaythrough', handleReady);
        audio.removeEventListener('ended', handleEnded);
        audio.removeEventListener('error', handleError);
        audioRef.current = null;
        setIsPlaying(false);
        setIsAudioReady(false);
      };
    }

    return () => {
      if (audioRef.current) {
        audioRef.current.pause();
        audioRef.current = null;
      }
      setIsPlaying(false);
      setIsAudioReady(false);
    };
  }, [article.audioFile]);

  const handleNextSection = () => {
    if (currentSectionIndex < article.sections.length - 1) {
      setCurrentSectionIndex(prev => prev + 1);
      setSectionScrollProgress(0);
      window.scrollTo({ top: 0, behavior: 'smooth' });
      triggerSectionComplete();
    }
  };

  const handlePreviousSection = () => {
    if (currentSectionIndex > 0) {
      setCurrentSectionIndex(prev => prev - 1);
      setSectionScrollProgress(0);
      window.scrollTo({ top: 0, behavior: 'smooth' });
    }
  };

  const handleToggleAudio = () => {
    if (!audioRef.current || !article.audioFile) return;

    if (isPlaying) {
      audioRef.current.pause();
      setIsPlaying(false);
    } else {
      audioRef.current
        .play()
        .then(() => setIsPlaying(true))
        .catch(() => {
          setIsPlaying(false);
          setIsAudioReady(false);
        });
    }
  };

  const triggerSectionComplete = () => {
    setShowCheckmark(true);
    // Haptic feedback (if supported)
    if ('vibrate' in navigator) {
      navigator.vibrate(50);
    }
    setTimeout(() => setShowCheckmark(false), 1000);
  };

  useEffect(() => {
    setShowVideo(!!article.videoFile);
    setVideoReady(false);
  }, [article.id, article.videoFile]);

  // Ensure hero video autoplays; fall back to image if blocked or fails
  useEffect(() => {
    if (!showVideo || !videoRef.current) return;
    const video = videoRef.current;
    video.muted = true;
    video.playsInline = true;
    const playPromise = video.play();
    if (playPromise) {
      playPromise.catch(() => setShowVideo(false));
    }
  }, [article.id, showVideo]);

  // Reset scroll/section on article change
  useEffect(() => {
    setCurrentSectionIndex(0);
    setSectionScrollProgress(0);
  }, [article.id]);

  const currentSection = article.sections[currentSectionIndex];
  const isLastSection = currentSectionIndex === article.sections.length - 1;
  const isFirstSection = currentSectionIndex === 0;
  const totalSections = article.sections.length;
  const sectionProgressPercent = Math.round(((currentSectionIndex + 1) / totalSections) * 100);

  return (
    <div ref={contentRef} className="relative min-h-screen detail-transition">
      {/* Floating audio control */}
      {article.audioFile && (
        <button
          onClick={handleToggleAudio}
          className={`fixed bottom-4 right-4 z-40 flex items-center gap-2 px-3 py-1.5 rounded-full text-[11px] font-semibold uppercase tracking-wide shadow-sm border transition-colors backdrop-blur-sm ${
            isPlaying
              ? 'bg-red-500 text-white border-red-600 hover:bg-red-600'
              : 'bg-white/90 text-zinc-800 border-zinc-200 hover:bg-white'
          }`}
          title={isPlaying ? 'Stop audio' : 'Play audio'}
        >
          {isPlaying ? <Square className="w-3.5 h-3.5" /> : <Volume2 className="w-3.5 h-3.5" />}
          {isPlaying ? 'Stop' : 'Audio'}
          {!isAudioReady && !isPlaying && <Loader2 className="w-3.5 h-3.5 animate-spin" />}
        </button>
      )}

      {/* Section Complete Checkmark */}
      {showCheckmark && (
        <div className="fixed top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 z-50 pointer-events-none">
          <div className="w-20 h-20 bg-[var(--brand)] rounded-full flex items-center justify-center animate-[ping_0.5s_ease-out] shadow-lg">
            <Check className="w-10 h-10 text-white" strokeWidth={3} />
          </div>
        </div>
      )}

      {/* Vertical Progress Indicator - Right Side, More Prominent */}
      <div className="fixed right-4 md:right-8 top-32 bottom-32 flex flex-col items-center z-30">
        <div className="relative flex-1 w-1 bg-gray-200/70 rounded-full">
          {/* Progress fill with glow */}
          <div 
            className="absolute top-0 w-full bg-[var(--brand)] rounded-full transition-all duration-500 ease-out"
            style={{ 
              height: `${sectionScrollProgress}%`,
              boxShadow: '0 0 10px rgba(15, 61, 46, 0.45), 0 0 20px rgba(15, 61, 46, 0.25)'
            }}
          />
          
          {/* Horizontal crosshair line */}
          <div 
            className="absolute left-1/2 w-16 h-0.5 bg-gradient-to-r from-transparent via-[var(--brand)] to-transparent transition-all duration-500 ease-out"
            style={{ 
              top: `${sectionScrollProgress}%`, 
              transform: `translate(-50%, -50%)`,
              boxShadow: '0 0 15px rgba(15, 61, 46, 0.6)'
            }}
          />
          
          {/* Glowing intersection point */}
          <div 
            className="absolute w-3 h-3 bg-white rounded-full transition-all duration-500 ease-out progress-glow border-2 border-[var(--brand)]"
            style={{ 
              top: `${sectionScrollProgress}%`, 
              left: '50%',
              transform: 'translate(-50%, -50%)'
            }}
          />
        </div>
      </div>

      {/* Main Content Container: single column layout */}
      <div className="max-w-4xl mx-auto px-4 space-y-10">
        {/* Hero */}
        <div className="mb-8">
          <div 
            ref={heroRef}
            className="relative h-80 bg-black overflow-hidden rounded-2xl"
          >
            {/* Base image always visible for smooth transitions */}
            <div className="absolute inset-0 hero-tilt hero-image-soft">
              <img
                src={currentSection.image || article.heroImage}
                alt={currentSection.headline}
                className="w-full h-full object-cover"
              />
            </div>

            {/* Video overlay fades in/out over the image */}
            {showVideo && article.videoFile && (
              <video
                ref={videoRef}
                className="absolute inset-0 w-full h-full object-cover transition-opacity duration-700"
                style={{ opacity: videoReady ? 1 : 0 }}
                autoPlay
                muted
                playsInline
                preload="auto"
                poster={currentSection.image || article.heroImage}
                onCanPlayThrough={() => setVideoReady(true)}
                onEnded={() => { setShowVideo(false); setVideoReady(false); }}
                onError={() => { setShowVideo(false); setVideoReady(false); }}
              >
                <source src={article.videoFile} />
              </video>
            )}
            <div className="absolute inset-0 shimmer pointer-events-none" />
            <div className="absolute inset-0 hero-overlay" />
            <div className="absolute inset-x-0 bottom-0 h-1/2 hero-text-veil" />

            {isFirstSection && (
              <div className="absolute inset-0 flex flex-col justify-end p-8">
                <div className="space-y-4">
                  <h1
                    className="text-5xl md:text-7xl font-extrabold leading-none drop-shadow-[0_6px_24px_rgba(0,0,0,0.4)] tracking-tight"
                    style={{ color: 'var(--neutral-0)' }}
                  >
                    {article.title}
                  </h1>
                  <div className="flex items-start gap-3">
                    <div className="w-1 h-16 bg-[var(--brand)] rounded-full shadow-lg" />
                    <p
                      className="hero-subtitle text-lg md:text-2xl leading-relaxed font-normal max-w-2xl"
                    >
                      {article.subtitle}
                    </p>
                  </div>
                </div>
              </div>
            )}
          </div>
        </div>

        {/* Article body */}
        <main
          key={`${article.id}-${currentSectionIndex}`}
          className="space-y-6 section-fade"
          ref={sectionRef}
        >
          <div className="space-y-2">
            <h2 className="text-2xl md:text-3xl font-bold text-zinc-900">
              {currentSection.headline}
            </h2>
          </div>

          <div className="prose prose-lg max-w-none">
            {currentSection.content.map((paragraph, pIndex) => (
              <p key={pIndex} className="text-zinc-900 leading-relaxed mb-4 text-lg">
                {paragraph}
              </p>
            ))}
          </div>

          <div className="space-y-3 pt-2">
            <div
              className="section-progress"
              role="progressbar"
              aria-valuemin={1}
              aria-valuemax={totalSections}
              aria-valuenow={currentSectionIndex + 1}
            >
              <div className="section-progress-bar">
                <div
                  className="section-progress-fill"
                  style={{ width: `${sectionProgressPercent}%` }}
                />
              </div>
              <div className="section-progress-dots">
                {article.sections.map((_, idx) => (
                  <span
                    key={idx}
                    className={`section-progress-dot ${idx === currentSectionIndex ? 'is-active' : ''}`}
                    aria-hidden="true"
                  />
                ))}
              </div>
            </div>

            <div className="flex items-center justify-between gap-4">
              <button
                onClick={handlePreviousSection}
                disabled={isFirstSection}
                className={`read-link section-nav-link section-nav-prev micro-press ${isFirstSection ? 'is-disabled' : ''}`}
              >
                <ChevronLeft className="w-4 h-4" />
                Prev
              </button>

              {!isLastSection ? (
                <button
                  onClick={handleNextSection}
                  className="read-link section-nav-link section-nav-next chapter-turn micro-press"
                >
                  Next
                  <ChevronRight className="w-4 h-4" />
                </button>
              ) : (
                <div className="flex-1 text-left">
                  <div className="flex items-center gap-2 text-[var(--brand)] font-bold">
                    <Check className="w-5 h-5" /> Done
                  </div>
                  <p className="text-sm text-zinc-600">{article.sections.length} sections read</p>
                </div>
              )}
            </div>
          </div>
        </main>
      </div>
    </div>
  );
};

export default ArticleViewer;
