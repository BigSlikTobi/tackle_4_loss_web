import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

/**
 * Calculate age from birth date
 */
function calculateAge(birthDate: string | null): number | null {
    if (!birthDate) return null
    const birth = new Date(birthDate)
    const today = new Date()
    let age = today.getFullYear() - birth.getFullYear()
    const monthDiff = today.getMonth() - birth.getMonth()
    if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < birth.getDate())) {
        age--
    }
    return age
}

/**
 * Get full player details for the reveal screen after game ends.
 * Returns comprehensive player profile.
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

        const { playerId } = await req.json()

        if (!playerId) {
            throw new Error('playerId is required')
        }

        // Fetch player details with correct column names
        const { data: player, error: playerError } = await supabaseClient
            .from('players')
            .select('*')
            .eq('player_id', playerId)
            .single()

        if (playerError) throw playerError
        if (!player) throw new Error('Player not found')

        // Fetch team details with normalization for LA/LAR and JAX/JAC
        const teamAbbrs = [player.latest_team]
        if (player.latest_team === 'LA') teamAbbrs.push('LAR')
        if (player.latest_team === 'LAR') teamAbbrs.push('LA')
        if (player.latest_team === 'JAC') teamAbbrs.push('JAX')
        if (player.latest_team === 'JAX') teamAbbrs.push('JAC')

        const { data: teamData, error: teamError } = await supabaseClient
            .from('teams')
            .select('team_name, team_conference, team_division, logo_url')
            .in('team_abbr', teamAbbrs)
            .limit(1)

        const team = teamData && teamData.length > 0 ? teamData[0] : null

        if (teamError && teamError.code !== 'PGRST116') { // Ignore not found
            throw teamError
        }

        // Calculate age from birth_date
        const age = calculateAge(player.birth_date)

        // Build response with correct column mappings
        const response = {
            playerId: player.player_id,
            displayName: player.display_name,
            team: player.latest_team,
            teamName: team?.team_name,
            teamLogo: team?.logo_url,
            conference: team?.team_conference,
            division: team?.team_division,
            position: player.position,
            jerseyNumber: parseInt(player.jersey_number) || null,
            age: age,
            height: player.height ? Math.round(player.height) : null,
            weight: player.weight ? Math.round(player.weight) : null,
            college: player.college_name, // Map college_name to college
            headshot: player.headshot,
            yearsExperience: player.years_of_experience,
            draftYear: player.draft_year,
            draftRound: player.draft_round,
            draftPick: player.draft_pick
        }

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
