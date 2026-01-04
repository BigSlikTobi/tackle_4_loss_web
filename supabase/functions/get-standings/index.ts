import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface TeamRecord {
    team_abbr: string;
    team_name: string;
    team_conference: string;
    team_division: string;
    logo_url: string;
}

interface GameRecord {
    id: number;
    season: number;
    week: number;
    game_type: string;
    home_team: string; // Abbr
    away_team: string; // Abbr
    home_score: number | null;
    away_score: number | null;
    result: string | null;
}

interface TeamStats {
    wins: number;
    losses: number;
    ties: number;
    pointsFor: number;
    pointsAgainst: number;
    conferenceWins: number;
    conferenceLosses: number;
    divisionWins: number;
    divisionLosses: number;
}

interface TeamStanding {
    teamId: string; // Abbr
    teamName: string;
    conference: string;
    division: string;
    logoUrl: string;
    season: number;
    wins: number;
    losses: number;
    ties: number;
    pointsFor: number;
    pointsAgainst: number;
    conferenceWins: number;
    conferenceLosses: number;
    divisionWins: number;
    divisionLosses: number;
    winPercentage: number;
    netPoints: number;
}

interface DivisionStandings {
    division: string;
    teams: TeamStanding[];
}

interface ConferenceStandings {
    conference: string;
    divisions: DivisionStandings[];
}

/**
 * Sorts teams using simplified NFL tiebreaker rules:
 * 1. Win Percentage (descending)
 * 2. Division Wins (descending) - for teams in same division
 * 3. Conference Wins (descending)
 * 4. Net Points (points_for - points_against, descending)
 */
function sortByNFLRules(a: TeamStanding, b: TeamStanding): number {
    // 1. Win Percentage
    if (a.winPercentage !== b.winPercentage) {
        return b.winPercentage - a.winPercentage;
    }

    // 2. Division Wins (if same division)
    if (a.division === b.division && a.divisionWins !== b.divisionWins) {
        return b.divisionWins - a.divisionWins;
    }

    // 3. Conference Wins
    if (a.conferenceWins !== b.conferenceWins) {
        return b.conferenceWins - a.conferenceWins;
    }

    // 4. Net Points
    return b.netPoints - a.netPoints;
}

serve(async (req) => {
    // Handle CORS preflight requests
    if (req.method === 'OPTIONS') {
        return new Response('ok', { headers: corsHeaders })
    }

    try {
        const supabaseClient = createClient(
            Deno.env.get('SUPABASE_URL') ?? '',
            Deno.env.get('SUPABASE_ANON_KEY') ?? '',
            { global: { headers: { Authorization: req.headers.get('Authorization')! } } }
        )

        // Parse optional season parameter from request body
        let season: number | null = null;
        try {
            const body = await req.json();
            season = body.season ?? null;
        } catch {
            // No body or invalid JSON
        }

        // 1. Fetch all teams
        const { data: teamsData, error: teamsError } = await supabaseClient
            .from('teams')
            .select('team_abbr, team_name, team_conference, team_division, logo_url');

        if (teamsError) throw teamsError;
        if (!teamsData || teamsData.length === 0) throw new Error('No teams found');

        // Map teams by Abbreviation
        const teamsMap = new Map<string, TeamRecord>();
        (teamsData as TeamRecord[]).forEach(team => {
            if (team.team_abbr) {
                teamsMap.set(team.team_abbr.toUpperCase(), team);
            }
        });

        // 2. determine season if not provided
        if (!season) {
            const { data: latestGame } = await supabaseClient
                .from('games')
                .select('season')
                .order('season', { ascending: false })
                .limit(1)
                .single();
            season = latestGame?.season ?? 2024; // Default fallback
        }

        // 3. Fetch REGULAR season games for the season
        const { data: gamesData, error: gamesError } = await supabaseClient
            .from('games')
            .select('id, season, week, game_type, home_team, away_team, home_score, away_score, result')
            .eq('season', season)
            .eq('game_type', 'REG') // Only calculate standings from regular season
            .not('result', 'is', null); // Only played games

        if (gamesError) throw gamesError;

        // 4. Calculate Stats
        const statsMap = new Map<string, TeamStats>();

        // Initialize stats for all teams found in the DB (to ensure 0-0-0 teams appear)
        for (const teamAbbr of teamsMap.keys()) {
            statsMap.set(teamAbbr, {
                wins: 0,
                losses: 0,
                ties: 0,
                pointsFor: 0,
                pointsAgainst: 0,
                conferenceWins: 0,
                conferenceLosses: 0,
                divisionWins: 0,
                divisionLosses: 0
            });
        }

        const validGames = (gamesData as GameRecord[]) || [];

        for (const game of validGames) {
            const homeAbbr = game.home_team?.toUpperCase();
            const awayAbbr = game.away_team?.toUpperCase();

            // Check if scores exist
            if (game.home_score === null || game.away_score === null) continue;

            const homeTeam = teamsMap.get(homeAbbr);
            const awayTeam = teamsMap.get(awayAbbr);
            const homeStats = statsMap.get(homeAbbr);
            const awayStats = statsMap.get(awayAbbr);

            if (!homeTeam || !awayTeam || !homeStats || !awayStats) continue;

            const hScore = game.home_score;
            const aScore = game.away_score;

            // Update Points
            homeStats.pointsFor += hScore;
            homeStats.pointsAgainst += aScore;
            awayStats.pointsFor += aScore;
            awayStats.pointsAgainst += hScore;

            // Determine Winner
            let homeWon = false;
            let awayWon = false;
            let tie = false;

            if (hScore > aScore) homeWon = true;
            else if (aScore > hScore) awayWon = true;
            else tie = true;

            // Update Records
            if (homeWon) {
                homeStats.wins++;
                awayStats.losses++;
            } else if (awayWon) {
                awayStats.wins++;
                homeStats.losses++;
            } else {
                homeStats.ties++;
                awayStats.ties++;
            }

            // Conference Record
            if (homeTeam.team_conference === awayTeam.team_conference) {
                if (homeWon) {
                    homeStats.conferenceWins++;
                    awayStats.conferenceLosses++;
                } else if (awayWon) {
                    awayStats.conferenceWins++;
                    homeStats.conferenceLosses++;
                }
                // Ties don't neatly fit into pure W/L bucket integers usually, but for simple sorting we might ignore or add logic.
                // NFL uses W-L-T percentage for these.
                // For now, keeping integer counts.
            }

            // Division Record
            // Logic: Same conference AND Same Division name
            // Note: Sometimes division is 'AFC North' vs 'North', check data consistency. 
            // Assuming full string match 'AFC North' == 'AFC North'.
            if (homeTeam.team_division === awayTeam.team_division && homeTeam.team_conference === awayTeam.team_conference) {
                if (homeWon) {
                    homeStats.divisionWins++;
                    awayStats.divisionLosses++;
                } else if (awayWon) {
                    awayStats.divisionWins++;
                    homeStats.divisionLosses++;
                }
            }
        }

        // 5. Construct Response
        const standings: TeamStanding[] = [];

        for (const [abbr, stats] of statsMap.entries()) {
            const team = teamsMap.get(abbr)!;
            const totalGames = stats.wins + stats.losses + stats.ties;
            const winPct = totalGames > 0 ? (stats.wins + 0.5 * stats.ties) / totalGames : 0.0;

            standings.push({
                teamId: team.team_abbr,
                teamName: team.team_name,
                conference: team.team_conference,
                division: team.team_division,
                logoUrl: team.logo_url,
                season: season!,
                wins: stats.wins,
                losses: stats.losses,
                ties: stats.ties,
                pointsFor: stats.pointsFor,
                pointsAgainst: stats.pointsAgainst,
                conferenceWins: stats.conferenceWins,
                conferenceLosses: stats.conferenceLosses,
                divisionWins: stats.divisionWins,
                divisionLosses: stats.divisionLosses,
                winPercentage: winPct,
                netPoints: stats.pointsFor - stats.pointsAgainst
            });
        }

        // Group by Conference -> Division
        const conferenceMap = new Map<string, Map<string, TeamStanding[]>>();

        for (const standing of standings) {
            // Filter out if conference/division is missing
            if (!standing.conference || !standing.division) continue;

            if (!conferenceMap.has(standing.conference)) {
                conferenceMap.set(standing.conference, new Map());
            }
            const divisionMap = conferenceMap.get(standing.conference)!;

            if (!divisionMap.has(standing.division)) {
                divisionMap.set(standing.division, []);
            }
            divisionMap.get(standing.division)!.push(standing);
        }

        // Build Final JSON
        const response: ConferenceStandings[] = [];

        for (const [conference, divisionMap] of conferenceMap) {
            const divisions: DivisionStandings[] = [];

            for (const [division, teams] of divisionMap) {
                teams.sort(sortByNFLRules);
                divisions.push({
                    division,
                    teams,
                });
            }
            divisions.sort((a, b) => a.division.localeCompare(b.division));
            response.push({
                conference,
                divisions,
            });
        }

        // Sort Conferences
        response.sort((a, b) => a.conference.localeCompare(b.conference));

        return new Response(JSON.stringify(response), {
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
            status: 200,
        })

    } catch (error) {
        return new Response(JSON.stringify({ error: error.message }), {
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
            status: 400,
        })
    }
})
