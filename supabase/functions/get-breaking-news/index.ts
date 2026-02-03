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

        const twentyFourHoursAgo = new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString()

        const fetchFromTable = async (table: string) => {
            let query = supabaseClient
                .schema('content')
                .from(table)
                .select('*')
                .gt('created_at', twentyFourHoursAgo)
                .order('created_at', { ascending: false })

            if (language_code) {
                query = query.eq('language_code', language_code)
            }

            return await query
        }

        let { data, error } = await fetchFromTable('breaking_news')
        if (error) {
            const fallback = await fetchFromTable('news_updates')
            data = fallback.data
            error = fallback.error
        }

        if (error) throw error

        // Extract all player IDs to fetch headshots in one go
        const rows = data ?? []
        const playerIds = new Set<string>()
        rows.forEach((item: any) => {
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

        const mappedData = rows.map((item: any) => {
            // Enrich players with headshot_url
            // Defensive check: ensure players is an array before mapping
            const playersArray = Array.isArray(item.players) ? item.players : []
            const enrichedPlayers = playersArray.map((p: any) => {
                const details = playersMap.get(p.player_id)
                return {
                    ...p,
                    headshot_url: details?.headshot
                }
            })

            // Construct image URL (existing logic)
            let imageUrl = item.image_url ?? item.image_file ?? item.imageUrl ?? item.imageFile
            if (imageUrl && typeof imageUrl === 'string' && !imageUrl.startsWith('http')) {
                imageUrl = `${Deno.env.get('SUPABASE_URL')}/storage/v1/object/public/content/${imageUrl}`
            }

            return {
                id: item.id,
                headline: item.headline,
                sub_header: item.sub_header ?? item.subHeader ?? null,
                introduction_paragraph:
                    item.introduction_paragraph ?? item.introductionParagraph ?? null,
                content: item.content ?? null,
                created_at: item.created_at ?? item.createdAt ?? null,
                image_url: imageUrl ?? null,
                teams: Array.isArray(item.teams) ? item.teams : [],
                players: enrichedPlayers,
                url: item.url ?? null,
                x_post: item.x_post ?? item.xPost ?? null,
                audio_file: item.audio_file ?? item.tts_file ?? item.audioFile ?? null
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
