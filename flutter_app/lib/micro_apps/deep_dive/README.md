# Deep Dive (Micro-App)

## 1. The Why
Users need more than just stats and headlines. They crave context, analysis, and storytelling. 
"Deep Dive" exists to provide a premium, magazine-like reading experience for long-form content within the T4L OS.

## 2. The How
- **Discovery**: Accessible via the "Deep Dive" icon on the Home Screen (after install).
- **Reading**: Offers an immersive, distraction-free view with large typography and hero imagery.
- **Audio**: Users can listen to articles via the integrated audio player.

## 3. Technical Implementation
- **Architecture**: Strict MVC.
- **Components**: Uses `T4LScaffold` and `T4LHeroHeader` from the ADK.
- **Data**: Fetches `DeepDiveArticle` from the controller (currently mock).
