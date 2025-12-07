# Tackle4Loss DeepDives - Design System

## 🏈 American Football Newspaper Theme

An emotional, engaging design inspired by classic sports newspapers with modern animations and haptic-ready interactions.

---

## 🎨 Design Philosophy

### Core Principles
1. **Emotional Connection** - Evoke the passion of football through bold typography and vibrant colors
2. **Newspaper Authenticity** - Classic sports section aesthetic with modern web capabilities  
3. **Haptic Engagement** - Visual and interaction patterns ready for mobile haptic feedback
4. **Cross-Platform** - Design tokens work seamlessly across Web (React) and Mobile (Flutter)

### Visual Language
- **Bold Headlines** - Anton & Alfa Slab One fonts for impactful newspaper-style headers
- **Field Green** - Primary brand color inspired by the football field
- **Stadium Lights Gold** - Secondary accent for highlights and victories
- **Newspaper Ink** - Deep black for strong contrast and readability
- **Paper Cream** - Subtle off-white background like vintage newspapers

---

## 📐 Design Tokens

All design decisions are centralized in `design-tokens.ts` for consistency and easy updates.

### Color System

#### Primary (Field Green)
```css
primary-500: #16a34a  /* Main brand green */
primary-600: #15803d  /* Interactive states */
primary-700: #14532d  /* Hover/focus */
```

#### Secondary (Stadium Lights Gold)
```css
secondary-500: #f59e0b  /* Vibrant gold */
secondary-600: #d97706  /* Hover state */
```

#### Accent Colors
- **Red** (#dc2626) - Passion, breaking news
- **Blue** (#2563eb) - Trust, analysis
- **Orange** (#ea580c) - Excitement
- **Purple** (#9333ea) - Premium content

#### Football-Specific
- **Field**: #1a5f3d (Dark field green)
- **Leather**: #8b4513 (Football leather brown)
- **Chalk**: #f8fafc (Chalk lines white)

### Typography

#### Font Families
- **Headline**: "Anton" - Bold, condensed newspaper headlines
- **Subheadline**: "Oswald" - Strong, versatile subheadings
- **Body**: "Merriweather" - Readable serif for article text
- **Mono**: "Roboto Mono" - Stats and numbers
- **Accent**: "Alfa Slab One" - Special emphasis

#### Font Sizes (Responsive)
```
xs: 12px    →  Small labels, metadata
sm: 14px    →  Body text
base: 16px  →  Default
2xl: 24px   →  Section headers
4xl: 36px   →  Article titles
6xl: 60px   →  Main headlines
8xl: 96px   →  Hero headlines
```

### Spacing Scale
Based on 4px grid system:
```
1: 4px    5: 20px    12: 48px
2: 8px    6: 24px    16: 64px
3: 12px   8: 32px    20: 80px
4: 16px   10: 40px   24: 96px
```

### Animation & Timing

#### Durations
- **Instant**: 75ms - Immediate feedback
- **Fast**: 150ms - Button presses, toggles
- **Normal**: 300ms - Standard transitions
- **Slow**: 500ms - Page transitions
- **Slower**: 750ms - Complex animations

#### Easing Curves
- **Linear**: Constant speed
- **EaseOut**: Natural deceleration (default for most)
- **Bounce**: Playful, engaging interactions
- **Elastic**: Energetic, attention-grabbing

---

## 🎭 Component Library

### Headline Impact
```tsx
<h1 className="headline-impact">
  LIONS ROAR TO VICTORY
</h1>
```
- Anton font, 900 weight
- 6rem desktop, 3rem mobile
- Hover animation pulse effect

### Breaking Banner
```tsx
<div className="breaking-banner">
  ⚡ BREAKING NEWS ⚡
</div>
```
- Red background with pulsing glow
- Always uppercase, wide tracking
- Grabs immediate attention

### Category Badge
```tsx
<span className="category-badge">
  DEEP DIVE
</span>
```
- Green primary color
- Uppercase, bold font
- Subtle scale hover effect

### Article Card
```tsx
<article className="article-card hover-lift">
  {/* Content */}
</article>
```
- 4px thick black border (newspaper clipping)
- Shine animation on hover
- Lift effect (-0.5rem translate)
- Shadow newspaper style

### Button Primary
```tsx
<button className="btn-primary haptic-medium">
  Read Full Story
</button>
```
- Green background, white text
- Bounce effect on hover
- Scale down on active (haptic hint)

---

## 📱 Haptic Feedback Patterns

Visual indicators that map to mobile haptic feedback:

### Light Haptic
```tsx
<button className="haptic-light">
  {/* Subtle tap - scale 98% */}
</button>
```

### Medium Haptic  
```tsx
<button className="haptic-medium">
  {/* Standard press - scale 95% + brightness */}
</button>
```

### Heavy Haptic
```tsx
<button className="haptic-heavy">
  {/* Impactful action - scale 90% + shake animation */}
</button>
```

---

## 🚀 Animations

### Entrance Animations
- **fade-in**: Smooth opacity transition
- **slide-up**: Slides from below with bounce
- **slide-in-left/right**: Horizontal entrance

### Hover Effects
- **hover-lift**: Elevates card with shadow
- **headline-pulse**: Subtle scale pulse on headlines
- **shine-swipe**: Light beam across cards

### Interactive Feedback
- **shake**: Error or important action
- **pulse-glow**: Attention-grabbing elements
- **typewriter**: Special text reveals

---

## 🌐 Cross-Platform (Flutter/Dart)

Design tokens are exportable to Dart/Flutter format:

```bash
cd web
npm run export-tokens
```

This generates `../flutter_app/lib/design_tokens.dart` with:
- Color constants (0xFFRRGGBB format)
- Typography scales
- Spacing values
- Animation durations and curves
- Haptic feedback type constants

### Usage in Flutter
```dart
import 'design_tokens.dart';

Container(
  color: DesignTokens.AppColors.primary600,
  padding: EdgeInsets.all(DesignTokens.Spacing.space4),
  child: Text(
    'HEADLINE',
    style: TextStyle(
      fontSize: DesignTokens.Typography.fontSize4XL,
      fontWeight: DesignTokens.Typography.fontWeightBlack,
    ),
  ),
)
```

---

## 🎯 Best Practices

### Do's ✅
- Use design tokens for all colors, spacing, and typography
- Apply haptic classes to interactive elements
- Leverage entrance animations for content reveals
- Maintain 4:1 contrast ratio for accessibility
- Test hover states and transitions
- Use semantic color names (primary, accent, etc.)

### Don'ts ❌
- Don't use arbitrary color values
- Don't skip haptic feedback indicators
- Don't overuse animations (causes fatigue)
- Don't mix font families unnecessarily
- Don't forget dark mode variations

---

## 🛠 Development Workflow

### Adding New Colors
1. Add to `design-tokens.ts`
2. Update `tailwind.config.js` to extend theme
3. Re-export to Dart if needed
4. Document usage in this README

### Creating New Components
1. Use existing CSS classes first
2. Follow naming convention (component-variant)
3. Include hover, active, and dark mode states
4. Add haptic feedback class
5. Test on mobile viewport

### Performance
- Animations use CSS transforms (GPU accelerated)
- Lazy load images with proper aspect ratios
- Minimize repaints with `will-change` where needed
- Keep bundle size small with tree-shaking

---

## 🎨 Figma Design File
[Coming Soon]

## 📦 Storybook Component Showcase
[Coming Soon]

---

## 📄 License
© 2025 Tackle4Loss. All Rights Reserved.
