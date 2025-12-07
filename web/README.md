# Tackle4Loss DeepDives 🏈 (Web)

Deep-dive analysis and insights for American Football enthusiasts. This folder holds the React/Vite web experience; the native Flutter app lives in `../flutter_app`.

## Features
- 📰 Newspaper-themed design with modern animations
- 🎨 Shared design tokens for Web + Flutter
- 🌍 German and English content support
- 🗄️ Supabase-backed article data with graceful fallbacks
- 📱 Responsive layout and haptic-friendly interaction patterns

## Quick Start (Web)
From the repo root:
```bash
cd web
npm install
npm run dev
```
Open http://localhost:3000

### Production Build
```bash
cd web
npm run build
```

## Configuration
Create `web/.env`:
```bash
cd web
cp .env.example .env
```
Add your Supabase keys (see `SUPABASE_SETUP.md` for details):
```env
VITE_SUPABASE_URL=your_supabase_url
VITE_SUPABASE_ANON_KEY=your_supabase_anon_key
```

## Design System
Run the export to generate Flutter tokens at `../flutter_app/lib/design_tokens.dart`:
```bash
cd web
npm run export-tokens
```
Docs: `DESIGN_SYSTEM.md` and `DESIGN_TOKENS_EXPORT.md`.

## Project Structure (Web)
```
web/
├── App.tsx
├── components/
├── constants.ts
├── design-tokens.ts
├── export-tokens-to-dart.js
├── index.css
├── index.html
├── index.tsx
├── lib/supabase.ts
├── metadata.json
├── tailwind.config.ts
└── types.ts
```

## Tech Stack
- React 19 + TypeScript
- Vite
- Tailwind CSS v4
- Supabase
- Lucide React

## Documentation
- `DESIGN_SYSTEM.md` — Design language
- `SUPABASE_SETUP.md` — Backend configuration
- `DESIGN_TOKENS_EXPORT.md` — Token export guide
