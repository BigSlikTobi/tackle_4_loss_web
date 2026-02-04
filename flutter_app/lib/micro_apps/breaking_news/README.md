# Breaking News Micro-App 🚨

**ID**: `breaking_news`

## Overview
The Breaking News app provides real-time updates on critical NFL events and game updates. It is designed to be a "second screen" experience, offering quick, digestible snippets of information.

## Key Features
- **Hero + Feed Layout**: Featured hero story followed by a clean list of headlines.
- **Detail View**: Dedicated detail screen that upgrades from summary to full content.
- **Source + Team Meta**: White source badges, team logos, and player headshots where available.
- **Home Screen Widget**: Supports a 2x2 interactive widget for the home screen.
- **Red Theme**: Uses a distinctive `breakingNewsRed` color palette to create urgency.

## Architecture
- **Controller**: `BreakingNewsController` manages the state and fetches data.
- **Service**: Real-time updates via **Supabase** Edge Functions.
- **Views**:
  - `BreakingNewsListScreen`: Hero + list feed.
  - `BreakingNewsDetailScreen`: Full article view.
  - `BreakingNewsWidget`: Home screen entry point.
