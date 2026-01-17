import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

/**
 * Returns the daily challenge player ID.
 * Selection logic:
 * 1. Get upcoming games (games with no result yet)
 * 2. Extract team abbreviations from those games
 * 3. Pick a random player from those teams (seeded by date for consistency)
 * 4. If no upcoming games (off-season), fall back to random team
 * 
 * The same player is returned for all users on the same day.
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

        // Parse optional difficulty from request body (default to 'pro')
        let difficulty = 'pro'
        try {
            const body = await req.json()
            difficulty = body.difficulty ?? 'pro'
        } catch {
            // No body, use default
        }

        // Get today's date in UTC for consistent seeding across timezones
        const today = new Date()
        const dateString = today.toISOString().split('T')[0] // "2026-01-17"
        
        console.log(`Daily challenge for ${dateString}, difficulty: ${difficulty}`)

        // 1. Find upcoming games (games without a result)
        const { data: upcomingGames, error: gamesError } = await supabaseClient
            .from('games')
            .select('home_team, away_team')
            .is('result', null)
            .order('season', { ascending: false })
            .order('week', { ascending: true })
            .limit(4) // Get next 4 games for team variety

        if (gamesError) throw gamesError

        let teamAbbrs: string[] = []

        if (upcomingGames && upcomingGames.length > 0) {
            // Extract unique team abbreviations from upcoming games
            const teamSet = new Set<string>()
            for (const game of upcomingGames) {
                if (game.home_team) teamSet.add(game.home_team.toUpperCase())
                if (game.away_team) teamSet.add(game.away_team.toUpperCase())
            }
            teamAbbrs = Array.from(teamSet)
            console.log(`Found ${teamAbbrs.length} teams from upcoming games: ${teamAbbrs.join(', ')}`)
        } else {
            // Off-season: Pick random teams
            console.log('No upcoming games found, selecting random teams')
            const { data: allTeams, error: teamsError } = await supabaseClient
                .from('teams')
                .select('team_abbr')
                .limit(8)

            if (teamsError) throw teamsError
            if (allTeams) {
                teamAbbrs = allTeams.map(t => t.team_abbr?.toUpperCase()).filter(Boolean)
            }
        }

        if (teamAbbrs.length === 0) {
            throw new Error('No teams found for daily challenge')
        }

        // 2. Get players from those teams based on difficulty
        let playerIds: string[] = []

        if (difficulty === 'allMadden') {
            // Any player from selected teams
            const { data, error } = await supabaseClient
                .from('players')
                .select('player_id')
                .in('team', teamAbbrs)

            if (error) throw error
            if (data) playerIds = data.map(p => p.player_id)

        } else if (difficulty === 'rookie') {
            // Value positions only
            const { data, error } = await supabaseClient
                .from('players')
                .select('player_id')
                .in('team', teamAbbrs)
                .or('position.eq.QB,position.eq.RB,position.eq.WR,position.eq.TE,position.eq.DE,position.eq.CB')

            if (error) throw error
            if (data) playerIds = data.map(p => p.player_id)

        } else {
            // Fan/Pro: Use depth chart starters
            const { data: versionData, error: versionError } = await supabaseClient
                .from('depth_charts')
                .select('version')
                .order('version', { ascending: false })
                .limit(1)
                .single()

            if (versionError) throw versionError
            if (!versionData) throw new Error('No depth chart data found')

            const latestVersion = versionData.version

            // Get starters (rank 1 or 2 for fan mode)
            const maxRank = difficulty === 'fan' ? 2 : 1

            const { data, error } = await supabaseClient
                .from('depth_charts')
                .select('player_id, team')
                .eq('version', latestVersion)
                .lte('pos_rank', maxRank)
                .in('team', teamAbbrs)

            if (error) throw error
            if (data) playerIds = data.map(p => p.player_id)
        }

        if (playerIds.length === 0) {
            throw new Error('No players found matching daily challenge criteria')
        }

        // 3. Deterministic selection based on date
        // Use a simple hash of the date string to seed the selection
        const dateHash = hashCode(dateString)
        const selectedIndex = Math.abs(dateHash) % playerIds.length
        const selectedPlayerId = playerIds[selectedIndex]

        console.log(`Selected player ${selectedPlayerId} (index ${selectedIndex} of ${playerIds.length})`)

        return new Response(JSON.stringify({
            playerId: selectedPlayerId,
            date: dateString,
            difficulty: difficulty,
            poolSize: playerIds.length,
            teamsInvolved: teamAbbrs,
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

/**
 * Simple hash function for deterministic seeding
 */
function hashCode(str: string): number {
    let hash = 0
    for (let i = 0; i < str.length; i++) {
        const char = str.charCodeAt(i)
        hash = ((hash << 5) - hash) + char
        hash = hash & hash // Convert to 32-bit integer
    }
    return hash
}
