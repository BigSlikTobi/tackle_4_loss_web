import React from 'react';
import { SHELL_APPS, ShellAppId } from '../constants/apps';

interface AppStripProps {
  installedApps: ShellAppId[];
  onOpenApp: (appId: ShellAppId) => void;
}

export default function AppStrip({ installedApps, onOpenApp }: AppStripProps) {
  const apps = SHELL_APPS.filter((app) => installedApps.includes(app.id) && app.id !== 'standings');

  return (
    <section className="t4l-app-strip" aria-label="Installed apps">
      <div className="t4l-app-strip-scroll">
        {apps.map((app) => (
          <button
            key={app.id}
            type="button"
            className="t4l-app-strip-item"
            onClick={() => onOpenApp(app.id)}
            title={app.name}
          >
            <span className="t4l-app-strip-icon-wrap">
              <img className="t4l-app-strip-icon" src={app.icon} alt="" aria-hidden="true" />
            </span>
          </button>
        ))}
      </div>
    </section>
  );
}
