import React from 'react';

const Header: React.FC = () => {
  return (
    <header className="fixed top-0 w-full z-50 pt-12 pb-6 px-6 flex justify-between items-center transition-all duration-300 bg-gradient-to-b from-black/60 to-transparent">
      <div className="h-10 w-10 bg-white/10 backdrop-blur-md rounded-xl flex items-center justify-center border border-white/20 transform active:scale-95 transition-transform duration-200">
        <span className="text-white font-black text-lg italic tracking-tighter">T4L</span>
      </div>
      <div className="flex items-center space-x-3">
        <button className="h-10 w-10 bg-white/10 backdrop-blur-md rounded-full flex items-center justify-center border border-white/20 text-white hover:bg-white/20 transition-colors">
          <span className="material-symbols-outlined text-[20px]">search</span>
        </button>
        <button
          className="h-10 w-10 bg-white/10 backdrop-blur-md rounded-full flex items-center justify-center border border-white/20 overflow-hidden relative"
          onClick={() => document.documentElement.classList.toggle('dark')}
        >
          <img
            alt="User Profile"
            className="w-full h-full object-cover opacity-90 hover:opacity-100 transition-opacity"
            src="https://lh3.googleusercontent.com/aida-public/AB6AXuDfdN8ByOhZckUvWA3oobvyT2tN2NY6a0Rsxk9EGigg6H8CSV89Zs82ObFaqwfcGzGOupY2FsgrOVwdiOQiG5NYjmadrrY8aSFwvv1VyRbvk1CiggJSd3BrP9PLwyxvEKzXJG0FbsD6zGzBJL4tOB8SZhaP928j2rF4UVGp-R6w139m6DdE3BjdHPZacHGGevn-en8Gk20y0gUvTseoEFM45l6jrTK5aTOqJYicJ686MJgm4eBtdVW4BzDiTxff02JdvMX-FgK5J5Eg"
          />
        </button>
      </div>
    </header>
  );
};

export default Header;
