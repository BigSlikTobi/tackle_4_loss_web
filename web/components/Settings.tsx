import React, { useEffect, useState } from 'react';
import { CheckCircle } from 'lucide-react';
import { useTeamTheme } from '../hooks/useTeamTheme';
import TeamSelector from './TeamSelector';
import { DEFAULT_USER_SETTINGS_LAYOUT, loadUserSettingsLayout } from '../lib/parity/userSettingsParityAdapter';

interface SettingsProps {
  selectedLanguage: 'de' | 'en';
  onChangeLanguage: (lang: 'de' | 'en') => void;
}

const DARK_MODE_STORAGE_KEY = 'settings_dark_mode';

const Settings: React.FC<SettingsProps> = ({ selectedLanguage, onChangeLanguage }) => {
  const { currentTeam } = useTeamTheme();
  const [isTeamSelectorOpen, setIsTeamSelectorOpen] = useState(false);
  const [layout, setLayout] = useState(DEFAULT_USER_SETTINGS_LAYOUT);
  const [isDarkMode, setIsDarkMode] = useState<boolean>(() => localStorage.getItem(DARK_MODE_STORAGE_KEY) === '1');

  useEffect(() => {
    const controller = new AbortController();
    loadUserSettingsLayout(controller.signal).then((nextLayout) => {
      setLayout(nextLayout);
    });
    return () => controller.abort();
  }, []);

  const toggleDarkMode = () => {
    setIsDarkMode((prev) => {
      const next = !prev;
      localStorage.setItem(DARK_MODE_STORAGE_KEY, next ? '1' : '0');
      return next;
    });
  };

  return (
    <section className="t4l-page t4l-page-narrow">
      <article
        className={`t4l-settings-shell ${isDarkMode ? 'is-dark' : ''}`}
        style={
          {
            '--t4l-settings-dialog-radius': `${layout.dialogRadius}px`,
            '--t4l-settings-dialog-padding': `${layout.dialogPadding}px`,
            '--t4l-settings-title-size': `${layout.titleFontSize}px`,
            '--t4l-settings-section-title-size': `${layout.sectionTitleFontSize}px`,
            '--t4l-settings-section-title-letter-spacing': `${layout.sectionTitleLetterSpacing}px`,
            '--t4l-settings-section-gap': `${layout.sectionGap}px`,
            '--t4l-settings-subsection-gap': `${layout.subsectionGap}px`,
            '--t4l-settings-lang-padding-x': `${layout.languageOptionPaddingX}px`,
            '--t4l-settings-lang-padding-y': `${layout.languageOptionPaddingY}px`,
            '--t4l-settings-lang-radius': `${layout.languageOptionRadius}px`,
            '--t4l-settings-lang-check-size': `${layout.languageCheckIconSize}px`,
            '--t4l-settings-appearance-padding-x': `${layout.appearancePaddingX}px`,
            '--t4l-settings-appearance-padding-y': `${layout.appearancePaddingY}px`,
            '--t4l-settings-appearance-radius': `${layout.appearanceRadius}px`,
            '--t4l-settings-team-padding': `${layout.teamCardPadding}px`,
            '--t4l-settings-team-radius': `${layout.teamCardRadius}px`,
            '--t4l-settings-team-logo-width': `${layout.teamLogoWidth}px`,
            '--t4l-settings-team-logo-height': `${layout.teamLogoHeight}px`,
            '--t4l-settings-team-logo-padding': `${layout.teamLogoPadding}px`,
            '--t4l-settings-team-logo-radius': `${layout.teamLogoRadius}px`,
            '--t4l-settings-team-gap': `${layout.teamRowGap}px`,
          } as React.CSSProperties
        }
      >
        <h2 className="t4l-settings-title">Settings</h2>

        <div className="t4l-settings-dialog-sections">
          <div className="t4l-settings-dialog-section">
            <p className="t4l-settings-section-label">Language</p>
            <div className="t4l-settings-language-list">
              {([
                { key: 'en', label: 'English' },
                { key: 'de', label: 'Deutsch' },
              ] as const).map((option) => {
                const selected = selectedLanguage === option.key;
                return (
                  <button
                    key={option.key}
                    type="button"
                    onClick={() => onChangeLanguage(option.key)}
                    className={`t4l-language-option ${selected ? 'is-selected' : ''}`}
                  >
                    <span>{option.label}</span>
                    {selected ? <CheckCircle size={layout.languageCheckIconSize} /> : null}
                  </button>
                );
              })}
            </div>
          </div>

          <div className="t4l-settings-dialog-section">
            <p className="t4l-settings-section-label">APPEARANCE</p>
            <div className="t4l-settings-appearance-row">
              <span>Dark Mode</span>
              <button
                type="button"
                className={`t4l-settings-switch ${isDarkMode ? 'is-on' : ''}`}
                onClick={toggleDarkMode}
                aria-pressed={isDarkMode}
              >
                <span className="t4l-settings-switch-knob" />
              </button>
            </div>
          </div>

          <div className="t4l-settings-dialog-section">
            <p className="t4l-settings-section-label">YOUR TEAM</p>
            <button type="button" className="t4l-settings-team-row" onClick={() => setIsTeamSelectorOpen(true)}>
              <span className="t4l-settings-team-logo">
                <img src={currentTeam?.logo_url || '/icons/nfl_logo.png'} alt={currentTeam?.team_name || 'NFL'} />
              </span>
              <span className="t4l-settings-team-name">{currentTeam?.team_name || 'No Team Selected'}</span>
              <span className="t4l-settings-team-change">CHANGE</span>
            </button>
          </div>
        </div>
      </article>

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
