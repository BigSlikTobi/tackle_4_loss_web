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

        const body = await req.json().catch(() => ({}))
        const language_code = body?.language_code
        const since_created_at = body?.since_created_at ?? body?.sinceCreatedAt

        const rawLimit = body?.limit
        const limit =
            typeof rawLimit === 'number' && Number.isFinite(rawLimit)
                ? Math.max(1, Math.min(100, Math.floor(rawLimit)))
                : undefined

        let query = supabaseClient
            .schema('content')
            .from('news_updates')
            .select('id, created_at, headline, image_file, teams, tts_file')
            .order('created_at', { ascending: false })

        if (language_code) {
            query = query.eq('language_code', language_code)
        }

        // Backwards compatible:
        // - Default returns the latest 30 (used for initial playlist fetch).
        // - If `since_created_at` is provided, return only newer rows (small polling payload).
        if (since_created_at) {
            query = query.gt('created_at', since_created_at)
            query = query.limit(limit ?? 10)
        } else {
            query = query.limit(limit ?? 30)
        }

        const { data, error } = await query

        if (error) throw error

        const mappedData = data.map((item: any) => {
            // Construct image URL (thumbnail)
            let imageUrl = item.image_file
            if (imageUrl && !imageUrl.startsWith('http')) {
                imageUrl = `${Deno.env.get('SUPABASE_URL')}/storage/v1/object/public/content/${imageUrl}`
            }

            // Construct audio URL
            let audioUrl = item.tts_file
            if (audioUrl && !audioUrl.startsWith('http')) {
                audioUrl = `${Deno.env.get('SUPABASE_URL')}/storage/v1/object/public/content/${audioUrl}`
            }


            return {
                id: item.id,
                title: item.headline,
                createdAt: item.created_at,
                imageUrl: imageUrl,
                audioUrl: audioUrl,
                primaryTeam: Array.isArray(item.teams) && item.teams.length > 0 ? item.teams[0] : null,
            }
        })

        return new Response(JSON.stringify(mappedData), {
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
