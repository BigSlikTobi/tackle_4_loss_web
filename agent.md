# Agent Operational Rules

## 1. UI/Layout Strictness

- **ALWAYS** use `T4LScaffold` in its default Standard Mode
  (`extendBodyBehindHeader: false`).
- **NEVER** use `SliverAppBar`, `NestedScrollView`, or
  `extendBodyBehindHeader: true` to "fix" spacing.
- **NEVER** add manual top padding to account for headers. `T4LScaffold` handles
  this.
- If a user reports a spacing issue, **simplify the layout** rather than adding
  hacks. Revert to a basic `Column` or `ListView`.

## 2. Micro-App Consistency

- All new micro-apps **MUST** follow the `ADK_GUIDE.md` exactly.
- Check existing apps (`RadioScreen`, `StandingsScreen`) as reference
  implementations for correct layout.

## 3. Code Quality

- Prefer readable, maintainable code over complex tricks.
- If a component is "acting weird" (e.g. `T4LHeroHeader`), refactor it into a
  standard widget rather than fighting the framework.

## 4. Git Hygiene

- **NEVER** push directly to `main`. Always use a feature branch (e.g.,
  `feature/xyz` or `issue_killer/xyz`).
- **ALWAYS** check the current branch before running `git push`.
- If a push fails, **STOP** and investigate. Do not blindly force push unless
  you are 100% sure of the branch.
