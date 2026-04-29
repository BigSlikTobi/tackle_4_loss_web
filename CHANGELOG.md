# Changelog — 2026-04-20

## Summary

Slimmed the Flutter app (`flutter_app/`) down to a focused MVP scope targeting App Store submission within 5 weeks. The session went from idea-discovery → product-architect → /plan → 8 implementation commits, leaving the app with a clean 4-item dock, mandatory onboarding, and all non-MVP features flag-off (code stays in repo, hidden at runtime).

## MVP Visible Surface (locked)

- **Home** — News feed
- **Standings** — Full standings view (Game Center button in dock)
- **Team Center** — Roster / Depth Chart / Injuries overlay (center team-logo button in dock)
- **Settings** — Language + team override, app info

## What Was Removed / Hidden

| Removed from MVP | Disposition |
|---|---|
| History dock tab | Deleted from Dock; can be restored post-launch |
| AppStrip (app grid) | Hidden at runtime; code intact |
| RadioHomeWidget | Hidden at runtime; code intact |
| Games Timeline (Team Center overlay) | Removed from overlay tab list |
| MicroApps: `app_store`, `deep_dive`, `game_reports`, `player_wordle`, `radio` | Feature-flagged off in `AppRegistry`; not shown in any shell UI |
| `flutter_gemma` / TensorFlow Lite dependency | Dropped from `pubspec.yaml`; `FunctionGemmaService` and `GameReportTools` stubbed |

## Changes (8 commits on `feature/flutter-mvp-slim`)

- **Phase 1** (`9e37e99`) — Strip boot graph: remove non-MVP MicroApp registrations from `AppRegistry`, disable `RadioController` provider, set feature flags off for flagged apps, trim `store_assets` from `pubspec.yaml`.
- **Phase 2** (`46fd6d4`) — Drop Deep Dive dependency from `OSShellController.isPageReady` so the home screen is no longer gated on a flagged-off app.
- **Phase 3** (`a20be93`) — Slim Dock to 4 items: remove History tab, rearrange Home / Standings / Team Center / Settings.
- **Phase 4** (`408438f`) — Hide `AppStrip` and `RadioHomeWidget` from the home layout; stop calling `InstalledAppsService.init()` (no app grid = no install state needed).
- **Phase 5** (`cda5aea`) — Drop Games Timeline tab from the Team Center overlay; Team Center now shows Roster / Depth / Injuries only.
- **Phase 6** (`3e5379a`) — Forced first-launch onboarding: new `FirstLaunchFlow` widget, `SettingsService.onboardingComplete` flag, `_RootGate` in `main.dart`. Non-dismissible until team + language are chosen. Auto-detects DE for German locale, EN otherwise; manual override available in Settings.
- **Phase 7** (`e3e5ac7`) — `dart format` pass across all MVP slim changes.
- **Phase 8** (`5a187b7`) — Drop `flutter_gemma` from `pubspec.yaml` to unblock iOS device build (`TensorFlowLiteSelectTfOps` framework was missing). Stubbed `FunctionGemmaService` and `GameReportTools` so the game_reports MicroApp compiles cleanly while flag-off.

## Files Modified (implementation — already committed)

- `flutter_app/lib/core/app_registry.dart` — feature-flag off non-MVP MicroApps
- `flutter_app/lib/core/os_shell/os_shell_controller.dart` — drop Deep Dive from isPageReady gate
- `flutter_app/lib/core/os_shell/views/os_shell_home.dart` — hide AppStrip + RadioHomeWidget
- `flutter_app/lib/core/os_shell/widgets/dock/dock.dart` — 4-item dock
- `flutter_app/lib/core/services/settings_service.dart` — add `onboardingComplete` flag + language auto-detect
- `flutter_app/lib/micro_apps/team_center/views/team_center_overlay.dart` — drop Games Timeline tab
- `flutter_app/lib/main.dart` — `_RootGate` driving `FirstLaunchFlow`
- `flutter_app/lib/core/os_shell/widgets/first_launch_flow.dart` — new onboarding widget
- `flutter_app/lib/micro_apps/game_reports/services/function_gemma_service.dart` — stubbed
- `flutter_app/lib/micro_apps/game_reports/services/game_report_tools.dart` — stubbed
- `flutter_app/pubspec.yaml` — drop `flutter_gemma`; trim `store_assets`

## Code Quality Notes

- `flutter analyze --fatal-warnings`: 2 pre-existing `info` hints in `radio_controller.dart` and its test — not warnings, not regressions.
- `flutter test`: **222 passing, 22 skipped**. Skipped tests cover AppStrip install/reorder logic intentionally deferred pending a future AppStrip return.
- `dart format --set-exit-if-changed .`: 1 file re-formatted post-commit (`game_report_tools.dart` — a line-wrap in a string description). Needs to be included in the next commit.

## Open Items / Carry-over

- [ ] Stage and commit `flutter_app/lib/micro_apps/game_reports/services/game_report_tools.dart` (dart format line-wrap fix) + `CLAUDE.md` (git workflow rules section) — awaiting explicit user approval.
- [ ] Push `feature/flutter-mvp-slim` (8 commits + pending) to remote — awaiting explicit user approval.
- [ ] App Store assets: screenshots, app description, Privacy Policy URL needed before submission.
- [ ] TestFlight distribution + first internal build — next milestone after branch is pushed.
- [ ] Push notifications, accounts/auth, monetization — explicitly out of MVP scope; revisit post-launch.
- [ ] 22 skipped tests (AppStrip install/reorder) — clean up or restore when AppStrip returns post-MVP.
- [ ] Plan file at `/Users/tobiaslatta/.claude/plans/snoopy-beaming-swing.md` covers full phase breakdown.
