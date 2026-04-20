# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Layout

This is a dual-stack monorepo:

- `flutter_app/` — **Source of truth.** The production Flutter app (Tackle4Loss OS).
- `web/` — A parallel React/Vite implementation. The README marks it as legacy/WIP, but the current branch (`Coder/parity-engine-foundation`) is actively rebuilding the web shell to reach parity with Flutter via shared design tokens.
- `supabase/` — Edge functions backing both clients (`get-team-roster`, `get-team-injuries`, `get-team-depth-chart`, `get-daily-player`, `get-news-feed`, `get-team-article-detail`, etc.).
- `flutter_app/lib/design_tokens.dart` is **generated** from `web/design-tokens.ts` by `web/export-tokens-to-dart.js` (`npm run export-tokens` in `web/`). Edit tokens in `web/`, not in Dart.

## Common Commands

### Flutter (`flutter_app/`)
```bash
cd flutter_app
flutter pub get
flutter run
flutter analyze --fatal-warnings   # CI uses --fatal-warnings
dart format --set-exit-if-changed . # CI fails on unformatted code
flutter test
flutter test test/path/to/file_test.dart   # single file
flutter test --plain-name "test name"      # single test
flutter test --coverage
```
A `.env` file with `SUPABASE_URL` and `SUPABASE_ANON_KEY` is required at `flutter_app/.env` (CI writes placeholders).

### Web (`web/`)
```bash
cd web
npm install
npm run dev          # vite dev on :3000
npm run build
npm run export-tokens # regenerate flutter_app/lib/design_tokens.dart
```
Requires `web/.env` with `VITE_SUPABASE_URL` and `VITE_SUPABASE_ANON_KEY`.

### CI
`.github/workflows/flutter.yml` runs only on changes under `flutter_app/**`. It runs format check, `flutter analyze --fatal-warnings`, and `flutter test --coverage`. There is currently no CI for `web/`.

## Architecture: The OS Shell + MicroApps

The Flutter app is structured as a **mini operating system**, not a traditional navigation app. Understanding this is essential before editing anything in `lib/`.

- `lib/core/os_shell/` hosts the shell UI: app strip, dock, news feed, team center overlay.
- `lib/core/services/` are the system services that the shell depends on:
  - `AppRegistry` (`lib/core/app_registry.dart`) — central catalog of every available MicroApp.
  - `InstalledAppsService` — tracks which apps the user has "installed" on their grid.
  - `NavigationService` — routes between the shell and individual MicroApps (do not bypass it with raw `Navigator` pushes for app-level navigation).
  - `FeatureFlagService` — gates MicroApp visibility; new apps default to off until production-audited.
- `lib/micro_apps/<id>/` — each MicroApp is a self-contained module following **strict MVC** (`models/`, `views/`, `controllers/` with `ChangeNotifier`). MicroApps must register themselves in `AppRegistry` to appear in the shell.
- `lib/core/adk/` — the App Development Kit. `ADK_GUIDE.md` defines the mandatory 8-step lifecycle for adding a MicroApp; follow it exactly. Reference implementations: `RadioScreen`, `StandingsScreen`.

The web side mirrors this concept (`web/components/OSAppGrid.tsx`, `AppStrip.tsx`, `FloatingNavBar.tsx`, `web/components/apps/`).

### MVP Slim State (as of 2026-04-20, branch `feature/flutter-mvp-slim`)

The app has been slimmed to an App Store MVP. Key runtime differences from the full architecture above:

- **Dock is 4 items only:** Home (news feed), Standings, Team Center (center logo button), Settings. History tab is dropped.
- **AppStrip and RadioHomeWidget are hidden** from the home screen layout. `InstalledAppsService.init()` is not called. The code remains in the repo.
- **Mandatory first-launch onboarding:** `_RootGate` in `main.dart` shows `FirstLaunchFlow` (team + language picker) until `SettingsService.onboardingComplete` is true. Non-dismissible.
- **Localization:** auto-detects German locale → DE, otherwise EN; user can override in Settings.
- **Flag-off MicroApps (code in repo, hidden at runtime):** `app_store`, `deep_dive`, `game_reports`, `player_wordle`, `radio`.
- **Games Timeline removed** from Team Center overlay. Team Center shows: Roster / Depth / Injuries.
- **`flutter_gemma` / TensorFlow Lite dropped** from `pubspec.yaml` (no MVP consumer; was blocking iOS device builds). `FunctionGemmaService` and `GameReportTools` are stubbed.

Full phase-by-phase breakdown: `/Users/tobiaslatta/.claude/plans/snoopy-beaming-swing.md`

## Git workflow rules

- **Never commit without the user's explicit approval.** Propose the change, show the diff or summarize what will be committed, and wait for a "yes, commit" from the user. Plan approval, task approval, and auto-mode are NOT approval to commit — they only authorize the code changes themselves. This applies even mid-plan and mid-phase: each commit needs its own green light.
- **Never push without the user's explicit approval.** Same rule. Branch approval is not push approval.
- **Never push to `main`.** Always work on a feature branch (e.g. `feature/xyz`, `issue_killer/xyz`). If a push fails, stop and investigate — never force-push without verifying the branch.

## Non-Obvious Rules (from `agent.md`)

- **Always** use `T4LScaffold` in default Standard Mode (`extendBodyBehindHeader: false`). It already handles header spacing.
- **Never** use `SliverAppBar`, `NestedScrollView`, `extendBodyBehindHeader: true`, or manual top padding to "fix" spacing. If spacing looks wrong, simplify the layout (revert to plain `Column`/`ListView`) instead of adding compensating hacks.
- If a core widget (e.g. `T4LHeroHeader`) misbehaves, refactor it into a standard widget — do not fight the framework.
- Design tokens in `lib/design_tokens.dart` (`AppColors`, `AppTextStyles`, `AppSpacing` — 8pt grid) are the **only** allowed source for color/type/spacing in Flutter. Hard-coded values are forbidden and will fail review.

## Adding a MicroApp (summary)

1. Create `lib/micro_apps/<id>/{models,views,controllers}/`.
2. Build the View on top of `T4LScaffold` and `design_tokens.dart`.
3. Register in `AppRegistry`; gate via `FeatureFlagService`.
4. Add unit tests (models/controllers) and widget tests (views); `flutter test` must be green.
5. Add `lib/micro_apps/<id>/README.md` documenting the why/how.
6. Open a PR titled `[PUBLISH] <App Name> (<App ID>)`.

Full checklist in `flutter_app/lib/core/adk/ADK_GUIDE.md`.
