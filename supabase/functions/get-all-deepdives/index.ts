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

        const { language_code, limit: rawLimit, offset: rawOffset } =
            await req.json()

        const DEFAULT_LIMIT = 25
        const MAX_LIMIT = 50
        const limit =
            typeof rawLimit === 'number' && rawLimit > 0
                ? Math.min(Math.floor(rawLimit), MAX_LIMIT)
                : DEFAULT_LIMIT
        const offset =
            typeof rawOffset === 'number' && rawOffset >= 0
                ? Math.floor(rawOffset)
                : 0

        let query = supabaseClient
            .schema('content')
            .from('deepdive_article')
            .select(
                'id, language_code, hero_image_url, published_at, author, title, subtitle, audio_file, notebook_link',
                { count: 'exact' }
            )
            .order('published_at', { ascending: false })

        if (language_code) {
            query = query.eq('language_code', language_code)
        }

        const { data, error, count } = await query.range(
            offset,
            offset + limit - 1
        )

        if (error) throw error

        return new Response(
            JSON.stringify({
                data,
                count,
                limit,
                offset,
            }),
            {
                headers: { ...corsHeaders, 'Content-Type': 'application/json' },
                status: 200,
            }
        )
    } catch (error) {
        return new Response(JSON.stringify({ error: error.message }), {
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
            status: 400,
        })
    }
})
