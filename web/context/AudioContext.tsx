import React, { createContext, useContext, useState, useRef, useEffect, ReactNode } from 'react';

interface AudioContextType {
    play: (url: string, title?: string, artist?: string, imageUrl?: string) => void;
    pause: () => void;
    resume: () => void;
    stop: () => void;
    isPlaying: boolean;
    currentUrl: string | null;
    currentTitle: string | null;
    currentArtist: string | null;
    currentImageUrl: string | null;
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
    const [currentArtist, setCurrentArtist] = useState<string | null>(null);
    const [currentImageUrl, setCurrentImageUrl] = useState<string | null>(null);
    const [isPlaying, setIsPlaying] = useState(false);
    const audioRef = useRef<HTMLAudioElement | null>(null);

    // Initialize audio element
    useEffect(() => {
        audioRef.current = new Audio();

        const handleEnded = () => {
            setIsPlaying(false);
            setCurrentUrl(null);
            setCurrentTitle(null);
            setCurrentArtist(null);
            setCurrentImageUrl(null);
        };

        audioRef.current.addEventListener('ended', handleEnded);

        return () => {
            audioRef.current?.removeEventListener('ended', handleEnded);
            audioRef.current?.pause();
            audioRef.current = null;
        };
    }, []);

    const play = (url: string, title?: string, artist?: string, imageUrl?: string) => {
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
                setCurrentArtist(artist || null);
                setCurrentImageUrl(imageUrl || null);
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
        setCurrentArtist(null);
        setCurrentImageUrl(null);
    };

    return (
        <AudioContext.Provider
            value={{
                play,
                pause,
                resume,
                stop,
                isPlaying,
                currentUrl,
                currentTitle,
                currentArtist,
                currentImageUrl,
            }}
        >
            {children}
        </AudioContext.Provider>
    );
};
