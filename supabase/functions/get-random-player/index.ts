import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

/**
 * Returns a random player ID for the guessing game.
 * Supports difficulty levels:
 * - fan: Top value positions (QB1, RB1, WR1/2, TE1, DE1/2, CB1/2) from depth chart.
 * - rookie: Value positions (QB, RB, WR, DE, CB) from players table (no depth filter).
 * - pro: All starters (Rank 1) from depth chart.
 * - allMadden: Any player from players table.
 */
serve(async (req) => {
    if (req.method === 'OPTIONS') {
        return new Response('ok', { headers: corsHeaders })
    }

    try {
        const supabaseClient = createClient(
            Deno.env.get('SUPABASE_URL') ?? '',
            Deno.env.get('SUPABASE_ANON_KEY') ?? '',
            { global: { headers: { Authorization: req.headers.get('Authorization')! } } }
        )

        // Parse difficulty from request body (default to 'fan')
        let difficulty = 'fan'
        try {
            const body = await req.json()
            difficulty = body.difficulty ?? 'fan'
        } catch {
            // No body, use default
        }

        console.log(`Searching for random player with difficulty: ${difficulty}`)

        let playerIds: string[] = []

        if (difficulty === 'allMadden') {
            // === ALL MADDEN ===
            // Any player in the database
            // We use a random offset to pick one, rather than fetching all IDs (too heavy)

            // First get count
            const { count, error: countError } = await supabaseClient
                .from('players')
                .select('*', { count: 'exact', head: true })

            if (countError) throw countError

            if (!count || count === 0) throw new Error('No players found')

            // Random offset
            const randomOffset = Math.floor(Math.random() * count)

            const { data, error } = await supabaseClient
                .from('players')
                .select('player_id')
                .range(randomOffset, randomOffset)
                .limit(1)

            if (error) throw error
            if (data) playerIds = data.map(p => p.player_id)

        } else if (difficulty === 'rookie') {
            // === ROOKIE ===
            // Value positions only, no depth chart filter
            // Positions: QB, RB, WR, TE, DE, CB (and variations like EDGE/FS/SS?)
            // User said: "QBs, RBs/WRs, Edge Rusher / Defensive End, Corner Back"

            // Let's stick to the specific list:
            // "Rookie" usually means "Easier". Knowing a backup OL is hard. Knowing a starting QB is easy.
            // But User def: "Mystery Players are selected from the top value positions on each team without filtering the depth chart".

            const { data, error } = await supabaseClient
                .from('players')
                .select('player_id')
                .or('position.eq.QB,position.eq.RB,position.eq.WR,position.eq.TE,position.eq.DE,position.eq.CB')
            // Note: edge cases like 'HB', 'FB', 'SAF' might be missed if strictly 'RB','S'.
            // Assuming standard position codes.

            if (error) throw error
            if (data) playerIds = data.map(p => p.player_id)

        } else {
            // === FAN & PRO ===
            // Requires Depth Chart

            // 1. Get latest version of depth chart
            // We assume 'version' is a string or timestamp. We order desc.
            const { data: versionData, error: versionError } = await supabaseClient
                .from('depth_charts')
                .select('version')
                .order('version', { ascending: false })
                .limit(1) // Get strictly the latest global version
                .single()

            if (versionError) throw versionError
            if (!versionData) throw new Error('No depth chart data found')

            const latestVersion = versionData.version

            // 2. Build Query on Depth Charts
            let query = supabaseClient
                .from('depth_charts')
                .select('player_id')
                .eq('version', latestVersion)

            if (difficulty === 'pro') {
                // === PRO ===
                // All starters (Rank 1)
                query = query.eq('pos_rank', 1)
            } else {
                // === FAN ===
                // Specific starters (Skill positions + specific depth)
                // QB1, RB1, TE1
                // WR1, WR2
                // DE1, DE2 (checking for matches in pos_grp)
                // CB1, CB2

                // Let's filter for Rank <= 2, then filter in memory.
                query = query.lte('pos_rank', 2)
            }

            const { data, error } = await query
            if (error) throw error

            // Post-processing for FAN mode strictly
            if (difficulty === 'fan' && data) {
                // Fetch the actual rows with position/group to filter
                // Retrying query with more fields
                const { data: detailedData, error: detailedError } = await supabaseClient
                    .from('depth_charts')
                    .select(`
                        player_id, 
                        pos_rank, 
                        pos_grp,
                        players!inner (
                            position
                        )
                    `)
                    .eq('version', latestVersion)
                    .lte('pos_rank', 2)

                if (detailedError) throw detailedError

                playerIds = detailedData.filter((row: any) => {
                    const group = (row.pos_grp || '').toUpperCase()
                    const rank = row.pos_rank
                    const actualPos = (row.players?.position || '').toUpperCase()

                    // STRICT Position Check for Fan Mode
                    // Must be one of the allowed positions in search-players
                    const allowedPositions = [
                        'QB',
                        'RB', 'FB', 'HB',
                        'WR',
                        'TE',
                        'DE', 'EDGE', 'EOLB',
                        'CB', 'RCB', 'LCB'
                    ]

                    if (!allowedPositions.includes(actualPos)) return false

                    // Additional Depth Chart Logic (Backup)
                    // QB, RB, TE -> Rank 1 only
                    if (group === 'QB' || group.includes('QUARTERBACK')) return rank === 1
                    if (group === 'RB' || group === 'HB' || group.includes('RUNNING')) return rank === 1
                    if (group === 'TE' || group.includes('TIGHT')) return rank === 1

                    // WR, CB/DB, DE/EDGE/S -> Rank 1 or 2
                    if (group === 'WR' || group.includes('RECEIVER')) return rank <= 2

                    // Defense: DE and DB/CB ONLY. (No DT, No LB)
                    if (group === 'DE' || group === 'EDGE' || group.includes('DEFENSIVE END')) return rank <= 2
                    if (group === 'CB' || group.includes('CORNER')) return rank <= 2

                    return false
                }).map((p: any) => p.player_id)

            } else if (data) {
                // Pro Mode (already filtered by rank=1, excludes nothing strictly but rank)
                playerIds = data.map(p => p.player_id)
            }
        }

        if (playerIds.length === 0) throw new Error('No players found directly matching criteria')

        // Select random player
        const randomIndex = Math.floor(Math.random() * playerIds.length)
        const selectedPlayerId = playerIds[randomIndex]

        return new Response(JSON.stringify({
            playerId: selectedPlayerId,
            difficulty: difficulty,
            poolSize: playerIds.length
        }), {
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
