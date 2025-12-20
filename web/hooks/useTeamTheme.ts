import { useEffect, useState } from 'react';
import ColorThief from 'colorthief';

const DEFAULT_BRAND_COLOR = '#0f3d2e';

export function useTeamTheme() {
    const [teamColor, setTeamColor] = useState<string>(DEFAULT_BRAND_COLOR);

    useEffect(() => {
        const updateTheme = async () => {
            const storedTeam = localStorage.getItem('favorite_team');
            if (storedTeam) {
                try {
                    const team = JSON.parse(storedTeam);
                    if (team.logo_url) {
                        const img = new Image();
                        img.crossOrigin = 'Anonymous';
                        img.src = team.logo_url;

                        img.onload = () => {
                            const colorThief = new ColorThief();
                            try {
                                const color = colorThief.getColor(img);
                                const colorString = `rgb(${color[0]}, ${color[1]}, ${color[2]})`;
                                setTeamColor(colorString);
                                applyTheme(colorString, team.logo_url);
                            } catch (e) {
                                console.error('Error extracting color', e);
                                applyTheme(DEFAULT_BRAND_COLOR, null);
                            }
                        };

                        img.onerror = () => {
                            applyTheme(DEFAULT_BRAND_COLOR, null);
                        }
                    } else {
                        applyTheme(DEFAULT_BRAND_COLOR, null);
                    }
                } catch (e) {
                    applyTheme(DEFAULT_BRAND_COLOR, null);
                }
            } else {
                applyTheme(DEFAULT_BRAND_COLOR, null);
            }
        };

        // Listen for storage changes (in case updated from another tab or component)
        window.addEventListener('storage', updateTheme);
        // Custom event for same-tab updates
        window.addEventListener('teamSelected', updateTheme);

        // Initial load
        updateTheme();

        return () => {
            window.removeEventListener('storage', updateTheme);
            window.removeEventListener('teamSelected', updateTheme);
        };
    }, []);

    const applyTheme = (color: string, logoUrl: string | null) => {
        const root = document.documentElement;
        root.style.setProperty('--brand', color);

        // Darker variant for hover/active
        root.style.setProperty('--brand-strong', adjustBrightness(color, -20));

        // Background tint
        const tint = mixWhite(color, 0.85); // 85% white, 15% color
        root.style.setProperty('--app-bg', tint);

        // Nav bar background tint
        const navTint = mixWhite(color, 0.75); // 75% white, 25% color
        root.style.setProperty('--nav-bg', navTint);

        if (logoUrl) {
            root.style.setProperty('--team-logo-url', `url('${logoUrl}')`);
        } else {
            root.style.removeProperty('--team-logo-url');
        }
    };


    return teamColor;
}

// SIMPLIFIED helper to mix with white
function mixWhite(rgbStr: string, amount: number): string {
    const match = rgbStr.match(/rgb\((\d+),\s*(\d+),\s*(\d+)\)/);
    if (!match) return '#f9fafb';

    let r = parseInt(match[1]);
    let g = parseInt(match[2]);
    let b = parseInt(match[3]);

    r = Math.round(r + (255 - r) * amount);
    g = Math.round(g + (255 - g) * amount);
    b = Math.round(b + (255 - b) * amount);

    return `rgb(${r}, ${g}, ${b})`;
}


// Helper to darken/lighten - simplistic implementation
function adjustBrightness(rgbStr: string, amount: number): string {
    const match = rgbStr.match(/rgb\((\d+),\s*(\d+),\s*(\d+)\)/);
    if (!match) return rgbStr; // Return original if not rgb format

    let r = parseInt(match[1]);
    let g = parseInt(match[2]);
    let b = parseInt(match[3]);

    r = Math.max(0, Math.min(255, r + amount));
    g = Math.max(0, Math.min(255, g + amount));
    b = Math.max(0, Math.min(255, b + amount));

    return `rgb(${r}, ${g}, ${b})`;
}
