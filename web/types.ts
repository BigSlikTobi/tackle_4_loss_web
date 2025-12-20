export interface ArticleSection {
  id: string;
  headline: string;
  content: string[]; // Array of paragraphs for the section
  image?: string;
}

export interface Article {
  id: string;
  title: string;
  subtitle: string;
  author: string;
  date: string;
  heroImage: string;
  languageCode: string;
  audioFile?: string; // New field
  videoFile?: string; // Optional teaser/hero video
  sections: ArticleSection[];
}

export interface SupabaseArticle {
  id: string;
  article_key: string;
  language_code: string;
  title: string;
  subtitle: string;
  author: string;
  published_at: string;
  hero_image_url: string;
  audio_file?: string; // New nullable field from DB
  video_file?: string; // New nullable field for hero/teaser video
  sections?: Record<string, string>; // "section_1": "## Headline..."
  created_at: string;
}

export interface BreakingNews {
  id: string;
  headline: string;
  created_at: string;
  image_url?: string;
  x_post?: string; // Content for notifications
  audio_file?: string; // URL to audio file
}

export interface BreakingNewsDetail extends BreakingNews {
  content: string;
  introduction: string;
}

export interface Team {
  team_name: string;
  team_conference: string;
  team_division: string;
  logo_url: string;
}