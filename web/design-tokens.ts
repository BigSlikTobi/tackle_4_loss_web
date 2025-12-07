/**
 * Design Tokens for Tackle4Loss DeepDives
 * Compact set aligned to 60/30/10 palette, 8pt grid, 4 font sizes, 2 weights.
 * Cross-platform compatible (Web & Flutter/Dart)
 */

export const designTokens = {
  // ============================================
  // COLORS - 60% neutral, 30% complementary (near-black), 10% brand (dark green metallic)
  // ============================================
  colors: {
    brand: {
      base: '#0f3d2e',       // Dark green metallic (10%)
      light: '#13543e',
    },
    neutral: {
      base: '#ffffff',       // 60% surface
      soft: '#f4f4f4',
      border: '#e0e0e0',
      text: '#111111',       // 30% complementary
      textMuted: '#3a3a3a',
    },
    accent: {
      line: '#cfd4d1',       // subtle dividers on neutral
    },
  },

  // ============================================
  // TYPOGRAPHY - Max 4 sizes, 2 weights
  // ============================================
  typography: {
    fontFamilies: {
      primary: '"Inter", "Segoe UI", system-ui, sans-serif',
      body: '"Inter", "Segoe UI", system-ui, sans-serif',
    },

    fontSizes: {
      sm: '0.875rem',   // 14px
      md: '1rem',       // 16px
      lg: '1.25rem',    // 20px
      xl: '1.75rem',    // 28px
    },

    fontWeights: {
      regular: 400,
      bold: 700,
    },
  },

  // ============================================
  // SPACING - 8pt grid
  // ============================================
  spacing: {
    0: '0',
    1: '0.5rem',    // 8px
    2: '1rem',      // 16px
    3: '1.5rem',    // 24px
    4: '2rem',      // 32px
    5: '2.5rem',    // 40px
    6: '3rem',      // 48px
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
      sm: '0.125rem',   // 2px
      base: '0.25rem',  // 4px
      md: '0.375rem',   // 6px
      lg: '0.5rem',     // 8px
      xl: '0.75rem',    // 12px
      '2xl': '1rem',    // 16px
      full: '9999px',
    }
  },

  // ============================================
  // SHADOWS - Depth & elevation
  // ============================================
  shadows: {
    sm: '0 1px 2px 0 rgba(0, 0, 0, 0.05)',
    base: '0 1px 3px 0 rgba(0, 0, 0, 0.1), 0 1px 2px -1px rgba(0, 0, 0, 0.1)',
    md: '0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -2px rgba(0, 0, 0, 0.1)',
    lg: '0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -4px rgba(0, 0, 0, 0.1)',
    xl: '0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 8px 10px -6px rgba(0, 0, 0, 0.1)',
    '2xl': '0 25px 50px -12px rgba(0, 0, 0, 0.25)',
    inner: 'inset 0 2px 4px 0 rgba(0, 0, 0, 0.05)',
    newspaper: '2px 2px 8px rgba(0, 0, 0, 0.15)',
  },

  // ============================================
  // ANIMATION - Emotional micro-interactions
  // ============================================
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
      bounce: 'cubic-bezier(0.68, -0.55, 0.265, 1.55)',
      elastic: 'cubic-bezier(0.175, 0.885, 0.32, 1.275)',
    },
    
    // Haptic feedback hints (for mobile implementation)
    haptics: {
      light: 'light',       // Subtle tap feedback
      medium: 'medium',     // Button press
      heavy: 'heavy',       // Important action
      success: 'success',   // Positive confirmation
      warning: 'warning',   // Caution
      error: 'error',       // Negative action
    }
  },

  // ============================================
  // BREAKPOINTS - Responsive design
  // ============================================
  breakpoints: {
    xs: '375px',   // Mobile
    sm: '640px',   // Large mobile
    md: '768px',   // Tablet
    lg: '1024px',  // Desktop
    xl: '1280px',  // Large desktop
    '2xl': '1536px', // Extra large
  },

  // ============================================
  // Z-INDEX - Layering
  // ============================================
  zIndex: {
    base: 0,
    dropdown: 1000,
    sticky: 1020,
    fixed: 1030,
    modal: 1040,
    popover: 1050,
    tooltip: 1060,
  }
};

export default designTokens;
