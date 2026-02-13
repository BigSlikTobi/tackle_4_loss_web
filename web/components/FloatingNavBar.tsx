import React, { useEffect, useState } from 'react';
import TeamSelector from './TeamSelector';
import { Team } from '../types';

interface FloatingNavBarProps {
  onHome: () => void;
  onGameCenter: () => void;
  onHistory: () => void;
  onSettings: () => void;
}

const NAV_ITEMS = [
  { key: 'home', icon: '/icons/home.svg', label: 'Home' },
  { key: 'game_center', icon: '/icons/schedule.svg', label: 'Game Center' },
  { key: 'history', icon: '/icons/back.svg', label: 'History' },
  { key: 'settings', icon: '/icons/settings.svg', label: 'Settings' },
] as const;

export default function FloatingNavBar({
  onHome,
  onGameCenter,
  onHistory,
  onSettings,
}: FloatingNavBarProps) {
  const [favoriteTeam, setFavoriteTeam] = useState<Team | null>(null);
  const [isSelectorOpen, setIsSelectorOpen] = useState(false);

  useEffect(() => {
    const hydrateTeam = () => {
      const storedTeam = localStorage.getItem('favorite_team');
      if (!storedTeam) {
        setFavoriteTeam(null);
        return;
      }

      try {
        setFavoriteTeam(JSON.parse(storedTeam) as Team);
      } catch {
        setFavoriteTeam(null);
      }
    };

    hydrateTeam();
    window.addEventListener('teamSelected', hydrateTeam);
    window.addEventListener('storage', hydrateTeam);

    return () => {
      window.removeEventListener('teamSelected', hydrateTeam);
      window.removeEventListener('storage', hydrateTeam);
    };
  }, []);

  const handleTeamSelect = (team: Team) => {
    setFavoriteTeam(team);
    localStorage.setItem('favorite_team', JSON.stringify(team));
    setIsSelectorOpen(false);
    window.dispatchEvent(new CustomEvent('teamSelected'));
  };

  return (
    <>
      <nav className="t4l-dock" aria-label="Primary">
        <button type="button" className="t4l-dock-button" onClick={onHome} title={NAV_ITEMS[0].label}>
          <img src={NAV_ITEMS[0].icon} alt="" aria-hidden="true" />
        </button>

        <button
          type="button"
          className="t4l-dock-button"
          onClick={onGameCenter}
          title={NAV_ITEMS[1].label}
        >
          <img src={NAV_ITEMS[1].icon} alt="" aria-hidden="true" />
        </button>

        <div className="t4l-dock-center-spacer" />

        <button
          type="button"
          className="t4l-dock-button"
          onClick={onHistory}
          title={NAV_ITEMS[2].label}
        >
          <img src={NAV_ITEMS[2].icon} alt="" aria-hidden="true" />
        </button>

        <button
          type="button"
          className="t4l-dock-button"
          onClick={onSettings}
          title={NAV_ITEMS[3].label}
        >
          <img src={NAV_ITEMS[3].icon} alt="" aria-hidden="true" />
        </button>

        <button
          type="button"
          onClick={() => setIsSelectorOpen(true)}
          className={`t4l-dock-team-button ${favoriteTeam ? '' : 'is-unset'}`}
          title={favoriteTeam ? favoriteTeam.team_name : 'Select team'}
        >
          <img
            src={favoriteTeam?.logo_url || '/icons/nfl_logo.png'}
            alt={favoriteTeam?.team_name || 'NFL'}
          />
        </button>
      </nav>

      {isSelectorOpen ? (
        <TeamSelector onSelect={handleTeamSelect} onClose={() => setIsSelectorOpen(false)} />
      ) : null}
    </>
  );
}
