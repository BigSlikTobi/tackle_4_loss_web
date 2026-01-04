# Publication: Standings App (standings)

## Certification
I certify that this Micro-App meets all T4L ADK Standards:
- [x] Follows strict MVC Pattern.
- [x] Uses Design Tokens (no hardcoded colors).
- [x] Implements the `MicroApp` contract.
- [x] Registered in `AppRegistry`.
- [x] Store assets (icon, 16:9 image, description) present.
- [x] Has a 2x2 home screen widget.

## Description
The Standings app provides a comprehensive view of the NFL season. It features a smart week-selector that automatically centers on the current week's games. Each game is displayed with high-quality team logos, scores, and overtime indicators.

## Technical Notes
- Edge Function: `get-latest-standings`
- Logic: `StandingsService` handles date parsing and closest-week calculation.
- UI: Uses `T4LScaffold` and `design_tokens.dart`.
