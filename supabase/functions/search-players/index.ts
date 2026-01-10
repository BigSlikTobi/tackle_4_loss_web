import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

/**
 * Search players by name for autocomplete in the guessing game.
 * Uses case-insensitive ILIKE search on display_name.
 * NOW UPDATED: Deduplicates players and strictly filters by Difficulty.
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

        // Parse search query and filters from request body
        let searchQuery = ''
        let limit = 10
        let offset = 0
        let teamFilter: string | null = null
        let positionFilter: string | null = null
        let difficulty = 'pro' // Default to pro (allow all)

        try {
            const body = await req.json()
            searchQuery = body.query ?? ''
            limit = body.limit ?? 10
            offset = body.offset ?? 0
            teamFilter = body.team ?? null
            positionFilter = body.position ?? null
            difficulty = body.difficulty ?? 'pro'
        } catch {
            // No body
        }

        if ((!searchQuery || searchQuery.length < 2) && !teamFilter && !positionFilter) {
            return new Response(JSON.stringify([]), {
                headers: { ...corsHeaders, 'Content-Type': 'application/json' },
                status: 200,
            })
        }

        // 1. Get Input Mappings (Reverse Normalization)
        // If user filters for "DL", we must look for "DT, NT, LB..."
        let targetPositions: string[] = []
        if (positionFilter) {
            switch (positionFilter) {
                case 'QB': targetPositions = ['QB']; break;
                case 'RB': targetPositions = ['RB', 'FB', 'HB']; break;
                case 'WR': targetPositions = ['WR']; break;
                case 'TE': targetPositions = ['TE']; break;
                case 'OL': targetPositions = ['OT', 'OG', 'C', 'T', 'G']; break;
                case 'DL': targetPositions = ['DT', 'NT', 'LB', 'ILB', 'MLB', 'OLB']; break;
                case 'DE': targetPositions = ['DE', 'EDGE', 'EOLB']; break;
                case 'DB': targetPositions = ['CB', 'RCB', 'LCB', 'DB']; break;
                case 'S': targetPositions = ['SS', 'FS', 'SAF', 'S']; break;
                case 'K': targetPositions = ['PK', 'K']; break;
                case 'P': targetPositions = ['P']; break;
                default: targetPositions = [positionFilter]; // Fallback
            }
        }

        // 2. Get Latest Depth Chart Version
        // We need this to sort by rank correctly
        const { data: versionData, error: versionError } = await supabaseClient
            .from('depth_charts')
            .select('version')
            .order('version', { ascending: false })
            .limit(1)
            .single()

        let latestVersion = versionData?.version

        // 3. Build Query
        // Query depth_charts (joined with players) to get ranked results.

        let query = supabaseClient
            .from('depth_charts')
            .select(`
                pos_rank,
                pos_grp,
                players!inner (
                    player_id,
                    display_name,
                    latest_team,
                    position,
                    headshot
                )
            `)
            .eq('version', latestVersion)
            .order('pos_rank', { ascending: true }) // Sort by Rank
            // Fetch extra rows to handle deduplication and post-filtering
            .range(offset, offset + limit + 40)

        // Apply Filters (on Joined Table)
        if (searchQuery && searchQuery.length >= 2) {
            query = query.ilike('players.display_name', `%${searchQuery}%`)
        }
        if (teamFilter) {
            const teamAbbrs = [teamFilter]
            if (teamFilter === 'LA') teamAbbrs.push('LAR')
            if (teamFilter === 'LAR') teamAbbrs.push('LA')
            if (teamFilter === 'JAC') teamAbbrs.push('JAX')
            if (teamFilter === 'JAX') teamAbbrs.push('JAC')

            query = query.in('players.latest_team', teamAbbrs)
        }
        if (positionFilter) {
            query = query.in('players.position', targetPositions)
        }

        const { data, error } = await query

        if (error) throw error

        // 4. Post-Process: Normalized, Deduped, and Difficulty Filtered
        const seenIds = new Set()
        const results = []

        for (const row of (data || [])) {
            // Deduplication
            if (seenIds.has(row.players.player_id)) continue;

            const player = row.players
            let pos = player.position
            const rank = row.pos_rank
            // const group = row.pos_grp?.toUpperCase() || ''

            // --- Difficulty Filtering (Fan Mode) ---
            if (difficulty === 'fan' || difficulty === 'rookie') {
                // STRICT Fan Mode Rules (must match get-random-player logic)
                // Only: QB, RB, WR, TE, DE, CB
                let isAllowed = false;

                // Offensive Skill (inc FB/HB)
                if (['QB', 'RB', 'FB', 'HB', 'WR', 'TE'].includes(pos)) isAllowed = true;

                // Defense: DE and CB only
                if (['DE', 'EDGE', 'EOLB'].includes(pos)) isAllowed = true;
                if (['CB', 'RCB', 'LCB'].includes(pos)) isAllowed = true;

                // Exclude everything else (DT, NT, LB, S, DB, OL, K, P)
                if (!isAllowed) continue;
            }
            // ---------------------------------------

            seenIds.add(player.player_id);

            // Output Normalization
            // Offense
            if (['OT', 'OG', 'C', 'T', 'G'].includes(pos)) pos = 'OL'
            if (pos === 'FB') pos = 'RB'

            // Defense
            if (['DT', 'NT'].includes(pos)) pos = 'DL'
            if (['DE', 'EDGE', 'EOLB'].includes(pos)) pos = 'DE'
            if (['CB', 'RCB', 'LCB', 'DB'].includes(pos)) pos = 'DB'
            if (['SS', 'FS', 'SAF', 'S'].includes(pos)) pos = 'S'
            if (['ILB', 'MLB', 'OLB', 'LB'].includes(pos)) pos = 'DL'

            // Special
            if (pos === 'PK') pos = 'K'

            results.push({
                playerId: player.player_id,
                displayName: player.display_name,
                team: player.latest_team,
                position: pos,
                headshot: player.headshot,
                rank: row.pos_rank // Optional: could expose rank if needed
            })

            if (results.length >= limit) break; // Apply manual limit after filtering
        }

        return new Response(JSON.stringify(results), {
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
