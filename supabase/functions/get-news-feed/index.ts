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

        // Fetch news updates from content schema
        let newsQuery = supabaseClient
            .schema('content')
            .from('news_updates')
            .select('id, created_at, x_post, image_file, url, headline, players, teams')
            .order('created_at', { ascending: false })

        if (language_code) {
            newsQuery = newsQuery.eq('language_code', language_code)
        }

        // Fetch deep dives from content schema
        let deepDiveQuery = supabaseClient
            .schema('content')
            .from('deepdive_article')
            .select('id, created_at, title, subtitle, hero_image_url, author')
            .order('created_at', { ascending: false })

        if (language_code) {
            deepDiveQuery = deepDiveQuery.eq('language_code', language_code)
        }

        // Execute both queries in parallel
        const [newsResult, deepDiveResult] = await Promise.all([
            newsQuery,
            deepDiveQuery
        ])

        if (newsResult.error) throw newsResult.error
        if (deepDiveResult.error) throw deepDiveResult.error

        const newsData = newsResult.data ?? []
        const deepDiveData = deepDiveResult.data ?? []

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

        // Map news items with type discriminator
        const mappedNewsData = newsData.map((item: any) => {
            const playersArray = Array.isArray(item.players) ? item.players : []
            const enrichedPlayers = playersArray.map((p: any) => {
                const details = playersMap.get(p.player_id)
                return {
                    ...p,
                    headshot_url: details?.headshot
                }
            })

            let imageUrl = item.image_file
            if (imageUrl && !imageUrl.startsWith('http')) {
                imageUrl = `${Deno.env.get('SUPABASE_URL')}/storage/v1/object/public/content/${imageUrl}`
            }

            return {
                type: 'newsUpdate',
                id: item.id,
                xPost: item.x_post,
                imageUrl: imageUrl,
                source: urlSourceMap.get(item.url) || null,
                createdAt: item.created_at,
                headline: item.headline,
                players: enrichedPlayers,
                teams: Array.isArray(item.teams) ? item.teams : [],
            }
        })

        // Map deep dive items with type discriminator
        const mappedDeepDiveData = deepDiveData.map((item: any) => {
            let imageUrl = item.hero_image_url
            if (imageUrl && !imageUrl.startsWith('http')) {
                imageUrl = `${Deno.env.get('SUPABASE_URL')}/storage/v1/object/public/content/${imageUrl}`
            }

            return {
                type: 'deepDive',
                id: `deepdive-${item.id}`,
                articleId: item.id,
                title: item.title,
                summary: item.subtitle,
                imageUrl: imageUrl,
                author: item.author,
                createdAt: item.created_at,
            }
        })

        // Merge and sort by createdAt descending
        const allItems = [...mappedNewsData, ...mappedDeepDiveData]
        allItems.sort((a, b) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime())

        // Apply pagination to merged results
        const paginatedItems = allItems.slice(offset, offset + limit)
        const hasMore = allItems.length > offset + limit

        return new Response(JSON.stringify({
            items: paginatedItems,
            hasMore: hasMore
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
