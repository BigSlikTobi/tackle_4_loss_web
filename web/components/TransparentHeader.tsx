
import React from 'react';


interface TransparentHeaderProps {
    onOpenBreakingNews?: () => void;
    hasUnread?: boolean;
}

const TransparentHeader: React.FC<TransparentHeaderProps> = ({ onOpenBreakingNews, hasUnread }) => {
    return (
        <header className="fixed top-0 w-full z-50 pt-12 pb-6 px-6 flex justify-between items-center transition-all duration-300 bg-gradient-to-b from-black/60 to-transparent pointer-events-none">
            <div className="pointer-events-auto h-12 w-auto transform active:scale-95 transition-transform duration-200">
                <img
                    src="/logo.png"
                    alt="T4L"
                    className="h-full w-auto object-contain"
                    style={{
                        maskImage: 'radial-gradient(circle, black 60%, transparent 100%)',
                        WebkitMaskImage: 'radial-gradient(circle, black 60%, transparent 100%)'
                    }}
                />
            </div>

            {/* Right side actions - Empty for now as requested */}
            <div className="flex items-center space-x-3 pointer-events-auto">
            </div>
        </header>
    );
};

export default TransparentHeader;
