export interface ArticleSection {
  id: string;
  headline: string;
  content: string[]; // Array of paragraphs for the section
}

export interface Article {
  id: string;
  title: string;
  subtitle: string;
  author: string;
  date: string;
  heroImage: string;
  audioFile?: string; // New field
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
  sections: Record<string, string>; // "section_1": "## Headline..."
  created_at: string;
}