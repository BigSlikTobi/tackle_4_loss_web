import React from 'react';
import { SHELL_APPS, ShellAppId } from '../constants/apps';

interface AppStoreProps {
  onOpenApp: (appId: ShellAppId) => void;
  installedApps: ShellAppId[];
  onToggleInstall: (appId: ShellAppId) => void;
}

export default function AppStore({ onOpenApp, installedApps, onToggleInstall }: AppStoreProps) {
  return (
    <section className="t4l-page t4l-page-narrow">
      <header className="t4l-page-header">
        <p className="t4l-page-eyebrow">App Hub</p>
        <h2>Manage Apps</h2>
        <p>Install and launch micro apps from the same catalog as the Flutter shell.</p>
      </header>

      <div className="t4l-card-list">
        {SHELL_APPS.map((app) => {
          const isInstalled = installedApps.includes(app.id);

          return (
            <article key={app.id} className="t4l-card-row">
              <button
                type="button"
                className="t4l-card-row-main"
                onClick={() => onOpenApp(app.id)}
                disabled={!isInstalled}
                title={isInstalled ? `Open ${app.name}` : `${app.name} is not installed`}
              >
                <span className="t4l-card-icon-wrap">
                  <img src={app.icon} alt="" aria-hidden="true" />
                </span>
                <span className="t4l-card-text">
                  <strong>{app.name}</strong>
                  <small>{app.description}</small>
                </span>
              </button>

              <button
                type="button"
                className={`t4l-install-button ${isInstalled ? 'is-installed' : ''}`}
                onClick={() => onToggleInstall(app.id)}
              >
                {isInstalled ? 'Remove' : 'Install'}
              </button>
            </article>
          );
        })}
      </div>
    </section>
  );
}
