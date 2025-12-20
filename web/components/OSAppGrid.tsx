import React from 'react';
import { Mic2, Bell, Newspaper } from 'lucide-react';
import { useAudio } from '../context/AudioContext';

interface AppIconProps {
    symbol: string;
    label: string;
    onClick?: () => void;
    isUnread?: boolean;
}

const AppIcon: React.FC<AppIconProps> = ({ symbol, label, onClick, isUnread }) => (
    <div
        onClick={onClick}
        className="flex flex-col items-center gap-1.5 group cursor-pointer active:scale-90 transition-transform duration-200"
    >
        {/* iOS Squircle Icon Container - Solid Team Color */}
        <div className="relative w-[3.8rem] h-[3.8rem] sm:w-[4.2rem] sm:h-[4.2rem] flex items-center justify-center transition-all duration-300 active:scale-95 shadow-md group-hover:shadow-lg"
            style={{
                borderRadius: '22%',
                backgroundColor: 'var(--brand)',
            }}
        >
            {/* Symbol Text */}
            <span className="text-white text-xl sm:text-2xl font-black tracking-tighter drop-shadow-sm select-none">
                {symbol}
            </span>

            {/* Notification Badge */}
            {isUnread && (
                <div className="absolute -top-1 -right-1 w-5 h-5 bg-red-500 rounded-full border-2 border-[var(--brand)] shadow-sm flex items-center justify-center animate-bounce">
                    <span className="text-[10px] font-bold text-white">1</span>
                </div>
            )}
        </div>

        {/* iOS Style Label */}
        <span className="text-[11px] sm:text-[12px] font-medium text-white/90 text-center drop-shadow-md tracking-tight leading-tight px-1 line-clamp-1 w-full overflow-hidden text-ellipsis">
            {label}
        </span>
    </div>
);

interface OSAppGridProps {
    onOpenNews: () => void;
    hasUnreadNews?: boolean;
    installedApps: string[];
}

const OSAppGrid: React.FC<OSAppGridProps> = ({ onOpenNews, hasUnreadNews, installedApps }) => {
    const { play } = useAudio();

    return (
        <div className="w-full px-4 pt-1 pb-1">
            {/* iOS Grid Layout: 5 columns standard for 5x5 grid */}
            <div className="grid grid-cols-5 gap-x-2 gap-y-6 max-w-[400px] mx-auto place-items-center">

                {installedApps.includes('radio') && (
                    <AppIcon
                        symbol="R"
                        label="Radio"
                        onClick={() => play('https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3', 'Live: Playoff Picture Update')}
                    />
                )}

                {installedApps.includes('breaking_news') && (
                    <AppIcon
                        symbol="B"
                        label="Breaking"
                        onClick={onOpenNews}
                        isUnread={hasUnreadNews}
                    />
                )}

                {installedApps.includes('deep_dives') && (
                    <AppIcon
                        symbol="DD"
                        label="Deep Dives"
                        onClick={() => {
                            window.dispatchEvent(new CustomEvent('scrollToDeepDives'));
                        }}
                    />
                )}
            </div>
        </div>
    );
};

export default OSAppGrid;
