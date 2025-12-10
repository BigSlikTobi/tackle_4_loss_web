import { useEffect, useState } from 'react';
import { supabase } from '../lib/supabase';
import { BreakingNews } from '../types';
import { Loader2 } from 'lucide-react';
import BreakingNewsModal from './BreakingNewsModal';

interface BreakingNewsListProps {
    languageCode: string;
}

export default function BreakingNewsList({ languageCode }: BreakingNewsListProps) {
    const [news, setNews] = useState<BreakingNews[]>([]);
    const [loading, setLoading] = useState(true);
    const [selectedNewsId, setSelectedNewsId] = useState<string | null>(null);

    useEffect(() => {
        const fetchBreakingNews = async () => {
            try {
                const { data, error } = await supabase.functions.invoke('get-breaking-news', {
                    body: { language_code: languageCode }
                });

                if (error) throw error;
                setNews(data || []);
            } catch (error) {
                console.error('Error fetching breaking news:', error);
            } finally {
                setLoading(false);
            }
        };

        fetchBreakingNews();

        // Realtime Subscription
        const channel = supabase
            .channel('breaking-news-changes')
            .on(
                'postgres_changes',
                {
                    event: '*',
                    schema: 'content',
                    table: 'breaking_news'
                },
                () => {
                    console.log('Breaking news changed, refreshing...');
                    fetchBreakingNews();
                }
            )
            .subscribe();

        return () => {
            supabase.removeChannel(channel);
        };
    }, [languageCode]);

    if (loading) {
        return (
            <div className="flex justify-center py-8">
                <Loader2 className="w-6 h-6 animate-spin text-zinc-400" />
            </div>
        );
    }

    if (news.length === 0) return null;

    return (
        <div className="w-full max-w-6xl mx-auto mt-4 mb-12">
            {/* Header */}
            <div className="flex items-center gap-3 mb-6 px-1">
                <div className="relative flex items-center justify-center bg-[var(--brand)] text-white px-3 py-1 rounded-full shadow-[0_4px_12px_rgba(15,61,46,0.25)]">
                    <div className="w-2 h-2 mr-2 rounded-full bg-red-500 animate-pulse-red shadow-[0_0_8px_rgba(239,68,68,0.8)]" />
                    <span className="text-[11px] font-black tracking-widest uppercase">Breaking</span>
                </div>
                <div className="h-px flex-1 bg-gradient-to-r from-[var(--brand)]/20 to-transparent" />
            </div>

            {/* Simple List Layout */}
            <div className="flex flex-col divide-y divide-zinc-200/50">
                {news.map((item) => (
                    <div
                        key={item.id}
                        onClick={() => setSelectedNewsId(item.id)}
                        className="group flex items-center gap-3 p-2 hover:bg-zinc-50 transition-colors cursor-pointer"
                    >


                        <span className="flex-1 text-zinc-800 text-sm md:text-base font-medium leading-relaxed group-hover:text-[var(--brand)] transition-colors">
                            {item.headline}
                        </span>

                        <span className="text-[11px] text-zinc-400 font-medium whitespace-nowrap ml-4 shrink-0">
                            {new Date(item.created_at).toLocaleTimeString(languageCode === 'de' ? 'de-DE' : 'en-US', {
                                hour: '2-digit',
                                minute: '2-digit'
                            })}
                        </span>
                    </div>
                ))}
            </div>

            {/* Modal */}
            {selectedNewsId && (
                (() => {
                    const currentIndex = news.findIndex(n => n.id === selectedNewsId);
                    const previousArticle = currentIndex > 0 ? news[currentIndex - 1] : null;
                    const nextArticle = currentIndex < news.length - 1 ? news[currentIndex + 1] : null;

                    return (
                        <BreakingNewsModal
                            newsId={selectedNewsId}
                            onClose={() => setSelectedNewsId(null)}
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
                            onNavigate={(id) => setSelectedNewsId(id)}
                        />
                    );
                })()
            )}
        </div>
    );
}
