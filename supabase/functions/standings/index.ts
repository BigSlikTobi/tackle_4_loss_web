// Edge function: standings
// Reads pre-computed rows from the `standings` table and groups them
// Conference -> Division -> teams[].
//
// Body (optional): { season?: number }. Defaults to the highest season in
// the table.
//
// Response shape mirrors ConferenceStandings.fromJson in
// flutter_app/lib/micro_apps/standings/models/team_standing.dart.
//
// Notes on the upstream schema (one row per team per season):
//   season, team_abbr, team_name, conference, division, wins, losses, ties,
//   win_pct, points_for, points_against, point_diff,
//   division_record (e.g. "4-2"), conference_record (e.g. "9-3"),
//   division_rank, conference_rank, league_rank
//
// `division` arrives as the full name ("NFC West"). The Flutter client
// concatenates conference + division for display, so we strip the
// conference prefix before sending.

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers':
    'authorization, x-client-info, apikey, content-type',
}

interface StandingsRow {
  season: number
  team_abbr: string
  team_name: string
  conference: string
  division: string
  wins: number
  losses: number
  ties: number
  win_pct: number
  points_for: number
  points_against: number
  point_diff: number
  division_record: string | null
  conference_record: string | null
  division_rank: number | null
  conference_rank: number | null
  league_rank: number | null
  conference_seed: number | null
}

interface TeamStanding {
  teamId: string
  teamName: string
  conference: string
  division: string
  logoUrl: string
  season: number
  wins: number
  losses: number
  ties: number
  pointsFor: number
  pointsAgainst: number
  conferenceWins: number
  conferenceLosses: number
  divisionWins: number
  divisionLosses: number
  winPercentage: number
  netPoints: number
  divisionRank: number | null
  conferenceRank: number | null
  leagueRank: number | null
  /** 1–7 if currently holding a conference playoff seed, else null. */
  conferenceSeed: number | null
}

function parseRecord(raw: string | null | undefined): {
  wins: number
  losses: number
} {
  if (!raw) return { wins: 0, losses: 0 }
  const parts = raw.split('-')
  return {
    wins: Number(parts[0] ?? 0) || 0,
    losses: Number(parts[1] ?? 0) || 0,
  }
}

function stripConferencePrefix(division: string, conference: string): string {
  const prefix = `${conference} `
  return division.startsWith(prefix) ? division.slice(prefix.length) : division
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

    let season: number | null = null
    try {
      const body = await req.json()
      season = typeof body?.season === 'number' ? body.season : null
    } catch {
      // No body — fall through to latest-season lookup.
    }

    if (season === null) {
      const { data: latest } = await supabase
        .from('standings')
        .select('season')
        .order('season', { ascending: false })
        .limit(1)
        .maybeSingle()
      season = latest?.season ?? new Date().getFullYear()
    }

    const { data: rows, error } = await supabase
      .from('standings')
      .select(
        'season, team_abbr, team_name, conference, division, wins, losses, ' +
          'ties, win_pct, points_for, points_against, point_diff, ' +
          'division_record, conference_record, ' +
          'division_rank, conference_rank, league_rank, conference_seed',
      )
      .eq('season', season)
    if (error) throw error

    const standings: TeamStanding[] = []
    for (const r of (rows ?? []) as StandingsRow[]) {
      if (!r.team_abbr || !r.conference || !r.division) continue
      const div = parseRecord(r.division_record)
      const conf = parseRecord(r.conference_record)
      standings.push({
        teamId: r.team_abbr,
        teamName: r.team_name,
        conference: r.conference,
        division: stripConferencePrefix(r.division, r.conference),
        logoUrl: '',
        season: r.season,
        wins: r.wins ?? 0,
        losses: r.losses ?? 0,
        ties: r.ties ?? 0,
        pointsFor: r.points_for ?? 0,
        pointsAgainst: r.points_against ?? 0,
        conferenceWins: conf.wins,
        conferenceLosses: conf.losses,
        divisionWins: div.wins,
        divisionLosses: div.losses,
        winPercentage: r.win_pct ?? 0,
        netPoints: r.point_diff ?? 0,
        divisionRank: r.division_rank,
        conferenceRank: r.conference_rank,
        leagueRank: r.league_rank,
        conferenceSeed: r.conference_seed,
      })
    }

    const byConference = new Map<string, Map<string, TeamStanding[]>>()
    for (const s of standings) {
      let div = byConference.get(s.conference)
      if (!div) {
        div = new Map()
        byConference.set(s.conference, div)
      }
      let list = div.get(s.division)
      if (!list) {
        list = []
        div.set(s.division, list)
      }
      list.push(s)
    }

    const tiebreak = (a: TeamStanding, b: TeamStanding) => {
      if (a.winPercentage !== b.winPercentage) {
        return b.winPercentage - a.winPercentage
      }
      if (a.divisionWins !== b.divisionWins) {
        return b.divisionWins - a.divisionWins
      }
      if (a.conferenceWins !== b.conferenceWins) {
        return b.conferenceWins - a.conferenceWins
      }
      return b.netPoints - a.netPoints
    }

    const response = [] as Array<{
      conference: string
      divisions: Array<{ division: string; teams: TeamStanding[] }>
    }>

    for (const [conference, divMap] of byConference) {
      const divisions = [] as Array<{ division: string; teams: TeamStanding[] }>
      for (const [division, list] of divMap) {
        list.sort(tiebreak)
        divisions.push({ division, teams: list })
      }
      divisions.sort((a, b) => a.division.localeCompare(b.division))
      response.push({ conference, divisions })
    }
    response.sort((a, b) => a.conference.localeCompare(b.conference))

    return new Response(JSON.stringify(response), {
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
