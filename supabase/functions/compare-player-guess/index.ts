import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

// Define which positions are on offense vs defense
const offensivePositions = ['QB', 'RB', 'FB', 'WR', 'TE', 'OT', 'OG', 'C', 'T', 'G']
const defensivePositions = ['DE', 'DT', 'NT', 'LB', 'ILB', 'OLB', 'MLB', 'CB', 'S', 'SS', 'FS', 'DB', 'EDGE']

function getSideOfBall(position: string): string {
    const pos = position?.toUpperCase() || ''
    if (offensivePositions.includes(pos)) return 'Offense'
    if (defensivePositions.includes(pos)) return 'Defense'
    // Special teams or unknown
    return 'Special'
}

function compareNumeric(guessed: number, target: number, threshold = 2): {
    match: boolean,
    direction: 'up' | 'down' | 'exact',
    isClose: boolean
} {
    if (guessed === target) {
        return { match: true, direction: 'exact', isClose: true }
    }
    const diff = Math.abs(guessed - target)
    return {
        match: false,
        direction: target > guessed ? 'up' : 'down',
        isClose: diff <= threshold
    }
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
 * Compare a guessed player against the mystery player.
 * Returns detailed comparison for each attribute.
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

        const { guessedPlayerId, mysteryPlayerId } = await req.json()

        if (!guessedPlayerId || !mysteryPlayerId) {
            throw new Error('guessedPlayerId and mysteryPlayerId are required')
        }

        // Fetch both players with correct column names
        const { data: players, error } = await supabaseClient
            .from('players')
            .select('player_id, display_name, latest_team, position, jersey_number, birth_date, height, headshot, college_name')
            .in('player_id', [guessedPlayerId, mysteryPlayerId])

        if (error) throw error

        // If guessedPlayerId === mysteryPlayerId, database will return only 1 row.
        const expectedCount = guessedPlayerId === mysteryPlayerId ? 1 : 2

        if (!players || players.length < expectedCount) {
            throw new Error('One or both players not found')
        }

        const guessed = players.find((p: any) => p.player_id === guessedPlayerId)
        const mystery = players.find((p: any) => p.player_id === mysteryPlayerId)

        if (!guessed || !mystery) {
            throw new Error('Player data mismatch')
        }

        // Get team info for conference/division
        const teamAbbrs = [guessed.latest_team, mystery.latest_team].filter(Boolean)
        const expandedAbbrs = [...teamAbbrs]
        if (teamAbbrs.includes('LA')) expandedAbbrs.push('LAR')
        if (teamAbbrs.includes('LAR')) expandedAbbrs.push('LA')
        if (teamAbbrs.includes('JAC')) expandedAbbrs.push('JAX')
        if (teamAbbrs.includes('JAX')) expandedAbbrs.push('JAC')

        const { data: teams, error: teamsError } = await supabaseClient
            .from('teams')
            .select('team_abbr, team_conference, team_division')
            .in('team_abbr', expandedAbbrs)

        if (teamsError) throw teamsError

        // Helper to find team with normalization
        const findTeam = (abbr: string) => {
            if (!abbr) return null
            return teams?.find(t =>
                t.team_abbr === abbr ||
                (abbr === 'LA' && t.team_abbr === 'LAR') ||
                (abbr === 'LAR' && t.team_abbr === 'LA') ||
                (abbr === 'JAC' && t.team_abbr === 'JAX') ||
                (abbr === 'JAX' && t.team_abbr === 'JAC')
            )
        }

        const guessedTeam = findTeam(guessed.latest_team)
        const mysteryTeam = findTeam(mystery.latest_team)

        // Build comparison
        const isCorrect = guessedPlayerId === mysteryPlayerId

        // Team comparison (if team matches, conference and division also match)
        const isSameTeam = (a: string, b: string) => {
            if (a === b) return true
            if ((a === 'LA' && b === 'LAR') || (a === 'LAR' && b === 'LA')) return true
            if ((a === 'JAC' && b === 'JAX') || (a === 'JAX' && b === 'JAC')) return true
            return false
        }
        const teamMatch = isSameTeam(guessed.latest_team, mystery.latest_team) ? 'match' : 'miss'
        const conferenceMatch = teamMatch === 'match' ? 'match' :
            (guessedTeam?.team_conference === mysteryTeam?.team_conference ? 'match' : 'miss')
        // Helper to check division match (ignoring conference prefix like "AFC North" vs "NFC North")
        const checkDivisionMatch = (div1: string | undefined, div2: string | undefined) => {
            if (!div1 || !div2) return false
            if (div1 === div2) return true // Exact match (e.g. "North" === "North")

            const directions = ['North', 'South', 'East', 'West']
            const dir1 = directions.find(d => div1.includes(d))
            const dir2 = directions.find(d => div2.includes(d))

            return dir1 && dir2 && dir1 === dir2
        }

        const divisionMatch = teamMatch === 'match' ? 'match' :
            (checkDivisionMatch(guessedTeam?.team_division, mysteryTeam?.team_division) ? 'match' : 'miss')

        // Position comparison
        let positionMatch: 'match' | 'side' | 'miss' = 'miss'
        if (guessed.position === mystery.position) {
            positionMatch = 'match'
        } else if (getSideOfBall(guessed.position) === getSideOfBall(mystery.position)) {
            positionMatch = 'side' // Correct side of ball, wrong position
        }

        // Parse jersey numbers (they're strings in DB)
        const guessedJersey = parseInt(guessed.jersey_number) || 0
        const mysteryJersey = parseInt(mystery.jersey_number) || 0

        // Calculate ages from birth_date
        const guessedAge = calculateAge(guessed.birth_date) ?? 0
        const mysteryAge = calculateAge(mystery.birth_date) ?? 0

        // Height is already a number in the schema
        const guessedHeight = guessed.height ?? 0
        const mysteryHeight = mystery.height ?? 0

        // Numeric comparisons
        const jerseyComparison = compareNumeric(guessedJersey, mysteryJersey)
        const ageComparison = compareNumeric(guessedAge, mysteryAge)
        const heightComparison = compareNumeric(guessedHeight, mysteryHeight)

        const response = {
            guessedPlayer: {
                playerId: guessed.player_id,
                displayName: guessed.display_name,
                team: guessed.latest_team,
                position: guessed.position,
                conference: guessedTeam?.team_conference,
                division: guessedTeam?.team_division,
                jerseyNumber: guessedJersey,
                age: guessedAge,
                height: Math.round(guessedHeight), // Ensure integer
                headshot: guessed.headshot
            },
            comparison: {
                conference: conferenceMatch,
                division: divisionMatch,
                team: teamMatch,
                position: positionMatch,
                jerseyNumber: jerseyComparison,
                age: ageComparison,
                height: heightComparison
            },
            isCorrect: isCorrect
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
