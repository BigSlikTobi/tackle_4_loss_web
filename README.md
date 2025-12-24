# Tackle4Loss 🏈

**"Tackle4Loss OS."**

Welcome to the Tackle4Loss mobile experience. This project is architected as a **Micro-App Operating System**. Instead of a traditional navigation app, we built a custom "OS Shell" that hosts independent, modular applications.

## 🏗️ Architecture: The "OS Shell"

The core of the application is the **OS Shell** (`lib/core/os_shell/`). It acts as a mini-operating system within the app, providing:

*   **Homescreen Grid**: A familiar, drag-and-drop enabled grid (16 slots) for app icons.
*   **Dock**: A persistent floating navigation bar.
*   **Hero Area**: A dynamic "Featured App" space at the top of the screen.
*   **System Services**:
    *   `InstalledAppsService`: Manages which apps are "installed" on the user's grid.
    *   `AppRegistry`: The central database of all available MicroApps.
    *   `NavigationService`: Handles switching between apps and the shell.

This architecture allows us to build features as completely standalone **MicroApps** that plug into the shell.

---

## 📱 MicroApps

The app comes pre-loaded with a suite of powerful MicroApps.

### [1. App Store 🛍️](lib/micro_apps/app_store/README.md)
The heart of the ecosystem. The App Store allows users to discover and install new features.
*   **Purpose**: Manages the "installed" state of other apps.
*   **Key Feature**: "App of the Month" promotion and seamless one-tap installation.

### [2. Deep Dives 🌊](lib/micro_apps/deep_dive/README.md)
The premier content experience. Long-form, immersive reading with rich media.
*   **Purpose**: Delivers high-quality analysis and storytelling.
*   **Key Feature**: "Immersive Reading Mode" with scrolling animations.

### [3. Breaking News 🚨](lib/micro_apps/breaking_news/README.md)
Real-time updates for the die-hard fan.
*   **Purpose**: Quick, digestible news snippets.
*   **Key Feature**: Live feed with urgent visual design.

### [4. Radio 📻](flutter_app/lib/micro_apps/radio/README.md)
The hands-free audio companion.
*   **Purpose**: Daily briefings and narrated deep dives for listening on the go.
*   **Key Feature**: "Smart Briefing" playlist and adaptive reverse-theming player widget.

---

## 🛠️ Setup & Development

### Prerequisites
*   Flutter SDK (Latests Stable)
*   Dart SDK

### Installation
1.  Navigate to the flutter app directory:
    ```bash
    cd flutter_app
    ```
2.  Install dependencies:
    ```bash
    flutter pub get
    ```
3.  Run the app:
    ```bash
    flutter run
    ```

### Design System
We enforce a strict design system located in [`lib/design_tokens.dart`](lib/design_tokens.dart).
*   **Colors**: `AppColors` (Brand, Neutral, Accent)
*   **Typography**: `AppTextStyles` (Display, H1-H3, Body)
*   **Spacing**: `AppSpacing` (8pt Grid)

**Violation of these tokens is strictly forbidden.**

---

## ⚠️ Web Status (WIP)

> **Note**: The web folder (`/web`) contains a legacy/parallel React implementation. It is currently **Outdated** and essentially a "Work In Progress". The Flutter codebase (`/flutter_app`) is the source of truth for the current architecture and design patterns.

---
