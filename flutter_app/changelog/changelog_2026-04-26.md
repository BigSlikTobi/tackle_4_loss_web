# Changelog — 2026-04-26

## Summary
Complete design overhaul of the home feed and article detail experience (V3 handoff), alongside a new dedicated Supabase articles backend with cursor pagination. The dock was rebuilt as a floating glass pill, and home-to-detail navigation is now direct (no sheet).

## Changes

### Home Feed Redesign (V3)
- Added `BreakingFeaturedCard`: full-bleed hero card with dark-green background, parallax image, gradient overlay, italic Anton headline (via `google_fonts`), BREAKING pill, and READ FULL STORY footer
- Added `BreakingListItemCard`: compact row card with team logo, category eyebrow, bold headline, and chevron
- Removed old team-logo watermark and the "BREAKING / Latest / See All" section header from the feed
- Category eyebrow uses `#4ADE80` in dark mode (`T4LThemeColors`) for contrast compliance
- Feed cards push `BreakingNewsDetailScreen` directly via new `feed_navigation.dart` helper (converts `NewsFeedItem` → `BreakingNewsArticle`)
- Deleted unused `news_detail_sheet.dart`

### V3 Floating Dock
- Rewrote `T4LFloatingNavBar` as a glass pill (3 buttons: Home / Schedule / Settings, with dividers)
- Team badge floats above the pill (54×54, 3px brand-green ring, overlapping pill by 10px)
- Active tab renders a brand-tinted pill + green icon/label
- Fixed Schedule tab alignment with `StackFit.expand` on its Stack wrapper
- Extracted dock + NavigationService wiring into new `AppDock` widget (`lib/core/os_shell/widgets/app_dock.dart`)
- Refactored `OSShellView` to use `AppDock`
- Public `T4LFloatingNavBar` API preserved; added optional `activeTab` param

### V3 Article Detail Screen
- Rewrote `BreakingNewsDetailScreen` with: full-bleed parallax hero, dark gradient overlay, italic Anton headline, eyebrow pill (BREAKING/UPDATE), 2px reading-progress bar, byline bar (source + date + read-time pill), team chips, player headshots, body text (lead + content), related-stories section
- Glass back/share floating buttons at top
- `AppDock` rendered via `bottomNavigationBar` + `extendBody: true` with 140px bottom clearance
- Detail screen accepts optional `detailFetcher` and `relatedFetcher` typedefs; legacy `BreakingNewsService` remains default; home flow injects `ArticlesService`-backed closures with locale baked in

### Articles Backend (New Supabase Project)
- New `ArticlesService` (`lib/core/services/articles_service.dart`) targeting `https://aiknjzinyxzhoseyxqev.supabase.co`
  - `fetchArticles({language, limit, cursor})` returns `ArticlesPage` (cursor pagination)
  - `fetchArticleDetail(String id, {String? language})` returns `BreakingNewsArticle`
  - `fetchRelatedStories` is no-op stub (related stories come from the detail payload)
  - Maps language codes `en`/`de` → BCP-47 `en-US`/`de-DE`
- `ARTICLES_SUPABASE_URL` and `ARTICLES_SUPABASE_ANON_KEY` added to `flutter_app/.env` (gitignored; CI writes placeholders)
- `NewsFeedController` rewritten to use `ArticlesService` with cursor pagination; dropped previous Postgres realtime subscription
- New payload shape (`headline`, `sub_headline`, `introduction`, `content`, `image`, `team`, `mentioned_players[]`, `sources[]`, `created_at`) mapped into existing model types; downstream UI unchanged

### Tests
- Rewrote `news_feed_controller_test.dart` and `news_feed_widget_test.dart` to mock `ArticlesService`
- Tests cover: cursor pagination, language-change reload, error rendering
- Removed previous realtime / `get-news-feed` mock setups

## Files Modified

| File | Change |
|---|---|
| `lib/core/os_shell/controllers/news_feed_controller.dart` | Rewritten to use `ArticlesService` with cursor pagination; realtime subscription removed |
| `lib/core/os_shell/views/os_shell_view.dart` | Refactored to use new `AppDock` widget |
| `lib/core/os_shell/widgets/news_feed/news_feed_widget.dart` | Updated to render `BreakingFeaturedCard` / `BreakingListItemCard`; wires tap to `feed_navigation.dart` |
| `lib/core/os_shell/widgets/t4l_floating_nav_bar.dart` | Full rewrite as glass pill; optional `activeTab` param added |
| `lib/micro_apps/breaking_news/views/breaking_news_detail_screen.dart` | Full V3 rewrite; optional fetcher typedefs; `AppDock` in bottom bar |
| `test/core/os_shell/controllers/news_feed_controller_test.dart` | Rewritten for `ArticlesService` mock; cursor + language tests |
| `test/core/os_shell/widgets/news_feed_widget_test.dart` | Rewritten for `ArticlesService` mock |
| `lib/core/os_shell/widgets/app_dock.dart` | NEW — extracted dock widget |
| `lib/core/os_shell/widgets/news_feed/breaking_featured_card.dart` | NEW — V3 hero card |
| `lib/core/os_shell/widgets/news_feed/breaking_list_item_card.dart` | NEW — V3 compact list card |
| `lib/core/os_shell/widgets/news_feed/feed_navigation.dart` | NEW — `NewsFeedItem` → `BreakingNewsDetailScreen` navigation helper |
| `lib/core/services/articles_service.dart` | NEW — `ArticlesService` backed by new Supabase project |

## Code Quality Notes

- `flutter analyze --fatal-warnings`: **2 info-level issues, 0 warnings, 0 errors**
  - `lib/micro_apps/radio/controllers/radio_controller.dart:3` — `unnecessary_import` (pre-existing, unrelated to today's changes)
  - `test/micro_apps/radio/controllers/radio_controller_test.dart:32` — `use_super_parameters` (pre-existing, unrelated)
  - CI passes (only errors and warnings are fatal; info is informational)
- `dart format --set-exit-if-changed .`: **PASSED** — 208 files formatted, 0 changed
- `flutter test`: **PASSED** — 218 tests passed, 22 skipped (known MVP skips), 0 failures

## Open Items / Carry-over

- `ArticlesService.fetchRelatedStories` is a no-op stub; related stories currently come only from the detail payload (`related_stories` field). A future iteration could fetch them independently or from the list endpoint.
- `get-article-detail` edge function currently ignores the `language` query param server-side; forwarding it client-side is in place for forward-compat once the function is updated.
- Two pre-existing info lints in radio (`radio_controller.dart`, `radio_controller_test.dart`) remain unresolved — they are in flag-off code and do not affect CI.
- `news_detail_sheet.dart` was deleted; if any other call site referenced it, it would have surfaced as a compile error in analyze — confirmed clean.
