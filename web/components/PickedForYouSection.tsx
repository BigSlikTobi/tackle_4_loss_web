import React from 'react';

const PickedForYouSection: React.FC = () => {
  return (
    <section>
      <div className="flex items-end justify-between mb-5 px-1">
        <div>
          <p className="text-xs font-semibold text-secondary uppercase tracking-wider mb-1">Personalized</p>
          <h3 className="text-xl font-bold text-text-main-light dark:text-text-main-dark">Picked For You</h3>
        </div>
        <button className="p-2 rounded-full hover:bg-gray-100 dark:hover:bg-gray-800 transition-colors">
          <span className="material-symbols-outlined text-text-sub-light dark:text-text-sub-dark text-xl">more_horiz</span>
        </button>
      </div>
      <div className="grid gap-4">
        <article className="flex items-center p-3 bg-card-light dark:bg-card-dark rounded-2xl shadow-sm border border-gray-100 dark:border-gray-800 active:bg-gray-50 dark:active:bg-gray-800/50 transition-colors">
          <div className="h-16 w-16 rounded-xl bg-gray-200 dark:bg-gray-700 flex-shrink-0 overflow-hidden mr-4 relative">
            <div className="absolute inset-0 bg-primary/20 flex items-center justify-center">
              <span className="material-symbols-outlined text-primary/60 dark:text-white/60">sports_football</span>
            </div>
          </div>
          <div className="flex-1 min-w-0">
            <h4 className="font-bold text-text-main-light dark:text-text-main-dark text-sm mb-1 truncate">Defensive Strategies 101</h4>
            <p className="text-xs text-text-sub-light dark:text-text-sub-dark line-clamp-1">Based on your interest in "Tactics"</p>
          </div>
          <span className="material-symbols-outlined text-gray-300 dark:text-gray-600 text-lg">chevron_right</span>
        </article>
        <article className="flex items-center p-3 bg-card-light dark:bg-card-dark rounded-2xl shadow-sm border border-gray-100 dark:border-gray-800 active:bg-gray-50 dark:active:bg-gray-800/50 transition-colors">
          <div className="h-16 w-16 rounded-xl bg-gray-200 dark:bg-gray-700 flex-shrink-0 overflow-hidden mr-4 relative">
            <div className="absolute inset-0 bg-secondary/20 flex items-center justify-center">
              <span className="material-symbols-outlined text-secondary/80">history_edu</span>
            </div>
          </div>
          <div className="flex-1 min-w-0">
            <h4 className="font-bold text-text-main-light dark:text-text-main-dark text-sm mb-1 truncate">The '85 Bears: A Retrospective</h4>
            <p className="text-xs text-text-sub-light dark:text-text-sub-dark line-clamp-1">Because you listened to "Legends"</p>
          </div>
          <span className="material-symbols-outlined text-gray-300 dark:text-gray-600 text-lg">chevron_right</span>
        </article>
      </div>
    </section>
  );
};

export default PickedForYouSection;
