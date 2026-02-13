import React from 'react';
import { PauseCircle, PlayCircle, SkipBack, SkipForward, X } from 'lucide-react';
import { useAudio } from '../context/AudioContext';

export default function MiniPlayerBar() {
  const { currentUrl, currentTitle, currentArtist, currentImageUrl, isPlaying, pause, resume, stop } = useAudio();

  if (!currentUrl) return null;

  return (
    <div className="t4l-mini-player-wrap">
      <div className="t4l-mini-player">
        <div className="t4l-mini-art">
          {currentImageUrl ? (
            <img src={currentImageUrl} alt={currentTitle ?? 'Now playing'} />
          ) : (
            <div className="t4l-mini-art-fallback" />
          )}
        </div>

        <div className="t4l-mini-meta">
          <p className="t4l-mini-title">{currentTitle ?? 'Now Playing'}</p>
          <p className="t4l-mini-artist">{currentArtist ?? 'T4L Radio'}</p>
        </div>

        <div className="t4l-mini-controls">
          <button type="button" className="t4l-mini-ghost" aria-label="Previous track">
            <SkipBack size={18} />
          </button>
          <button
            type="button"
            className="t4l-mini-play"
            aria-label={isPlaying ? 'Pause' : 'Play'}
            onClick={isPlaying ? pause : resume}
          >
            {isPlaying ? <PauseCircle size={28} /> : <PlayCircle size={28} />}
          </button>
          <button type="button" className="t4l-mini-ghost" aria-label="Next track">
            <SkipForward size={18} />
          </button>
          <button type="button" className="t4l-mini-close" aria-label="Stop" onClick={stop}>
            <X size={14} />
          </button>
        </div>
      </div>
    </div>
  );
}
