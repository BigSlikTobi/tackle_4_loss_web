import { useEffect, useState } from 'react';
import { supabase } from '../lib/supabase';
import { BreakingNews } from '../types';

const STORAGE_KEY_LAST_VIEWED = 'start_app_last_viewed_breaking_news_timestamp';

export function useBreakingNews(languageCode: string) {
    const [news, setNews] = useState<BreakingNews[]>([]);
    const [hasUnread, setHasUnread] = useState(false);

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

    // Request permission on mount
    useEffect(() => {
        if ('Notification' in window && Notification.permission === 'default') {
            // Optional: Request permission immediately or waiting for user interaction?
            // Since we have a button now, we might not want to spam. 
            // Leaving as is for now to match previous behavior.
        }
    }, []);

    return {
        news,
        hasUnread,
        markAsRead
    };
}
