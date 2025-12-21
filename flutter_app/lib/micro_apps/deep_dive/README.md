# Deep Dive Micro-App (`deep_dive`)

## 1. The Why (Need)
In the modern sports media landscape, users are bombarded with headlines and short tweets. **Deep Dive** exists to provide the antidote: distinct, high-quality, long-form analysis that respects the user's intelligence.

It solves the problem of "content snacking" by offering a dedicated space for "content feasting"—immersive, distraction-free reading experiences that focus on the "how" and "why" of football strategy, not just the "what".

## 2. The How (Functionality)
Deep Dive provides a premium reading experience designed to be "emotionally resonant."

*   **Immersive List**: Browse articles with large, cinematic hero images that bleed to the edges.
*   **Instant Transitions**: Tap an article, and the image flies seamlessly into the detail view using custom **Hero Animations**, masking loading times.
*   **Audio Integration**: Users can listen to articles via the global audio player, allowing them to consume content on the go.
*   **Distraction-Free Reading**: The article view minimizes UI clutter, focusing purely on typography and imagery.
*   **Dynamic Language Support**: Content automatically adapts to the user's selected language (English/German).

## 3. Technical Implementation
This app strictly follows the **Tackle 4 Loss ADK** and **MVC Architecture**.

### Architecture
*   **Model (`DeepDiveArticle`)**: Pure data class. Handles complex business logic like concatenating `sections` into full content strings for the view.
*   **View (`DeepDiveListScreen`, `DeepDiveScreen`)**:
    *   Uses `T4LScaffold` for OS integration.
    *   Uses `T4LHeroHeader` for the signature immersive look.
    *   Strictly uses `design_tokens.dart` for all styling.
*   **Controller (`DeepDiveController`, `DeepDiveDetailController`)**:
    *   Manages state (`isLoading`, `articles`).
    *   Implements **caching** to prevent redundant network requests.
    *   Kept lean by delegating heavy logic to the Model.

### Key Decisions
*   **Skeletal Data Passing**: We pass the available `DeepDiveArticle` data from the list to the detail view immediately. This allows the Hero header to render *instantly* while the full body content fetches in the background, creating a perceived "zero latency" experience.
*   **Supabase Edge Functions**: All data is fetched via secured Edge Functions (`get-all-deepdives`, `get-article-viewer-data`), ensuring logic remains server-side and updatable.
