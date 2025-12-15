import React, { useState } from 'react';
import { BreakingNews } from '../types';
import BreakingNewsModal from './BreakingNewsModal';
import { useAudio } from '../context/AudioContext';
import { X, Headphones, Play, Pause, ChevronRight } from 'lucide-react';

interface BreakingNewsOverviewModalProps {
    isOpen: boolean;
    onClose: () => void;
    news: BreakingNews[];
    languageCode: string;
}

export default function BreakingNewsOverviewModal({
    isOpen,
    onClose,
    news,
    languageCode
}: BreakingNewsOverviewModalProps) {
    const [selectedDetailId, setSelectedDetailId] = useState<string | null>(null);
    const { play, pause, isPlaying, currentUrl } = useAudio();

    if (!isOpen) return null;

    // Derived states for detail modal navigation
    const currentIndex = selectedDetailId ? news.findIndex(n => n.id === selectedDetailId) : -1;
    const previousArticle = currentIndex > 0 ? news[currentIndex - 1] : null;
    const nextArticle = currentIndex >= 0 && currentIndex < news.length - 1 ? news[currentIndex + 1] : null;

    const handleAudioClick = (e: React.MouseEvent, item: BreakingNews) => {
        e.stopPropagation();
        if (!item.audio_file) return;

        if (currentUrl === item.audio_file && isPlaying) {
            pause();
        } else {
            play(item.audio_file, item.headline);
        }
    };

    return (
        <div className="fixed inset-0 z-[100] flex items-start justify-end p-4 sm:p-8 pointer-events-none">
            {/* Backdrop - Click to close */}
            <div
                className="absolute inset-0 bg-black/20 backdrop-blur-sm pointer-events-auto transition-opacity duration-300 ease-out"
                onClick={onClose}
            />

            {/* Modal Content - Slide in from right */}
            <div className="pointer-events-auto w-full max-w-md bg-white rounded-2xl shadow-2xl overflow-hidden flex flex-col max-h-[85vh] animate-slide-in-right relative top-12">

                {/* Header */}
                <div className="px-6 py-5 border-b border-zinc-100 flex items-center justify-between bg-white z-10">
                    <div className="flex items-center gap-3">
                        <div className="w-2 h-2 rounded-full bg-red-600 animate-pulse" />
                        <h2 className="text-lg font-black tracking-tight text-zinc-900 uppercase">Breaking News</h2>
                    </div>
                    <button
                        onClick={onClose}
                        className="p-2 -mr-2 text-zinc-400 hover:text-zinc-900 rounded-full hover:bg-zinc-100 transition-colors"
                    >
                        <X size={20} />
                    </button>
                </div>

                {/* List */}
                <div className="overflow-y-auto p-2 space-y-1">
                    {news.map((item) => {
                        const isItemAudioPlaying = currentUrl === item.audio_file && isPlaying;

                        return (
                            <div
                                key={item.id}
                                onClick={() => setSelectedDetailId(item.id)}
                                className="group relative p-4 rounded-xl hover:bg-zinc-50 transition-colors cursor-pointer border border-transparent hover:border-zinc-100"
                            >
                                <div className="flex gap-4">
                                    {/* Text Content */}
                                    <div className="flex-1 space-y-1.5">
                                        <div className="flex items-center gap-2 text-[10px] font-bold text-zinc-400 uppercase tracking-wider">
                                            <span>
                                                {new Date(item.created_at).toLocaleTimeString(languageCode === 'de' ? 'de-DE' : 'en-US', {
                                                    hour: '2-digit',
                                                    minute: '2-digit'
                                                })}
                                            </span>
                                            {item.audio_file && (
                                                <span className="flex items-center gap-0.5 text-blue-600 bg-blue-50 px-1.5 py-0.5 rounded-full">
                                                    <Headphones size={10} />
                                                    <span>Audio</span>
                                                </span>
                                            )}
                                        </div>
                                        <h3 className="text-sm font-semibold text-zinc-900 leading-snug group-hover:text-[var(--brand)] transition-colors">
                                            {item.headline}
                                        </h3>
                                    </div>

                                    {/* Action Buttons */}
                                    <div className="flex flex-col items-end gap-2 shrink-0">
                                        {item.audio_file ? (
                                            <button
                                                onClick={(e) => handleAudioClick(e, item)}
                                                className={`w-8 h-8 rounded-full flex items-center justify-center transition-all ${isItemAudioPlaying
                                                        ? 'bg-red-600 text-white shadow-md scale-110'
                                                        : 'bg-zinc-100 text-zinc-500 hover:bg-zinc-200 hover:scale-105'
                                                    }`}
                                            >
                                                {isItemAudioPlaying ? <Pause size={14} fill="currentColor" /> : <Headphones size={14} />}
                                            </button>
                                        ) : (
                                            <div className="w-8 h-8 rounded-full flex items-center justify-center bg-zinc-50 text-zinc-300">
                                                <Headphones size={14} />
                                            </div>
                                        )}
                                    </div>
                                </div>
                            </div>
                        );
                    })}
                </div>
            </div>

            {/* Detail Modal (Nested) */}
            {selectedDetailId && (
                <BreakingNewsModal
                    newsId={selectedDetailId}
                    onClose={() => setSelectedDetailId(null)}
                    previousArticle={previousArticle ? {
                        id: previousArticle.id,
                        headline: previousArticle.headline,
                        image: previousArticle.image_url
                    } : null}
                    nextArticle={nextArticle ? {
                        id: nextArticle.id,
                        headline: nextArticle.headline,
                        image: nextArticle.image_url
                    } : null}
                    onNavigate={(id) => setSelectedDetailId(id)}
                />
            )}
        </div>
    );
}
