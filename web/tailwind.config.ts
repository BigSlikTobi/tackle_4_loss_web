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
        'background-light': designTokens.colors.background.light,
        'background-dark': designTokens.colors.background.dark,
        'card-light': designTokens.colors.card.light,
        'card-dark': designTokens.colors.card.dark,
        'text-main-light': designTokens.colors.text.main.light,
        'text-main-dark': designTokens.colors.text.main.dark,
        'text-sub-light': designTokens.colors.text.sub.light,
        'text-sub-dark': designTokens.colors.text.sub.dark,
      },
      fontFamily: {
        sans: [designTokens.typography.fontFamilies.sans],
      },
      fontSize: designTokens.typography.fontSizes,
      fontWeight: designTokens.typography.fontWeights,
      spacing: designTokens.spacing,
      borderRadius: designTokens.borders.radius,
      borderWidth: designTokens.borders.width,
      boxShadow: designTokens.shadows,
      transitionDuration: designTokens.animation.durations,
      transitionTimingFunction: designTokens.animation.easings,
      animation: designTokens.animation.definitions,
      keyframes: designTokens.animation.keyframes,
      screens: designTokens.breakpoints,
      zIndex: designTokens.zIndex,
    },
  },
  plugins: [],
}
