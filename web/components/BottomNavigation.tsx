import React from 'react';

const BottomNavigation: React.FC = () => {
  return (
    <nav className="fixed bottom-6 left-6 right-6 h-16 bg-white/80 dark:bg-card-dark/80 backdrop-blur-xl border border-white/40 dark:border-white/10 rounded-2xl shadow-2xl z-50 flex justify-around items-center px-1">
      <a className="flex flex-col items-center justify-center w-12 h-12 rounded-xl text-primary dark:text-secondary bg-primary/5 dark:bg-secondary/10" href="#">
        <span className="material-symbols-outlined text-[24px]">home</span>
        <span className="text-[9px] font-bold mt-0.5">Home</span>
      </a>
      <a className="flex flex-col items-center justify-center w-12 h-12 rounded-xl text-text-sub-light dark:text-text-sub-dark hover:text-primary dark:hover:text-secondary transition-colors" href="#">
        <span className="material-symbols-outlined text-[24px]">podcasts</span>
        <span className="text-[9px] font-medium mt-0.5">Deep Dive</span>
      </a>
      <button className="relative -top-6 h-14 w-14 bg-primary text-white rounded-2xl shadow-lg shadow-primary/40 flex items-center justify-center transform hover:scale-105 active:scale-95 transition-all duration-200 border-4 border-background-light dark:border-background-dark">
        <span className="material-symbols-outlined text-[28px]">radio</span>
      </button>
      <a className="flex flex-col items-center justify-center w-12 h-12 rounded-xl text-text-sub-light dark:text-text-sub-dark hover:text-primary dark:hover:text-secondary transition-colors" href="#">
        <span className="material-symbols-outlined text-[24px]">scoreboard</span>
        <span className="text-[9px] font-medium mt-0.5">Scores</span>
      </a>
      <a className="flex flex-col items-center justify-center w-12 h-12 rounded-xl text-text-sub-light dark:text-text-sub-dark hover:text-primary dark:hover:text-secondary transition-colors" href="#">
        <span className="material-symbols-outlined text-[24px]">person</span>
        <span className="text-[9px] font-medium mt-0.5">Profile</span>
      </a>
    </nav>
  );
};

export default BottomNavigation;
