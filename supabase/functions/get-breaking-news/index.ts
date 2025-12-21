import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

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

        const { language_code } = await req.json()

        const fortyEightHoursAgo = new Date(Date.now() - 48 * 60 * 60 * 1000).toISOString()

        let query = supabaseClient
            .schema('content')
            .from('news_updates')
            .select('id, created_at, headline, sub_header, introduction_paragraph, content, image_file, teams, players, url, tts_file')
            .gt('created_at', fortyEightHoursAgo)
            .order('created_at', { ascending: false })

        if (language_code) {
            query = query.eq('language_code', language_code)
        }

        const { data, error } = await query

        if (error) throw error

        // Extract all player IDs to fetch headshots in one go
        const playerIds = new Set<string>()
        data.forEach((item: any) => {
            if (item.players && Array.isArray(item.players)) {
                item.players.forEach((p: any) => {
                    if (p.player_id) playerIds.add(p.player_id)
                })
            }
        })

        // Fetch player details (headshot) from public.players
        let playersMap = new Map<string, any>()
        if (playerIds.size > 0) {
            const { data: playersData, error: playersError } = await supabaseClient
                .from('players')
                .select('player_id, headshot')
                .in('player_id', Array.from(playerIds))

            if (!playersError && playersData) {
                playersData.forEach((p: any) => playersMap.set(p.player_id, p))
            }
        }

        const mappedData = data.map((item: any) => {
            // Enrich players with headshot_url
            const enrichedPlayers = item.players?.map((p: any) => {
                const details = playersMap.get(p.player_id)
                return {
                    ...p,
                    headshot_url: details?.headshot
                }
            }) ?? []

            // Construct image URL (existing logic)
            let imageUrl = item.image_file
            if (imageUrl && !imageUrl.startsWith('http')) {
                imageUrl = `${Deno.env.get('SUPABASE_URL')}/storage/v1/object/public/content/${imageUrl}`
            }

            return {
                id: item.id,
                headline: item.headline,
                subHeader: item.sub_header,
                introductionParagraph: item.introduction_paragraph,
                content: item.content, // New field
                createdAt: item.created_at,
                imageUrl: imageUrl,
                teams: item.teams,
                players: enrichedPlayers, // Enriched list
                url: item.url,
                audioFile: item.tts_file
            }
        })

        if (error) throw error

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
