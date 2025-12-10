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

        const oneDayAgo = new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString()

        let query = supabaseClient
            .schema('content')
            .from('breaking_news')
            .select('id, headline, created_at, article_images(image_url)')
            .gt('created_at', oneDayAgo)
            .eq('is_reviewed', true)
            .order('created_at', { ascending: false })

        if (language_code) {
            query = query.eq('language_code', language_code)
        }

        const { data, error } = await query

        if (error) throw error

        const mappedData = data.map((item: any) => ({
            id: item.id,
            headline: item.headline,
            created_at: item.created_at,
            image_url: item.article_images?.image_url
        }))

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
