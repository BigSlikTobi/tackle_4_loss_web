import React from 'react';
import BreakingNewsList from '../BreakingNewsList';

interface BreakingNewsAppProps {
  languageCode: string;
}

export default function BreakingNewsApp({ languageCode }: BreakingNewsAppProps) {
  return (
    <section className="t4l-page t4l-page-narrow">
      <header className="t4l-page-header">
        <p className="t4l-page-eyebrow">Breaking News</p>
        <h2>Live Headlines</h2>
        <p>Feed powered by the same `get-breaking-news` and detail functions as Flutter.</p>
      </header>
      <BreakingNewsList languageCode={languageCode} />
    </section>
  );
}
