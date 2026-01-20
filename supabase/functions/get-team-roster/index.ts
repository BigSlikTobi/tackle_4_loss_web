
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

Deno.serve(async (req) => {
    if (req.method === 'OPTIONS') {
        return new Response('ok', { headers: corsHeaders })
    }

    try {
        const supabase = createClient(
            Deno.env.get('SUPABASE_URL') ?? '',
            Deno.env.get('SUPABASE_ANON_KEY') ?? ''
        )

        const { team_id } = await req.json()

        if (!team_id) {
            throw new Error('Missing team_id parameter')
        }

        console.log('Fetching roster for team:', team_id)

        // 1. Get the latest roster version for this team
        const { data: versionData, error: versionError } = await supabase
            .from('rosters')
            .select('version')
            .eq('team', team_id) // Using 'team' column as requested
            .order('version', { ascending: false })
            .limit(1)
            .maybeSingle() // Use maybeSingle to avoid error when no rows found

        if (versionError) {
            console.error('Error fetching version:', versionError)
            throw new Error(`Could not determine latest roster version: ${versionError.message}`)
        }

        if (!versionData) {
            console.log('No roster found for team:', team_id)
            // Return empty lists instead of error for teams with no roster data
            return new Response(
                JSON.stringify({
                    offense: [],
                    defense: [],
                    specialTeams: [],
                }),
                {
                    headers: {
                        ...corsHeaders,
                        'Content-Type': 'application/json',
                    },
                }
            )
        }

        const latestVersion = versionData.version
        console.log('Latest version for', team_id, ':', latestVersion)

        // 2. Fetch roster data with player details
        const { data: rosterData, error: rosterError } = await supabase
            .from('rosters')
            .select(`
        player,
        dept_chart_position,
        players (
          first_name,
          last_name,
          headshot,
          years_of_experience,
          college_name,
          jersey_number,
          position
        )
      `)
            .eq('team', team_id)
            .eq('version', latestVersion)

        if (rosterError) {
            console.error('Error fetching roster:', rosterError)
            throw rosterError
        }

        console.log('Roster data fetched. Row count:', rosterData?.length ?? 0)
        if (rosterData && rosterData.length > 0) {
            console.log('First entry sample:', JSON.stringify(rosterData[0]))
        }

        // 3. Process and categorize players
        const offense: any[] = []
        const defense: any[] = []
        const specialTeams: any[] = []
        const processedPlayerIds = new Set<string>()

        const positionGroups = {
            'OFFENSE': ['QB', 'RB', 'FB', 'WR', 'TE', 'C', 'G', 'OT', 'OL'],
            'DEFENSE': ['DE', 'DT', 'LB', 'CB', 'S', 'DB', 'MLB', 'OLB', 'ILB', 'FS', 'SS', 'NT'],
            'SPECIAL_TEAMS': ['K', 'P', 'LS']
        }

        // Sort orders map
        const offenseOrder = ['QB', 'RB', 'FB', 'WR', 'TE', 'C', 'G', 'OT', 'OL']
        const defenseOrder = ['DE', 'NT', 'DT', 'LB', 'ILB', 'MLB', 'OLB', 'CB', 'S', 'FS', 'SS', 'DB']
        const stOrder = ['K', 'P', 'LS']

        rosterData.forEach((entry: any) => {
            if (!entry.players) return

            const player = entry.players
            // Skip if we already processed this player
            const playerId = entry.player
            if (processedPlayerIds.has(playerId)) return
            processedPlayerIds.add(playerId)

            let pos = entry.dept_chart_position || player.position

            // Normalize positions
            if (!pos) pos = 'UNK'
            pos = pos.toUpperCase()

            // Create player object
            const playerObj = {
                id: playerId,
                name: `${player.first_name} ${player.last_name}`,
                number: player.jersey_number ? `#${player.jersey_number}` : 'N/A',
                position: pos,
                experience: player.years_of_experience ? `${player.years_of_experience}Y` : 'R',
                college: player.college_name || 'N/A',
                imageUrl: player.headshot || '',
            }

            // Categorize
            if (positionGroups.OFFENSE.includes(pos)) {
                offense.push(playerObj)
            } else if (positionGroups.DEFENSE.includes(pos)) {
                // Normalize LB/DB for better sorting if needed, but keeping original pos for display is usually better
                defense.push(playerObj)
            } else if (positionGroups.SPECIAL_TEAMS.includes(pos)) {
                specialTeams.push(playerObj)
            } else {
                // Fallback: try to guess based on standard positions or just add to offense as fallback? 
                // Or maybe ignore. Let's add to offense if it looks offensive, etc.
                // For now, if unknown, maybe skip or put in a 'Reserve' list? 
                // Let's put in offense if not found to avoid losing players, or check for specific keywords
                offense.push(playerObj)
            }
        })

        // 4. Sort lists
        const sortPlayers = (list: any[], order: string[]) => {
            list.sort((a, b) => {
                const indexA = order.indexOf(a.position)
                const indexB = order.indexOf(b.position)

                // If both defined in order, sort by index
                if (indexA !== -1 && indexB !== -1) {
                    return indexA - indexB
                }
                // If only A defined, A comes first
                if (indexA !== -1) return -1
                // If only B defined, B comes first
                if (indexB !== -1) return 1

                // If neither defined or same position, sort by name
                return a.name.localeCompare(b.name)
            })
        }

        sortPlayers(offense, offenseOrder)
        sortPlayers(defense, defenseOrder)
        sortPlayers(specialTeams, stOrder)

        return new Response(
            JSON.stringify({
                offense,
                defense,
                specialTeams,
            }),
            {
                headers: {
                    ...corsHeaders,
                    'Content-Type': 'application/json',
                    'Cache-Control': 'public, max-age=3600', // Cache for 1 hour
                },
            }
        )

    } catch (error) {
        return new Response(
            JSON.stringify({ error: error.message }),
            {
                status: 400,
                headers: {
                    ...corsHeaders,
                    'Content-Type': 'application/json',
                },
            }
        )
    }
})
