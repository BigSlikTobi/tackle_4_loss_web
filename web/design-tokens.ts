/**
 * Design Tokens for Tackle4Loss DeepDives
 * New design system based on the provided HTML reference.
 * Cross-platform compatible (Web & Flutter/Dart)
 */

export const designTokens = {
  // ============================================
  // COLORS
  // ============================================
  colors: {
    primary: "#113528", // Dark Green
    secondary: "#D4B363", // Gold
    accent: "#C92A2A", // Red for live/breaking
    background: {
      light: "#F3F5F7",
      dark: "#000000",
    },
    card: {
      light: "#FFFFFF",
      dark: "#111111",
    },
    text: {
      main: {
        light: "#113528",
        dark: "#F9FAFB",
      },
      sub: {
        light: "#5D7369",
        dark: "#9CA3AF",
      },
    },
  },

  // ============================================
  // TYPOGRAPHY
  // ============================================
  typography: {
    fontFamilies: {
      sans: '"Inter", sans-serif',
    },
    fontSizes: {
      'xs': '0.75rem',   // 12px
      'sm': '0.875rem',  // 14px
      'base': '1rem',      // 16px
      'lg': '1.125rem',  // 18px
      'xl': '1.25rem',  // 20px
      '2xl': '1.5rem',   // 24px
      '3xl': '1.875rem', // 30px
      '4xl': '2.25rem',  // 36px
      '5xl': '3rem',     // 48px
    },
    fontWeights: {
      normal: 400,
      medium: 500,
      semibold: 600,
      bold: 700,
      extrabold: 800,
      black: 900,
    },
  },

  // ============================================
  // SPACING
  // ============================================
  spacing: {
    0: '0',
    1: '0.25rem',   // 4px
    2: '0.5rem',    // 8px
    3: '0.75rem',   // 12px
    4: '1rem',      // 16px
    5: '1.25rem',   // 20px
    6: '1.5rem',    // 24px
    8: '2rem',      // 32px
    10: '2.5rem',   // 40px
    12: '3rem',     // 48px
    16: '4rem',     // 64px
    20: '5rem',     // 80px
    24: '6rem',     // 96px
  },

  // ============================================
  // BORDERS & RADIUS
  // ============================================
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
        xl: '1rem',
        '2xl': '1.5rem',
        '3xl': '2rem',
        '4xl': '2.5rem',
        full: '9999px',
    }
  },

  // ============================================
  // SHADOWS
  // ============================================
  shadows: {
    sm: '0 1px 2px 0 rgba(0, 0, 0, 0.05)',
    base: '0 1px 3px 0 rgba(0, 0, 0, 0.1), 0 1px 2px -1px rgba(0, 0, 0, 0.1)',
    md: '0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -2px rgba(0, 0, 0, 0.1)',
    lg: '0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -4px rgba(0, 0, 0, 0.1)',
    xl: '0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 8px 10px -6px rgba(0, 0, 0, 0.1)',
    '2xl': '0 25px 50px -12px rgba(0, 0, 0, 0.25)',
    inner: 'inset 0 2px 4px 0 rgba(0, 0, 0, 0.05)',
  },

  // ============================================
  // ANIMATION
  // ============================================
  animation: {
    durations: {
      75: '75ms',
      100: '100ms',
      150: '150ms',
      200: '200ms',
      300: '300ms',
      500: '500ms',
      700: '700ms',
      1000: '1000ms',
    },
    easings: {
      'ease-in-out': 'ease-in-out',
      'ease-out': 'ease-out',
    },
    definitions: {
        'wave': 'wave 1.2s ease-in-out infinite',
        'fade-in': 'fadeIn 0.5s ease-out forwards',
    },
    keyframes: {
        wave: {
            '0%, 100%': { height: '8px' },
            '50%': { height: '16px' },
        },
        fadeIn: {
            '0%': { opacity: '0', transform: 'translateY(10px)' },
            '100%': { opacity: '1', transform: 'translateY(0)' },
        }
    }
  },

  // ============================================
  // BREAKPOINTS & Z-INDEX
  // ============================================
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
    10: 10,
    20: 20,
    30: 30,
    40: 40,
    50: 50,
  }
};

export default designTokens;
