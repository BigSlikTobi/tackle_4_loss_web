export type ShellAppId =
  | 'deep_dive'
  | 'breaking_news'
  | 'radio'
  | 'standings'
  | 'game_reports'
  | 'player_wordle';

export interface ShellAppDefinition {
  id: ShellAppId;
  name: string;
  description: string;
  icon: string;
}

export const SHELL_APPS: ShellAppDefinition[] = [
  {
    id: 'deep_dive',
    name: 'Deep Dive',
    description: 'Long-form analysis and editorial stories.',
    icon: '/apps/deep_dive.svg',
  },
  {
    id: 'breaking_news',
    name: 'Breaking News',
    description: 'Latest updates with instant headline alerts.',
    icon: '/apps/breaking_news.svg',
  },
  {
    id: 'radio',
    name: 'Radio',
    description: 'Live audio stream and episode playback.',
    icon: '/apps/radio.svg',
  },
  {
    id: 'standings',
    name: 'Standings',
    description: 'Division tables, records, and game calendar.',
    icon: '/apps/standings.png',
  },
  {
    id: 'game_reports',
    name: 'Game Reports',
    description: 'AI-assisted recap generation and summaries.',
    icon: '/apps/game_reports.png',
  },
  {
    id: 'player_wordle',
    name: 'Player Wordle',
    description: 'Daily NFL guessing challenge.',
    icon: '/apps/player_wordle.svg',
  },
];

export const HOME_STRIP_DEFAULT_APPS: ShellAppId[] = [
  'deep_dive',
  'breaking_news',
  'radio',
  'standings',
  'game_reports',
  'player_wordle',
];
