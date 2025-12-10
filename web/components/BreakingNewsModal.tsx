import React, { useState, useRef, useEffect } from 'react';
// Re-trigger TS analysis
import { Check, Volume2, Square, Loader2, ChevronLeft, ChevronRight, ArrowLeft } from 'lucide-react';
import { supabase } from '../lib/supabase';
import { BreakingNewsDetail } from '../types';
import ReactMarkdown from 'react-markdown';

interface BreakingNewsModalProps {
    newsId: string | null;
    onClose: () => void;
    nextArticle: { id: string; headline: string; image?: string } | null;
    previousArticle: { id: string; headline: string; image?: string } | null;
    onNavigate: (id: string) => void;
}

// Internal interface matching ArticleViewer's Article structure for consistent rendering
interface MappedArticle {
    id: string;
    title: string;
    subtitle: string;
    introduction?: string; // New field for the intro text below image
    heroImage: string;
    videoFile?: string;
    audioFile?: string;
    sections: {
        headline: string;
        content: string[];
        image?: string;
    }[];
}

export default function BreakingNewsModal({
    newsId,
    onClose,
    nextArticle,
    previousArticle,
    onNavigate
}: BreakingNewsModalProps) {
    const [loading, setLoading] = useState(false);
    const [article, setArticle] = useState<MappedArticle | null>(null);

    // ArticleViewer State
    const [currentSectionIndex] = useState(0);
    const [sectionScrollProgress, setSectionScrollProgress] = useState(0);
    const [showCheckmark, setShowCheckmark] = useState(false);
    const [showVideo, setShowVideo] = useState(false);
    const [videoReady, setVideoReady] = useState(false);
    const [isAudioReady, setIsAudioReady] = useState(false);
    const [isPlaying, setIsPlaying] = useState(false);

    // Refs
    const heroRef = useRef<HTMLDivElement>(null);
    const contentRef = useRef<HTMLDivElement>(null); // Acts as the "Window" for the modal
    const sectionRef = useRef<HTMLDivElement>(null);
    const videoRef = useRef<HTMLVideoElement | null>(null);
    const audioRef = useRef<HTMLAudioElement | null>(null);

    // --- 1. DATA FETCHING & MAPPING ---
    useEffect(() => {
        if (!newsId) return;

        const fetchDetail = async () => {
            setLoading(true);
            try {
                const { data, error } = await supabase.functions.invoke('get-breaking-news-detail', {
                    body: { id: newsId }
                });
                if (error) throw error;

                // Clean & Map Data
                const rawContent = data.content || '';
                const cleanContent = rawContent
                    .replace(/([^\n])\s*(#{1,6}\s)/g, '$1\n\n$2')
                    .replace(/([^\n])\s*(-{3,})\s*/g, '$1\n\n$2\n\n')
                    .replace(/\n\s*\n/g, '\n\n');

                const paragraphs = cleanContent.split(/\n\n+/).filter(p => p.trim().length > 0);

                const mapped: MappedArticle = {
                    id: data.id,
                    title: data.headline,
                    subtitle: '', // Breaking News doesn't have a sub-header, just intro
                    introduction: data.introduction, // Mapped to distinct field
                    heroImage: data.image_url || '',
                    videoFile: undefined, // Breaking news video support can be added here
                    audioFile: undefined, // Breaking news audio support can be added here
                    sections: [
                        {
                            headline: '', // Single section flow for breaking news
                            content: paragraphs
                        }
                    ]
                };

                setArticle(mapped);
            } catch (err) {
                console.error('Failed to fetch news detail:', err);
            } finally {
                setLoading(false);
            }
        };

        fetchDetail();
    }, [newsId]);


    // --- 2. SCROLL PROGRESS LOGIC (Adapted for Modal) ---
    useEffect(() => {
        const handleScroll = () => {
            // NOTE: In ArticleViewer, we track window scroll.
            // Here, because it's a modal, we must track the overflow container's scroll.
            const scrollContainer = contentRef.current;
            if (!scrollContainer || !sectionRef.current) return;

            const rect = sectionRef.current.getBoundingClientRect();
            const containerHeight = scrollContainer.clientHeight;

            // Calculate progress relative to the text section
            const sectionTop = rect.top; // Relative to viewport
            const sectionHeight = rect.height;

            // We use the same logic: how far has the section top moved up?
            // When sectionTop matches the "start" (e.g. viewable area), progress starts.
            // Adjust offset based on hero height or standard viewport behavior.
            const startOffset = containerHeight;
            const scrolled = Math.max(0, startOffset - sectionTop);
            const progress = Math.min((scrolled / sectionHeight) * 100, 100);

            setSectionScrollProgress(progress);
        };

        const container = contentRef.current;
        if (container) {
            container.addEventListener('scroll', handleScroll);
            handleScroll(); // Initial check
            return () => container.removeEventListener('scroll', handleScroll);
        }
    }, [article, currentSectionIndex]);

    // --- 3. HELPER HANDLERS ---
    const handleToggleAudio = () => {
        if (!audioRef.current || !article?.audioFile) return;

        if (isPlaying) {
            audioRef.current.pause();
            setIsPlaying(false);
        } else {
            audioRef.current.play()
                .then(() => setIsPlaying(true))
                .catch(() => {
                    setIsPlaying(false);
                    setIsAudioReady(false);
                });
        }
    };

    // Close on Escape
    useEffect(() => {
        const handleEsc = (e: KeyboardEvent) => {
            if (e.key === 'Escape') onClose();
        };
        window.addEventListener('keydown', handleEsc);
        return () => window.removeEventListener('keydown', handleEsc);
    }, [onClose]);


    // Derived State
    const currentSection = article?.sections[currentSectionIndex];


    if (!newsId) return null;

    return (
        <div className="fixed inset-0 z-50 bg-white">
            {/* Scrollable Container (The "Body" of the modal) */}
            <div
                ref={contentRef}
                className="h-full overflow-y-auto overflow-x-hidden bg-white detail-transition"
            >

                {/* --- FIXED UI ELEMENTS --- */}

                {/* 1. Back Button */}
                <button
                    onClick={onClose}
                    className="fixed top-8 left-8 z-50 flex items-center gap-2 text-zinc-500 hover:text-zinc-900 transition-colors group"
                >
                    <ArrowLeft size={24} className="group-hover:-translate-x-1 transition-transform" />
                    <span className="text-lg font-medium">Back</span>
                </button>

                {loading || !article || !currentSection ? (
                    <div className="flex items-center justify-center h-screen">
                        <Loader2 className="w-8 h-8 animate-spin text-red-800" />
                    </div>
                ) : (
                    <>
                        {/* 2. Floating Audio Button (Red Theme) */}
                        {article.audioFile && (
                            <button
                                onClick={handleToggleAudio}
                                className={`fixed bottom-10 right-10 z-50 flex items-center gap-2 px-5 py-2.5 rounded-full text-xs font-extrabold uppercase tracking-widest shadow-lg border transition-all duration-300 hover:scale-105 ${isPlaying
                                    ? 'bg-red-600 text-white border-red-700 hover:bg-red-700'
                                    : 'bg-white text-zinc-900 border-zinc-100 hover:shadow-xl'
                                    }`}
                                title={isPlaying ? 'Stop audio' : 'Play audio'}
                            >
                                {isPlaying ? <Square className="w-3.5 h-3.5" /> : <Volume2 className="w-3.5 h-3.5" />}
                                {isPlaying ? 'Stop' : 'Audio'}
                            </button>
                        )}
                        {!article.audioFile && (
                            <div className="fixed bottom-10 right-10 z-50">
                                <button className="flex items-center gap-3 px-5 py-2.5 bg-white rounded-full shadow-[0_8px_30px_rgba(0,0,0,0.12)] border border-zinc-100 hover:scale-105 hover:shadow-[0_8px_30px_rgba(0,0,0,0.15)] transition-all duration-300">
                                    <Volume2 size={18} className="text-zinc-900" />
                                    <span className="text-xs font-extrabold tracking-widest uppercase text-zinc-900">Audio</span>
                                </button>
                            </div>
                        )}

                        {/* 3. Section Complete Checkmark */}
                        {showCheckmark && (
                            <div className="fixed top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 z-50 pointer-events-none">
                                <div className="w-20 h-20 bg-red-600 rounded-full flex items-center justify-center animate-[ping_0.5s_ease-out] shadow-lg">
                                    <Check className="w-10 h-10 text-white" strokeWidth={3} />
                                </div>
                            </div>
                        )}

                        {/* 4. Vertical Scroll Progress (Right Side - RED THEME) */}
                        <div className="fixed right-4 md:right-8 top-32 bottom-32 flex flex-col items-center z-30">
                            <div className="relative flex-1 w-1 bg-zinc-200/70 rounded-full">
                                {/* Progress fill with glow */}
                                <div
                                    className="absolute top-0 w-full bg-red-800 rounded-full transition-all duration-100 ease-out"
                                    style={{
                                        height: `${sectionScrollProgress}%`,
                                        boxShadow: '0 0 10px rgba(153, 27, 27, 0.45), 0 0 20px rgba(153, 27, 27, 0.25)'
                                    }}
                                />
                                {/* Horizontal crosshair */}
                                <div
                                    className="absolute left-1/2 w-16 h-0.5 bg-gradient-to-r from-transparent via-red-800 to-transparent transition-all duration-100 ease-out"
                                    style={{
                                        top: `${sectionScrollProgress}%`,
                                        transform: `translate(-50%, -50%)`,
                                        boxShadow: '0 0 15px rgba(153, 27, 27, 0.6)'
                                    }}
                                />
                                {/* Glowing intersection dot */}
                                <div
                                    className="absolute w-3 h-3 bg-white rounded-full transition-all duration-100 ease-out border-2 border-red-800"
                                    style={{
                                        top: `${sectionScrollProgress}%`,
                                        left: '50%',
                                        transform: 'translate(-50%, -50%)',
                                        boxShadow: '0 0 8px rgba(153, 27, 27, 0.8)'
                                    }}
                                />
                            </div>
                        </div>


                        {/* --- MAIN CONTENT LAYOUT --- */}
                        <div className="max-w-4xl mx-auto pl-4 pr-14 md:px-4 space-y-10 pt-24 pb-32">

                            {/* HERO */}
                            <div className="mb-8">
                                <div
                                    ref={heroRef}
                                    className="relative h-80 bg-black overflow-hidden rounded-2xl"
                                >
                                    {/* Base Image */}
                                    <div className="absolute inset-0 hero-tilt hero-image-soft">
                                        {currentSection.image || article.heroImage ? (
                                            <img
                                                src={currentSection.image || article.heroImage}
                                                alt={article.title}
                                                className="w-full h-full object-cover"
                                            />
                                        ) : (
                                            <div className="w-full h-full flex items-center justify-center text-white/10 text-6xl font-black">T4L</div>
                                        )}
                                    </div>

                                    {/* Video Overlay Logic (If we add video support later) */}
                                    {showVideo && article.videoFile && (
                                        <video
                                            ref={videoRef}
                                            className="absolute inset-0 w-full h-full object-cover transition-opacity duration-700"
                                            style={{ opacity: videoReady ? 1 : 0 }}
                                            autoPlay muted playsInline loop
                                        >
                                            <source src={article.videoFile} />
                                        </video>
                                    )}

                                    <div className="absolute inset-0 shimmer pointer-events-none" />
                                    <div className="absolute inset-0 hero-overlay" />
                                    <div className="absolute inset-x-0 bottom-0 h-1/2 hero-text-veil" />

                                    {/* Hero Text Content - Headline Only if no Subtitle */}
                                    {true && (
                                        <div className="absolute inset-0 flex flex-col justify-end p-8">
                                            <div className="space-y-4">
                                                <h1
                                                    className="text-5xl md:text-7xl font-extrabold leading-none drop-shadow-[0_6px_24px_rgba(0,0,0,0.4)] tracking-tight"
                                                    style={{ color: 'var(--neutral-0)' }}
                                                >
                                                    {article.title}
                                                </h1>
                                                {/* Subtitle removed from here as per new design */}
                                            </div>
                                        </div>
                                    )}
                                </div>
                            </div>

                            {/* INTRODUCTION (If Exists, Below Hero) */}
                            {article.introduction && (
                                <div className="px-2">
                                    <p className="text-xl md:text-2xl leading-relaxed font-medium text-zinc-900 mb-8 border-l-4 border-red-800 pl-6 py-1">
                                        {article.introduction}
                                    </p>
                                </div>
                            )}

                            {/* ARTICLE BODY */}
                            <main
                                key={`${article.id}-${currentSectionIndex}`}
                                className="space-y-6"
                                ref={sectionRef}
                            >
                                {currentSection.headline && (
                                    <div className="space-y-2">
                                        <h2 className="text-2xl md:text-3xl font-bold text-zinc-900">
                                            {currentSection.headline}
                                        </h2>
                                    </div>
                                )}

                                <div className="prose prose-lg max-w-none">
                                    <ReactMarkdown>
                                        {currentSection.content.join('\n\n')}
                                    </ReactMarkdown>
                                </div>

                                {/* --- PREV/NEXT ARTICLE NAVIGATION (Redesigned) --- */}
                                <div className="pt-16 mt-16 border-t border-zinc-100/50 flex items-center justify-between">

                                    {/* Previous Article Link */}
                                    <div>
                                        {previousArticle ? (
                                            <button
                                                onClick={() => onNavigate(previousArticle.id)}
                                                className="group flex items-center gap-4 transition-all duration-300 hover:-translate-x-1"
                                            >
                                                <div className="relative w-12 h-12 rounded-lg overflow-hidden shadow-sm group-hover:shadow-[0_4px_12px_rgba(153,27,27,0.3)] transition-shadow">
                                                    {previousArticle.image ? (
                                                        <img src={previousArticle.image} className="w-full h-full object-cover opacity-80 group-hover:opacity-100 transition-opacity" alt="Previous" />
                                                    ) : (
                                                        <div className="w-full h-full bg-zinc-100 flex items-center justify-center text-zinc-300">
                                                            <ChevronLeft size={16} />
                                                        </div>
                                                    )}
                                                    <div className="absolute inset-0 ring-1 ring-inset ring-black/5 rounded-lg" />
                                                </div>
                                                <div className="flex flex-col items-start gap-0.5">
                                                    <span className="flex items-center gap-1 text-[10px] font-black tracking-[0.2em] uppercase text-zinc-300 group-hover:text-red-800 transition-colors">
                                                        <ChevronLeft size={10} strokeWidth={4} />
                                                        Previous
                                                    </span>
                                                </div>
                                            </button>
                                        ) : (
                                            <div className="w-12 h-12" /> /* Spacer */
                                        )}
                                    </div>

                                    {/* Next Article Link */}
                                    <div>
                                        {nextArticle ? (
                                            <button
                                                onClick={() => onNavigate(nextArticle.id)}
                                                className="group flex flex-row-reverse items-center gap-4 transition-all duration-300 hover:translate-x-1"
                                            >
                                                <div className="relative w-12 h-12 rounded-lg overflow-hidden shadow-sm group-hover:shadow-[0_4px_12px_rgba(153,27,27,0.3)] transition-shadow">
                                                    {nextArticle.image ? (
                                                        <img src={nextArticle.image} className="w-full h-full object-cover opacity-80 group-hover:opacity-100 transition-opacity" alt="Next" />
                                                    ) : (
                                                        <div className="w-full h-full bg-zinc-100 flex items-center justify-center text-zinc-300">
                                                            <ChevronRight size={16} />
                                                        </div>
                                                    )}
                                                    <div className="absolute inset-0 ring-1 ring-inset ring-black/5 rounded-lg" />
                                                </div>
                                                <div className="flex flex-col items-end gap-0.5">
                                                    <span className="flex items-center gap-1 text-[10px] font-black tracking-[0.2em] uppercase text-zinc-300 group-hover:text-red-800 transition-colors">
                                                        Next
                                                        <ChevronRight size={10} strokeWidth={4} />
                                                    </span>
                                                </div>
                                            </button>
                                        ) : (
                                            <div className="w-12 h-12" /> /* Spacer */
                                        )}
                                    </div>

                                </div>
                            </main>

                        </div>
                    </>
                )}
            </div>
        </div >
    );
}
