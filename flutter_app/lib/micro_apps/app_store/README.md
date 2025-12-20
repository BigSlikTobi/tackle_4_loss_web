# App Store Micro-App 🛍️

**ID**: `app_store`

## Overview
The App Store is the central hub for the Tackle4Loss ecosystem. It allows users to browse, install, and manage other MicroApps. It acts as the "sysadmin" interface for the user.

## Key Features
- **App of the Month**: Highlights a featured app (e.g., Deep Dives) with a large Hero card.
- **Installation Management**: One-tap Install/Uninstall buttons.
- **Dynamic Registry**: Fetches app metadata directly from the `AppRegistry`.
- **Localization**: Displays app descriptions in English or German based on device settings.

## Architecture
- **Controller**: `AppStoreController` handles installation logic via `InstalledAppsService`.
- **Logic**: Filters apps into "Featured" and "Other" lists dynamically.
- **Views**:
  - `AppStoreScreen`: The main storefront UI.
