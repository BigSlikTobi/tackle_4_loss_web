// Edge function: injuries
// Returns the most recent injury report for a team, bucketed into
// out / doubtful / questionable. Body: { team_id: string }.
//
// Reads from `injuries_current` (pre-filtered to `is_current = true`,
// pre-joined with `players`). Picks the latest report by
// season DESC → season_type (post > reg > pre) DESC → week DESC, and
// drops rows whose status normalizes to ACTIVE — those aren't injuries.
//
// Response shape mirrors InjuryPlayer.fromJson in
// flutter_app/lib/core/team_center/models/injury_player.dart.

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers':
    'authorization, x-client-info, apikey, content-type',
}

const SEASON_TYPE_RANK: Record<string, number> = { post: 3, reg: 2, pre: 1 }

const empty = () => ({ out: [], doubtful: [], questionable: [] })

function normalizeStatus(s: string | null | undefined): string {
  const v = (s ?? '').toUpperCase()
  if (v.includes('OUT')) return 'OUT'
  if (v.includes('DOUBT')) return 'DOUBTFUL'
  if (v.includes('QUEST') || v.includes('QST')) return 'QUESTIONABLE'
  if (v.includes('ACTIVE') || v.includes('HEALTHY')) return 'ACTIVE'
  if (v.length === 0) return 'ACTIVE'
  return v
}

function normalizeParticipation(s: string | null | undefined): string {
  const v = (s ?? '').toUpperCase()
  if (v.includes('DNP') || v.includes('DID NOT')) return 'DNP'
  if (v.includes('LP') || v.includes('LIMITED')) return 'LP'
  if (v.includes('FP') || v.includes('FULL')) return 'FP'
  return v.length > 0 ? v : 'DNP'
}

interface MetaRow {
  season: number
  season_type: string | null
  week: number
}

interface InjuryRow {
  player_id: string
  player_name: string | null
  injury: string | null
  practice_status: string | null
  game_status: string | null
  display_name: string | null
  first_name: string | null
  last_name: string | null
  jersey_number: number | string | null
  position: string | null
  headshot: string | null
}

interface PlayerOut {
  id: string
  name: string
  position: string
  number: string
  imageUrl: string
  status: string
  injuryType: string
  participation: string
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

    const { data: meta, error: mErr } = await supabase
      .from('injuries_current')
      .select('season, season_type, week')
      .eq('team_abbr', team_id)
    if (mErr) throw mErr
    if (!meta?.length) return json(empty())

    const latest = (meta as MetaRow[]).slice().sort((a, b) => {
      if (b.season !== a.season) return b.season - a.season
      const ar = SEASON_TYPE_RANK[a.season_type?.toLowerCase() ?? ''] ?? 0
      const br = SEASON_TYPE_RANK[b.season_type?.toLowerCase() ?? ''] ?? 0
      if (br !== ar) return br - ar
      return b.week - a.week
    })[0]

    const { data: rows, error: rErr } = await supabase
      .from('injuries_current')
      .select(
        'player_id, player_name, injury, practice_status, game_status, ' +
          'display_name, first_name, last_name, jersey_number, position, ' +
          'headshot',
      )
      .eq('team_abbr', team_id)
      .eq('season', latest.season)
      .eq('season_type', latest.season_type)
      .eq('week', latest.week)
    if (rErr) throw rErr
    if (!rows?.length) return json(empty())

    const out: PlayerOut[] = []
    const doubtful: PlayerOut[] = []
    const questionable: PlayerOut[] = []

    for (const row of rows as InjuryRow[]) {
      // Prefer game_status; fall back to the lowercase `injury` column,
      // which on this schema also carries the status.
      const status = normalizeStatus(row.game_status ?? row.injury)
      if (status === 'ACTIVE') continue
      if (
        status !== 'OUT' && status !== 'DOUBTFUL' && status !== 'QUESTIONABLE'
      ) {
        continue
      }

      const fullName = (row.display_name && row.display_name.trim().length > 0)
        ? row.display_name
        : (row.player_name && row.player_name.trim().length > 0)
          ? row.player_name
          : `${row.first_name ?? ''} ${row.last_name ?? ''}`.trim()

      const player: PlayerOut = {
        id: row.player_id,
        name: fullName.length > 0 ? fullName : 'Unknown',
        position: row.position ?? '',
        number: row.jersey_number != null && `${row.jersey_number}`.length > 0
          ? `${row.jersey_number}`
          : '',
        imageUrl: row.headshot ?? '',
        status,
        // The new schema's `injury` column is the lowercase status, not a
        // body part — there's no Knee / Hamstring data to surface, so
        // default rather than echo the status text.
        injuryType: 'Undisclosed',
        participation: normalizeParticipation(row.practice_status),
      }

      if (status === 'OUT') out.push(player)
      else if (status === 'DOUBTFUL') doubtful.push(player)
      else questionable.push(player)
    }

    return json({ out, doubtful, questionable })
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

function json(body: unknown) {
  return new Response(JSON.stringify(body), {
    status: 200,
    headers: {
      ...corsHeaders,
      'Content-Type': 'application/json',
      'Cache-Control': 'public, max-age=1800',
    },
  })
}
