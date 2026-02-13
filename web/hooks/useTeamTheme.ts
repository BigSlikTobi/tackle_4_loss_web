import { useEffect, useState } from 'react';
import ColorThief from 'colorthief';
import { Team } from '../types';
import { designTokens } from '../design-tokens';

const STORAGE_KEY = 'favorite_team';
const DEFAULT_BRAND_COLOR = designTokens.colors.brand.base;
const DEFAULT_BRAND_LIGHT_COLOR = designTokens.colors.brand.light;

interface TeamThemeState {
  currentTeam: Team | null;
  brandColor: string;
  brandLightColor: string;
}

export function useTeamTheme(): TeamThemeState {
  const [currentTeam, setCurrentTeam] = useState<Team | null>(null);
  const [brandColor, setBrandColor] = useState<string>(DEFAULT_BRAND_COLOR);
  const [brandLightColor, setBrandLightColor] = useState<string>(DEFAULT_BRAND_LIGHT_COLOR);

  useEffect(() => {
    const updateTheme = async () => {
      const storedTeam = localStorage.getItem(STORAGE_KEY);
      if (!storedTeam) {
        setCurrentTeam(null);
        applyTheme(DEFAULT_BRAND_COLOR, DEFAULT_BRAND_LIGHT_COLOR, null);
        return;
      }

      try {
        const team = JSON.parse(storedTeam) as Team;
        setCurrentTeam(team);

        if (team.primary_color && team.secondary_color) {
          // Flutter light mode convention:
          // brand = team.secondaryColor, brandLight = team.primaryColor.
          applyTheme(team.secondary_color, team.primary_color, team.logo_url);
          setBrandColor(team.secondary_color);
          setBrandLightColor(team.primary_color);
          return;
        }

        if (!team.logo_url) {
          applyTheme(DEFAULT_BRAND_COLOR, DEFAULT_BRAND_LIGHT_COLOR, null);
          setBrandColor(DEFAULT_BRAND_COLOR);
          setBrandLightColor(DEFAULT_BRAND_LIGHT_COLOR);
          return;
        }

        const img = new Image();
        img.crossOrigin = 'anonymous';
        img.src = team.logo_url;
        img.onload = () => {
          const colorThief = new ColorThief();
          try {
            const [r, g, b] = colorThief.getColor(img);
            const extracted = `rgb(${r}, ${g}, ${b})`;
            const extractedLight = mixWithWhite(extracted, 0.2);

            applyTheme(extracted, extractedLight, team.logo_url);
            setBrandColor(extracted);
            setBrandLightColor(extractedLight);
          } catch {
            applyTheme(DEFAULT_BRAND_COLOR, DEFAULT_BRAND_LIGHT_COLOR, team.logo_url);
            setBrandColor(DEFAULT_BRAND_COLOR);
            setBrandLightColor(DEFAULT_BRAND_LIGHT_COLOR);
          }
        };

        img.onerror = () => {
          applyTheme(DEFAULT_BRAND_COLOR, DEFAULT_BRAND_LIGHT_COLOR, team.logo_url);
          setBrandColor(DEFAULT_BRAND_COLOR);
          setBrandLightColor(DEFAULT_BRAND_LIGHT_COLOR);
        };
      } catch {
        setCurrentTeam(null);
        applyTheme(DEFAULT_BRAND_COLOR, DEFAULT_BRAND_LIGHT_COLOR, null);
        setBrandColor(DEFAULT_BRAND_COLOR);
        setBrandLightColor(DEFAULT_BRAND_LIGHT_COLOR);
      }
    };

    updateTheme();
    window.addEventListener('storage', updateTheme);
    window.addEventListener('teamSelected', updateTheme);

    return () => {
      window.removeEventListener('storage', updateTheme);
      window.removeEventListener('teamSelected', updateTheme);
    };
  }, []);

  return { currentTeam, brandColor, brandLightColor };
}

function applyTheme(brandColor: string, brandLightColor: string, logoUrl: string | null) {
  const root = document.documentElement;
  root.style.setProperty('--brand', brandColor);
  root.style.setProperty('--brand-light', brandLightColor);
  root.style.setProperty('--brand-strong', adjustBrightness(brandColor, -20));

  const appGradientStart = mixWithWhite(brandLightColor, 0.85);
  const appGradientEnd = mixWithWhite(brandLightColor, 0.6);
  root.style.setProperty(
    '--app-background-gradient',
    `linear-gradient(135deg, ${appGradientStart} 0%, ${appGradientEnd} 100%)`,
  );

  const dockTint = setAlpha(mixWithWhite(brandColor, 0.75), 0.68);
  root.style.setProperty('--nav-bg', dockTint);

  if (logoUrl) {
    root.style.setProperty('--team-logo-url', `url('${logoUrl}')`);
  } else {
    root.style.removeProperty('--team-logo-url');
  }
}

function setAlpha(input: string, alpha: number): string {
  const rgb = parseRgb(input);
  if (!rgb) {
    return input;
  }
  return `rgba(${rgb.r}, ${rgb.g}, ${rgb.b}, ${alpha})`;
}

function mixWithWhite(input: string, amount: number): string {
  const rgb = parseRgb(input);
  if (!rgb) {
    return '#f9fafb';
  }

  const r = Math.round(rgb.r + (255 - rgb.r) * amount);
  const g = Math.round(rgb.g + (255 - rgb.g) * amount);
  const b = Math.round(rgb.b + (255 - rgb.b) * amount);

  return `rgb(${r}, ${g}, ${b})`;
}

function adjustBrightness(input: string, amount: number): string {
  const rgb = parseRgb(input);
  if (!rgb) {
    return input;
  }

  const r = clamp(rgb.r + amount);
  const g = clamp(rgb.g + amount);
  const b = clamp(rgb.b + amount);

  return `rgb(${r}, ${g}, ${b})`;
}

function clamp(value: number) {
  return Math.max(0, Math.min(255, value));
}

function parseRgb(input: string): { r: number; g: number; b: number } | null {
  if (input.startsWith('#')) {
    const hex = input.replace('#', '');
    if (hex.length !== 6) {
      return null;
    }
    return {
      r: parseInt(hex.slice(0, 2), 16),
      g: parseInt(hex.slice(2, 4), 16),
      b: parseInt(hex.slice(4, 6), 16),
    };
  }

  const match = input.match(/rgb\((\d+),\s*(\d+),\s*(\d+)\)/);
  if (!match) {
    return null;
  }

  return {
    r: Number(match[1]),
    g: Number(match[2]),
    b: Number(match[3]),
  };
}
