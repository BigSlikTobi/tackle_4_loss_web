// Edge function: schedule
// Returns every game in the database, sorted season DESC, week ASC, gameday ASC.
// Consumed by the Standings "Schedule" tab and by the Team Center game carousel
// (which filters client-side by team).
//
// Response shape mirrors Game.fromJson in
// flutter_app/lib/micro_apps/standings/models/game_model.dart.

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers':
    'authorization, x-client-info, apikey, content-type',
}

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      {
        global: {
          headers: { Authorization: req.headers.get('Authorization') ?? '' },
        },
      },
    )

    const { data, error } = await supabase
      .from('games')
      .select(
        'id, game_id, season, game_type, week, gameday, weekday, gametime, ' +
          'away_team, away_score, home_team, home_score, location, result, total, ' +
          'overtime, pfr, pff, ftn, roof, surface, temp, wind, referee, stadium',
      )
      .order('season', { ascending: false })
      .order('week', { ascending: true })
      .order('gameday', { ascending: true })

    if (error) throw error

    const games = (data ?? []).map((g) => ({
      id: g.id,
      gameId: g.game_id,
      season: g.season,
      gameType: g.game_type,
      week: g.week,
      gameday: g.gameday,
      weekday: g.weekday,
      gametime: g.gametime,
      awayTeam: g.away_team,
      awayScore: g.away_score,
      homeTeam: g.home_team,
      homeScore: g.home_score,
      location: g.location,
      result: g.result,
      total: g.total,
      overtime: g.overtime,
      pfr: g.pfr,
      pff: g.pff,
      ftn: g.ftn,
      roof: g.roof,
      surface: g.surface,
      temp: g.temp,
      wind: g.wind,
      referee: g.referee,
      stadium: g.stadium,
    }))

    return new Response(JSON.stringify(games), {
      status: 200,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })
  } catch (err) {
    return new Response(
      JSON.stringify({ error: (err as Error).message }),
      {
        status: 400,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      },
    )
  }
})
