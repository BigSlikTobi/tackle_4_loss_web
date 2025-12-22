# Breaking News Micro-App 🚨

**ID**: `breaking_news`

## Overview
The Breaking News app provides real-time updates on critical NFL events and game updates. It is designed to be a "second screen" experience, offering quick, digestible snippets of information.

## Key Features
- **Live Feed**: A scrolling list of the latest news items.
- **Home Screen Widget**: Supports a 2x2 interactive widget for the home screen.
- **Red Theme**: Uses a distinctive `breakingNewsRed` color palette to create urgency.
- **Markdown Support**: Content is rendered using Markdown for rich text formatting.

## Architecture
- **Controller**: `BreakingNewsController` manages the state and fetches data.
- **Service**: Real-time updates via **Supabase** Edge Functions.
- **Views**:
  - `BreakingNewsListScreen`: Main feed.
  - `BreakingNewsWidget`: Home screen entry point.
