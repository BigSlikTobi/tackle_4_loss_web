# Standings Micro-App

A premium NFL game schedule and results viewer for the Tackle 4 Loss OS.

## Why?
Football fans need a quick, beautiful way to track the season's progress without leaving the OS. This app provides a "source of truth" for all game data, integrated seamlessly with the T4L design system.

## How?
- **MVC Architecture**: Strict separation of data, logic, and UI.
- **Supabase Integration**: Real-time data from the `public.games` table via a secure edge function.
- **Emotional Design**: Smooth transitions, team-specific highlights, and a physics-based week selector.
- **Fixed Spatial Grid**: Supports a 2x2 home screen widget for glancing at the week's top games.

## Technical Details
- **App ID**: `standings`
- **Controller**: `StandingsController` (ChangeNotifier)
- **Service**: `StandingsService` (HTTP/REST via Edge Functions)
- **Design**: Uses `AppColors.brandBase` and `AppLayout.goldenRatio`.
