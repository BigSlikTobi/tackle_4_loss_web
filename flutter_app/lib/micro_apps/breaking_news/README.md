# Breaking News Micro-App 🚨

**ID**: `breaking_news`

## Overview
The Breaking News app provides real-time (mocked) updates on critical NFL events and game updates. It is designed to be a "second screen" experience, offering quick, digestible snippets of information.

## Key Features
- **Live Feed**: A scrolling list of the latest news items.
- **Red Theme**: Uses a distinctive `breakingNewsRed` color palette to create urgency.
- **Markdown Support**: Content is rendered using Markdown for rich text formatting.
- **Audio Integration**: (Planned) Audio playback for news briefs.

## Architecture
- **Controller**: `BreakingNewsController` manages the state and fetches data.
- **Service**: `MockNewsService` provides data abstraction (currently mocked).
- **Views**:
  - `BreakingNewsListScreen`: Main feed.
