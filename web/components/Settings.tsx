import React, { useState } from 'react';
import { useTeamTheme } from '../hooks/useTeamTheme';
import { Settings as SettingsIcon, Globe, Shield } from 'lucide-react';
import TeamSelector from './TeamSelector';

interface SettingsProps {
    selectedLanguage: 'de' | 'en';
    onChangeLanguage: (lang: 'de' | 'en') => void;
}

const Settings: React.FC<SettingsProps> = ({ selectedLanguage, onChangeLanguage }) => {
    const { currentTeam } = useTeamTheme();
    const [isTeamSelectorOpen, setIsTeamSelectorOpen] = useState(false);

    return (
        <div className="w-full max-w-2xl mx-auto pt-24 px-6 pb-32 animate-fade-in text-white">
            <h1 className="text-4xl font-['Anton'] mb-2 flex items-center gap-3">
                <SettingsIcon size={32} strokeWidth={1.5} /> Settings
            </h1>
            <p className="text-zinc-400 mb-8">Personalize your experience.</p>

            <div className="space-y-6">
                {/* Language Section */}
                <div className="bg-zinc-900/50 backdrop-blur-md border border-white/10 p-6 rounded-3xl">
                    <div className="flex items-center gap-3 mb-4">
                        <div className="p-2 bg-blue-500/20 text-blue-400 rounded-xl">
                            <Globe size={24} />
                        </div>
                        <h2 className="text-xl font-bold">Language</h2>
                    </div>

                    <div className="flex bg-black/40 p-1.5 rounded-xl">
                        {(['de', 'en'] as const).map((lang) => (
                            <button
                                key={lang}
                                onClick={() => onChangeLanguage(lang)}
                                className={`flex-1 py-3 rounded-lg text-sm font-bold uppercase tracking-wide transition-all ${selectedLanguage === lang
                                        ? 'bg-[var(--brand)] text-white shadow-lg'
                                        : 'text-zinc-500 hover:text-zinc-300 hover:bg-white/5'
                                    }`}
                            >
                                {lang === 'de' ? 'Deutsch' : 'English'}
                            </button>
                        ))}
                    </div>
                </div>

                {/* Team Section */}
                <div className="bg-zinc-900/50 backdrop-blur-md border border-white/10 p-6 rounded-3xl">
                    <div className="flex items-center gap-3 mb-4">
                        <div className="p-2 bg-[var(--brand)]/20 text-[var(--brand)] rounded-xl">
                            <Shield size={24} />
                        </div>
                        <h2 className="text-xl font-bold">Favorite Team</h2>
                    </div>

                    <div
                        onClick={() => setIsTeamSelectorOpen(true)}
                        className="flex items-center gap-4 bg-black/40 p-4 rounded-2xl cursor-pointer hover:bg-black/60 transition-colors border border-white/5 group"
                    >
                        {currentTeam ? (
                            <div className="w-16 h-16 bg-white rounded-xl p-2 shadow-sm">
                                <img src={currentTeam.logo_url} alt={currentTeam.team_name} className="w-full h-full object-contain" />
                            </div>
                        ) : (
                            <div className="w-16 h-16 bg-zinc-800 rounded-xl flex items-center justify-center text-zinc-500">?</div>
                        )}

                        <div className="flex-1">
                            <h3 className="text-lg font-bold text-white group-hover:text-[var(--brand)] transition-colors">
                                {currentTeam ? currentTeam.team_name : "Select a Team"}
                            </h3>
                            <p className="text-sm text-zinc-400">Tap to change</p>
                        </div>
                    </div>
                </div>
            </div>

            {isTeamSelectorOpen && (
                <TeamSelector
                    onSelect={(team) => {
                        localStorage.setItem('favorite_team', JSON.stringify(team));
                        window.dispatchEvent(new CustomEvent('teamSelected'));
                        setIsTeamSelectorOpen(false);
                    }}
                    onClose={() => setIsTeamSelectorOpen(false)}
                />
            )}
        </div>
    );
};

export default Settings;
