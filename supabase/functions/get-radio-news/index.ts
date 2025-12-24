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

        let query = supabaseClient
            .schema('content')
            .from('news_updates')
            .select('id, created_at, headline, image_file, teams, tts_file')
            .order('created_at', { ascending: false })
            .limit(30)

        if (language_code) {
            query = query.eq('language_code', language_code)
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
                primaryTeam: item.teams && item.teams.length > 0 ? item.teams[0] : null,
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
