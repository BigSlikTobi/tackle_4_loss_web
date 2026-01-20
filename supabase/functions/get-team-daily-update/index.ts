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

        const { team_id, language_code } = await req.json()

        if (!team_id) {
            throw new Error('team_id is required')
        }

        // Fetch latest article for the team
        let query = supabaseClient
            .schema('content')
            .from('team_article')
            .select('id, headline, image, tts_file, created_at')
            .eq('team', team_id)
            .order('created_at', { ascending: false })
            .limit(1)

        if (language_code) {
            query = query.eq('language', language_code)
        }

        const { data, error } = await query

        if (error) throw error

        let article = null
        if (data && data.length > 0) {
            const item = data[0]

            // Construct full image URL if it's a relative path
            let imageUrl = item.image
            if (imageUrl && !imageUrl.startsWith('http')) {
                imageUrl = `${Deno.env.get('SUPABASE_URL')}/storage/v1/object/public/content/${imageUrl}`
            }

            // Construct full audio URL if it's a relative path
            let audioUrl = item.tts_file
            if (audioUrl && !audioUrl.startsWith('http')) {
                audioUrl = `${Deno.env.get('SUPABASE_URL')}/storage/v1/object/public/content/${audioUrl}`
            }

            article = {
                id: item.id,
                headline: item.headline,
                image: imageUrl,
                tts_file: audioUrl,
                created_at: item.created_at
            }
        }

        return new Response(JSON.stringify({ article }), {
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
