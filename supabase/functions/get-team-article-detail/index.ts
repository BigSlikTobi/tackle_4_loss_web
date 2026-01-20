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

        const { id, language_code } = await req.json()

        if (!id) {
            throw new Error('id is required')
        }
        if (!language_code) {
            throw new Error('language_code is required')
        }

        const { data, error } = await supabaseClient
            .schema('content')
            .from('team_article')
            .select('headline, image, sub_headline, introduction, bullet_points, content')
            .eq('id', id)
            .eq('language', language_code)
            .single()

        if (error) throw error

        let article = null
        if (data) {
            // Construct full image URL if it's a relative path
            let imageUrl = data.image
            if (imageUrl && !imageUrl.startsWith('http')) {
                imageUrl = `${Deno.env.get('SUPABASE_URL')}/storage/v1/object/public/content/${imageUrl}`
            }

            article = {
                ...data,
                image: imageUrl
            }
        }

        return new Response(JSON.stringify(article), {
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
