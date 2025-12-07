# Tackle4Loss (Web + Flutter)

This repo now houses both the React/Vite web app and a Flutter project for native iOS/Android.

## Structure
- `web/` — existing Vite + React app (see `web/README.md`)
- `flutter_app/` — freshly scaffolded Flutter project targeting iOS and Android

## Quick Start
- Web: `cd web && npm install && npm run dev`
- Flutter: `cd flutter_app && flutter pub get && flutter run`

## Design Tokens
- Source of truth: `web/design-tokens.ts`
- Export script: `web/export-tokens-to-dart.js`
- Output: `flutter_app/lib/design_tokens.dart` (run `cd web && npm run export-tokens`)

## Notes
- Web environment variables now live in `web/.env` (see `web/SUPABASE_SETUP.md`)
- Flutter dependencies were not fetched during scaffolding (`--no-pub`); run `flutter pub get` before building
