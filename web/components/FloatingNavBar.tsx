import React, { useState, useEffect } from 'react';
import { Home, LayoutGrid, Trophy, User, History } from 'lucide-react';
import { Team } from '../types';
import TeamSelector from './TeamSelector';

interface FloatingNavBarProps {
    onOpenBreakingNews?: () => void;
    hasUnread?: boolean;
    onHome: () => void;
    onAppStore: () => void;
    onHistory: () => void;
    onSettings: () => void;
}

const NFL_LOGO_URL = "https://upload.wikimedia.org/wikipedia/en/a/a2/National_Football_League_logo.svg";

const FloatingNavBar: React.FC<FloatingNavBarProps> = ({
    onOpenBreakingNews,
    hasUnread,
    onHome,
    onAppStore,
    onHistory,
    onSettings
}) => {
    const [favoriteTeam, setFavoriteTeam] = useState<Team | null>(null);
    const [isSelectorOpen, setIsSelectorOpen] = useState(false);

    useEffect(() => {
        const storedTeam = localStorage.getItem('favorite_team');
        if (storedTeam) {
            try {
                setFavoriteTeam(JSON.parse(storedTeam));
            } catch (e) {
                console.error("Failed to parse favorite team", e);
            }
        }
    }, []);

    const handleTeamSelect = (team: Team) => {
        setFavoriteTeam(team);
        localStorage.setItem('favorite_team', JSON.stringify(team));
        setIsSelectorOpen(false);
        window.dispatchEvent(new CustomEvent('teamSelected'));
    };


    return (
        <>
            <nav
                className="fixed bottom-6 left-6 right-6 h-16 backdrop-blur-xl border border-white/40 dark:border-white/10 rounded-2xl shadow-2xl z-[200] flex justify-around items-center px-2 transition-colors duration-500"
                style={{ backgroundColor: 'var(--nav-bg)' }}
            >
                {/* Slot 1: Home (H) */}
                <button
                    onClick={onHome}
                    className="flex flex-col items-center justify-center w-12 h-12 rounded-xl text-primary dark:text-secondary group transition-all duration-300"
                >
                    <span className="font-['Anton'] text-2xl font-bold group-hover:scale-110 transition-transform">H</span>
                    <div className="w-1 h-1 bg-primary dark:bg-secondary rounded-full mt-0.5 opacity-0 group-hover:opacity-100 transition-opacity"></div>
                </button>

                {/* Slot 2: App Store */}
                <button
                    onClick={onAppStore}
                    className="flex flex-col items-center justify-center w-12 h-12 rounded-xl text-zinc-500 dark:text-zinc-400 hover:text-primary dark:hover:text-secondary transition-all group"
                >
                    <LayoutGrid size={24} className="group-hover:scale-110 transition-transform" />
                </button>

                {/* Slot 3: Team Logo (Center) */}
                <button
                    onClick={() => setIsSelectorOpen(true)}
                    className={`relative -top-6 h-14 w-14 bg-white dark:bg-zinc-900 rounded-2xl shadow-lg flex items-center justify-center transform hover:scale-105 active:scale-95 transition-all duration-200 border-4 ${favoriteTeam ? 'border-primary dark:border-primary' : 'border-red-500 animate-pulse ring-4 ring-red-500/20'
                        }`}
                >
                    {favoriteTeam ? (
                        <div className="w-full h-full p-2">
                            <img
                                src={favoriteTeam.logo_url}
                                alt={favoriteTeam.team_name}
                                className="w-full h-full object-contain"
                            />
                        </div>
                    ) : (
                        <div className="w-full h-full p-2 flex items-center justify-center">
                            <img
                                src={NFL_LOGO_URL}
                                onError={(e) => {
                                    e.currentTarget.style.display = 'none';
                                    e.currentTarget.nextElementSibling?.classList.remove('hidden');
                                }}
                                alt="NFL"
                                className="w-full h-full object-contain opacity-80"
                            />
                            <Trophy size={28} className="text-red-500 hidden" fill="currentColor" />
                        </div>
                    )}
                </button>

                {/* Slot 4: Last App Placeholder */}
                <button
                    onClick={onHistory}
                    className="flex flex-col items-center justify-center w-12 h-12 rounded-xl text-zinc-500 dark:text-zinc-400 hover:text-primary dark:hover:text-secondary transition-all group"
                >
                    <History size={24} className="group-hover:scale-110 transition-transform opacity-60" />
                </button>

                {/* Slot 5: Personal Side (User) */}
                <button
                    onClick={onSettings}
                    className="flex flex-col items-center justify-center w-12 h-12 rounded-xl text-zinc-500 dark:text-zinc-400 hover:text-primary dark:hover:text-secondary transition-all group"
                >
                    <User size={24} className="group-hover:scale-110 transition-transform" />
                </button>
            </nav>

            {isSelectorOpen && (
                <TeamSelector
                    onSelect={handleTeamSelect}
                    onClose={() => setIsSelectorOpen(false)}
                />
            )}
        </>
    );
};

export default FloatingNavBar;

