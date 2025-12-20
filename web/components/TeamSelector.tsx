import React, { useEffect, useState } from 'react';
import { supabase } from '../lib/supabase';
import { Team } from '../types';
import { X } from 'lucide-react';

interface TeamSelectorProps {
    onSelect: (team: Team) => void;
    onClose: () => void;
}

const TeamSelector: React.FC<TeamSelectorProps> = ({ onSelect, onClose }) => {
    const [teams, setTeams] = useState<Team[]>([]);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        const fetchTeams = async () => {
            try {
                const { data, error } = await supabase.functions.invoke('get-all-teams');
                if (error) {
                    console.error('Error fetching teams:', error);
                } else {
                    setTeams(data as Team[]);
                }
            } catch (error) {
                console.error('Unexpected error:', error);
            } finally {
                setLoading(false);
            }
        };

        fetchTeams();
    }, []);


    const groupedTeams = teams.reduce((acc, team) => {
        if (!acc[team.team_conference]) {
            acc[team.team_conference] = {};
        }
        if (!acc[team.team_conference][team.team_division]) {
            acc[team.team_conference][team.team_division] = [];
        }
        acc[team.team_conference][team.team_division].push(team);
        return acc;
    }, {} as Record<string, Record<string, Team[]>>);

    const conferences = ['NFC', 'AFC']; // Enforce order or discovered
    const divisions = ['North', 'South', 'East', 'West'];

    return (
        <div className="fixed inset-0 z-[250] flex items-center justify-center bg-black/60 backdrop-blur-sm p-4">
            <div className="bg-white dark:bg-zinc-900 rounded-3xl w-full max-w-4xl max-h-[90vh] overflow-y-auto shadow-2xl border border-white/20 relative">
                <button
                    onClick={onClose}
                    className="absolute top-4 right-4 p-2 rounded-full bg-gray-100 dark:bg-zinc-800 hover:bg-gray-200 dark:hover:bg-zinc-700 transition-colors"
                >
                    <X size={24} />
                </button>

                <div className="p-8">
                    <h2 className="text-3xl font-['Anton'] text-center mb-2 dark:text-white uppercase tracking-wider">Select Your Team</h2>
                    <p className="text-center text-zinc-500 mb-8">Choose your favorite team to display in the navigation bar</p>

                    {loading ? (
                        <div className="flex justify-center items-center h-64">
                            <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary"></div>
                        </div>
                    ) : (
                        <div className="space-y-12">
                            {conferences.map(conf => (
                                groupedTeams[conf] && (
                                    <div key={conf} className="space-y-6">
                                        <div className="flex items-center gap-4">
                                            <h3 className="text-4xl font-black text-gray-200 dark:text-zinc-800 select-none">{conf}</h3>
                                            <div className="h-px bg-gray-200 dark:bg-zinc-800 flex-1"></div>
                                        </div>

                                        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
                                            {Object.keys(groupedTeams[conf]).sort().map(div => (
                                                <div key={div} className="space-y-3">
                                                    <h4 className="text-sm font-semibold text-primary uppercase tracking-widest">{div}</h4>
                                                    <div className="grid grid-cols-2 gap-2">
                                                        {groupedTeams[conf][div].map(team => (
                                                            <button
                                                                key={team.team_name}
                                                                onClick={() => onSelect(team)}
                                                                className="group flex flex-col items-center justify-center p-3 rounded-xl bg-gray-50 dark:bg-zinc-800/50 hover:bg-white dark:hover:bg-zinc-800 border border-transparent hover:border-primary/20 hover:shadow-lg hover:shadow-primary/10 transition-all duration-200"
                                                            >
                                                                <div className="w-12 h-12 relative mb-2 transition-transform group-hover:scale-110">
                                                                    <img
                                                                        src={team.logo_url}
                                                                        alt={team.team_name}
                                                                        className="w-full h-full object-contain"
                                                                        loading="lazy"
                                                                    />
                                                                </div>
                                                                <span className="text-xs font-medium text-center text-zinc-600 dark:text-zinc-300 group-hover:text-primary dark:group-hover:text-white transition-colors line-clamp-1">{team.team_name}</span>
                                                            </button>
                                                        ))}
                                                    </div>
                                                </div>
                                            ))}
                                        </div>

                                    </div>
                                )
                            ))}
                        </div>
                    )}
                </div>
            </div>
        </div>
    );
};

export default TeamSelector;
