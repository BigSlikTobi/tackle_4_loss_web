// Edge function: depth-chart
// Returns the latest depth chart for a team, grouped position-group → ranked
// players. Body: { team_id: string }.
//
// Reads directly from the `depth_charts_current` view, which is pre-filtered
// to `is_current = true` rows and pre-joined with `players` for jersey
// number, headshot, display name, etc.
//
// The upstream `position` column is granular (LDE / RDE / LCB / RCB / MLB /
// LOLB / ROLB / etc.). We normalize those to broad buckets so the depth
// chart screen renders one row per position group with all starters/backups
// at that bucket — matching the existing UI contract.
//
// Response shape mirrors DepthChartPlayer.fromJson in
// flutter_app/lib/core/team_center/models/depth_chart_player.dart.

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers':
    'authorization, x-client-info, apikey, content-type',
}

const OFFENSE_ORDER = ['QB', 'RB', 'FB', 'WR', 'TE', 'C', 'G', 'OT']
const DEFENSE_ORDER = ['DE', 'DT', 'LB', 'CB', 'S']
const SPECIAL_ORDER = ['K', 'P', 'LS']

const GROUP_LABEL: Record<string, string> = {
  QB: 'QUARTERBACKS',
  RB: 'RUNNING BACKS',
  FB: 'FULLBACKS',
  WR: 'WIDE RECEIVERS',
  TE: 'TIGHT ENDS',
  C: 'CENTERS',
  G: 'GUARDS',
  OT: 'OFFENSIVE TACKLES',
  DE: 'DEFENSIVE ENDS',
  DT: 'DEFENSIVE TACKLES',
  LB: 'LINEBACKERS',
  CB: 'CORNERBACKS',
  S: 'SAFETIES',
  K: 'KICKERS',
  P: 'PUNTERS',
  LS: 'LONG SNAPPERS',
}

function normalizePosition(raw: string): string {
  const p = raw.toUpperCase()
  // Offense
  if (['QB'].includes(p)) return 'QB'
  if (['RB', 'HB'].includes(p)) return 'RB'
  if (['FB'].includes(p)) return 'FB'
  if (['WR', 'LWR', 'RWR', 'SWR'].includes(p)) return 'WR'
  if (['TE', 'LTE', 'RTE'].includes(p)) return 'TE'
  if (['C'].includes(p)) return 'C'
  if (['G', 'OG', 'LG', 'RG'].includes(p)) return 'G'
  if (['T', 'OT', 'LT', 'RT', 'OL'].includes(p)) return 'OT'

  // Defense — collapse left/right and edge/inside variants
  if (['DE', 'LDE', 'RDE', 'EDGE', 'EOLB'].includes(p)) return 'DE'
  if (['DT', 'NT', 'LDT', 'RDT'].includes(p)) return 'DT'
  if (
    ['LB', 'ILB', 'MLB', 'OLB', 'LOLB', 'ROLB', 'LILB', 'RILB', 'WLB', 'SLB']
      .includes(p)
  ) {
    return 'LB'
  }
  if (['CB', 'LCB', 'RCB', 'NCB', 'SCB', 'DB'].includes(p)) return 'CB'
  if (['S', 'FS', 'SS', 'SAF'].includes(p)) return 'S'

  // Special teams
  if (['K', 'PK'].includes(p)) return 'K'
  if (['P'].includes(p)) return 'P'
  if (['LS'].includes(p)) return 'LS'

  return p
}

function rankStatus(rank: number): string {
  switch (rank) {
    case 1:
      return 'STARTER'
    case 2:
      return '2ND STRING'
    case 3:
      return '3RD STRING'
    default:
      return `${rank}TH STRING`
  }
}

interface DepthRow {
  team: string
  position: string | null
  rank: number | string | null
  player_id: string
  pos_grp: string | null
  pos_name: string | null
  pos_slot: number | string | null
  player_name: string | null
  first_name: string | null
  last_name: string | null
  jersey_number: number | string | null
  roster_position: string | null
  headshot: string | null
}

interface PlayerOut {
  id: string
  name: string
  number: string
  position: string
  rank: number
  status: string
  imageUrl: string
  isHot: boolean
  hasQuest: boolean
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

    const empty = { offense: {}, defense: {}, specialTeams: {} }

    const { data: rows, error } = await supabase
      .from('depth_charts_current')
      .select(
        'team, position, rank, player_id, pos_grp, pos_name, pos_slot, ' +
          'player_name, first_name, last_name, jersey_number, ' +
          'roster_position, headshot',
      )
      .eq('team', team_id)
    if (error) throw error
    if (!rows?.length) return json(empty)

    const offense = new Map<string, PlayerOut[]>()
    const defense = new Map<string, PlayerOut[]>()
    const special = new Map<string, PlayerOut[]>()
    OFFENSE_ORDER.forEach((k) => offense.set(GROUP_LABEL[k] ?? k, []))
    DEFENSE_ORDER.forEach((k) => defense.set(GROUP_LABEL[k] ?? k, []))
    SPECIAL_ORDER.forEach((k) => special.set(GROUP_LABEL[k] ?? k, []))

    for (const row of rows as DepthRow[]) {
      if (!row.player_id) continue
      const raw = row.position || row.roster_position || 'UNK'
      const norm = normalizePosition(raw)
      const label = GROUP_LABEL[norm] ?? norm

      const rank = typeof row.rank === 'number'
        ? row.rank
        : parseInt(`${row.rank ?? ''}`, 10) || 1

      const fullName = (row.player_name && row.player_name.trim().length > 0)
        ? row.player_name
        : `${row.first_name ?? ''} ${row.last_name ?? ''}`.trim()

      const player: PlayerOut = {
        id: row.player_id,
        name: fullName.length > 0 ? fullName : 'Unknown',
        number: row.jersey_number != null && `${row.jersey_number}`.length > 0
          ? `${row.jersey_number}`
          : '',
        position: norm,
        rank,
        status: rankStatus(rank),
        imageUrl: row.headshot ?? '',
        isHot: false,
        hasQuest: false,
      }

      if (OFFENSE_ORDER.includes(norm)) offense.get(label)?.push(player)
      else if (DEFENSE_ORDER.includes(norm)) defense.get(label)?.push(player)
      else if (SPECIAL_ORDER.includes(norm)) special.get(label)?.push(player)
    }

    return json({
      offense: finalize(offense),
      defense: finalize(defense),
      specialTeams: finalize(special),
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

function finalize(map: Map<string, PlayerOut[]>) {
  const out: Record<string, PlayerOut[]> = {}
  for (const [label, list] of map) {
    if (list.length === 0) continue
    list.sort((a, b) => {
      if (a.rank !== b.rank) return a.rank - b.rank
      return a.name.localeCompare(b.name)
    })
    out[label] = list
  }
  return out
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
