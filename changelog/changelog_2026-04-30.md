# Changelog — 2026-04-30

## Summary
Migrated the app from the old multi-project Supabase setup (22 legacy edge functions, two URL/key pairs) to a single consolidated Supabase project with five purpose-built Deno edge functions. Alongside that, the Standings MicroApp received a backend-driven rank/seed model and a dynamic playoff-line UI.

## Changes

### 1. Supabase project migration (single project, new functions)
- Replaced 22 legacy edge functions with five new dedicated Deno functions in `supabase/functions/`:
  - `schedule/index.ts` — full game list, replaces `get-latest-standings`
  - `standings/index.ts` — reads pre-computed `standings` table; emits `divisionRank`, `conferenceRank`, `leagueRank`, `conferenceSeed` for dynamic playoff-line computation
  - `roster/index.ts` — reads enriched `rosters_current` view (joined to `players`)
  - `depth-chart/index.ts` — reads enriched `depth_charts_current` view; normalises granular positions (LDE/RDE → DE, LCB/RCB → CB, MLB/OLB → LB, etc.)
  - `injuries/index.ts` — reads enriched `injuries_current` view; filters `ACTIVE` rows, picks latest by season → post > reg > pre → week
- Deleted all 22 legacy function directories from `supabase/functions/`.
- Flutter clients repointed: `standings_service.dart` → `schedule`, `standings_data_service.dart` → `standings`, `team_center_controller.dart` → `roster` / `depth-chart` / `injuries`.
- Collapsed dual env vars into a single pair: `ARTICLES_SUPABASE_URL` / `ARTICLES_SUPABASE_ANON_KEY` used everywhere.
  - `flutter_app/lib/main.dart` updated to initialise Supabase with the single key pair.
  - `articles_service.dart` now uses `Supabase.instance.client` directly (no second client).
  - `.github/workflows/flutter.yml` and `.github/workflows/release.yml` updated to read the single secret pair.
- Stubbed dead Supabase calls in flag-off MicroApps to keep the build clean (all marked `// TODO(restore-on-revive)`):
  - `breaking_news_service.dart`, `team_article_screen.dart`, `deep_dive_controller.dart`, `deep_dive_detail_controller.dart`, `player_wordle_service.dart`, `radio_controller.dart`
- Deleted two obsolete deep_dive tests (`deep_dive_controller_test.dart`, `deep_dive_list_screen_test.dart`) that asserted on now-stubbed controller behavior.

### 2. Standings UI — rank/seed model + dynamic playoff line
- Extended `TeamStanding` model with `divisionRank`, `conferenceRank`, `leagueRank`, `conferenceSeed` fields plus helpers `inPlayoffs`, `isDivisionWinner`, `isWildcardSeed`.
- `standings_tab.dart` sorts each view by the matching server-supplied rank and computes the playoff line dynamically (last team where `inPlayoffs == true`) — replaces hardcoded "top 7 / top 1" logic.
- Supporting UI work: `standings_controller.dart` (added `selectedDivision` / `setDivision`), `standings_filter_header.dart` layout overhaul, `team_standings_card.dart` (`isExpanded` parameter), `week_selector.dart` cleanup, `schedule_tab.dart` / `featured_game_card.dart` / `timeline_game_row.dart` / `timeline_date_header.dart` refinements.

### 3. Documentation
- `CLAUDE.md`: updated `supabase/` section to list active functions post-migration; replaced old function list.

## Files Modified
- `.github/workflows/flutter.yml` — uses single `ARTICLES_SUPABASE_*` secret pair
- `.github/workflows/release.yml` — uses single `ARTICLES_SUPABASE_*` secret pair
- `CLAUDE.md` — supabase section updated
- `flutter_app/lib/core/services/articles_service.dart` — uses `Supabase.instance.client`
- `flutter_app/lib/core/team_center/controllers/team_center_controller.dart` — new function endpoints
- `flutter_app/lib/core/team_center/views/team_article_screen.dart` — stubbed dead calls
- `flutter_app/lib/main.dart` — single Supabase initialisation
- `flutter_app/lib/micro_apps/breaking_news/services/breaking_news_service.dart` — stubbed
- `flutter_app/lib/micro_apps/deep_dive/controllers/deep_dive_controller.dart` — stubbed
- `flutter_app/lib/micro_apps/deep_dive/controllers/deep_dive_detail_controller.dart` — stubbed
- `flutter_app/lib/micro_apps/player_wordle/services/player_wordle_service.dart` — stubbed
- `flutter_app/lib/micro_apps/radio/controllers/radio_controller.dart` — stubbed
- `flutter_app/lib/micro_apps/standings/controllers/standings_controller.dart` — selectedDivision / setDivision
- `flutter_app/lib/micro_apps/standings/models/team_standing.dart` — rank/seed fields + helpers
- `flutter_app/lib/micro_apps/standings/services/standings_data_service.dart` — new endpoint
- `flutter_app/lib/micro_apps/standings/services/standings_service.dart` — new endpoint
- `flutter_app/lib/micro_apps/standings/views/widgets/featured_game_card.dart` — UI refresh
- `flutter_app/lib/micro_apps/standings/views/widgets/schedule_tab.dart` — UI refresh
- `flutter_app/lib/micro_apps/standings/views/widgets/standings_filter_header.dart` — layout overhaul
- `flutter_app/lib/micro_apps/standings/views/widgets/standings_tab.dart` — dynamic playoff line
- `flutter_app/lib/micro_apps/standings/views/widgets/team_standings_card.dart` — isExpanded param
- `flutter_app/lib/micro_apps/standings/views/widgets/timeline_date_header.dart` — UI refresh
- `flutter_app/lib/micro_apps/standings/views/widgets/timeline_game_row.dart` — UI refresh
- `flutter_app/lib/micro_apps/standings/views/widgets/week_selector.dart` — UI cleanup
- `flutter_app/test/micro_apps/deep_dive/deep_dive_controller_test.dart` — DELETED
- `flutter_app/test/micro_apps/deep_dive/deep_dive_list_screen_test.dart` — DELETED
- `supabase/functions/depth-chart/index.ts` — NEW
- `supabase/functions/injuries/index.ts` — NEW
- `supabase/functions/roster/index.ts` — NEW
- `supabase/functions/schedule/index.ts` — NEW
- `supabase/functions/standings/index.ts` — NEW
- `supabase/functions/<22 legacy dirs>` — ALL DELETED

## Code Quality Notes
- `dart format --set-exit-if-changed .` — PASSED (0 files changed)
- `flutter analyze --fatal-warnings` — PASSED (no issues found)
- `flutter test` — PASSED: 199 tests, 22 skipped (MVP stubs), 0 failures

## Open Items / Carry-over
- **GitHub Actions secrets rename required:** `release.yml` now reads `secrets.ARTICLES_SUPABASE_URL` / `secrets.ARTICLES_SUPABASE_ANON_KEY`. Any existing GitHub Actions secrets under the old names (`SUPABASE_URL` / `SUPABASE_ANON_KEY`) must be renamed or duplicated in the repo settings before the release workflow will succeed.
- Flag-off MicroApps (`breaking_news`, `deep_dive`, `player_wordle`, `radio`) have stubbed services marked `// TODO(restore-on-revive)` — real implementations needed when those apps are re-enabled.
- `supabase/.temp/` version files updated by Supabase CLI — reflect new project versions.
