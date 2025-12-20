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
        primary: designTokens.colors.brand.base,
        secondary: designTokens.colors.brand.light,
        accent: designTokens.colors.accent.line,
        neutral: designTokens.colors.neutral,
      },
      fontFamily: {
        heading: designTokens.typography.fontFamilies.primary.split(','),
        body: designTokens.typography.fontFamilies.body.split(','),
      },
      fontSize: designTokens.typography.fontSizes,
      fontWeight: designTokens.typography.fontWeights,
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
