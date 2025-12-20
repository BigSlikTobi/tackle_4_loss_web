import React from 'react';
import { Newspaper, Radio, BadgeCheck } from 'lucide-react';

interface AppStoreProps {
    onOpenApp: (appId: string) => void;
    installedApps: string[];
    onToggleInstall: (appId: string) => void;
}

const apps = [
    {
        id: 'deep_dives',
        name: 'Deep Dives',
        description: 'In-depth analysis and articles about your favorite team.',
        // Icon handled dynamically
        color: 'bg-[#C9A256]', // Gold fallback
    },
    {
        id: 'breaking_news',
        name: 'Breaking News',
        description: 'Stay updated with the latest breaking news and updates.',
        icon: <Newspaper size={32} className="text-white" />,
        color: 'bg-red-600',
    },
    {
        id: 'radio',
        name: 'Radio',
        description: 'Listen to live broadcasts, podcasts, and audio content.',
        icon: <Radio size={32} className="text-white" />,
        color: 'bg-blue-600',
    },
];

const AppStore: React.FC<AppStoreProps> = ({ onOpenApp, installedApps, onToggleInstall }) => {
    return (
        <div className="w-full max-w-2xl mx-auto pt-24 px-6 pb-32 animate-fade-in">
            <h1 className="text-4xl font-['Anton'] text-white mb-2">App Store</h1>
            <p className="text-zinc-400 mb-8">Discover customized apps for your team.</p>

            <div className="grid gap-4">
                {apps.map((app) => {
                    const isInstalled = installedApps.includes(app.id);

                    return (
                        <div
                            key={app.id}
                            className="bg-zinc-900/50 backdrop-blur-md border border-white/10 p-4 rounded-2xl flex items-center gap-4 hover:bg-zinc-800/50 transition-all group"
                        >
                            {/* App Icon */}
                            <div className={`w-16 h-16 rounded-xl ${app.color} flex items-center justify-center shadow-lg group-hover:scale-105 transition-transform overflow-hidden relative`}>
                                {app.id === 'deep_dives' ? (
                                    <>
                                        <div
                                            className="absolute inset-0 bg-center bg-contain bg-no-repeat m-2"
                                            style={{ backgroundImage: 'var(--team-logo-url)' }}
                                        />
                                        {/* Fallback Check if needed, but logo replaces it */}
                                    </>
                                ) : (
                                    app.icon
                                )}
                            </div>

                            {/* Text Info */}
                            <div className="flex-1">
                                <h3 className="text-xl font-bold text-white mb-1 group-hover:text-[var(--brand)] transition-colors">{app.name}</h3>
                                <p className="text-sm text-zinc-400 leading-snug">{app.description}</p>
                            </div>

                            {/* Action Button */}
                            <button
                                onClick={(e) => {
                                    e.stopPropagation();
                                    onToggleInstall(app.id);
                                }}
                                className={`px-4 py-2 rounded-full text-xs font-bold uppercase tracking-wider transition-all duration-200 border ${isInstalled
                                        ? 'bg-transparent border-white/20 text-white hover:bg-red-500/20 hover:border-red-500 hover:text-red-500'
                                        : 'bg-[var(--brand)] border-transparent text-white hover:brightness-110 shadow-lg hover:shadow-[var(--brand)]/20'
                                    }`}
                            >
                                {isInstalled ? 'Remove' : 'Get'}
                            </button>
                        </div>
                    );
                })}
            </div>
        </div>
    );
};

export default AppStore;
