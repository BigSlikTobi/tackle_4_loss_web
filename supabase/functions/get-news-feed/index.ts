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

        const { language_code, limit = 20, offset = 0 } = await req.json()

        // Fetch news updates from content schema (including players and teams)
        let query = supabaseClient
            .schema('content')
            .from('news_updates')
            .select('id, created_at, x_post, image_file, url, headline, players, teams')
            .order('created_at', { ascending: false })
            .range(offset, offset + limit - 1)

        if (language_code) {
            query = query.eq('language_code', language_code)
        }

        const { data: newsData, error: newsError } = await query

        if (newsError) throw newsError

        // Get unique URLs to fetch sources from news_urls table (public schema)
        const urls = [...new Set(newsData.map((item: any) => item.url).filter(Boolean))]

        let urlSourceMap = new Map<string, string>()
        if (urls.length > 0) {
            const { data: urlsData, error: urlsError } = await supabaseClient
                .from('news_urls')
                .select('url, source_name')
                .in('url', urls)

            if (!urlsError && urlsData) {
                urlsData.forEach((item: any) => urlSourceMap.set(item.url, item.source_name))
            }
        }

        // Extract all player IDs to fetch headshots in one go
        const playerIds = new Set<string>()
        newsData.forEach((item: any) => {
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

        const mappedData = newsData.map((item: any) => {
            // Enrich players with headshot_url
            const enrichedPlayers = item.players?.map((p: any) => {
                const details = playersMap.get(p.player_id)
                return {
                    ...p,
                    headshot_url: details?.headshot
                }
            }) ?? []

            // Construct image URL
            let imageUrl = item.image_file
            if (imageUrl && !imageUrl.startsWith('http')) {
                imageUrl = `${Deno.env.get('SUPABASE_URL')}/storage/v1/object/public/content/${imageUrl}`
            }

            return {
                id: item.id,
                xPost: item.x_post,
                imageUrl: imageUrl,
                source: urlSourceMap.get(item.url) || null,
                createdAt: item.created_at,
                headline: item.headline,
                players: enrichedPlayers,
                teams: item.teams ?? [],
            }
        })

        return new Response(JSON.stringify({
            items: mappedData,
            hasMore: newsData.length === limit
        }), {
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
            status: 200,
        })
    } catch (error) {
        const status = error instanceof SyntaxError ? 400 : 500
        return new Response(JSON.stringify({ error: error.message }), {
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
            status,
        })
    }
})
