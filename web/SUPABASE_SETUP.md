# Supabase Integration Setup

This project now fetches article data from your Supabase database instead of using mock data. The web app lives in `web/`, so run the commands below from that directory.

## Setup Instructions

### 1. Configure Environment Variables

From the repo root, set up `web/.env`:

```bash
cd web
cp .env.example .env
```

### 2. Add Your Supabase Credentials

Edit the `.env` file and replace `your_supabase_anon_key_here` with your actual Supabase anonymous (public) key:

```env
VITE_SUPABASE_URL=https://yqtiuzhedkfacwgormhn.supabase.co
VITE_SUPABASE_ANON_KEY=your_actual_anon_key_here
```

You can find these credentials in your Supabase project settings:
- Go to your Supabase project dashboard
- Navigate to **Settings** → **API**
- Copy the **Project URL** and **anon/public key**

### 3. Install Dependencies

If you haven't already, install the dependencies:

```bash
cd web
npm install
```

### 4. Start the Development Server

```bash
cd web
npm run dev
```

## Database Schema

The app expects a table named `deepdive_article` in the `content` schema with the following structure:

```sql
{
  id: uuid (primary key)
  article_key: text
  language_code: text
  title: text
  subtitle: text
  author: text
  published_at: date
  hero_image_url: text
  audio_file: text (nullable)
  sections: jsonb
  created_at: timestamptz
}
```

The `sections` field should be a JSON object with keys like `section_1`, `section_2`, etc., where each value contains the markdown content for that section.

## How It Works

1. **Supabase Client**: Initialized in `lib/supabase.ts` using environment variables
2. **Data Fetching**: `App.tsx` queries the `deepdive_article` table on mount
3. **Fallback**: If the fetch fails or credentials are missing, the app falls back to mock data
4. **Multi-language**: Articles are filtered by `language_code` (de/en)

## Features

- ✅ Fetches articles from Supabase database
- ✅ Supports multiple languages (German/English)
- ✅ Falls back to mock data if database is unavailable
- ✅ Type-safe database queries with TypeScript
- ✅ Ordered by creation date (newest first)
