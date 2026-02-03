import type { BreakingNews } from '../types';

const isNonEmptyString = (value: unknown): value is string =>
  typeof value === 'string' && value.trim().length > 0;

export const normalizeBreakingNews = (item: Record<string, unknown>): BreakingNews => {
  const createdAt =
    (item.created_at as string | undefined) ??
    (item.createdAt as string | undefined);

  if (!isNonEmptyString(createdAt)) {
    throw new Error('Breaking news item missing created_at field');
  }

  const headline =
    (item.headline as string | undefined) ??
    (item.title as string | undefined) ??
    '';

  if (!isNonEmptyString(headline)) {
    throw new Error('Breaking news item missing headline field');
  }

  return {
    id: String((item.id as string | number | undefined) ?? ''),
    headline,
    created_at: createdAt,
    image_url:
      (item.image_url as string | undefined) ??
      (item.imageUrl as string | undefined),
    x_post: (item.x_post as string | undefined) ?? (item.xPost as string | undefined),
    audio_file:
      (item.audio_file as string | undefined) ??
      (item.audioFile as string | undefined),
  };
};

export const normalizeBreakingNewsList = (items: unknown): BreakingNews[] => {
  if (!Array.isArray(items)) return [];
  return items.map((item) => normalizeBreakingNews(item as Record<string, unknown>));
};
