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

        let language_code = 'en';
        try {
            const body = await req.json();
            language_code = body.language_code || 'en';
        } catch (e) {
            // body-less request
        }

        // 1. Try fetching articles with audio for the requested language
        let { data, error } = await supabaseClient
            .schema('content')
            .from('deepdive_article')
            .select('id, title, subtitle, hero_image_url, audio_file, published_at, language_code')
            .eq('language_code', language_code)
            .not('audio_file', 'is', null)
            .order('published_at', { ascending: false })

        if (error) throw error


        // Map data to include full URLs
        const mappedData = (data || []).map((item: any) => {
            let imageUrl = item.hero_image_url;
            if (imageUrl && !imageUrl.startsWith('http')) {
                imageUrl = `${Deno.env.get('SUPABASE_URL')}/storage/v1/object/public/content/${imageUrl}`;
            }

            let audioUrl = item.audio_file;
            if (audioUrl && !audioUrl.startsWith('http')) {
                // Check if it's in the 'tts' bucket or 'content' bucket
                // Based on our previous check, it was in 'tts' bucket
                // Wait, if it's an absolute URL, we skip this.
                // If it's a path, we need to know the bucket.
                // In get-article-viewer-data it returned an absolute URL.
                // So this logic might not even be needed if the DB stores absolute URLs.
                // But for safety, if it's a path, we'll try content bucket.
                audioUrl = `${Deno.env.get('SUPABASE_URL')}/storage/v1/object/public/content/${audioUrl}`;
            }

            return {
                ...item,
                hero_image_url: imageUrl,
                audio_file: audioUrl,
            };
        });

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
