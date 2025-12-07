import { createClient } from '@supabase/supabase-js';
import { SupabaseArticle } from '../types';

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL;
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY;

if (!supabaseUrl || !supabaseAnonKey) {
  console.warn('Missing Supabase environment variables. Please check your .env file.');
}

export const supabase = createClient(supabaseUrl || '', supabaseAnonKey || '', {
  db: {
    schema: 'content'
  }
});

// Type-safe database schema
export type Database = {
  content: {
    Tables: {
      deepdive_article: {
        Row: SupabaseArticle;
        Insert: Omit<SupabaseArticle, 'id' | 'created_at'>;
        Update: Partial<Omit<SupabaseArticle, 'id'>>;
      };
    };
  };
};
