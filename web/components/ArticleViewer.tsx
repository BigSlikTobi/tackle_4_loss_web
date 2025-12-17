import React from 'react';
import { Article } from '../types';
import { ArrowLeft } from 'lucide-react';

interface ArticleViewerProps {
  article: Article;
  onBack: () => void;
}

const ArticleViewer: React.FC<ArticleViewerProps> = ({ article, onBack }) => {
  return (
    <div className="bg-background-light dark:bg-background-dark min-h-screen p-6">
      <button
        onClick={onBack}
        className="mb-4 inline-flex items-center gap-1 text-sm text-zinc-600 hover:text-zinc-900 haptic-light px-2 py-1 rounded-md border border-transparent"
      >
        <ArrowLeft size={14} /> Back
      </button>
      <div className="max-w-4xl mx-auto">
        <h1 className="text-4xl font-bold mb-2">{article.title}</h1>
        <p className="text-lg text-gray-500 mb-4">{article.subtitle}</p>
        <img src={article.heroImage} alt={article.title} className="w-full h-96 object-cover rounded-2xl mb-8" />
        {article.sections.map((section) => (
          <div key={section.id} className="mb-8">
            <h2 className="text-2xl font-bold mb-2">{section.headline}</h2>
            <div className="prose prose-lg max-w-none">
              {section.content.join('\n\n')}
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};

export default ArticleViewer;
