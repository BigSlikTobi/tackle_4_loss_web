import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

/**
 * Fetches current injury report for a specific team.
 * Returns players grouped by status: OUT, DOUBTFUL, QUESTIONABLE.
 * 
 * Sorting logic: Gets the latest report by season DESC, season_type priority (post > reg > pre), week DESC.
 */
Deno.serve(async (req) => {
    if (req.method === 'OPTIONS') {
        return new Response('ok', { headers: corsHeaders })
    }

    try {
        const supabase = createClient(
            Deno.env.get('SUPABASE_URL') ?? '',
            Deno.env.get('SUPABASE_ANON_KEY') ?? ''
        )

        const { team_id } = await req.json()

        if (!team_id) {
            throw new Error('Missing team_id parameter')
        }

        console.log('Fetching injuries for team:', team_id)

        // 1. Get all current injury records for this team to determine latest season/week/type
        const { data: allInjuries, error: allError } = await supabase
            .from('injuries')
            .select('season, season_type, week')
            .eq('team_abbr', team_id)
            .eq('is_current', true)

        if (allError) {
            console.error('Error fetching injury metadata:', allError)
            throw allError
        }

        if (!allInjuries || allInjuries.length === 0) {
            console.log('No current injuries found for team:', team_id)
            return new Response(
                JSON.stringify({ out: [], doubtful: [], questionable: [] }),
                {
                    headers: {
                        ...corsHeaders,
                        'Content-Type': 'application/json',
                    },
                }
            )
        }

        // 2. Determine the latest report using priority: season DESC, season_type (post > reg > pre), week DESC
        const seasonTypePriority: Record<string, number> = {
            'post': 3,
            'reg': 2,
            'pre': 1,
        }

        // Sort to find the latest entry
        const sorted = allInjuries.sort((a, b) => {
            // First by season (descending)
            if (b.season !== a.season) return b.season - a.season

            // Then by season_type priority (descending)
            const aPriority = seasonTypePriority[a.season_type?.toLowerCase()] || 0
            const bPriority = seasonTypePriority[b.season_type?.toLowerCase()] || 0
            if (bPriority !== aPriority) return bPriority - aPriority

            // Then by week (descending)
            return b.week - a.week
        })

        const latest = sorted[0]
        console.log('Latest injury report:', latest)

        // 3. Fetch injuries for this specific season/season_type/week
        const { data: injuryData, error: injuryError } = await supabase
            .from('injuries')
            .select('player_id, player_name, injury, practice_status, game_status')
            .eq('team_abbr', team_id)
            .eq('is_current', true)
            .eq('season', latest.season)
            .eq('season_type', latest.season_type)
            .eq('week', latest.week)

        if (injuryError) {
            console.error('Error fetching injuries:', injuryError)
            throw injuryError
        }

        console.log('Injuries fetched. Count:', injuryData?.length ?? 0)

        if (!injuryData || injuryData.length === 0) {
            return new Response(
                JSON.stringify({ out: [], doubtful: [], questionable: [] }),
                {
                    headers: {
                        ...corsHeaders,
                        'Content-Type': 'application/json',
                    },
                }
            )
        }

        // 4. Get unique player IDs
        const playerIds = [...new Set(injuryData.map(i => i.player_id))].filter(Boolean)
        console.log('Fetching player details for', playerIds.length, 'players')

        // 5. Fetch player details separately
        const { data: playerData, error: playerError } = await supabase
            .from('players')
            .select('player_id, first_name, last_name, headshot, jersey_number, position')
            .in('player_id', playerIds)

        if (playerError) {
            console.error('Error fetching players:', playerError)
            throw playerError
        }

        // Create player lookup map
        const playerMap = new Map<string, any>()
        playerData?.forEach(p => playerMap.set(p.player_id, p))

        // Normalize game_status to our categories
        const normalizeStatus = (status: string): string => {
            const s = status?.toUpperCase() || 'OUT'
            if (s.includes('OUT')) return 'OUT'
            if (s.includes('DOUBT')) return 'DOUBTFUL'
            if (s.includes('QUEST') || s.includes('QST')) return 'QUESTIONABLE'
            return s
        }

        // Normalize practice participation status
        const normalizeParticipation = (status: string): string => {
            const s = status?.toUpperCase() || 'DNP'
            if (s.includes('DNP') || s.includes('DID NOT')) return 'DNP'
            if (s.includes('LP') || s.includes('LIMITED')) return 'LP'
            if (s.includes('FP') || s.includes('FULL')) return 'FP'
            return s
        }

        // 6. Group injuries by game_status
        const out: any[] = []
        const doubtful: any[] = []
        const questionable: any[] = []

        injuryData.forEach((entry: any) => {
            const player = playerMap.get(entry.player_id)
            // Use player data if found, else fallback to injury record's player_name
            const playerName = player
                ? `${player.first_name} ${player.last_name}`
                : entry.player_name || 'Unknown'

            const normalizedStatus = normalizeStatus(entry.game_status)

            const playerObj = {
                id: entry.player_id,
                name: playerName,
                position: player?.position || '',
                number: player?.jersey_number ? `${player.jersey_number}` : '',
                imageUrl: player?.headshot || '',
                status: normalizedStatus,
                injuryType: entry.injury || 'Undisclosed',
                participation: normalizeParticipation(entry.practice_status),
            }

            switch (normalizedStatus) {
                case 'OUT':
                    out.push(playerObj)
                    break
                case 'DOUBTFUL':
                    doubtful.push(playerObj)
                    break
                case 'QUESTIONABLE':
                    questionable.push(playerObj)
                    break
            }
        })

        return new Response(
            JSON.stringify({
                out,
                doubtful,
                questionable,
            }),
            {
                headers: {
                    ...corsHeaders,
                    'Content-Type': 'application/json',
                    'Cache-Control': 'public, max-age=1800',
                },
            }
        )

    } catch (error) {
        return new Response(
            JSON.stringify({ error: error.message }),
            {
                status: 400,
                headers: {
                    ...corsHeaders,
                    'Content-Type': 'application/json',
                },
            }
        )
    }
})
