import React, { createContext, useContext, useState, useRef, useEffect, ReactNode } from 'react';
import { Play, Pause, X } from 'lucide-react';

interface AudioContextType {
    play: (url: string, title?: string) => void;
    pause: () => void;
    resume: () => void;
    stop: () => void;
    isPlaying: boolean;
    currentUrl: string | null;
    currentTitle: string | null;
}

const AudioContext = createContext<AudioContextType | undefined>(undefined);

export const useAudio = () => {
    const context = useContext(AudioContext);
    if (!context) {
        throw new Error('useAudio must be used within an AudioProvider');
    }
    return context;
};

interface AudioProviderProps {
    children: ReactNode;
}

export const AudioProvider: React.FC<AudioProviderProps> = ({ children }) => {
    const [currentUrl, setCurrentUrl] = useState<string | null>(null);
    const [currentTitle, setCurrentTitle] = useState<string | null>(null);
    const [isPlaying, setIsPlaying] = useState(false);
    const audioRef = useRef<HTMLAudioElement | null>(null);

    // Initialize audio element
    useEffect(() => {
        audioRef.current = new Audio();

        const handleEnded = () => {
            setIsPlaying(false);
            setCurrentUrl(null);
            setCurrentTitle(null);
        };

        audioRef.current.addEventListener('ended', handleEnded);

        return () => {
            audioRef.current?.removeEventListener('ended', handleEnded);
            audioRef.current?.pause();
            audioRef.current = null;
        };
    }, []);

    const play = (url: string, title?: string) => {
        if (!audioRef.current) return;

        // If clicking the same already playing URL, treat as pause request? 
        // Or strictly strictly "Play this". Let's assume strict Play.

        if (currentUrl === url) {
            audioRef.current.play()
                .then(() => setIsPlaying(true))
                .catch(e => console.warn('Audio play failed', e));
            return;
        }

        audioRef.current.src = url;
        audioRef.current.load();
        audioRef.current.play()
            .then(() => {
                setIsPlaying(true);
                setCurrentUrl(url);
                setCurrentTitle(title || 'Playing Audio');
            })
            .catch(e => {
                console.error('Audio playback error', e);
                setIsPlaying(false);
            });
    };

    const pause = () => {
        audioRef.current?.pause();
        setIsPlaying(false);
    };

    const resume = () => {
        if (currentUrl && audioRef.current) {
            audioRef.current.play()
                .then(() => setIsPlaying(true))
                .catch(e => console.warn('Resume failed', e));
        }
    };

    const stop = () => {
        if (audioRef.current) {
            audioRef.current.pause();
            audioRef.current.currentTime = 0;
        }
        setIsPlaying(false);
        setCurrentUrl(null);
        setCurrentTitle(null);
    };

    return (
        <AudioContext.Provider value={{ play, pause, resume, stop, isPlaying, currentUrl, currentTitle }}>
            {children}

            {/* Global Mini Player */}
            {currentUrl && (
                <div className="fixed bottom-4 right-4 z-[9999] animate-slide-up">
                    <div className="bg-zinc-900 border border-zinc-800 text-white p-3 rounded-full shadow-[0_8px_32px_rgba(0,0,0,0.5)] backdrop-blur-md flex items-center gap-4 pr-5 max-w-sm">
                        {/* Play/Pause Button */}
                        <button
                            onClick={isPlaying ? pause : resume}
                            className="w-10 h-10 rounded-full bg-white text-black flex items-center justify-center hover:scale-105 transition-transform"
                        >
                            {isPlaying ? (
                                <Pause size={18} fill="currentColor" />
                            ) : (
                                <Play size={18} fill="currentColor" className="ml-0.5" />
                            )}
                        </button>

                        <div className="flex flex-col min-w-[120px]">
                            <span className="text-[10px] uppercase tracking-widest text-zinc-400 font-bold">Now Playing</span>
                            <span className="text-xs font-medium truncate max-w-[160px]">{currentTitle}</span>
                        </div>

                        {/* Stop/Close Button */}
                        <button
                            onClick={stop}
                            className="p-1.5 rounded-full hover:bg-zinc-800 text-zinc-400 hover:text-white transition-colors ml-auto"
                        >
                            <X size={16} />
                        </button>
                    </div>
                </div>
            )}
        </AudioContext.Provider>
    );
};
