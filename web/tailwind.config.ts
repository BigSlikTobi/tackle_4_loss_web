import { designTokens } from './design-tokens';

/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
    "./*.{js,ts,jsx,tsx}",
    "./components/**/*.{js,ts,jsx,tsx}",
  ],
  darkMode: 'class',
  theme: {
    extend: {
      colors: {
        primary: designTokens.colors.primary,
        secondary: designTokens.colors.secondary,
        accent: designTokens.colors.accent,
        neutral: designTokens.colors.neutral,
        football: designTokens.colors.football,
      },
      fontFamily: {
        headline: designTokens.typography.fontFamilies.headline.split(','),
        subheadline: designTokens.typography.fontFamilies.subheadline.split(','),
        body: designTokens.typography.fontFamilies.body.split(','),
        mono: designTokens.typography.fontFamilies.mono.split(','),
        accent: designTokens.typography.fontFamilies.accent.split(','),
      },
      fontSize: designTokens.typography.fontSizes,
      fontWeight: designTokens.typography.fontWeights,
      lineHeight: designTokens.typography.lineHeights,
      letterSpacing: designTokens.typography.letterSpacing,
      spacing: designTokens.spacing,
      borderRadius: designTokens.borders.radius,
      borderWidth: designTokens.borders.width,
      boxShadow: designTokens.shadows,
      transitionDuration: designTokens.animation.durations,
      transitionTimingFunction: designTokens.animation.easings,
      screens: designTokens.breakpoints,
      zIndex: designTokens.zIndex,
    },
  },
  plugins: [],
}
