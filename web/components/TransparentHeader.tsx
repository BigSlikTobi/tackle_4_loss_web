import React from 'react';

interface TransparentHeaderProps {
  title?: string;
  actions?: React.ReactNode;
}

export default function TransparentHeader({ title, actions }: TransparentHeaderProps) {
  return (
    <header className="t4l-header-shell">
      <div className="t4l-header">
        <div className="t4l-header-leading">
          <div className="t4l-header-logo">
            <img src="/T4L_app_logo.png" alt="Tackle4Loss" />
          </div>
          {title ? <h1 className="t4l-header-title">{title}</h1> : null}
        </div>

        {actions ? <div className="t4l-header-actions">{actions}</div> : null}
      </div>
    </header>
  );
}
