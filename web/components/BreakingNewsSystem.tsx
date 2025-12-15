import React, { useEffect, useState } from 'react';
import { supabase } from '../lib/supabase';
import { BreakingNews } from '../types';
import BreakingNewsOverviewModal from './BreakingNewsOverviewModal';

interface BreakingNewsSystemProps {
    languageCode: string;
}

const STORAGE_KEY_LAST_VIEWED = 'start_app_last_viewed_breaking_news_timestamp';

export default function BreakingNewsSystem({ languageCode }: BreakingNewsSystemProps) {
    const [news, setNews] = useState<BreakingNews[]>([]);
    const [hasUnread, setHasUnread] = useState(false);
    const [isModalOpen, setIsModalOpen] = useState(false);

    // --- 1. Fetch & Realtime ---
    useEffect(() => {
        const fetchNews = async () => {
            const { data, error } = await supabase.functions.invoke('get-breaking-news', {
                body: { language_code: languageCode }
            });
            if (!error && data) {
                setNews(data);
                checkUnreadStatus(data);
            }
        };

        fetchNews();

        const channel = supabase
            .channel('breaking-news-system')
            .on(
                'postgres_changes',
                { event: 'INSERT', schema: 'content', table: 'breaking_news' },
                (payload) => {
                    console.log('New breaking news!', payload);
                    fetchNews();
                    handleNewNotification(payload.new as BreakingNews);
                }
            )
            .subscribe();

        return () => { supabase.removeChannel(channel); };
    }, [languageCode]);

    // --- 2. Unread Logic ---
    const checkUnreadStatus = (articles: BreakingNews[]) => {
        if (articles.length === 0) {
            setHasUnread(false);
            return;
        }

        const lastViewed = localStorage.getItem(STORAGE_KEY_LAST_VIEWED);
        if (!lastViewed) {
            setHasUnread(true);
            return;
        }

        const latestTimestamp = new Date(articles[0].created_at).getTime();
        const lastViewedTimestamp = new Date(lastViewed).getTime();

        setHasUnread(latestTimestamp > lastViewedTimestamp);
    };

    const markAsRead = () => {
        if (news.length > 0) {
            localStorage.setItem(STORAGE_KEY_LAST_VIEWED, news[0].created_at);
            setHasUnread(false);
        }
    };

    // --- 3. Notification Logic ---
    const handleNewNotification = (newItem: BreakingNews) => {
        if (!('Notification' in window)) return;

        if (Notification.permission === 'granted') {
            showNotification(newItem);
        } else if (Notification.permission !== 'denied') {
            Notification.requestPermission().then(permission => {
                if (permission === 'granted') showNotification(newItem);
            });
        }
    };

    const showNotification = (item: BreakingNews) => {
        const title = "Breaking News! 🚨";
        const body = item.x_post || item.headline;
        new Notification(title, { body, icon: '/favicon.ico' });
    };

    // Request permission on mount (optional, might be aggressive, but ensures availability)
    useEffect(() => {
        if ('Notification' in window && Notification.permission === 'default') {
            // Only ask if user interacts? Or just try? 
            // Browsers usually block this unless triggered by user interaction.
            // We'll leave it to be triggered by the user clicking something else or specific "Enable" button later if needed.
            // For now, let's just wait for the first event, but the first event is async pushed, so browser might block it if page isn't focused.
            // Let's rely on the visual cue mostly.
        }
    }, []);


    // --- 4. Render ---
    // --- 4. Render ---
    // if (news.length === 0) return null; // User wants it visible always

    return (
        <>
            {/* Pulsing Chip (Top Right) */}
            <button
                onClick={() => {
                    setIsModalOpen(true);
                    markAsRead();
                }}
                className={`fixed top-24 right-5 z-50 bg-zinc-900 text-white pl-3 pr-4 py-1.5 rounded-full shadow-lg hover:scale-105 active:scale-95 transition-all duration-300 flex items-center gap-2 group border border-zinc-800 ${hasUnread ? 'animate-bounce-subtle' : ''
                    }`}
            >
                {/* Red Dot */}
                <span className="relative flex h-2 w-2">
                    {hasUnread && <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-red-500 opacity-75"></span>}
                    <span className={`relative inline-flex rounded-full h-2 w-2 ${hasUnread ? 'bg-red-600' : 'bg-zinc-600'}`}></span>
                </span>

                <span className="text-[10px] font-black tracking-[0.15em] uppercase group-hover:text-red-500 transition-colors">
                    Breaking
                </span>
            </button>

            {/* Overview Modal */}
            <BreakingNewsOverviewModal
                isOpen={isModalOpen}
                onClose={() => setIsModalOpen(false)}
                news={news}
                languageCode={languageCode}
            />
        </>
    );
}
