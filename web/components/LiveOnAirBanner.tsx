import React from 'react';

const LiveOnAirBanner: React.FC = () => {
  return (
    <section className="relative overflow-hidden bg-gradient-to-r from-gray-900 to-primary rounded-2xl p-0.5 shadow-lg group cursor-pointer active:scale-[0.99] transition-transform duration-200">
      <div className="bg-card-dark rounded-[14px] p-4 flex items-center justify-between relative overflow-hidden">
        <div className="absolute -right-10 -top-10 w-40 h-40 bg-accent/20 rounded-full blur-3xl animate-pulse"></div>
        <div className="flex items-center space-x-4 z-10 w-full">
          <div className="flex-shrink-0 relative">
            <div className="h-12 w-12 rounded-xl bg-gradient-to-br from-gray-800 to-black flex items-center justify-center shadow-inner border border-white/10">
              <span className="material-symbols-outlined text-white animate-pulse">campaign</span>
            </div>
            <div className="absolute -top-1 -right-1 h-3 w-3 bg-accent rounded-full border-2 border-card-dark animate-pulse"></div>
          </div>
          <div className="flex-1 min-w-0">
            <div className="flex items-center space-x-2 mb-0.5">
              <span className="text-[10px] font-black text-accent tracking-widest uppercase">Live On Air</span>
              <div className="flex space-x-0.5 items-end h-3">
                <div className="w-0.5 bg-accent/60 rounded-full animate-wave" style={{ animationDelay: '0s' }}></div>
                <div className="w-0.5 bg-accent/60 rounded-full animate-wave" style={{ animationDelay: '0.2s' }}></div>
                <div className="w-0.5 bg-accent/60 rounded-full animate-wave" style={{ animationDelay: '0.4s' }}></div>
              </div>
            </div>
            <h3 className="text-white font-bold text-sm truncate pr-2 italic">Breaking: Playoff Picture Update</h3>
          </div>
          <div className="flex-shrink-0">
            <span className="material-symbols-outlined text-gray-400">play_arrow</span>
          </div>
        </div>
      </div>
    </section>
  );
};

export default LiveOnAirBanner;
