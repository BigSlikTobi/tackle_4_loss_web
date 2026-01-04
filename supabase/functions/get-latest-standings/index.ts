import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
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

        // Query all games from public.games table, ordered by season, week, and gameday
        const { data, error } = await supabaseClient
            .from('games')
            .select(`
        id,
        game_id,
        season,
        game_type,
        week,
        gameday,
        weekday,
        gametime,
        away_team,
        away_score,
        home_team,
        home_score,
        location,
        result,
        total,
        overtime,
        pfr,
        pff,
        ftn,
        roof,
        surface,
        temp,
        wind,
        referee,
        stadium
      `)
            .order('season', { ascending: false })
            .order('week', { ascending: true })
            .order('gameday', { ascending: true })

        if (error) throw error

        // Transform data to ensure consistent field naming
        const mappedData = data.map(game => ({
            id: game.id,
            gameId: game.game_id,
            season: game.season,
            gameType: game.game_type,
            week: game.week,
            gameday: game.gameday,
            weekday: game.weekday,
            gametime: game.gametime,
            awayTeam: game.away_team,
            awayScore: game.away_score,
            homeTeam: game.home_team,
            homeScore: game.home_score,
            location: game.location,
            result: game.result,
            total: game.total,
            overtime: game.overtime,
            pfr: game.pfr,
            pff: game.pff,
            ftn: game.ftn,
            roof: game.roof,
            surface: game.surface,
            temp: game.temp,
            wind: game.wind,
            referee: game.referee,
            stadium: game.stadium,
        }))

        return new Response(JSON.stringify(mappedData), {
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
