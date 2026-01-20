import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

/**
 * Fetches depth chart data for a specific team.
 * Returns players grouped by position group and sorted by rank.
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

        console.log('Fetching depth chart for team:', team_id)

        // 1. Get the latest depth chart version for this team
        const { data: versionData, error: versionError } = await supabase
            .from('depth_charts')
            .select('version')
            .eq('team', team_id)
            .order('version', { ascending: false })
            .limit(1)
            .maybeSingle()

        if (versionError) {
            console.error('Error fetching version:', versionError)
            throw new Error(`Could not determine latest depth chart version: ${versionError.message}`)
        }

        if (!versionData) {
            console.log('No depth chart found for team:', team_id)
            return new Response(
                JSON.stringify({
                    offense: {},
                    defense: {},
                    specialTeams: {},
                }),
                {
                    headers: {
                        ...corsHeaders,
                        'Content-Type': 'application/json',
                    },
                }
            )
        }

        const latestVersion = versionData.version
        console.log('Latest version for', team_id, ':', latestVersion)

        // 2. Fetch depth chart data with player details
        const { data: depthData, error: depthError } = await supabase
            .from('depth_charts')
            .select(`
                player_id,
                pos_rank,
                pos_grp,
                players (
                    first_name,
                    last_name,
                    headshot,
                    jersey_number,
                    position
                )
            `)
            .eq('team', team_id)
            .eq('version', latestVersion)
            .order('pos_rank', { ascending: true })

        if (depthError) {
            console.error('Error fetching depth chart:', depthError)
            throw depthError
        }

        console.log('Depth chart data fetched. Row count:', depthData?.length ?? 0)

        // 3. Normalization and Grouping Configuration
        const normalizePosition = (pos: string): string => {
            const p = pos.toUpperCase()
            // Offense
            if (['QB', 'QUARTERBACK'].includes(p)) return 'QB'
            if (['RB', 'HB', 'RUNNING BACK', 'HALFBACK'].includes(p)) return 'RB'
            if (['FB', 'FULLBACK'].includes(p)) return 'FB'
            if (['WR', 'WIDE RECEIVER'].includes(p)) return 'WR'
            if (['TE', 'TIGHT END'].includes(p)) return 'TE'
            if (['C', 'CENTER'].includes(p)) return 'C'
            if (['G', 'OG', 'LG', 'RG', 'GUARD', 'OFFENSIVE GUARD', 'LEFT GUARD', 'RIGHT GUARD'].includes(p)) return 'G'
            if (['T', 'OT', 'LT', 'RT', 'OL', 'TACKLE', 'OFFENSIVE TACKLE', 'LEFT TACKLE', 'RIGHT TACKLE'].includes(p)) return 'OT'

            // Defense
            if (['DE', 'EDGE', 'EOLB', 'DEFENSIVE END', 'LEFT DEFENSIVE END', 'RIGHT DEFENSIVE END'].includes(p)) return 'DE'
            if (['DT', 'NT', 'DEFENSIVE TACKLE', 'NOSE TACKLE'].includes(p)) return 'DT'
            if (['LB', 'ILB', 'MLB', 'OLB', 'LINEBACKER', 'INSIDE LINEBACKER', 'MIDDLE LINEBACKER', 'OUTSIDE LINEBACKER', 'STRONGSIDE LINEBACKER', 'WEAKSIDE LINEBACKER'].includes(p)) return 'LB'
            if (['CB', 'RCB', 'LCB', 'DB', 'CORNERBACK', 'LEFT CORNERBACK', 'RIGHT CORNERBACK'].includes(p)) return 'CB'
            if (['S', 'FS', 'SS', 'SAF', 'SAFETY', 'FREE SAFETY', 'STRONG SAFETY'].includes(p)) return 'S'

            // Special
            if (['K', 'PK', 'KICKER', 'PLACE KICKER'].includes(p)) return 'K'
            if (['P', 'PUNTER'].includes(p)) return 'P'
            if (['LS', 'LONG SNAPPER'].includes(p)) return 'LS'

            return p // Return original if no match (e.g. custom positions)
        }

        const positionGroupLabels: Record<string, string> = {
            'QB': 'QUARTERBACKS',
            'RB': 'RUNNING BACKS',
            'FB': 'FULLBACKS',
            'WR': 'WIDE RECEIVERS',
            'TE': 'TIGHT ENDS',
            'C': 'CENTERS',
            'G': 'GUARDS',
            'OT': 'OFFENSIVE TACKLES',

            'DE': 'DEFENSIVE ENDS',
            'DT': 'DEFENSIVE TACKLES',
            'LB': 'LINEBACKERS',
            'CB': 'CORNERBACKS',
            'S': 'SAFETIES',

            'K': 'KICKERS',
            'P': 'PUNTERS',
            'LS': 'LONG SNAPPERS',
        }

        // Ordered lists as requested
        const offenseOrder = ['QB', 'RB', 'FB', 'WR', 'TE', 'C', 'G', 'OT']
        const defenseOrder = ['DE', 'DT', 'LB', 'CB', 'S']
        const specialOrder = ['K', 'P', 'LS']

        const getRankStatus = (rank: number): string => {
            switch (rank) {
                case 1: return 'STARTER'
                case 2: return '2ND STRING'
                case 3: return '3RD STRING'
                default: return `${rank}TH STRING`
            }
        }

        // 4. Group players
        // We use Map to preserve insertion order for the groups, then convert to object
        const offenseMap = new Map<string, any[]>()
        const defenseMap = new Map<string, any[]>()
        const specialMap = new Map<string, any[]>()

        // Initialize maps with ordered keys to ensure output order
        offenseOrder.forEach(k => offenseMap.set(positionGroupLabels[k] || k, []))
        defenseOrder.forEach(k => defenseMap.set(positionGroupLabels[k] || k, []))
        specialOrder.forEach(k => specialMap.set(positionGroupLabels[k] || k, []))

        depthData?.forEach((entry: any) => {
            if (!entry.players) return

            const player = entry.players
            // Use pos_grp if available, else player position. Then normalize.
            let rawPos = entry.pos_grp || player.position || 'UNK'
            const normPos = normalizePosition(rawPos)
            const groupLabel = positionGroupLabels[normPos] || normPos // Fallback to abbr if no label

            const playerObj = {
                id: entry.player_id,
                name: `${player.first_name} ${player.last_name}`,
                number: player.jersey_number ? `${player.jersey_number}` : '',
                position: normPos,
                rank: entry.pos_rank || 1,
                status: getRankStatus(entry.pos_rank || 1),
                imageUrl: player.headshot || '',
                isHot: false,
                hasQuest: false,
            }

            // Route to correct map based on normalized position
            if (offenseOrder.includes(normPos)) {
                offenseMap.get(groupLabel)?.push(playerObj)
            } else if (defenseOrder.includes(normPos)) {
                defenseMap.get(groupLabel)?.push(playerObj)
            } else if (specialOrder.includes(normPos)) {
                specialMap.get(groupLabel)?.push(playerObj)
            } else {
                // Unmapped positions are intentionally skipped
            }
        })

        // 5. Convert Maps to Objects and Sort Players
        const prepareResult = (map: Map<string, any[]>) => {
            const result: Record<string, any[]> = {}
            for (const [key, players] of map.entries()) {
                if (players.length > 0) {
                    // Sort by rank
                    players.sort((a, b) => a.rank - b.rank)
                    result[key] = players
                }
            }
            return result
        }

        const offense = prepareResult(offenseMap)
        const defense = prepareResult(defenseMap)
        const specialTeams = prepareResult(specialMap)

        return new Response(
            JSON.stringify({
                offense,
                defense,
                specialTeams,
            }),
            {
                headers: {
                    ...corsHeaders,
                    'Content-Type': 'application/json',
                    'Cache-Control': 'public, max-age=3600',
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
