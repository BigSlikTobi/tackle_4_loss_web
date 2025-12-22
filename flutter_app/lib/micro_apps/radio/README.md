# Radio Micro-App

**ID**: `radio`  
**Description**: The central audio hub of the T4L OS, providing personalized news briefings and deep-dive storytelling experiences.

## 1. Why (Need)
Users need a passive, hands-free way to consume NFL content tailored to their favorite team. Reading articles isn't always convenient (e.g., while driving or working out). The Radio app solves this by converting text updates into audio briefings and offering long-form narrated deep dives.

## 2. How (Functionality)
-   **Daily Briefing**: A one-tap "play" button that compiles a playlist of the latest breaking news for the user's favorite team.
-   **Deep Dives**: A dedicated collection of long-form audio stories (narrated articles) with high production value.
-   **Team Integration**: deeply integrated with `SettingsService` to theme the experience based on the user's team colors.
-   **Localization**: Content is strictly filtered by language (English/German).
-   **Widget Support**: Offers a Home Screen widget for quick access.

## 3. Architecture (MVC)
-   **Model**:
    -   `RadioStation`: Represents a playable item (News Briefing, Deep Dive, Single Episode).
    -   `RadioCategory`: Filter logic.
-   **View**:
    -   `RadioScreen`: Main scaffold.
    -   `RadioHomeWidget`: The "breathing" interactive widget on the OS Home Screen.
    -   `DeepDiveCollectionScreen`: Grid view for browsing episodes.
    -   `RadioStationCard`: Reusable UI component for stations.
-   **Controller**:
    -   `RadioController`: Manages data fetching (Edge Functions), playback state (`AudioPlayerService`), and "played" history tracking.

## 4. Technical Details
-   **Data Source**: Supabase Edge Functions (`get-radio-news`, `get-radio-deepdives`). No direct DB access.
-   **Audio**: Powered by `AudioPlayerService` (just_audio + audio_service) for background playback and system controls.
-   **Theming**: The `RadioHomeWidget` implements a "Reverse Theme" logic, inverting colors based on the app's background/dark mode setting for maximum contrast.
-   **Localization**: Strict filtering. If no content is available in the selected language, a friendly empty state is shown.

## 5. Assets
-   `store_assets/radio_icon.png`: Branding icon.
-   `store_assets/image.png`: Store banner.
-   `store_assets/description.md`: Store description.
