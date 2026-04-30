// Edge function: roster
// Returns the latest roster for a team, split into offense / defense /
// special teams. Body: { team_id: string }.
//
// Reads directly from the `rosters_current` view, which is pre-filtered to
// `is_current = true` rows and pre-joined with `players` for jersey number,
// headshot, college, etc. No version lookup needed.
//
// Response shape mirrors RosterPlayer.fromJson in
// flutter_app/lib/core/team_center/models/roster_player.dart.

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers':
    'authorization, x-client-info, apikey, content-type',
}

const OFFENSE = ['QB', 'RB', 'FB', 'WR', 'TE', 'C', 'G', 'OT', 'OL']
const DEFENSE = [
  'DE', 'NT', 'DT', 'LB', 'ILB', 'MLB', 'OLB', 'CB', 'S', 'FS', 'SS', 'DB',
]
const SPECIAL = ['K', 'P', 'LS']

const empty = () => ({ offense: [], defense: [], specialTeams: [] })

interface RosterRow {
  team: string
  depth_chart_position: string | null
  player_id: string
  player_name: string | null
  first_name: string | null
  last_name: string | null
  jersey_number: number | string | null
  roster_position: string | null
  headshot: string | null
  years_of_experience: number | null
  college_name: string | null
}

interface Player {
  id: string
  name: string
  number: string
  position: string
  experience: string
  college: string
  imageUrl: string
}

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
    )

    const { team_id } = await req.json()
    if (!team_id) throw new Error('Missing team_id')

    const { data: rows, error } = await supabase
      .from('rosters_current')
      .select(
        'team, depth_chart_position, player_id, player_name, ' +
          'first_name, last_name, jersey_number, roster_position, ' +
          'headshot, years_of_experience, college_name',
      )
      .eq('team', team_id)
    if (error) throw error
    if (!rows?.length) return json(empty())

    const offense: Player[] = []
    const defense: Player[] = []
    const specialTeams: Player[] = []
    const seen = new Set<string>()

    for (const row of rows as RosterRow[]) {
      if (!row.player_id || seen.has(row.player_id)) continue
      seen.add(row.player_id)

      const pos = (row.depth_chart_position || row.roster_position || 'UNK')
        .toUpperCase()

      const fullName = (row.player_name && row.player_name.trim().length > 0)
        ? row.player_name
        : `${row.first_name ?? ''} ${row.last_name ?? ''}`.trim()

      const player: Player = {
        id: row.player_id,
        name: fullName.length > 0 ? fullName : 'Unknown',
        number: row.jersey_number != null && `${row.jersey_number}`.length > 0
          ? `#${row.jersey_number}`
          : 'N/A',
        position: pos,
        experience: row.years_of_experience != null
          ? `${row.years_of_experience}Y`
          : 'R',
        college: row.college_name && row.college_name.length > 0
          ? row.college_name
          : 'N/A',
        imageUrl: row.headshot ?? '',
      }

      if (OFFENSE.includes(pos)) offense.push(player)
      else if (DEFENSE.includes(pos)) defense.push(player)
      else if (SPECIAL.includes(pos)) specialTeams.push(player)
      else offense.push(player) // fallback bucket for unknown positions
    }

    sortByOrder(offense, OFFENSE)
    sortByOrder(defense, DEFENSE)
    sortByOrder(specialTeams, SPECIAL)

    return json({ offense, defense, specialTeams })
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

function sortByOrder(list: Player[], order: string[]) {
  list.sort((a, b) => {
    const ia = order.indexOf(a.position)
    const ib = order.indexOf(b.position)
    if (ia !== -1 && ib !== -1) return ia - ib
    if (ia !== -1) return -1
    if (ib !== -1) return 1
    return a.name.localeCompare(b.name)
  })
}

function json(body: unknown) {
  return new Response(JSON.stringify(body), {
    status: 200,
    headers: {
      ...corsHeaders,
      'Content-Type': 'application/json',
      'Cache-Control': 'public, max-age=3600',
    },
  })
}
