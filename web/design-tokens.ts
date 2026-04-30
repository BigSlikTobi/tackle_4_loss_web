/**
 * Web tokens synchronized to Flutter's `flutter_app/lib/design_tokens.dart`.
 * Keep naming compatible with existing Tailwind usage while exposing
 * Flutter-style aliases for shell implementation.
 */
export const designTokens = {
  colors: {
    brand: {
      base: '#0f3d2e',
      light: '#13543e',
    },
    neutral: {
      base: '#ffffff',
      soft: '#f4f4f4',
      border: '#e0e0e0',
      text: '#111111',
      textMuted: '#3a3a3a',
      textLight: '#71717a',
    },
    accent: {
      line: '#cfd4d1',
    },
    semantic: {
      backgroundLight: '#f4f4f4',
      backgroundDark: '#0f1010',
      cardLight: '#ffffff',
      cardDark: '#1a1c1c',
      textMainLight: '#111111',
      textMainDark: '#e0e0e0',
      textSubLight: '#71717a',
      textSubDark: '#a1a1aa',
      breakingNewsRed: '#991b1b',
      breakingNewsRedBright: '#ef4444',
    },
    // Player availability indicators (team center surfaces)
    status: {
      active: '#4caf80', // healthy / active
      quest: '#c9a256', // questionable
      doubtful: '#e08040', // doubtful
      out: '#e06060', // out / IR
    },
    // Editorial accent — used for podcast/premium chips and starter pills
    editorial: {
      gold: '#c9a256',
    },
  },
  typography: {
    fontFamilies: {
      primary: '"Russo One", "Inter", "Segoe UI", system-ui, sans-serif',
      body: '"Inter", "Segoe UI", system-ui, sans-serif',
    },
    fontSizes: {
      sm: '0.875rem',
      md: '1rem',
      lg: '1.25rem',
      xl: '1.75rem',
    },
    fontWeights: {
      regular: 400,
      bold: 700,
    },
  },
  spacing: {
    0: '0',
    1: '0.5rem',
    2: '1rem',
    3: '1.5rem',
    4: '2rem',
    5: '2.5rem',
    6: '3rem',
  },
  borders: {
    width: {
      0: '0',
      1: '1px',
      2: '2px',
      4: '4px',
      8: '8px',
    },
    radius: {
      none: '0',
      sm: '0.125rem',
      base: '0.25rem',
      md: '0.375rem',
      lg: '0.5rem',
      xl: '0.75rem',
      '2xl': '1rem',
      full: '9999px',
    },
  },
  shadows: {
    sm: '0 1px 2px 0 rgba(0, 0, 0, 0.05)',
    base: '0 1px 3px 0 rgba(0, 0, 0, 0.1), 0 1px 2px -1px rgba(0, 0, 0, 0.1)',
    md: '0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -2px rgba(0, 0, 0, 0.1)',
    lg: '0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -4px rgba(0, 0, 0, 0.1)',
    xl: '0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 8px 10px -6px rgba(0, 0, 0, 0.1)',
    newspaper: '2px 2px 8px rgba(0, 0, 0, 0.15)',
  },
  animation: {
    durations: {
      instant: '75ms',
      fast: '150ms',
      normal: '300ms',
      slow: '500ms',
      slower: '750ms',
    },
    easings: {
      linear: 'linear',
      easeIn: 'cubic-bezier(0.4, 0, 1, 1)',
      easeOut: 'cubic-bezier(0, 0, 0.2, 1)',
      easeInOut: 'cubic-bezier(0.4, 0, 0.2, 1)',
      bounce: 'cubic-bezier(0.175, 0.885, 0.32, 1.275)',
    },
  },
  breakpoints: {
    xs: '375px',
    sm: '640px',
    md: '768px',
    lg: '1024px',
    xl: '1280px',
    '2xl': '1536px',
  },
  zIndex: {
    base: 0,
    dropdown: 1000,
    sticky: 1020,
    fixed: 1030,
    modal: 1040,
    popover: 1050,
    tooltip: 1060,
  },
  layout: {
    goldenRatio: 1.618033988749895,
    goldenUpper: 0.381966011250105,
    goldenLower: 0.618033988749895,
  },
} as const;

export type ThemeMode = 'light' | 'dark';

export function resolveThemeColors(mode: ThemeMode = 'light') {
  const semantic = designTokens.colors.semantic;
  if (mode === 'dark') {
    return {
      background: semantic.backgroundDark,
      surface: semantic.cardDark,
      textPrimary: semantic.textMainDark,
      textSecondary: semantic.textSubDark,
      textMuted: designTokens.colors.neutral.textLight,
      border: '#2c2c2e',
    };
  }

  return {
    background: semantic.backgroundLight,
    surface: semantic.cardLight,
    textPrimary: semantic.textMainLight,
    textSecondary: semantic.textSubLight,
    textMuted: designTokens.colors.neutral.textMuted,
    border: designTokens.colors.neutral.border,
  };
}

export default designTokens;
