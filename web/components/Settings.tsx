import React, { useState } from 'react';
import { useTeamTheme } from '../hooks/useTeamTheme';
import { Globe, Shield } from 'lucide-react';
import TeamSelector from './TeamSelector';

interface SettingsProps {
    selectedLanguage: 'de' | 'en';
    onChangeLanguage: (lang: 'de' | 'en') => void;
}

const Settings: React.FC<SettingsProps> = ({ selectedLanguage, onChangeLanguage }) => {
    const { currentTeam } = useTeamTheme();
    const [isTeamSelectorOpen, setIsTeamSelectorOpen] = useState(false);

    return (
        <section className="t4l-page t4l-page-narrow">
            <header className="t4l-page-header">
                <p className="t4l-page-eyebrow">Settings</p>
                <h2>Personal Preferences</h2>
                <p>Language and team selection sync with the dock and shell theme.</p>
            </header>

            <div className="t4l-settings-grid">
                <article className="t4l-settings-card">
                    <div className="t4l-settings-card-head">
                        <Globe size={18} />
                        <h3>Language</h3>
                    </div>
                    <div className="t4l-segmented">
                        {(['de', 'en'] as const).map((lang) => (
                            <button
                                key={lang}
                                type="button"
                                onClick={() => onChangeLanguage(lang)}
                                className={selectedLanguage === lang ? 'is-active' : ''}
                            >
                                {lang === 'de' ? 'Deutsch' : 'English'}
                            </button>
                        ))}
                    </div>
                </article>

                <article className="t4l-settings-card">
                    <div className="t4l-settings-card-head">
                        <Shield size={18} />
                        <h3>Favorite Team</h3>
                    </div>
                    <button type="button" className="t4l-team-picker" onClick={() => setIsTeamSelectorOpen(true)}>
                        <span className="t4l-team-picker-icon">
                            {currentTeam ? <img src={currentTeam.logo_url} alt={currentTeam.team_name} /> : '?'}
                        </span>
                        <span className="t4l-team-picker-text">
                            <strong>{currentTeam ? currentTeam.team_name : 'Select a Team'}</strong>
                            <small>Tap to choose your team</small>
                        </span>
                    </button>
                </article>
            </div>

            {isTeamSelectorOpen ? (
                <TeamSelector
                    onSelect={(team) => {
                        localStorage.setItem('favorite_team', JSON.stringify(team));
                        window.dispatchEvent(new CustomEvent('teamSelected'));
                        setIsTeamSelectorOpen(false);
                    }}
                    onClose={() => setIsTeamSelectorOpen(false)}
                />
            ) : null}
        </section>
    );
};

export default Settings;
